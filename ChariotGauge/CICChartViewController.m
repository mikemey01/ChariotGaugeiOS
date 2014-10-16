//
//  CICChartViewController.m
//  ChariotGauge
//
//  Created by Mike on 8/19/14.
//  Copyright (c) 2014 Chariot Instruments. All rights reserved.
//

#import "CICChartViewController.h"
#import "CICAppDelegate.h"
#import "CICChartBuilder.h"
#import "CorePlot-CocoaTouch.h"
#import "CICCalculateData.h"

static const double kFrameRate = 20.0;  // frames per second

@interface CICChartViewController ()

@end

@implementation CICChartViewController

@synthesize chartView, gaugeType, bluetooth, chartLabel1, chartLabelData1, chartVoltLabel, chartVoltLabelData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//Handles portrait only mode.
- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
//End handling portrait only mode.


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self initPrefs];
    
    //Set bar button styles
    [self setBarButtonStyle:[UIColor whiteColor]];
    
    //set up bar button items
    pauseButton = [[UIBarButtonItem alloc]
                 initWithTitle:@"Pause"
                 style:UIBarButtonItemStylePlain
                 target:self
                 action:@selector(pauseButtonAction)];
    
    //set the bar button items in the nav bar.
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:pauseButton, nil];
    
    //build selected gauge.
    if(gaugeType==0){
        [self createBoostChart];
    }else if(gaugeType==1){
        [self createBoostChart];
    }else if(gaugeType==2){
        [self createWidebandChart];
    }else if(gaugeType==3){
        [self createTempChart];
    }else if(gaugeType==4){
        [self createOilChart];
    }else{
        [self createBoostChart];
    }
    
    //added voltage plot if wanted
    if(showVolts){
        _localPlotBuilderVolts = [self buildPlot:@"plotVolts" withPlotBuilder:_localPlotBuilderVolts withColor:[CPTColor redColor]];
    }

    [self startTimer];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Set the backbutton title
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"Back";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    
    //Set background color
    self.view.backgroundColor = [UIColor colorWithRed:73/255.0 green:73/255.0 blue:73/255.0 alpha:1];
    
    //Init the labels
    [self initLabels];
    
    //set bluetooth delegate to self;
    [self.bluetooth setBtDelegate:self];
    
    //create CalculateData object and initialize it.
    calcData = [[CICCalculateData alloc] init];
    [calcData initPrefs];
    [calcData initStoich];
    [calcData initSHHCoefficients];
    
    calcDataVolts = [[CICCalculateData alloc]init];
    [calcDataVolts initPrefs];
    [calcDataVolts initStoich];
    [calcDataVolts initSHHCoefficients];
}

#pragma mark Create Chart Section
-(void)createBoostChart
{
    //Create the graph
    if([pressureUnits isEqualToString:@"BAR"]){
        [self buildChart:-5.0f withYMax:5.0f];
    }else if([pressureUnits isEqualToString:@"PSI"]){
        [self buildChart:0.0f withYMax:10.0f];
    }else{
        [self buildChart:0.0f withYMax:30.0f];
    }
    
    //Create the boost plot
    _localPlotBuilderOne = [self buildPlot:@"plotBoost" withPlotBuilder:_localPlotBuilderOne withColor:[CPTColor greenColor]];
    
}

-(void)createWidebandChart
{
    //Create the graph
    if([widebandUnits isEqualToString:@"Lambda"]){
        [self buildChart:0 withYMax:2];
    }else{
        if([widebandFuelType isEqualToString:@"Gasoline"] || [widebandFuelType isEqualToString:@"Propane"] || [widebandFuelType isEqualToString:@"Diesel"]){
            [self buildChart:5 withYMax:15];
        }else if([widebandFuelType isEqualToString:@"Methanol"]){
            [self buildChart:0 withYMax:10];
        }else if([widebandFuelType isEqualToString:@"Ethanol"] || [widebandFuelType isEqualToString:@"E85"]){
            [self buildChart:5 withYMax:12];
        }else{
            [self buildChart:5 withYMax:25];
        }
    }
    
    //Create the wideband plot
    _localPlotBuilderOne = [self buildPlot:@"plotWideband" withPlotBuilder:_localPlotBuilderOne withColor:[CPTColor whiteColor]];
}

-(void)createTempChart
{
    //Create the graph
    if([temperatureUnits isEqualToString:@"Fahrenheit"]){
        [self buildChart:20 withYMax:60];
    }else{
        [self buildChart:-5 withYMax:30];
    }
    
    //Create the temp plot
    _localPlotBuilderOne = [self buildPlot:@"plotTemp" withPlotBuilder:_localPlotBuilderOne withColor:[CPTColor colorWithComponentRed:113.0f/255.0f green:226.0f/255.0f blue:243.0f/255.0f alpha:1.0f]];
}

-(void)createOilChart
{
    //Create the graph
    if([oilPressureUnits isEqualToString:@"PSI"]){
        [self buildChart:0 withYMax:30];
    }else{
        [self buildChart:0 withYMax:10];
    }
    
    //Create the oil plot
    _localPlotBuilderOne = [self buildPlot:@"plotOil" withPlotBuilder:_localPlotBuilderOne withColor:[CPTColor yellowColor]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)buildChart:(CGFloat)yMinIn withYMax:(CGFloat)yMaxIn
{
    //Setup initial y-range.
    [chartView setYMin:yMinIn];
    [chartView setYMax:yMaxIn];
    
    //Build chart
    [chartView initPlot];
    
    //TODO: this is hacky - but forces the x/y axes to work together.
    [chartView resizeYAxis:chartView.yMin-1 withYMax:chartView.yMax+1];
}

-(CICPlotBuilder *)buildPlot:(NSString *)plotNameIn withPlotBuilder:(CICPlotBuilder *)plotBuilderIn withColor:(CPTColor *)colorIn
{
    //Create the plot, add it to the graph.
    plotBuilderIn = [CICPlotBuilder alloc];
    
    CPTScatterPlot *newPlot = [plotBuilderIn createPlot:plotNameIn withColor:colorIn];
    
    [chartView addPlotToGraph:newPlot];
    
    return plotBuilderIn;
}

-(void)addNewDataToPlot:(CICPlotBuilder *) plotBuilderIn withData:(CGFloat)newData
{
    //add plots to graph
    newData = (CGFloat)rand()/(double)RAND_MAX*10;
    [plotBuilderIn addNewDataToPlot:newData];
    
    //resize axes if needed
    [chartView resizeXAxis:_localPlotBuilderOne.currentIndex];
    [self resizeAxes:newData];
}

-(void)resizeAxes:(CGFloat)newData
{
    if(newData+2 > chartView.yMax){
        [chartView resizeYAxis:chartView.yMin withYMax:newData+2];
    }
    if(newData-2 < chartView.yMin){
        [chartView resizeYAxis:newData-2 withYMax:chartView.yMax];
    }
}

-(void)startTimer
{
    [dataTimer invalidate];
    dataTimer = nil;
    
    dataTimer = [NSTimer timerWithTimeInterval:1.0 / kFrameRate
                                        target:self
                                      selector:@selector(addTimerData)
                                      userInfo:nil
                                       repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:dataTimer forMode:NSRunLoopCommonModes];
}

-(void)addTimerData
{
    if(!isPaused){
        [self addNewDataToPlot:_localPlotBuilderOne withData:0.0f];
        chartLabelData1.text = [NSString stringWithFormat:@"%.1f", 10.0];
        
        [self addNewDataToPlot:_localPlotBuilderVolts withData:0.0f];
        chartVoltLabelData.text = [NSString stringWithFormat:@"%.1f", 800.0];
    }
}

-(void)getLatestData:(NSMutableString *)newData
{
    
}

-(void) initPrefs
{
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    
    pressureUnits = [standardDefaults stringForKey:@"boost_psi_kpa"];
    oilPressureUnits = [standardDefaults stringForKey:@"oil_psi_bar"];
    widebandUnits = [standardDefaults stringForKey:@"wideband_afr_lambda"];
    widebandFuelType = [standardDefaults stringForKey:@"wideband_fuel_type"];
    temperatureUnits = [standardDefaults stringForKey:@"temperature_celsius_fahrenheit"];
    showVolts = [standardDefaults boolForKey:@"general_show_volts"];
    isNightMode = [standardDefaults boolForKey:@"general_night_mode"];
    
    isPaused = NO;
}


-(void)initLabels
{
    //build selected chart labels.
    if(gaugeType==0){
        chartLabel1.textColor = [UIColor greenColor];
        chartLabel1.font = [UIFont fontWithName:@"Futura" size:15];
        chartLabel1.text = @"Boost:";
        chartLabel1.textAlignment = NSTextAlignmentRight;
        chartLabelData1.textColor = [UIColor whiteColor];
        chartLabelData1.font = [UIFont fontWithName:@"LetsgoDigital-Regular" size:20];
        chartLabelData1.text = @"00.0";
        chartLabelData1.textAlignment = NSTextAlignmentLeft;
    }else if(gaugeType==1){
        chartLabel1.textColor = [UIColor greenColor];
        chartLabel1.font = [UIFont fontWithName:@"Futura" size:15];
        chartLabel1.text = @"Boost:";
        chartLabel1.textAlignment = NSTextAlignmentRight;
        chartLabelData1.textColor = [UIColor whiteColor];
        chartLabelData1.font = [UIFont fontWithName:@"LetsgoDigital-Regular" size:20];
        chartLabelData1.text = @"00.0";
        chartLabelData1.textAlignment = NSTextAlignmentLeft;
    }else if(gaugeType==2){
        chartLabel1.textColor = [UIColor whiteColor];
        chartLabel1.font = [UIFont fontWithName:@"Futura" size:15];
        chartLabel1.text = @"WB:";
        chartLabel1.textAlignment = NSTextAlignmentRight;
        chartLabelData1.textColor = [UIColor whiteColor];
        chartLabelData1.font = [UIFont fontWithName:@"LetsgoDigital-Regular" size:20];
        chartLabelData1.text = @"00.0";
        chartLabelData1.textAlignment = NSTextAlignmentLeft;
    }else if(gaugeType==3){
        chartLabel1.textColor = [UIColor colorWithRed: 113.0/255.0 green: 226.0/255.0 blue:243.0/255.0 alpha: 1.0];
        chartLabel1.font = [UIFont fontWithName:@"Futura" size:15];
        chartLabel1.text = @"Temp:";
        chartLabel1.textAlignment = NSTextAlignmentRight;
        chartLabelData1.textColor = [UIColor whiteColor];
        chartLabelData1.font = [UIFont fontWithName:@"LetsgoDigital-Regular" size:20];
        chartLabelData1.text = @"00.0";
        chartLabelData1.textAlignment = NSTextAlignmentLeft;
    }else if(gaugeType==4){
        chartLabel1.textColor = [UIColor yellowColor];
        chartLabel1.font = [UIFont fontWithName:@"Futura" size:15];
        chartLabel1.text = @"Oil:";
        chartLabel1.textAlignment = NSTextAlignmentRight;
        chartLabelData1.textColor = [UIColor whiteColor];
        chartLabelData1.font = [UIFont fontWithName:@"LetsgoDigital-Regular" size:20];
        chartLabelData1.text = @"00.0";
        chartLabelData1.textAlignment = NSTextAlignmentLeft;
    }else{
        //do nothing
    }
    
    //Setup volt labels
    chartVoltLabel.textColor = [UIColor redColor];
    chartVoltLabel.font = [UIFont fontWithName:@"Futura" size:15];
    chartVoltLabel.text = @"Volts:";
    chartVoltLabel.textAlignment = NSTextAlignmentRight;
    chartVoltLabelData.textColor = [UIColor whiteColor];
    chartVoltLabelData.font = [UIFont fontWithName:@"LetsgoDigital-Regular" size:20];
    chartVoltLabelData.text = @"00.0";
    chartVoltLabelData.textAlignment = NSTextAlignmentLeft;
}

-(void)setBarButtonStyle:(UIColor*) colorIn
{
    //set the UIBarButtonItems style
    NSShadow* shadow = [NSShadow new];
    shadow.shadowOffset = CGSizeMake(1.0f, 1.2f);
    shadow.shadowColor = [UIColor blackColor];
    
    NSDictionary *normalAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                      colorIn, NSForegroundColorAttributeName,
                                      shadow, NSShadowAttributeName,
                                      nil];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:normalAttributes forState:UIControlStateNormal];
}

-(void)pauseButtonAction
{
    if(isPaused){
        isPaused = NO;
        pauseButton.title = @"Pause";
    }else{
        isPaused = YES;
        pauseButton.title = @"Play";
    }
}

- (void)viewDidUnload
{
    dataTimer = nil;
}

-(void)dealloc
{
    [dataTimer invalidate];
}



@end

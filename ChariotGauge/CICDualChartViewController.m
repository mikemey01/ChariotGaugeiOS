//
//  CICDualChartViewController.m
//  ChariotGauge
//
//  Created by Mike on 9/7/14.
//  Copyright (c) 2014 Chariot Instruments. All rights reserved.
//

//
//  CICDualChartViewController.m
//  ChariotGauge
//
//  Created by Mike on 9/7/14.
//  Copyright (c) 2014 Chariot Instruments. All rights reserved.
//

#import "CICDualChartViewController.h"
#import "CICAppDelegate.h"
#import "CICChartBuilder.h"
#import "CorePlot-CocoaTouch.h"
#import "CICCalculateData.h"
#import "CICDualGaugeViewController.h"

@interface CICDualChartViewController ()

@end

@implementation CICDualChartViewController

@synthesize chartView, gaugeType, bluetooth;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//Force landscape right for dual gauge.
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeRight;
}

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
    if([gaugeOneType isEqualToString:@"Boost"]){
        _localPlotBuilderOne = [self createBoostChart:_localPlotBuilderOne];
        //[self initLabels:chartLabel1 withDataLabel:chartLabelData1 forGaugeType:1];
    }else if([gaugeOneType isEqualToString:@"Wideband"]){
        [self createWidebandChart:_localPlotBuilderOne];
        //[self initLabels:chartLabel1 withDataLabel:chartLabelData1 forGaugeType:2];
    }else if([gaugeOneType isEqualToString:@"Temperature"]){
        [self createTempChart:_localPlotBuilderOne];
        //[self initLabels:chartLabel1 withDataLabel:chartLabelData1 forGaugeType:3];
    }else if([gaugeOneType isEqualToString:@"Oil"]){
        [self createOilChart:_localPlotBuilderOne];
        //[self initLabels:chartLabel1 withDataLabel:chartLabelData1 forGaugeType:4];
    }
    
    //    if([gaugeTwoType isEqualToString:@"Boost"]){
    //        [self createBoostChart:_localPlotBuilderTwo];
    //        [self initLabels:chartLabel2 withDataLabel:chartLabelData2 forGaugeType:1];
    //    }else if([gaugeTwoType isEqualToString:@"Wideband"]){
    //        [self createWidebandChart:_localPlotBuilderTwo];
    //        [self initLabels:chartLabel2 withDataLabel:chartLabelData2 forGaugeType:2];
    //    }else if([gaugeTwoType isEqualToString:@"Temperature"]){
    //        [self createTempChart:_localPlotBuilderTwo];
    //        [self initLabels:chartLabel2 withDataLabel:chartLabelData2 forGaugeType:3];
    //    }else if([gaugeTwoType isEqualToString:@"Oil"]){
    //        [self createOilChart:_localPlotBuilderTwo];
    //        [self initLabels:chartLabel2 withDataLabel:chartLabelData2 forGaugeType:4];
    //    }
    
    //added voltage plot if wanted
    if(showVolts){
        _localPlotBuilderVolts = [self buildPlot:@"plotVolts" withPlotBuilder:_localPlotBuilderVolts withColor:[CPTColor redColor]];
    }
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
    
    //Init the labels - do this in createChart methods
    //[self initLabels];
    
    //set bluetooth delegate to self;
    [self.bluetooth setBtDelegate:self];
    
    //create CalculateData object and initialize it.
    calcData = [[CICCalculateData alloc] init];
    [calcData initPrefs];
    [calcData initStoich];
    [calcData initSHHCoefficients];
    
    //    calcDataTwo = [[CICCalculateData alloc] init];
    //    [calcDataTwo initPrefs];
    //    [calcDataTwo initStoich];
    //    [calcDataTwo initSHHCoefficients];
    
    calcDataVolts = [[CICCalculateData alloc]init];
    [calcDataVolts initPrefs];
    [calcDataVolts initStoich];
    [calcDataVolts initSHHCoefficients];
    
}

-(void)getLatestData:(NSMutableString *)newData
{
    //NSLog(@"made it here...");
    if(!isPaused){
        newArray = [newData componentsSeparatedByString: @","];
        [self setChartValue:newArray];
        newArray = nil;
    }
}

-(void) setChartValue:(NSArray *)array
{
    if(array.count >= 4){
        
        if([gaugeOneType isEqualToString:@"Boost"]){
            currentStringValue = [array objectAtIndex:1];
            currentIntergerValue = [currentStringValue integerValue];
            [self addNewDataToPlot:_localPlotBuilderOne withData:[calcData calcBoost:currentIntergerValue]];
        }else if([gaugeOneType isEqualToString:@"Wideband"]){
            currentStringValue = [array objectAtIndex:2];
            currentIntergerValue = [currentStringValue integerValue];
            [self addNewDataToPlot:_localPlotBuilderOne withData:[calcData calcWideBand:currentIntergerValue]];
        }else if([gaugeOneType isEqualToString:@"Temperature"]){
            currentStringValue = [array objectAtIndex:3];
            currentIntergerValue = [currentStringValue integerValue];
            [self addNewDataToPlot:_localPlotBuilderOne withData:[calcData calcTemp:currentIntergerValue]];
        }else if([gaugeOneType isEqualToString:@"Oil"]){
            currentStringValue = [array objectAtIndex:4];
            currentIntergerValue = [currentStringValue integerValue];
            [self addNewDataToPlot:_localPlotBuilderOne withData:[calcData calcOil:currentIntergerValue]];
        }
        
        //        if([gaugeTwoType isEqualToString:@"Boost"]){
        //            currentStringValue = [array objectAtIndex:1];
        //            currentIntergerValue = [currentStringValue integerValue];
        //            [self addNewDataToPlot:_localPlotBuilderTwo withData:[calcDataTwo calcBoost:currentIntergerValue]];
        //        }else if([gaugeTwoType isEqualToString:@"Wideband"]){
        //            currentStringValue = [array objectAtIndex:2];
        //            currentIntergerValue = [currentStringValue integerValue];
        //            [self addNewDataToPlot:_localPlotBuilderTwo withData:[calcDataTwo calcWideBand:currentIntergerValue]];
        //        }else if([gaugeTwoType isEqualToString:@"Temperature"]){
        //            currentStringValue = [array objectAtIndex:3];
        //            currentIntergerValue = [currentStringValue integerValue];
        //            [self addNewDataToPlot:_localPlotBuilderTwo withData:[calcDataTwo calcTemp:currentIntergerValue]];
        //        }else if([gaugeTwoType isEqualToString:@"Oil"]){
        //            currentStringValue = [array objectAtIndex:4];
        //            currentIntergerValue = [currentStringValue integerValue];
        //            [self addNewDataToPlot:_localPlotBuilderTwo withData:[calcDataTwo calcOil:currentIntergerValue]];
        //        }
        
        
        //Set voltage value
        currentStringValue = [array objectAtIndex:0];
        currentIntergerValue = [currentStringValue integerValue];
        
        [self addNewDataToPlot:_localPlotBuilderVolts withData:[calcDataVolts calcVolts:currentIntergerValue]];
    }
}

-(void)addNewDataToPlot:(CICPlotBuilder *) plotBuilderIn withData:(CGFloat)newData
{
    //newData = (CGFloat)rand()/(double)RAND_MAX*10;
    [plotBuilderIn addNewDataToPlot:newData];
    [self setDigitalLabel:newData withPlotIdentifier:[plotBuilderIn getPlotIdentifierAsString]];
    
    //resize axes if needed
    [chartView resizeXAxis:_localPlotBuilderOne.currentIndex];
    [self resizeAxes:newData];
}


-(void)setDigitalLabel:(CGFloat)value withPlotIdentifier:(NSString *)plotIdentifier
{
    if([plotIdentifier isEqualToString:@"plotVolts"]){
        [chartVoltLabelData setText:[NSString stringWithFormat:@"%.02f", value]];
    }else{
        [chartLabelData1 setText:[NSString stringWithFormat:@"%.02f", value]];
    }
}

#pragma mark Create Chart Section
-(CICPlotBuilder *)createBoostChart:(CICPlotBuilder *)plotBuilder
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
    return [self buildPlot:@"plotBoost" withPlotBuilder:plotBuilder withColor:[CPTColor greenColor]];
    
}

-(CICPlotBuilder *)createWidebandChart:(CICPlotBuilder *)plotBuilder
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
     return [self buildPlot:@"plotWideband" withPlotBuilder:plotBuilder withColor:[CPTColor whiteColor]];
}

-(void)createTempChart:(CICPlotBuilder *)plotBuilder
{
    //Create the graph
    if([temperatureUnits isEqualToString:@"Fahrenheit"]){
        [self buildChart:20 withYMax:60];
    }else{
        [self buildChart:-5 withYMax:30];
    }
    
    //Create the temp plot
    plotBuilder = [self buildPlot:@"plotTemp" withPlotBuilder:plotBuilder withColor:[CPTColor colorWithComponentRed:113.0f/255.0f green:226.0f/255.0f blue:243.0f/255.0f alpha:1.0f]];
}

-(void)createOilChart:(CICPlotBuilder *)plotBuilder
{
    //Create the graph
    if([oilPressureUnits isEqualToString:@"PSI"]){
        [self buildChart:0 withYMax:30];
    }else{
        [self buildChart:0 withYMax:10];
    }
    
    //Create the oil plot
    plotBuilder = [self buildPlot:@"plotOil" withPlotBuilder:plotBuilder withColor:[CPTColor yellowColor]];
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
    
    newPlot.plotSymbolMarginForHitDetection = 20.0f;
    
    [chartView addPlotToGraph:newPlot];
    
    [plotBuilderIn setSelectedDelegate:self];
    
    return plotBuilderIn;
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

//Delegate method to receive new touched value from CICPlotBuilder.
-(void)getTouchedPointValue:(CGFloat)selectedValue withPlotIdentifier:(NSString *)plotIdentifier
{
    [self setDigitalLabel:selectedValue withPlotIdentifier:plotIdentifier];
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
    gaugeOneType = [standardDefaults stringForKey:@"twogauge_gauge_one"];
    gaugeTwoType = [standardDefaults stringForKey:@"twogauge_gauge_two"];
    
    isPaused = NO;
}


-(void)initLabels:(UILabel *)chartLabel withDataLabel:(UILabel *)chartLabelData forGaugeType:(GaugeType)gaugeTypeIn
{
    //build selected chart labels.
    if(gaugeTypeIn==0){
        chartLabel.textColor = [UIColor greenColor];
        chartLabel.font = [UIFont fontWithName:@"Futura" size:15];
        chartLabel.text = @"Boost:";
        chartLabel.textAlignment = NSTextAlignmentRight;
        chartLabelData.textColor = [UIColor whiteColor];
        chartLabelData.font = [UIFont fontWithName:@"LetsgoDigital-Regular" size:20];
        chartLabelData.text = @"00.0";
        chartLabelData.textAlignment = NSTextAlignmentLeft;
    }else if(gaugeTypeIn==1){
        chartLabel.textColor = [UIColor greenColor];
        chartLabel.font = [UIFont fontWithName:@"Futura" size:15];
        chartLabel.text = @"Boost:";
        chartLabel.textAlignment = NSTextAlignmentRight;
        chartLabelData.textColor = [UIColor whiteColor];
        chartLabelData.font = [UIFont fontWithName:@"LetsgoDigital-Regular" size:20];
        chartLabelData.text = @"00.0";
        chartLabelData.textAlignment = NSTextAlignmentLeft;
    }else if(gaugeTypeIn==2){
        chartLabel.textColor = [UIColor whiteColor];
        chartLabel.font = [UIFont fontWithName:@"Futura" size:15];
        chartLabel.text = @"WB:";
        chartLabel.textAlignment = NSTextAlignmentRight;
        chartLabelData.textColor = [UIColor whiteColor];
        chartLabelData.font = [UIFont fontWithName:@"LetsgoDigital-Regular" size:20];
        chartLabelData.text = @"00.0";
        chartLabelData.textAlignment = NSTextAlignmentLeft;
    }else if(gaugeTypeIn==3){
        chartLabel.textColor = [UIColor colorWithRed: 113.0/255.0 green: 226.0/255.0 blue:243.0/255.0 alpha: 1.0];
        chartLabel.font = [UIFont fontWithName:@"Futura" size:15];
        chartLabel.text = @"Temp:";
        chartLabel.textAlignment = NSTextAlignmentRight;
        chartLabelData.textColor = [UIColor whiteColor];
        chartLabelData.font = [UIFont fontWithName:@"LetsgoDigital-Regular" size:20];
        chartLabelData.text = @"00.0";
        chartLabelData.textAlignment = NSTextAlignmentLeft;
    }else if(gaugeTypeIn==4){
        chartLabel.textColor = [UIColor yellowColor];
        chartLabel.font = [UIFont fontWithName:@"Futura" size:15];
        chartLabel.text = @"Oil:";
        chartLabel.textAlignment = NSTextAlignmentRight;
        chartLabelData.textColor = [UIColor whiteColor];
        chartLabelData.font = [UIFont fontWithName:@"LetsgoDigital-Regular" size:20];
        chartLabelData.text = @"00.0";
        chartLabelData.textAlignment = NSTextAlignmentLeft;
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
        [chartView resetYAxis];
        isPaused = NO;
        pauseButton.title = @"Pause";
    }else{
        isPaused = YES;
        pauseButton.title = @"Play";
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end

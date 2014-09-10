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

@synthesize chartView, gaugeType, bluetooth;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self initPrefs];
    
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
    
    if(showVolts){
        _localPlotBuilderVolts = [self buildPlot:@"plotVolts" withPlotBuilder:_localPlotBuilderVolts withColor:[CPTColor redColor]];
    }
    
    //[self buildChart];
    //[self buildPlots];
    [self startTimer];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
        [self buildChart:-30.0f withYMax:25.0f];
    }else{
        [self buildChart:0.0f withYMax:250.0f];
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
            [self buildChart:5 withYMax:25];
        }else if([widebandFuelType isEqualToString:@"Methanol"]){
            [self buildChart:3 withYMax:8];
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
        [self buildChart:-20 withYMax:220];
    }else{
        [self buildChart:-35 withYMax:105];
    }
    
    //Create the temp plot
    _localPlotBuilderOne = [self buildPlot:@"plotTemp" withPlotBuilder:_localPlotBuilderOne withColor:[CPTColor yellowColor]];
}

-(void)createOilChart
{
    //Create the graph
    if([oilPressureUnits isEqualToString:@"PSI"]){
        [self buildChart:0 withYMax:100];
    }else{
        [self buildChart:0 withYMax:10];
    }
    
    //Create the oil plot
    _localPlotBuilderOne = [self buildPlot:@"plotOil" withPlotBuilder:_localPlotBuilderOne withColor:[CPTColor blueColor]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)buildChart:(CGFloat)yMinIn withYMax:(CGFloat)yMaxIn
{
    //Setup initial y-range.
    [chartView setYMin:-30.0f];
    [chartView setYMax:20.0f];
    
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
    newData = (CGFloat)rand()/(double)RAND_MAX*10;
//    if(plotBuilderIn.currentIndex%10==0){
//        newData = -22.0;
//    }
    [plotBuilderIn addNewDataToPlot:newData];
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
    [self addNewDataToPlot:_localPlotBuilderOne withData:0.0f];
    [self addNewDataToPlot:_localPlotBuilderVolts withData:0.0f];
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
}

- (void)viewDidUnload
{
    //[dataTimer invalidate];
    //dataTimer = nil;
}

-(void)dealloc
{
    [dataTimer invalidate];
}



@end

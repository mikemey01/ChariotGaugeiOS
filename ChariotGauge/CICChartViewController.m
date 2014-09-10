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
        [self buildPlot:@"plotVolts" withPlotBuilder:_localPlotBuilderVolts withColor:[CPTColor redColor]];
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
        [self buildChart:-1 withYMax:3];
    }else if([pressureUnits isEqualToString:@"PSI"]){
        [self buildChart:-30 withYMax:25];
    }else{
        [self buildChart:0 withYMax:250];
    }
    
    //Create the boost plot
    [self buildPlot:@"plotBoost" withPlotBuilder:_localPlotBuilderOne withColor:[CPTColor greenColor]];
}

-(void)createWidebandChart
{
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
    [self buildPlot:@"plotWideband" withPlotBuilder:_localPlotBuilderOne withColor:[CPTColor whiteColor]];
}

-(void)createTempChart
{
    if([temperatureUnits isEqualToString:@"Fahrenheit"]){
        [self buildChart:-20 withYMax:220];
    }else{
        [self buildChart:-35 withYMax:105];
    }
    
    //Create the temp plot
    [self buildPlot:@"plotTemp" withPlotBuilder:_localPlotBuilderOne withColor:[CPTColor yellowColor]];
}

-(void)createOilChart
{
    if([oilPressureUnits isEqualToString:@"PSI"]){
        [self buildChart:0 withYMax:100];
    }else{
        [self buildChart:0 withYMax:10];
    }
    
    //Create the oil plot
    [self buildPlot:@"plotOil" withPlotBuilder:_localPlotBuilderOne withColor:[CPTColor blueColor]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)buildChart:(NSInteger)yMinIn withYMax:(NSInteger)yMaxIn
{
    //Setup initial y-range.
    [chartView setYMin:yMinIn];
    [chartView setYMax:yMaxIn];
    
    //Build chart
    [chartView initPlot];
}

-(void)buildPlot:(NSString *)plotNameIn withPlotBuilder:(CICPlotBuilder *)plotBuilderIn withColor:(CPTColor *)colorIn
{
    //Create the plot, add it to the graph.
    plotBuilderIn = [[CICPlotBuilder alloc] init];
    
    CPTScatterPlot *newPlot = [plotBuilderIn createPlot:plotNameIn withColor:colorIn];
    
    [chartView addPlotToGraph:newPlot];
}

-(void)addNewDataToPlot:(CGFloat)newData
{
    CGFloat newDataForPlot = (CGFloat)rand()/(double)RAND_MAX*10;
    if(_localPlotBuilderOne.currentIndex%10==0){
        newDataForPlot = -22.0;
    }
    [_localPlotBuilderOne addNewDataToPlot:newDataForPlot];
    [chartView resizeXAxis:_localPlotBuilderOne.currentIndex];
    [self resizeAxes:newDataForPlot];
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
                                      selector:@selector(addNewDataToPlot:)
                                      userInfo:nil
                                       repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:dataTimer forMode:NSRunLoopCommonModes];
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
    [dataTimer invalidate];
    dataTimer = nil;
}

-(void)dealloc
{
    [dataTimer invalidate];
}



@end

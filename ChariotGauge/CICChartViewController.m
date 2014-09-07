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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIViewController lifecycle methods
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self buildChart];
    [self buildPlots];
    [self startTimer];
}

-(void)buildChart
{
    //Setup initial y-range.
    [chartView setYMin:-5.0];
    [chartView setYMax:1.0];
    
    //Build chart
    [chartView initPlot];
}

-(void)buildPlots
{
    //Create the plot, add it to the graph.
    _localPlotBuilderOne = [CICPlotBuilder alloc];
    
    CPTScatterPlot *newPlot = [_localPlotBuilderOne createPlot:@"PlotOne" withColor:[CPTColor greenColor]];
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

-(void)dealloc
{
    [dataTimer invalidate];
}



@end

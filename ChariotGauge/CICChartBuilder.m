//
//  CICChartBuilder.m
//  ChariotGauge
//
//  Created by Mike on 8/19/14.
//  Copyright (c) 2014 Chariot Instruments. All rights reserved.
//

#import "CICChartBuilder.h"
#import "CorePlot-CocoaTouch.h"

static const double kFrameRate = 5.0;  // frames per second
static const double kAlpha     = 0.25; // smoothing constant

static const NSUInteger kMaxDataPoints = 52;
static NSString *const kPlotIdentifier = @"Data Source Plot";

@implementation CICChartBuilder

@synthesize graph, thisFrame, hostView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    self.thisFrame = rect;
}

-(void)initPlot
{
    if (self.graph == nil) self.graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    
    [self killGraph];
    plotData  = [[NSMutableArray alloc] initWithCapacity:kMaxDataPoints];
    dataTimer = nil;
    self.hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:self.thisFrame];
    self.hostView.clipsToBounds = YES;
	self.hostView.allowPinchScaling = YES;
    
    [self generateData];
	[self addSubview:self.hostView];
    [self renderInLayer:hostView animated:YES];
}

-(void)killGraph
{
    [dataTimer invalidate];
    dataTimer = nil;
}

-(void)generateData
{
    [plotData removeAllObjects];
    currentIndex = 0;
}


-(void)renderInLayer:(CPTGraphHostingView *)layerHostingView animated:(BOOL)animated
{
    
    [graph applyTheme:[CPTTheme themeNamed:kCPTDarkGradientTheme]];
    self.hostView.hostedGraph = graph;

    
    [graph.plotAreaFrame setFrame:thisFrame];
    graph.plotAreaFrame.paddingTop    = 15.0;
    graph.plotAreaFrame.paddingRight  = 15.0;
    graph.plotAreaFrame.paddingBottom = 55.0;
    graph.plotAreaFrame.paddingLeft   = 55.0;
    graph.plotAreaFrame.masksToBorder = NO;
    
    // Grid line styles
    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
    majorGridLineStyle.lineWidth = 0.75;
    majorGridLineStyle.lineColor = [[CPTColor colorWithGenericGray:0.2] colorWithAlphaComponent:0.75];
    
    CPTMutableLineStyle *minorGridLineStyle = [CPTMutableLineStyle lineStyle];
    minorGridLineStyle.lineWidth = 0.25;
    minorGridLineStyle.lineColor = [[CPTColor whiteColor] colorWithAlphaComponent:0.1];
    
    // Axes
    // X axis
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    x.labelingPolicy              = CPTAxisLabelingPolicyAutomatic;
    x.orthogonalCoordinateDecimal = CPTDecimalFromUnsignedInteger(0);
    x.majorGridLineStyle          = majorGridLineStyle;
    x.minorGridLineStyle          = minorGridLineStyle;
    x.minorTicksPerInterval       = 9;
    x.title                       = @"X Axis";
    x.titleOffset                 = 35.0;
    NSNumberFormatter *labelFormatter = [[NSNumberFormatter alloc] init];
    labelFormatter.numberStyle = NSNumberFormatterNoStyle;
    x.labelFormatter           = labelFormatter;
    
    // Y axis
    CPTXYAxis *y = axisSet.yAxis;
    y.labelingPolicy              = CPTAxisLabelingPolicyAutomatic;
    y.orthogonalCoordinateDecimal = CPTDecimalFromUnsignedInteger(0);
    y.majorGridLineStyle          = majorGridLineStyle;
    y.minorGridLineStyle          = minorGridLineStyle;
    y.minorTicksPerInterval       = 3;
    y.labelOffset                 = 5.0;
    y.title                       = @"Y Axis";
    y.titleOffset                 = 30.0;
    y.axisConstraints             = [CPTConstraints constraintWithLowerOffset:0.0];
    
    // Rotate the labels by 45 degrees, just to show it can be done.
    x.labelRotation = M_PI_4;
    
    // Create the plot
    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init];
    dataSourceLinePlot.identifier     = kPlotIdentifier;
    dataSourceLinePlot.cachePrecision = CPTPlotCachePrecisionDouble;
    
    CPTMutableLineStyle *lineStyle = [dataSourceLinePlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth              = 3.0;
    lineStyle.lineColor              = [CPTColor greenColor];
    dataSourceLinePlot.dataLineStyle = lineStyle;
    
    dataSourceLinePlot.dataSource = self;
    [graph addPlot:dataSourceLinePlot];
    
    // Plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromUnsignedInteger(0) length:CPTDecimalFromUnsignedInteger(kMaxDataPoints - 2)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromUnsignedInteger(0) length:CPTDecimalFromUnsignedInteger(1)];
    
    [dataTimer invalidate];
    
    if ( animated ) {
        dataTimer = [NSTimer timerWithTimeInterval:1.0 / kFrameRate
                                            target:self
                                          selector:@selector(newData:)
                                          userInfo:nil
                                           repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:dataTimer forMode:NSRunLoopCommonModes];
    }
    else {
        dataTimer = nil;
    }
}

-(void)dealloc
{
    [dataTimer invalidate];
}

#pragma mark -
#pragma mark Timer callback

-(void)newData:(NSTimer *)theTimer
{
    CPTPlot *thePlot   = [graph plotWithIdentifier:kPlotIdentifier];
    
    if ( thePlot ) {
        if ( plotData.count >= kMaxDataPoints ) {
            [plotData removeObjectAtIndex:0];
            [thePlot deleteDataInIndexRange:NSMakeRange(0, 1)];
        }
        
        CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
        NSUInteger location       = (currentIndex >= kMaxDataPoints ? currentIndex - kMaxDataPoints + 2 : 0);
        
        CPTPlotRange *oldRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromUnsignedInteger( (location > 0) ? (location - 1) : 0 )
                                                              length:CPTDecimalFromUnsignedInteger(kMaxDataPoints - 2)];
        CPTPlotRange *newRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromUnsignedInteger(location)
                                                              length:CPTDecimalFromUnsignedInteger(kMaxDataPoints - 2)];
        
        [CPTAnimation animate:plotSpace
                     property:@"xRange"
                fromPlotRange:oldRange
                  toPlotRange:newRange
                     duration:CPTFloat(1.0 / kFrameRate)];
        
        currentIndex++;
        [plotData addObject:@( (1.0 - kAlpha) * [[plotData lastObject] doubleValue] + kAlpha * rand() / (double)RAND_MAX )];
        [thePlot insertDataAtIndex:plotData.count - 1 numberOfRecords:1];
    }
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return [plotData count];
}

-(id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSNumber *num = nil;
    
    switch ( fieldEnum ) {
        case CPTScatterPlotFieldX:
            num = @(index + currentIndex - plotData.count);
            break;
            
        case CPTScatterPlotFieldY:
            num = plotData[index];
            break;
            
        default:
            break;
    }
    
    return num;
}

@end

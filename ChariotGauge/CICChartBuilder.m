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

//Gets this views bounds - Important!
- (void)drawRect:(CGRect)rect
{
    self.thisFrame = rect;
}

-(void)initPlot
{
    if (self.graph == nil) self.graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    
    [dataTimer invalidate];
    dataTimer = nil;
    plotData  = [[NSMutableArray alloc] initWithCapacity:kMaxDataPoints];
    dataTimer = nil;
    self.hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:self.thisFrame];
    self.hostView.clipsToBounds = YES;
	self.hostView.allowPinchScaling = YES;
    self.hostView.userInteractionEnabled = YES;
    
    [plotData removeAllObjects];
    currentIndex = 0;
	[self addSubview:self.hostView];
    [self renderInLayer:hostView animated:YES];
}


-(void)renderInLayer:(CPTGraphHostingView *)layerHostingView animated:(BOOL)animated
{
    
    [graph applyTheme:[CPTTheme themeNamed:kCPTDarkGradientTheme]];
    self.hostView.hostedGraph = graph;
    [self.hostView.layer setBorderWidth:1.0f];

    
    [graph.plotAreaFrame setFrame:thisFrame];
    graph.paddingLeft = 0.0;
    graph.paddingRight = 0.0;
    graph.paddingTop = 0.0;
    graph.paddingBottom = 0.0;
    graph.plotAreaFrame.paddingTop    = 0.0;
    graph.plotAreaFrame.paddingRight  = 0.0;
    graph.plotAreaFrame.paddingBottom = 0.0;
    graph.plotAreaFrame.paddingLeft   = 0.0;
    graph.plotAreaFrame.masksToBorder = NO;
    graph.plotAreaFrame.borderWidth = 0;
    graph.plotAreaFrame.cornerRadius = 0;
	[graph.plotAreaFrame setPaddingLeft:30.0f];
	[graph.plotAreaFrame setPaddingBottom:25.0f];
    [graph.plotAreaFrame setPaddingTop:5.0f];
    [graph.plotAreaFrame setPaddingRight:10.0f];
    
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
    x.titleOffset                 = 5.0;
    NSNumberFormatter *labelFormatter = [[NSNumberFormatter alloc] init];
    labelFormatter.numberStyle = NSNumberFormatterNoStyle;
    x.labelFormatter           = labelFormatter;
    x.labelOffset                 = 1.0;
    
    // Y axis
    CPTXYAxis *y = axisSet.yAxis;
    y.labelingPolicy              = CPTAxisLabelingPolicyAutomatic;
    y.orthogonalCoordinateDecimal = CPTDecimalFromUnsignedInteger(0);
    y.majorGridLineStyle          = majorGridLineStyle;
    y.minorGridLineStyle          = minorGridLineStyle;
    y.minorTicksPerInterval       = 3;
    y.labelOffset                 = 2.0;
    y.title                       = @"Y Axis";
    y.titleOffset                 = 5.0;
    y.axisConstraints             = [CPTConstraints constraintWithLowerOffset:0.0];
    
    // Rotate the labels by 45 degrees, just to show it can be done.
    x.labelRotation = M_PI_4;
    
    [self addPlotToGraph:kPlotIdentifier withColor:[CPTColor greenColor]];
    
    // Plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromUnsignedInteger(0) length:CPTDecimalFromUnsignedInteger(kMaxDataPoints + 10)];
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

-(void)addPlotToGraph:(NSString*)plotIdentifierIn withColor:(CPTColor*)colorIn
{
    // Create the plot
    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init];
    dataSourceLinePlot.identifier     = plotIdentifierIn;
    dataSourceLinePlot.cachePrecision = CPTPlotCachePrecisionDouble;
    
    CPTMutableLineStyle *lineStyle = [dataSourceLinePlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth              = 2.0;
    lineStyle.lineColor              = colorIn;
    dataSourceLinePlot.dataLineStyle = lineStyle;
    
    dataSourceLinePlot.dataSource = self;
    [graph addPlot:dataSourceLinePlot];
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
        
        [self resizeAxes];
        
        currentIndex++;
        [plotData addObject:@(rand()/(double)RAND_MAX*10)];
        [thePlot insertDataAtIndex:plotData.count - 1 numberOfRecords:1];
    }
}

-(void)resizeAxes
{
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    NSUInteger location       = (currentIndex >= kMaxDataPoints ? currentIndex - kMaxDataPoints + 2 : 0);
    NSUInteger yLocation      = (0);
    
    CPTPlotRange *oldRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromUnsignedInteger( (location > 0) ? (location - 1) : 0 )
                                                          length:CPTDecimalFromUnsignedInteger(kMaxDataPoints + 10)];
    CPTPlotRange *newRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromUnsignedInteger(location)
                                                          length:CPTDecimalFromUnsignedInteger(kMaxDataPoints + 10)];
    
    //The following will scale the y-axis up! The conditional statement should reflect the highest/lowest point of the data received.
    if(currentIndex < 11 && currentIndex > 0){ //only expand the y range up to ten.
        CPTPlotRange *yOldRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromUnsignedInteger(yLocation) length:CPTDecimalFromUnsignedInteger(currentIndex)];
        CPTPlotRange *yNewRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromUnsignedInteger(yLocation) length:CPTDecimalFromUnsignedInteger(currentIndex+1)];
        
        [CPTAnimation animate:plotSpace
                     property:@"yRange"
                fromPlotRange:yOldRange
                  toPlotRange:yNewRange
                     duration:CPTFloat(1.0 / kFrameRate)];
    }
    
    [CPTAnimation animate:plotSpace
                 property:@"xRange"
            fromPlotRange:oldRange
              toPlotRange:newRange
                 duration:CPTFloat(1.0 / kFrameRate)];
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

-(void)dealloc
{
    [dataTimer invalidate];
}

@end

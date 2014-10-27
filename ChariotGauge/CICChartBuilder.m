//
//  CICChartBuilder.m
//  ChariotGauge
//
//  Created by Mike on 8/19/14.
//  Copyright (c) 2014 Chariot Instruments. All rights reserved.
//

#import "CICChartBuilder.h"
#import "CorePlot-CocoaTouch.h"
#import "CICPlotBuilder.h"

static const double kFrameRate = 20.0;  // frames per second
static const NSUInteger kMaxDataPoints = 40;
static const NSUInteger kGlobalDataPoints = 54000;

@implementation CICChartBuilder

@synthesize graph, thisFrame, hostView, yMin, yMax;

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

    self.hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:self.thisFrame];
    self.hostView.clipsToBounds = YES;
	self.hostView.allowPinchScaling = YES;
    self.hostView.userInteractionEnabled = YES;
    
    //self.yMin = -5.0;
    //self.yMax = 1;
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
    x.orthogonalCoordinateDecimal = CPTDecimalFromCGFloat(yMin);
    x.majorGridLineStyle          = majorGridLineStyle;
    x.minorGridLineStyle          = minorGridLineStyle;
    x.minorTicksPerInterval       = 9;
    x.title                       = @"";
    x.titleOffset                 = 5.0;
    NSNumberFormatter *labelFormatter = [[NSNumberFormatter alloc] init];
    labelFormatter.numberStyle = NSNumberFormatterNoStyle;
    x.labelFormatter           = labelFormatter;
    x.labelOffset                 = 1.0;
    
    // Y axis
    CPTXYAxis *y = axisSet.yAxis;
    y.labelingPolicy              = CPTAxisLabelingPolicyAutomatic;
    y.orthogonalCoordinateDecimal = CPTDecimalFromCGFloat(yMin);
    y.majorGridLineStyle          = majorGridLineStyle;
    y.minorGridLineStyle          = minorGridLineStyle;
    y.minorTicksPerInterval       = 3;
    y.labelOffset                 = 0.0;
    y.title                       = @"";
    y.titleOffset                 = 5.0;
    y.axisConstraints             = [CPTConstraints constraintWithLowerOffset:0.0];
    y.labelFormatter              = labelFormatter;
    
    // Rotate the labels by 0 degrees
    x.labelRotation = 0;
    
    //Allows user interaction/scrolling
    [[graph defaultPlotSpace] setAllowsUserInteraction:YES];
    
    // Create Plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    
    //Setup initial x-Range
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromUnsignedInteger(0) length:CPTDecimalFromUnsignedInteger(kMaxDataPoints + 10)];
    
    //Setup initial y-Range. yMax - yMin to handle negatives for the length.
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromUnsignedInteger(yMin) length:CPTDecimalFromUnsignedInteger(yMax-yMin)];
    
    //Setup global x-range for scrolling
    plotSpace.globalXRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromUnsignedInteger(0) length:CPTDecimalFromUnsignedInteger(kGlobalDataPoints)];
    
    //Sets the global y-range for only scrolling x-axis. Has to be reset when y-axis is resized.
    plotSpace.globalYRange = plotSpace.yRange;

}

-(void)addPlotToGraph:(CPTScatterPlot *) plotIn
{
    plotIn.plotSymbolMarginForHitDetection = 5.0f;
    [graph addPlot:plotIn];
    
}

-(void)resetYAxis
{
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromUnsignedInteger(yMin) length:CPTDecimalFromUnsignedInteger(yMax-yMin)];
}


-(void)resizeXAxis:(NSUInteger)currentIndexIn
{
    currentIndex = currentIndexIn;
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    NSUInteger location       = (currentIndex >= kMaxDataPoints ? currentIndex - kMaxDataPoints + 2 : 0);
    
    CPTPlotRange *oldRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromUnsignedInteger( (location > 0) ? (location - 1) : 0 )
                                                          length:CPTDecimalFromUnsignedInteger(kMaxDataPoints + 10)];
    CPTPlotRange *newRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromUnsignedInteger(location)
                                                          length:CPTDecimalFromUnsignedInteger(kMaxDataPoints + 10)];
    
    [CPTAnimation animate:plotSpace
                 property:@"xRange"
            fromPlotRange:oldRange
              toPlotRange:newRange
                 duration:CPTFloat(1.0 / kFrameRate)];
}

-(void)resizeYAxis:(CGFloat)yMinIn withYMax:(CGFloat)yMaxIn
{
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *y          = axisSet.yAxis;
    CPTXYAxis *x          = axisSet.xAxis;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    
    //The following will scale the y-axis up! The conditional statement should reflect the highest/lowest point of the data received.
    CPTPlotRange *yOldRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromCGFloat(yMin) length:CPTDecimalFromUnsignedInteger(yMax-yMin)];
    CPTPlotRange *yNewRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromCGFloat(yMinIn) length:CPTDecimalFromUnsignedInteger(yMaxIn-yMinIn)];
    
    [CPTAnimation animate:plotSpace
                 property:@"yRange"
            fromPlotRange:yOldRange
              toPlotRange:yNewRange
                 duration:CPTFloat(1.0 / kFrameRate)];
    
    //Reset this for scrolling the x-axis.
    plotSpace.globalYRange = yNewRange;
    
    //Move the x-axis down to match the ymin value.
    y.orthogonalCoordinateDecimal = CPTDecimalFromCGFloat(yMinIn);
    x.orthogonalCoordinateDecimal = CPTDecimalFromCGFloat(yMinIn);
    
    //Set these for future range changes.
    yMin = yMinIn;
    yMax = yMaxIn;

}


@end

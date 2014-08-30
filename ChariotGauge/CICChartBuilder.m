//
//  CICChartBuilder.m
//  ChariotGauge
//
//  Created by Mike on 8/19/14.
//  Copyright (c) 2014 Chariot Instruments. All rights reserved.
//

#import "CICChartBuilder.h"
#import "CorePlot-CocoaTouch.h"

@implementation CICChartBuilder

NSString *  const CPDTickerSymbolAAPL = @"AAPL";

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

//START

@synthesize hostView = hostView_, thisFrame, plotIdentifier, graph;



 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    self.thisFrame = rect;
}

//check if variables are null or if they were created in the view controller - handle.
-(void)initVariables{
    if (self.plotIdentifier == (id)[NSNull null] || self.plotIdentifier.length == 0 ) self.plotIdentifier = @"gauge1";
    if (self.graph == nil) self.graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
}


#pragma mark - Chart behavior
-(void)initPlot {
    [self initVariables];
    [self configureHost];
    [self configureGraph];
    [self configurePlots];
    //[self configureAxes];
}

-(void)configureHost {
	self.hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:self.thisFrame];
    self.hostView.clipsToBounds = YES;
	self.hostView.allowPinchScaling = NO;
	[self addSubview:self.hostView];
}

-(void)configureGraph {
    
    //Set graph style
	[graph applyTheme:[CPTTheme themeNamed:kCPTPlainBlackTheme]];
	self.hostView.hostedGraph = graph;
    [self.hostView.layer setBorderWidth:1.0f];
    
    
	// Create and set text style for title
	CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
	titleStyle.color = [CPTColor whiteColor];
	titleStyle.fontName = @"Helvetica-Bold";
	titleStyle.fontSize = 15.0f;
	graph.titleTextStyle = titleStyle;
	graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
	graph.titleDisplacement = CGPointMake(0.0f, 0.0f);
    graph.title = @"Charting";
    
	// Set padding for plot area
    graph.paddingLeft = 0;
    graph.paddingRight = 0;
    graph.paddingTop = 0;
    graph.paddingBottom = 0;
    graph.plotAreaFrame.borderWidth = 0;
    graph.plotAreaFrame.cornerRadius = 0;
	[graph.plotAreaFrame setPaddingLeft:30.0f];
	[graph.plotAreaFrame setPaddingBottom:25.0f];
    [graph.plotAreaFrame setFrame:self.thisFrame];
}

-(void)configurePlots {

	// 1 - Get graph and plot space
	CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    
	// 2 - Create the plot data source, identifier, color
	CPTScatterPlot *gaugePlot = [[CPTScatterPlot alloc] init];
	gaugePlot.dataSource = self;
	gaugePlot.identifier = self.plotIdentifier;
	CPTColor *plotColor = [CPTColor redColor];
	[graph addPlot:gaugePlot toPlotSpace:plotSpace];
	
	// 3 - Set up plot space
	[plotSpace scaleToFitPlots:[NSArray arrayWithObjects:gaugePlot, nil]];
	CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
	[xRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
	plotSpace.xRange = xRange;
	CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
	[yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.2f)];
	plotSpace.yRange = yRange;
    
	// 4 - Create styles and symbols
	CPTMutableLineStyle *aaplLineStyle = [gaugePlot.dataLineStyle mutableCopy];
	aaplLineStyle.lineWidth = 1.0;
	aaplLineStyle.lineColor = plotColor;
	gaugePlot.dataLineStyle = aaplLineStyle;
	CPTMutableLineStyle *aaplSymbolLineStyle = [CPTMutableLineStyle lineStyle];
	aaplSymbolLineStyle.lineColor = plotColor;
	CPTPlotSymbol *aaplSymbol = [CPTPlotSymbol ellipsePlotSymbol];
	aaplSymbol.fill = [CPTFill fillWithColor:plotColor];
	aaplSymbol.lineStyle = aaplSymbolLineStyle;
	aaplSymbol.size = CGSizeMake(2.0f, 2.0f);
	gaugePlot.plotSymbol = aaplSymbol;

}

-(void)configureAxes {
/*
     // 1 - Create styles
     CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
     axisTitleStyle.color = [CPTColor whiteColor];
     axisTitleStyle.fontName = @"Helvetica-Bold";
     axisTitleStyle.fontSize = 12.0f;
     CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
     axisLineStyle.lineWidth = 2.0f;
     axisLineStyle.lineColor = [CPTColor whiteColor];
     CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
     axisTextStyle.color = [CPTColor whiteColor];
     axisTextStyle.fontName = @"Helvetica-Bold";
     axisTextStyle.fontSize = 11.0f;
     CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
     tickLineStyle.lineColor = [CPTColor whiteColor];
     tickLineStyle.lineWidth = 2.0f;
     CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
     tickLineStyle.lineColor = [CPTColor blackColor];
     tickLineStyle.lineWidth = 1.0f;
     
     // 2 - Get axis set
     CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
     
     // 3 - Configure x-axis
     CPTAxis *x = axisSet.xAxis;
     x.title = @"Day of Month";
     x.titleTextStyle = axisTitleStyle;
     x.titleOffset = 15.0f;
     x.axisLineStyle = axisLineStyle;
     x.labelingPolicy = CPTAxisLabelingPolicyNone;
     x.labelTextStyle = axisTextStyle;
     x.majorTickLineStyle = axisLineStyle;
     x.majorTickLength = 4.0f;
     x.tickDirection = CPTSignNegative;
     CGFloat dateCount = [[[CPDStockPriceStore sharedInstance] datesInMonth] count];
     NSMutableSet *xLabels = [NSMutableSet setWithCapacity:dateCount];
     NSMutableSet *xLocations = [NSMutableSet setWithCapacity:dateCount];
     NSInteger i = 0;
     for (NSString *date in [[CPDStockPriceStore sharedInstance] datesInMonth]) {
     CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:date  textStyle:x.labelTextStyle];
     CGFloat location = i++;
     label.tickLocation = CPTDecimalFromCGFloat(location);
     label.offset = x.majorTickLength;
     if (label) {
     [xLabels addObject:label];
     [xLocations addObject:[NSNumber numberWithFloat:location]];
     }
     }
     x.axisLabels = xLabels;
     x.majorTickLocations = xLocations;
     
     // 4 - Configure y-axis
     CPTAxis *y = axisSet.yAxis;
     y.title = @"Price";
     y.titleTextStyle = axisTitleStyle;
     y.titleOffset = -40.0f;
     y.axisLineStyle = axisLineStyle;
     y.majorGridLineStyle = gridLineStyle;
     y.labelingPolicy = CPTAxisLabelingPolicyNone;
     y.labelTextStyle = axisTextStyle;
     y.labelOffset = 16.0f;
     y.majorTickLineStyle = axisLineStyle;
     y.majorTickLength = 4.0f;
     y.minorTickLength = 2.0f;
     y.tickDirection = CPTSignPositive;
     NSInteger majorIncrement = 100;
     NSInteger minorIncrement = 50;
     CGFloat yMax = 700.0f;  // should determine dynamically based on max price
     NSMutableSet *yLabels = [NSMutableSet set];
     NSMutableSet *yMajorLocations = [NSMutableSet set];
     NSMutableSet *yMinorLocations = [NSMutableSet set];
     for (NSInteger j = minorIncrement; j <= yMax; j += minorIncrement) {
     NSUInteger mod = j % majorIncrement;
     if (mod == 0) {
     CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%li", (long)j] textStyle:y.labelTextStyle];
     NSDecimal location = CPTDecimalFromInteger(j);
     label.tickLocation = location;
     label.offset = -y.majorTickLength - y.labelOffset;
     if (label) {
     [yLabels addObject:label];
     }
     [yMajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
     } else {
     [yMinorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromInteger(j)]];
     }
     }
     y.axisLabels = yLabels;
     y.majorTickLocations = yMajorLocations;
     y.minorTickLocations = yMinorLocations;
 */
}

#pragma mark - Rotation
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

#pragma mark - CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return [[self xValueStore] count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {

     NSInteger valueCount = [[self xValueStore] count];
     switch (fieldEnum) {
     case CPTScatterPlotFieldX:
         if (index < valueCount) {
             return [NSNumber numberWithUnsignedInteger:index];
         }
         break;
     
     case CPTScatterPlotFieldY:
         if ([plot.identifier isEqual:self.plotIdentifier] == YES) {
             return [[self yValueStore] objectAtIndex:index];
         }
         break;
     }

	return [NSDecimalNumber zero];
}

-(NSArray *)yValueStore
{
    static NSArray *yValueArray = nil;
    yValueArray = [NSArray arrayWithObjects:
              [NSDecimalNumber numberWithFloat:6],
              [NSDecimalNumber numberWithFloat:6],
              [NSDecimalNumber numberWithFloat:7],
              [NSDecimalNumber numberWithFloat:8],
              [NSDecimalNumber numberWithFloat:3],
              [NSDecimalNumber numberWithFloat:6],
              [NSDecimalNumber numberWithFloat:2],
              [NSDecimalNumber numberWithFloat:6],
              [NSDecimalNumber numberWithFloat:5],
              [NSDecimalNumber numberWithFloat:7],
              [NSDecimalNumber numberWithFloat:6],
              [NSDecimalNumber numberWithFloat:8],
              [NSDecimalNumber numberWithFloat:4],
              [NSDecimalNumber numberWithFloat:5],
              [NSDecimalNumber numberWithFloat:5],
              [NSDecimalNumber numberWithFloat:6],
              [NSDecimalNumber numberWithFloat:6],
              [NSDecimalNumber numberWithFloat:6],
              [NSDecimalNumber numberWithFloat:6],
              [NSDecimalNumber numberWithFloat:6],
              nil];
    return yValueArray;
}

-(NSArray *)xValueStore
{
    static NSArray *xValueArray = nil;
    xValueArray = [NSArray arrayWithObjects:
                   [NSDecimalNumber numberWithFloat:1],
                   [NSDecimalNumber numberWithFloat:2],
                   [NSDecimalNumber numberWithFloat:3],
                   [NSDecimalNumber numberWithFloat:4],
                   [NSDecimalNumber numberWithFloat:5],
                   [NSDecimalNumber numberWithFloat:6],
                   [NSDecimalNumber numberWithFloat:7],
                   [NSDecimalNumber numberWithFloat:8],
                   [NSDecimalNumber numberWithFloat:9],
                   [NSDecimalNumber numberWithFloat:10],
                   [NSDecimalNumber numberWithFloat:11],
                   [NSDecimalNumber numberWithFloat:12],
                   [NSDecimalNumber numberWithFloat:13],
                   [NSDecimalNumber numberWithFloat:14],
                   [NSDecimalNumber numberWithFloat:15],
                   [NSDecimalNumber numberWithFloat:16],
                   [NSDecimalNumber numberWithFloat:17],
                   [NSDecimalNumber numberWithFloat:18],
                   [NSDecimalNumber numberWithFloat:19],
                   [NSDecimalNumber numberWithFloat:20],
                   nil];
    return xValueArray;
}

- (int)generateRand:(int)minNum withMaxNum:(int)maxNum
{
    int randNum = 0;
    randNum = rand() % (maxNum - minNum) + minNum;
    
    return randNum;
}

@end

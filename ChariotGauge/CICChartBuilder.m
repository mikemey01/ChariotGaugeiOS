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

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

//START

@synthesize hostView = hostView_, thisFrame;



 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    self.thisFrame = rect;
}


#pragma mark - Chart behavior
-(void)initPlot {
    [self configureHost];
    [self configureGraph];
    //[self configurePlots];
    //[self configureAxes];
}

-(void)configureHost {
	self.hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:self.thisFrame];
    self.hostView.clipsToBounds = YES;
	self.hostView.allowPinchScaling = NO;
	[self addSubview:self.hostView];
}

-(void)configureGraph {
    
	// 1 - Create the graph
	CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    
    //Set graph style
	[graph applyTheme:[CPTTheme themeNamed:kCPTPlainBlackTheme]];
    //[graph applyTheme:nil];
	self.hostView.hostedGraph = graph;
    [self.hostView.layer setBorderWidth:1.0f];
    
    //Remove Border
    graph.paddingLeft = 0;
    graph.paddingRight = 0;
    graph.paddingTop = 0;
    graph.paddingBottom = 0;
    graph.plotAreaFrame.borderWidth = 0;
    graph.plotAreaFrame.cornerRadius = 0;
    
    
	// 2 - Set graph title
	NSString *title = @"Charting";
	graph.title = title;
    
	// 3 - Create and set text style
	CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
	titleStyle.color = [CPTColor whiteColor];
	titleStyle.fontName = @"Helvetica-Bold";
	titleStyle.fontSize = 7.0f;
	graph.titleTextStyle = titleStyle;
	graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
	graph.titleDisplacement = CGPointMake(0.0f, 0.0f);
    
	// 4 - Set padding for plot area
	[graph.plotAreaFrame setPaddingLeft:30.0f];
	[graph.plotAreaFrame setPaddingBottom:30.0f];
    [graph.plotAreaFrame setFrame:self.thisFrame];
    
	// 5 - Enable user interactions for plot space
	CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
	plotSpace.allowsUserInteraction = YES;
}

-(void)configurePlots {
/*
	// 1 - Get graph and plot space
	CPTGraph *graph = self.hostView.hostedGraph;
	CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    
	// 2 - Create the three plots
	CPTScatterPlot *aaplPlot = [[CPTScatterPlot alloc] init];
	aaplPlot.dataSource = self;
	aaplPlot.identifier = CPDTickerSymbolAAPL;
	CPTColor *aaplColor = [CPTColor redColor];
	[graph addPlot:aaplPlot toPlotSpace:plotSpace];
	
	// 3 - Set up plot space
	[plotSpace scaleToFitPlots:[NSArray arrayWithObjects:aaplPlot, nil]];
	CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
	[xRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
	plotSpace.xRange = xRange;
	CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
	[yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.2f)];
	plotSpace.yRange = yRange;
    
	// 4 - Create styles and symbols
	CPTMutableLineStyle *aaplLineStyle = [aaplPlot.dataLineStyle mutableCopy];
	aaplLineStyle.lineWidth = 2.5;
	aaplLineStyle.lineColor = aaplColor;
	aaplPlot.dataLineStyle = aaplLineStyle;
	CPTMutableLineStyle *aaplSymbolLineStyle = [CPTMutableLineStyle lineStyle];
	aaplSymbolLineStyle.lineColor = aaplColor;
	CPTPlotSymbol *aaplSymbol = [CPTPlotSymbol ellipsePlotSymbol];
	aaplSymbol.fill = [CPTFill fillWithColor:aaplColor];
	aaplSymbol.lineStyle = aaplSymbolLineStyle;
	aaplSymbol.size = CGSizeMake(6.0f, 6.0f);
	aaplPlot.plotSymbol = aaplSymbol;
 */
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
     CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%i", j] textStyle:y.labelTextStyle];
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
    /*	return [[[CPDStockPriceStore sharedInstance] datesInMonth] count]; */
    return 10;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    /*
     NSInteger valueCount = [[[CPDStockPriceStore sharedInstance] datesInMonth] count];
     switch (fieldEnum) {
     case CPTScatterPlotFieldX:
     if (index < valueCount) {
     return [NSNumber numberWithUnsignedInteger:index];
     }
     break;
     
     case CPTScatterPlotFieldY:
     if ([plot.identifier isEqual:CPDTickerSymbolAAPL] == YES) {
     return [[[CPDStockPriceStore sharedInstance] monthlyPrices:CPDTickerSymbolAAPL] objectAtIndex:index];
     }
     break;
     }
     */
	return [NSDecimalNumber zero];
}

//END

- (int)generateRand:(int)minNum withMaxNum:(int)maxNum
{
    int randNum = 0;
    randNum = rand() % (maxNum - minNum) + minNum;
    
    return randNum;
}

@end

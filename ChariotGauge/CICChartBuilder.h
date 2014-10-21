//
//  CICChartBuilder.h
//  ChariotGauge
//
//  Created by Mike on 8/19/14.
//  Copyright (c) 2014 Chariot Instruments. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"
#import "CICPlotBuilder.h"

@interface CICChartBuilder : UIView
{
@private
    NSMutableArray *plotData;
    NSUInteger currentIndex;
    NSMutableArray *graphs;
    CPTGraph *graph;
    CGRect thisFrame;
    CPTGraphHostingView *hostView;
    CICPlotBuilder * _localPlotBuilder;
    CGFloat yMin;
    CGFloat yMax;
}

@property (nonatomic, retain) CPTGraph *graph;
@property (nonatomic, assign) CGRect thisFrame;
@property (nonatomic, retain) CPTGraphHostingView *hostView;
@property (nonatomic, assign) CGFloat yMin;
@property (nonatomic, assign) CGFloat yMax;

-(void)initPlot;
-(void)addPlotToGraph:(CPTScatterPlot *) plotIn;
-(void)resizeXAxis:(NSUInteger)currentIndexIn;
-(void)resizeYAxis:(CGFloat)yMinIn withYMax:(CGFloat)yMaxIn;
-(void)resetYAxis;

@end


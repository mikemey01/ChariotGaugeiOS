//
//  CICChartBuilder.h
//  ChariotGauge
//
//  Created by Mike on 8/19/14.
//  Copyright (c) 2014 Chariot Instruments. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface CICChartBuilder : UIView <CPTPlotDataSource>
{
@private
    NSMutableArray *plotData;
    NSUInteger currentIndex;
    NSTimer *dataTimer;
    NSMutableArray *graphs;
    CPTGraph *graph;
    CGRect thisFrame;
    CPTGraphHostingView *hostView;
}

@property (nonatomic, retain) CPTGraph *graph;
@property (nonatomic, assign) CGRect thisFrame;
@property (nonatomic, retain) CPTGraphHostingView *hostView;

-(void)newData:(NSTimer *)theTimer;
-(void)initPlot;

@end


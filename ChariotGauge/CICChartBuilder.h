//
//  CICChartBuilder.h
//  ChariotGauge
//
//  Created by Mike on 8/19/14.
//  Copyright (c) 2014 Chariot Instruments. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface CICChartBuilder : UIView <CPTPlotDataSource>{
    CGRect thisFrame;
    NSString *plotIdentifier;
    CPTGraph *graph;
    
}

@property (nonatomic, strong) CPTGraphHostingView *hostView;
@property (nonatomic, assign) CGRect thisFrame;
@property (nonatomic, retain) NSString *plotIdentifier;
@property (nonatomic, retain) CPTGraph *graph;

- (int)generateRand:(int)minNum withMaxNum:(int)maxNum;
- (void)initPlot;
- (void)configureHost;
- (void)configureGraph;

@end

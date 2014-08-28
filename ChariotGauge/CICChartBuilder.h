//
//  CICChartBuilder.h
//  ChariotGauge
//
//  Created by Mike on 8/19/14.
//  Copyright (c) 2014 Chariot Instruments. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface CICChartBuilder : UIView{
    CGRect thisFrame;
    
}

@property (nonatomic, strong) CPTGraphHostingView *hostView;
@property (nonatomic, assign) CGRect thisFrame;

- (int)generateRand:(int)minNum withMaxNum:(int)maxNum;
- (void)initPlot;
- (void)configureHost;
- (void)configureGraph;

@end

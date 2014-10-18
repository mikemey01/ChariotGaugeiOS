//
//  CICPlotBuilder.h
//  ChariotGauge
//
//  Created by Mike on 9/6/14.
//  Copyright (c) 2014 Chariot Instruments. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface CICPlotBuilder : NSObject <CPTPlotSpaceDelegate, CPTPlotDataSource, CPTScatterPlotDelegate>{
    NSMutableArray *plotData;
    NSUInteger currentIndex;
    NSString *plotIdentifier;
    CPTScatterPlot *scatterPlot;
    CGFloat plotYMax;
    CGFloat plotYMin;
    
}

@property (nonatomic, retain) NSMutableArray *plotData;
@property (nonatomic, retain) NSString *plotIdentifier;
@property (nonatomic, assign) CGFloat plotYMax;
@property (nonatomic, assign) CGFloat plotYMin;
@property (nonatomic, assign) NSUInteger currentIndex;

-(CPTScatterPlot *)createPlot:(NSString *) plotIdentifierIn withColor:(CPTColor *) colorIn;
-(NSString *)getPlotIdentifier:(CPTScatterPlot *)plotIn;
-(void)addNewDataToPlot:(CGFloat)newData;

@end

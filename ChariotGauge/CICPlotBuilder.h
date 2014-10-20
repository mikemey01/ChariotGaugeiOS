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

@protocol CICSelectedPointDelegate <NSObject>
@required
-(void)getTouchedPointValue:(CGFloat)selectedValue withPlotIdentifier:(NSString *)plotIdentifier;
@end

@interface CICPlotBuilder : NSObject <CPTPlotSpaceDelegate, CPTPlotDataSource, CPTScatterPlotDelegate>{
    NSMutableArray *plotData;
    NSUInteger currentIndex;
    NSString *plotIdentifier;
    CPTScatterPlot *scatterPlot;
    CGFloat plotYMax;
    CGFloat plotYMin;
    
    id <CICSelectedPointDelegate> selectedDelegate;
    
}

@property (nonatomic, retain) NSMutableArray *plotData;
@property (nonatomic, retain) NSString *plotIdentifier;
@property (nonatomic, assign) CGFloat plotYMax;
@property (nonatomic, assign) CGFloat plotYMin;
@property (nonatomic, assign) NSUInteger currentIndex;
@property (nonatomic, retain) id selectedDelegate;

-(CPTScatterPlot *)createPlot:(NSString *) plotIdentifierIn withColor:(CPTColor *) colorIn;
-(NSString *)getPlotIdentifierAsString;
-(void)addNewDataToPlot:(CGFloat)newData;

@end

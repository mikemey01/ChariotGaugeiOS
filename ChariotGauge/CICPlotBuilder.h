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

@interface CICPlotBuilder : NSObject <CPTPlotDataSource>{
    NSMutableArray *plotData;
    NSUInteger currentIndex;
    NSString *plotIdentifier;
    CPTScatterPlot *scatterPlot;
}

@property (nonatomic, retain) NSMutableArray *plotData;
@property (nonatomic, retain) NSString *plotIdentifier;

-(CPTScatterPlot *)createPlot:(NSString *) plotIdentifierIn withColor:(CPTColor *) colorIn;
-(NSString *)getPlotIdentifier:(CPTScatterPlot *)plotIn;

@end

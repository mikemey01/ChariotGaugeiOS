//
//  CICPlotBuilder.m
//  ChariotGauge
//
//  Created by Mike on 9/6/14.
//  Copyright (c) 2014 Chariot Instruments. All rights reserved.
//

#import "CICPlotBuilder.h"

@implementation CICPlotBuilder

@synthesize plotData, plotIdentifier;

-(CPTScatterPlot *)createPlot:(NSString *)plotIdentifierIn withColor:(CPTColor *) colorIn
{
    // Create the plot
    scatterPlot = [[CPTScatterPlot alloc] init];
    scatterPlot.identifier     = plotIdentifierIn;
    scatterPlot.cachePrecision = CPTPlotCachePrecisionDouble;

    CPTMutableLineStyle *lineStyle = [scatterPlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth              = 2.0;
    lineStyle.lineColor              = colorIn;
    scatterPlot.dataLineStyle = lineStyle;

    scatterPlot.dataSource = self;
    
    return scatterPlot;
}

-(NSString *)getPlotIdentifier:(CPTScatterPlot *)plotIn
{
    return (NSString *)scatterPlot.identifier;
}


#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return [plotData count];
}

-(id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSNumber *num = nil;
    
    switch ( fieldEnum ) {
        case CPTScatterPlotFieldX:
            num = @(index + currentIndex - plotData.count);
            break;
            
        case CPTScatterPlotFieldY:
            num = plotData[index];
            break;
            
        default:
            break;
    }
    
    return num;
}

@end

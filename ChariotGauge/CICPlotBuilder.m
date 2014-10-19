//
//  CICPlotBuilder.m
//  ChariotGauge
//
//  Created by Mike on 9/6/14.
//  Copyright (c) 2014 Chariot Instruments. All rights reserved.
//

#import "CICPlotBuilder.h"

static const NSUInteger kMaxDataPoints = 520;

@implementation CICPlotBuilder

@synthesize plotData, plotIdentifier, plotYMax, plotYMin, currentIndex;


-(CPTScatterPlot *)createPlot:(NSString *)plotIdentifierIn withColor:(CPTColor *) colorIn
{
    //Setup variables
    currentIndex = 0;
    plotYMin = 0.0f;
    plotYMax = 0.0f;
    plotData  = [[NSMutableArray alloc] initWithCapacity:kMaxDataPoints];
    [plotData removeAllObjects];
    
    
    // Create the plot
    scatterPlot = [[CPTScatterPlot alloc] init];
    scatterPlot.identifier     = plotIdentifierIn;
    scatterPlot.cachePrecision = CPTPlotCachePrecisionDouble;

    CPTMutableLineStyle *lineStyle = [scatterPlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth              = 1.0;
    lineStyle.lineColor              = colorIn;
    scatterPlot.dataLineStyle = lineStyle;
    
    CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    plotSymbol.fill      = [CPTFill fillWithColor:colorIn];
    plotSymbol.lineStyle = lineStyle;
    plotSymbol.size      = CGSizeMake(2.0, 2.0);
    scatterPlot.plotSymbol  = plotSymbol;

    scatterPlot.dataSource = self;
    scatterPlot.delegate = self;
    
    scatterPlot.plotSymbolMarginForHitDetection = 2.0f;
    
    return scatterPlot;
}

-(void)addNewDataToPlot:(CGFloat)newData
{
    if ( plotData.count >= kMaxDataPoints ) {
        [plotData removeObjectAtIndex:0];
        [scatterPlot deleteDataInIndexRange:NSMakeRange(0, 1)];
    }
    
    //Set the max/min values for resizing the chart.
    if(newData > plotYMax){
        plotYMax = newData;
    }
    if(newData < plotYMin){
        plotYMin = newData;
    }
    
    currentIndex++;
    [plotData addObject:@(newData)];
    [scatterPlot insertDataAtIndex:plotData.count - 1 numberOfRecords:1];
}


-(NSString *)getPlotIdentifier:(CPTScatterPlot *)plotIn
{
    return (NSString *)scatterPlot.identifier;
}

-(void)scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)index
{
    NSLog(@"plotSymbolWasSelectedAtRecordIndex %lu", (unsigned long)index);
    NSNumber *y = [plotData objectAtIndex:index];
    
    NSLog(@"point y: %f", y.floatValue);
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

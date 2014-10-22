//
//  CICPlotBuilder.m
//  ChariotGauge
//
//  Created by Mike on 9/6/14.
//  Copyright (c) 2014 Chariot Instruments. All rights reserved.
//

#import "CICPlotBuilder.h"

//Saves enough data for 45 minutes. 20 updates/sec = 1200/minute, 1200*45 = 54,000
static const NSUInteger kMaxDataPoints = 54000;

@implementation CICPlotBuilder

@synthesize plotData, plotIdentifier, plotYMax, plotYMin, currentIndex, selectedDelegate;


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
    
    CPTMutableLineStyle *symbolLineStyle = [scatterPlot.dataLineStyle mutableCopy];
    symbolLineStyle.lineWidth = 0.25;
    symbolLineStyle.lineColor = colorIn;
    
    
    CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    plotSymbol.fill      = [CPTFill fillWithColor:colorIn];
    plotSymbol.lineStyle = lineStyle;
    plotSymbol.size      = CGSizeMake(3.0, 3.0);
    scatterPlot.plotSymbol  = plotSymbol;

    //This is only side-to-side, should really be top and bottom too.
    scatterPlot.plotSymbolMarginForHitDetection = 5.0;
    
    scatterPlot.dataSource = self;
    scatterPlot.delegate = self;
    
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


-(NSString *)getPlotIdentifierAsString
{
    return (NSString *)scatterPlot.identifier;
}

//used to return the value of a point that is touched.
-(void)scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)index
{
    NSNumber *y = [plotData objectAtIndex:index];
    
    //Push the value to the viewcontroller.
    [self.selectedDelegate getTouchedPointValue:y.floatValue withPlotIdentifier:(NSString *)plot.identifier];
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

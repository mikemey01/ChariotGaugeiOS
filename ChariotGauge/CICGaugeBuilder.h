//
//  CICGaugeBuilder.h
//  ChariotGauge
//
//  Created by Mike on 11/29/13.
//  Copyright (c) 2013 Chariot Instruments. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CICGaugeBuilder : UIView{
    CGFloat lineWidth; //width of the circles
    int tickLineLength; //Tick lengths.
    
    
    
    //Min number on the gauge
    int minGaugeNumber;
    
    //Max number on the gauge
    int maxGaugeNumber;
    
    //Gauge range based on min/max numbers
    int gaugeRange;
    
    //Increment per large tick
    int incrementPerLargeTick;
    
    //text label for gauge type
    NSString *gaugeLabel;
    
    //gauge curvature type (1 = 180, 2 = 270, 3 = 315).
    int gaugeType;
    
    //angle to start drawing ticks, east = 0.
    float tickStartAngleDegrees;
    
    //distance in degrees to travel around arc.
    float tickDistance;
    
    
    
    struct angleRanges{
        float startRange;
        float endRange;
    } angle_Range;
}

@property (nonatomic, assign) int minGaugeNumber;
@property (nonatomic, assign) int maxGaugeNumber;
@property (nonatomic, assign) int incrementPerLargeTick;
@property (nonatomic, retain) NSString *gaugeLabel;
@property (nonatomic, assign) int gaugeType;
@property (nonatomic, assign) float tickStartAngleDegrees;
@property (nonatomic, assign) float tickDistance;


-(void)drawOuterRim:(CGContextRef)context;
-(CGRect)drawInnerRim:(CGContextRef)context;
-(void)drawRect:(CGRect)rect;
-(void)fillGradient:(CGRect)rect withContext:(CGContextRef)context;

-(void)drawTickArc:(CGContextRef)context;
-(void)initializeGauge;
-(void)drawInnerShadow:(CGContextRef)context withFrame:(CGRect)rect;
-(void)drawTicksOnArc:(CGContextRef)context;

@end
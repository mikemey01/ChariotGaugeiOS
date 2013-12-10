//
//  CICGaugeBuilder.h
//  ChariotGauge
//
//  Created by Mike on 11/29/13.
//  Copyright (c) 2013 Chariot Instruments. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface NeedleBuilder : NSObject {
    
    //Needle Length
    float needleLength;
    
    //Needle Width
    float needleWidth;
    
    //Needle tint
    UIColor *needleColor;
}

//Needle props
@property (nonatomic, assign) float needleLength;
@property (nonatomic, assign) float needleWidth;
@property (nonatomic, retain) UIColor *needleColor;

- (void)drawLayer:(CALayer*)layer inContext:(CGContextRef)ctx;

@end

@interface CICGaugeBuilder : UIView{
    CGFloat lineWidth; //width of the circles
    int tickLineLength; //Tick lengths.
    
        /*gauge stuff*/
    
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
    
    //TODO: update
    UIFont *menuItemsFont;
    
    
        /*Needle stuff*/
    
    //Needle value
    float value;
    
    //Needle layer
    CALayer *needleLayer;
    
    //Needle object
    NeedleBuilder *needleBuilder_;
    
    
    struct angleRanges{
        float startRange;
        float endRange;
    } angle_Range;
}

//gauge props
@property (nonatomic, assign) int minGaugeNumber;
@property (nonatomic, assign) int maxGaugeNumber;
@property (nonatomic, assign) int incrementPerLargeTick;
@property (nonatomic, retain) NSString *gaugeLabel;
@property (nonatomic, assign) int gaugeType;
@property (nonatomic, assign) float tickStartAngleDegrees;
@property (nonatomic, assign) float tickDistance;
@property (nonatomic, retain) UIFont *menuItemsFont;
@property (nonatomic, readonly) NeedleBuilder *needleBuilder;
@property (nonatomic, assign) float value;


//gauge functions
-(void)drawOuterRim:(CGContextRef)context;
-(CGRect)drawInnerRim:(CGContextRef)context;
-(void)drawRect:(CGRect)rect;
-(void)fillGradient:(CGRect)rect withContext:(CGContextRef)context;
-(void)drawTickArc:(CGContextRef)context;
-(void)initializeGauge;
-(void)drawInnerShadow:(CGContextRef)context withFrame:(CGRect)rect;
-(void)drawTicksOnArc:(CGContextRef)context;
-(void)drawStringAtContext:(CGContextRef) context string:(NSString*) text atAngle:(float) angle withRadius:(float) radius;
-(void)drawCurvedText:(NSString *)text atAngle:(float)angle withContext:(CGContextRef)context;

//needle functions
-(void)setValue:(float)val;
@end
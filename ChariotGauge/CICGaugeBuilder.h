//
//  CICGaugeBuilder.h
//  ChariotGauge
//
//  Created by Mike on 11/29/13.
//  Copyright (c) 2013 Chariot Instruments. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface NeedleBuilder : NSObject{
    
    //Needle Length
    float needleLength;
    
    //Needle Width
    float needleWidth;
    
    //Needle tint
    UIColor *needleColor;
    
    //Offset for smaller gauges
    float gaugeWidth;
    float viewWidth;
    float gaugeX;
}

//Needle props
@property (nonatomic, assign) float needleLength;
@property (nonatomic, assign) float needleWidth;
@property (nonatomic, retain) UIColor *needleColor;
@property (nonatomic, assign) float gaugeX;
@property (nonatomic, assign) float gaugeWidth;
@property (nonatomic, assign) float viewWidth;

- (void)drawLayer:(CALayer*)layer inContext:(CGContextRef)ctx;

@end


@interface DigitalBuilder : NSObject{
    NSString *digitalValue;
    float gaugeWidth;
    float viewWidth;
    float gaugeX;
    UIFont *digitalFont;
}

@property (nonatomic, retain) NSString *digitalValue;
@property (nonatomic, assign) float gaugeWidth;
@property (nonatomic, assign) float viewWidth;
@property (nonatomic, assign) float gaugeX;
@property (nonatomic, retain) UIFont *digitalFont;

- (void)drawLayer:(CALayer*)layer inContext:(CGContextRef)context;

@end



@interface CICGaugeBuilder : UIView{
    CGFloat lineWidth; //width of the circles
    int tickLineLength; //Tick lengths.
    
        /*gauge stuff*/
    
    //Min number on the gauge
    float minGaugeNumber;
    
    //Max number on the gauge
    float maxGaugeNumber;
    
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
    
    //gauge and view width for placement of the gauge on the view.
    float gaugeWidth;
    float viewWidth;
    float gaugeX;
    float gaugeY;
    
    //TODO: update
    UIFont *menuItemsFont;
    UIFont *gaugeLabelFont;
    
        /*Needle stuff*/
    
    //Needle value
    float value;
    
    //Needle layer
    CALayer *needleLayer;
    
    //Needle object
    NeedleBuilder *needleBuilder_;
    
        /*digital stuff*/
    
    //gauge value for digital (as string)
    NSString *digitalGaugeValue;
    
    DigitalBuilder *digitalBuilder_;
    CATextLayer *digitalLayer;
    
    
    struct angleRanges{
        float startRange;
        float endRange;
    } angle_Range;
}

//gauge props
@property (nonatomic, assign) float minGaugeNumber;
@property (nonatomic, assign) float maxGaugeNumber;
@property (nonatomic, assign) int incrementPerLargeTick;
@property (nonatomic, retain) NSString *gaugeLabel;
@property (nonatomic, assign) int gaugeType;
@property (nonatomic, assign) float tickStartAngleDegrees;
@property (nonatomic, assign) float tickDistance;
@property (nonatomic, retain) UIFont *menuItemsFont;
@property (nonatomic, retain) UIFont *gaugeLabelFont;
@property (nonatomic, readonly) NeedleBuilder *needleBuilder;
@property (nonatomic, assign) float value;
@property (nonatomic, retain) CALayer *needleLayer;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, retain) NSString *digitalGaugeValue;
@property (nonatomic, readonly) DigitalBuilder *digitalBuilder;
@property (nonatomic, retain) CATextLayer *digitalLayer;
@property (nonatomic, assign) float gaugeWidth;
@property (nonatomic, assign) float viewWidth;
@property (nonatomic, assign) float gaugeX;
@property (nonatomic, assign) float gaugeY;


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
-(void)drawCurvedText:(NSString *)text atAngle:(float)angle withContext:(CGContextRef)context forTickArc:(BOOL)isForTickArc;
-(void)drawGaugeText:(NSString*) text;

//needle functions
-(void)setValue:(CGFloat)val;

@end
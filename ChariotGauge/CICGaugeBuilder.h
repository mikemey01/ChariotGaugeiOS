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
    
    //Needle extension for various gauge/screen sizes
    CGFloat needleExtension;
    
    //Needle Width
    float needleWidth;
    
    //Needle tint
    UIColor *needleColor;
    
    //Offset for smaller gauges
    float gaugeWidth;
    float viewWidth;
    float gaugeX;
    
    CGFloat needleScaler;
}

//Needle props
@property (nonatomic, assign) float needleLength;
@property (nonatomic, assign) float needleWidth;
@property (nonatomic, retain) UIColor *needleColor;
@property (nonatomic, assign) float gaugeX;
@property (nonatomic, assign) float gaugeWidth;
@property (nonatomic, assign) float viewWidth;
@property (nonatomic, assign) CGFloat needleExtension;
@property (nonatomic, assign) CGFloat needleScaler;

- (void)drawLayer:(CALayer*)layer inContext:(CGContextRef)ctx;

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
    UIFont *gaugeLabelFont;
    CGFloat gaugeLabelHeight;
    
    //gauge curvature type (1 = 180, 2 = 270, 3 = 315).
    int gaugeType;
    
    //angle to start drawing ticks, east = 0.
    float tickStartAngleDegrees;
    
    //distance in degrees to travel around arc.
    float tickDistance;
    
    //Radius of tick arc adjustable for different gauge sizes
    CGFloat tickArcRadius;
    
    //gauge and view width for placement of the gauge on the view.
    float gaugeWidth;
    float viewWidth;
    float gaugeX;
    float gaugeY;
    
    //TODO: update
    UIFont *menuItemsFont;
    
    //Scaler variables for sizing.
    CGFloat kerningScaler;
    CGFloat gaugeRingScaler;
    
        /*Needle stuff*/
    
    //Needle value
    CGFloat value;
    
    //Needle layer
    CALayer *needleLayer;
    
    //Needle object
    NeedleBuilder *needleBuilder_;
    
        /*digital stuff*/
    
    UILabel *digitalLabel;
    CGFloat digitalFontSize;
    
    //Allow negative numbers or not (boost/vac = not)
    BOOL allowNegatives;
    
    
    struct angleRanges{
        float startRange;
        float endRange;
    } angle_Range;
}

//gauge props
@property (nonatomic, assign) float minGaugeNumber;
@property (nonatomic, assign) float maxGaugeNumber;
@property (nonatomic, assign) int incrementPerLargeTick;
@property (nonatomic, assign) int gaugeType;
@property (nonatomic, assign) float tickStartAngleDegrees;
@property (nonatomic, assign) float tickDistance;
@property (nonatomic, retain) UIFont *menuItemsFont;
@property (nonatomic, readonly) NeedleBuilder *needleBuilder;
@property (nonatomic, assign) CGFloat value;
@property (nonatomic, retain) CALayer *needleLayer;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign) float gaugeWidth;
@property (nonatomic, assign) float viewWidth;
@property (nonatomic, assign) CGFloat tickArcRadius;
@property (nonatomic, assign) float gaugeX;
@property (nonatomic, assign) float gaugeY;
@property (nonatomic, assign) CGFloat kerningScaler;
@property (nonatomic, retain) UILabel *digitalLabel;
@property (nonatomic, assign) CGFloat digitalFontSize;
@property (nonatomic, retain) NSString *gaugeLabel;
@property (nonatomic, assign) CGFloat gaugeLabelHeight;
@property (nonatomic, retain) UIFont *gaugeLabelFont;
@property (nonatomic, assign) BOOL allowNegatives;
@property (nonatomic, assign) CGFloat gaugeRingScaler;


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

//TEST AREA//

- (void)drawDigitalLabel:(CGContextRef)context;

//test area//

//needle functions
-(void)setValue:(CGFloat)val;

@end
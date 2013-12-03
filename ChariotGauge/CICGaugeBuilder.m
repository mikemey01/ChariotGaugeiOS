//
//  CICGaugeBuilder.m
//  ChariotGauge
//
//  Created by Mike on 11/29/13.
//  Copyright (c) 2013 Chariot Instruments. All rights reserved.
//

#import "CICGaugeBuilder.h"
#import "math.h"
#import <QuartzCore/QuartzCore.h>

#define   DEGREES_TO_RADIANS(degrees)  ((M_PI * degrees)/ 180)
#define   DIAMETER  self.frame.size.width // TODO: needs work
#define   TICK_ARC_RADIUS (DIAMETER/2) - 50

@implementation CICGaugeBuilder

@synthesize minGaugeNumber, maxGaugeNumber, gaugeLabel, incrementPerLargeTick, gaugeType;
@synthesize tickStartAngleDegrees, tickDistance;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGRect innerFrame;
    
    [self initializeGauge];
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self drawOuterRim:(context)];
    
    innerFrame = [self drawInnerRim:(context)];
    
    [self drawInnerShadow:(context) withFrame:innerFrame];
    
    [self drawTickArc:(context)];
    
    [self drawTicksOnArc:(context)];
    
}

- (void)drawTicksOnArc:(CGContextRef)context
{
    gaugeRange = maxGaugeNumber - minGaugeNumber;
    int angleRange = 0;
    
    while(angleRange <= gaugeRange){
        
        //Setup the lenth of the tick depending on if it's a major or minor tick.
        if(angleRange % incrementPerLargeTick == 0){
            self->tickLineLength = 10; //Major tick
        }else{
            self->tickLineLength = 5; //Minor tick
        }
        
        //setup the range for this tick.
        angle_Range.startRange = 0; //This sets up where the angle begins. must be used in conjunction with the end range!
        angle_Range.endRange   = tickStartAngleDegrees+(tickDistance * angleRange)/gaugeRange; //0 degress is East. xxx+(yyy.f * angleRange)/gaugeRange.
                                                                                               //x = degrees clock wise to start. yyy = how far to go.
        
        double actualLineAngle = angle_Range.endRange - angle_Range.startRange;
        float startAngle = actualLineAngle - 0.25; //Width of the ticks
        float endAngle = actualLineAngle + 0.25; //width of the ticks.
        
        startAngle =  DEGREES_TO_RADIANS(startAngle);
        endAngle = DEGREES_TO_RADIANS(endAngle);
        UIBezierPath *aPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(DIAMETER/2, DIAMETER/2-20)
                                                             radius:(TICK_ARC_RADIUS+tickLineLength/2) //Sets the radius based on the tick length;
                                                         startAngle:startAngle
                                                           endAngle:endAngle
                                                          clockwise:YES];

        
        //Draw the ticks.
        CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
        [shapeLayer setFrame: self.frame];
        [shapeLayer setPath: [aPath CGPath]];
        shapeLayer.lineWidth = tickLineLength; //sets the tick length;
        [shapeLayer setStrokeColor:[[UIColor grayColor] CGColor]];
        [shapeLayer setFillColor:[[UIColor clearColor] CGColor]];
        [shapeLayer setMasksToBounds:YES];
        [self.layer addSublayer:shapeLayer];
        [aPath closePath];
        
        //Increments based on the assumption there are 4 minor ticks plus one major. each increment is set in a property.
        angleRange = angleRange + incrementPerLargeTick/5; //Loop through each degree, set a major or minor tick.
    }
}

- (void)drawOuterRim:(CGContextRef)context
{
    CGRect borderRect = CGRectMake(0.5, 0.5, DIAMETER-1.0, DIAMETER-1.0);
    borderRect = CGRectInset(borderRect, lineWidth * 0.75, lineWidth * 0.75);
    
    CGContextSetRGBStrokeColor(context, 110.0/255.0, 110.0/255.0, 110.0/255.0, 1.0);
    CGContextSetLineWidth(context, 0.75);
    CGContextStrokeEllipseInRect(context, borderRect);
    
    [self fillGradient:borderRect withContext:context];
}

- (CGRect)drawInnerRim:(CGContextRef)context
{
    CGRect innerRect = CGRectMake(7.5, 7.5, DIAMETER-15, DIAMETER-15);
    innerRect = CGRectInset(innerRect, lineWidth * 0.75, lineWidth * 0.75);
    CGContextSetRGBStrokeColor(context, 110.0/255.0, 110.0/255.0, 110.0/255.0, 1.0);
    CGContextSetRGBFillColor(context, 250.0/255.0, 250.0/255.0, 242.0/255.0, 1.0);
    CGContextSetLineWidth(context, 0.75);
    CGContextFillEllipseInRect (context, innerRect);
    CGContextStrokeEllipseInRect(context, innerRect);
    CGContextFillPath(context);
    
    return innerRect;
}

-(void)drawInnerShadow:(CGContextRef)context withFrame:(CGRect)rect;
{
    //// Shadow Declarations
    UIColor* shadow = [UIColor blackColor];
    CGSize shadowOffset = CGSizeMake(1, 1);
    CGFloat shadowBlurRadius = 8;
    
    //// Frames
    CGRect frame = rect;
    
    
    //Create the CGRect and set its location
    CGRect shadowBoxRect = CGRectMake(7.5, 7.5, DIAMETER-15, DIAMETER-15);
    
    //Create the bezier path using the CGRect as a ref.
    UIBezierPath* bPath = [UIBezierPath bezierPathWithOvalInRect: shadowBoxRect];
    
    
    CGRect shadowBoxBorderRect = CGRectInset(frame, -shadowBlurRadius, -shadowBlurRadius);
    
    
    UIBezierPath* shadowBoxNegativePath = [UIBezierPath bezierPathWithRect: shadowBoxBorderRect];
    [shadowBoxNegativePath appendPath: bPath];
    shadowBoxNegativePath.usesEvenOddFillRule = YES;
    
    CGContextSaveGState(context);
    {
        CGFloat xOffset = shadowOffset.width + round(shadowBoxBorderRect.size.width);
        CGFloat yOffset = shadowOffset.height;
        CGContextSetShadowWithColor(context,
                                    CGSizeMake(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset)),
                                    shadowBlurRadius,
                                    shadow.CGColor);
        
        [bPath addClip];
        CGAffineTransform transform = CGAffineTransformMakeTranslation(-round(shadowBoxBorderRect.size.width), 0);
        [shadowBoxNegativePath applyTransform: transform];
        [[UIColor grayColor] setFill];
        [shadowBoxNegativePath fill];
        [shadowBoxNegativePath closePath];
    }
    
    CGContextRestoreGState(context);
}


- (void)drawTickArc:(CGContextRef)context
{
    [[UIColor grayColor] setStroke];
    [[UIColor redColor] setFill]; //unused for now.
    
    //controls the look of the arc NOT placement.
    UIBezierPath *aPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(0, 0)
                                                         radius:TICK_ARC_RADIUS //Controls the size of the tick arc
                                                     startAngle:0
                                                       endAngle:DEGREES_TO_RADIANS(360)
                                                      clockwise:YES];
    
    // If you have content to draw after the shape,
    // save the current state before changing the transform.
    CGContextSaveGState(context);
    
    aPath.lineWidth = lineWidth;
    
    //controls the placement of the arc.
    CGContextTranslateCTM(context, DIAMETER/2, DIAMETER/2);
    
    //draws the arc.
    [aPath stroke];
    
    // Restore the graphics state before drawing any other content.
    CGContextRestoreGState(context);
    [aPath closePath];
    
}

- (void)fillGradient:(CGRect)rect withContext:(CGContextRef)context
{
    // Create a gradient from white to red
    CGFloat colors [] = {
        0.90, 0.90, 0.90, 1.0,
        0.30, 0.30, 0.35, 1.0
    };
    
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;
    
    CGContextSaveGState(context);
    CGContextAddEllipseInRect(context, rect);
    CGContextClip(context);
    
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient), gradient = NULL;
    
    CGContextRestoreGState(context);
    
    CGContextAddEllipseInRect(context, rect);
    CGContextDrawPath(context, kCGPathStroke);
}

- (void)initializeGauge
{
    lineWidth = 1;
    self.minGaugeNumber = 0;
    self.maxGaugeNumber = 100;
    self.gaugeType = 2;
    self.gaugeLabel = @"Boost/Vac";
    self.incrementPerLargeTick = 10;
    self.tickStartAngleDegrees = 135;
    self.tickDistance = 270;
    
}

@end

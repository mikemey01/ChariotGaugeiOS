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
#define   DIAMETER  self.frame.size.width//fmin(self.frame.size.width, self.frame.size.height)

#define RADIUS (DIAMETER/2) - 50
#define METER_END_LIMIT 50.f
#define CIRCLE_STROKE_PATH_WIDTH 39.f

@implementation CICGaugeBuilder

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
    
    [self drawTickArc:(context)];
    
    [self drawInnerShadow:(context) withFrame:innerFrame];
    
    [self drawTicksOnArc:(context)];
    
}

- (void)drawTicksOnArc:(CGContextRef)context
{
    NSInteger numberOfParts = METER_END_LIMIT;
    int angleRange = 0;
    
    for(int loopIndex = 0; loopIndex <= numberOfParts; loopIndex++){
        
        //Setup the lenth of the tick depending on if it's a major or minor tick.
        //TODO: set the "% 5" to be the major tick increment
        if(angleRange % 5 == 0){
            self->tickLineLength = 10; //Major tick
        }else{
            self->tickLineLength = 5; //Minor tick
        }
        
        //setup the range.
        //TODO: needs to be configurable
        angle_Range.startRange = -45; //This sets up where the angle begins. must be used in conjunction with the end range!
        angle_Range.endRange   = 360 - (270.f * angleRange)/METER_END_LIMIT; //Adjust the 360 - (xxx.f) to change the total degree range.
        
        double actualLineAngle = angle_Range.endRange - angle_Range.startRange;
        float startAngle = actualLineAngle - 0.25; //Width of the ticks
        float endAngle = actualLineAngle + 0.25; //widht of the ticks.
        
        startAngle =  DEGREES_TO_RADIANS(startAngle);
        endAngle = DEGREES_TO_RADIANS(endAngle);
        UIBezierPath *aPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(DIAMETER/2, DIAMETER/2-20)
                                                             radius:(RADIUS+tickLineLength/2) //Sets the radius based on the tick length;
                                                         startAngle:startAngle
                                                           endAngle:endAngle
                                                          clockwise:YES];

        
        CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
        [shapeLayer setFrame: self.frame];
        [shapeLayer setPath: [aPath CGPath]];
        shapeLayer.lineWidth = tickLineLength; //sets the tick length;
        [shapeLayer setStrokeColor:[[UIColor grayColor] CGColor]];
        [shapeLayer setFillColor:[[UIColor clearColor] CGColor]];
        [shapeLayer setMasksToBounds:YES];
        [self.layer addSublayer:shapeLayer];
        [aPath closePath];
        
        //TODO: Set the "+1.0f" to instead be what the minor tick increment is.
        angleRange = angleRange + 1.0f; //Loop through each degree, set a major or minor tick.
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
                                                         radius:DIAMETER/2 - 50 //Controls the size of the tick arc
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
}

@end

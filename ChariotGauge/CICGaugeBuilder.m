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
#define   DIAMETER  fmin(self.frame.size.width, self.frame.size.height)

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
    }
    
    CGContextRestoreGState(context);
}


- (void)drawTickArc:(CGContextRef)context
{
    [[UIColor blackColor] setStroke];
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

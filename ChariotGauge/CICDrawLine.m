//
//  CICDrawLine.m
//  ChariotGauge
//
//  Created by Mike on 12/28/13.
//  Copyright (c) 2013 Chariot Instruments. All rights reserved.
//

#import "CICDrawLine.h"

#define   DIAMETER  self.frame.size.width

@implementation CICDrawLine

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
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat colors[16] = { 0,0, 0, 0,
        0, 0, 0, .5,
        0, 0, 0, .5,
        0, 0,0 ,0 };
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 4);
    
    CGContextSaveGState(context);
    CGContextAddRect(context, CGRectMake(CGRectGetMinX(rect),CGRectGetMinY(rect), rect.size.width, 1));
    CGContextClip(context);
    CGContextDrawLinearGradient (context, gradient, CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect)), CGPointMake(CGRectGetMaxX(rect),CGRectGetMaxY(rect)), 0);
    CGContextRestoreGState(context);
    
}


@end

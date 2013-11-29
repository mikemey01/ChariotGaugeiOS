//
//  CICGaugeBuilder.h
//  ChariotGauge
//
//  Created by Mike on 11/29/13.
//  Copyright (c) 2013 Chariot Instruments. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CICGaugeBuilder : UIView{
    CGFloat lineWidth;
}

-(void)drawOuterRim:(CGContextRef)context;
-(CGRect)drawInnerRim:(CGContextRef)context;
-(void)drawRect:(CGRect)rect;
-(void)fillGradient:(CGRect)rect withContext:(CGContextRef)context;

-(void)drawTickArc:(CGContextRef)context;
-(void)initializeGauge;
-(void)drawInnerShadow:(CGContextRef)context withFrame:(CGRect)rect;

@end
//
//  CICGaugeBuilder.m
//  ChariotGauge
//
//  Created by Mike Meyer on 11/29/13.
//  Copyright (c) 2013 Chariot Instruments. All rights reserved.
//

#import "CICGaugeBuilder.h"
#import "math.h"
#import <QuartzCore/QuartzCore.h>

#define   DEGREES_TO_RADIANS(degrees)  ((M_PI * degrees)/ 180)
#define   DIAMETER  self.frame.size.width // TODO: needs work
#define   DIAMETER_HEIGHT self.frame.size.height
#define   DIAMETER_LAYER layer.frame.size.width //TODO: needs work
#define   TICK_ARC_RADIUS (DIAMETER/2) - 50

@implementation NeedleBuilder

//synthesize needle props
@synthesize needleLength, needleWidth, needleColor;


- (void)drawLayer:(CALayer*)layer inContext:(CGContextRef)context
{
	CGContextSaveGState(context);
    
    /* draw needle circle */
    
    //draw shadow on circle
    CGContextSetShadow(context, CGSizeMake(2.0f, 2.0f), 2.0f);
    
	CATransform3D transform = layer.transform;
	layer.transform = CATransform3DIdentity;
	
    //Setup needle circle options
	CGContextSetFillColorWithColor(context, self.needleColor.CGColor);
	CGContextSetStrokeColorWithColor(context, self.needleColor.CGColor);
	CGContextSetLineWidth(context, self.needleWidth);
    CGFloat ellipseRadius = floor(self.needleWidth * 2.5);
	
    //Get center coordinates
	CGFloat centerX = layer.frame.size.width / 2.0;
	CGFloat centerY = layer.frame.size.height / 2.0;
	
    //Fill the needle circle
	CGContextFillEllipseInRect(context, CGRectMake(centerX - ellipseRadius, centerY - ellipseRadius, ellipseRadius * 2.0, ellipseRadius * 2.0));
    
    CGContextRestoreGState(context);
    CGContextSaveGState(context);
    
    
    /* draw needle */
    
    
    //draw shadow
    CGContextSetShadow(context, CGSizeMake(2.0f, 2.0f), 2.0f);
    
    //controls the size of the hand.
    CGRect rect = CGRectMake(centerX, centerY, DIAMETER_LAYER/2-48, DIAMETER_LAYER/2-48);
    
    //controls the shape (mirrored)
    CGContextBeginPath(context);
    CGContextMoveToPoint   (context, CGRectGetMinX(rect)+12, CGRectGetMinY(rect)+6);
    CGContextAddLineToPoint(context, CGRectGetMinX(rect)+25, CGRectGetMinY(rect)+12);
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect)+1.5);
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect)-1.5);
    CGContextAddLineToPoint(context, CGRectGetMinX(rect)+25, CGRectGetMinY(rect)-12);
    CGContextAddLineToPoint(context, CGRectGetMinX(rect)+12, CGRectGetMinY(rect)-6);
    CGContextClosePath(context);
    
    //Set the color and fill
    CGContextSetFillColorWithColor(context, [UIColor orangeColor].CGColor);
    CGContextFillPath(context);
    
    CGContextRestoreGState(context);
    CGContextSaveGState(context);
    
    /* draw screw */
    
    CGRect needleScrew = CGRectMake(centerX - ellipseRadius + 10.0, centerY - ellipseRadius + 10.0, ellipseRadius-5.0, ellipseRadius-5.0);
    CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);
    CGContextSetRGBStrokeColor(context, 110.0/255.0, 110.0/255.0, 110.0/255.0, 1.0);
    CGContextFillEllipseInRect(context, needleScrew);
    
    
	layer.transform = transform;
	CGContextRestoreGState(context);
    
    
    
}


@end




@implementation CICGaugeBuilder

//synthesize gauge props
@synthesize minGaugeNumber, maxGaugeNumber, gaugeLabel, incrementPerLargeTick, gaugeType, tickStartAngleDegrees, tickDistance, menuItemsFont, value;
@synthesize needleBuilder = needleBuilder_;
@synthesize lineWidth, needleLayer;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGRect innerFrame;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self drawOuterRim:(context)];
    
    innerFrame = [self drawInnerRim:(context)];
    
    [self drawInnerShadow:(context) withFrame:innerFrame];
    
    [self drawTickArc:(context)];
    
    [self drawTicksOnArc:(context)];
    
    
}

- (void)setValue:(float)val
{
    //Make sure the passed in value is within the bounds of the current gauge.
	if (val > self.maxGaugeNumber)
		val = self.maxGaugeNumber;
	if (val < self.minGaugeNumber)
		val = self.minGaugeNumber;
    
    //Get the range of the current gauge.
    int gaugeRangeLocal = self.maxGaugeNumber - self.minGaugeNumber;
    
    //Calculate the angle value in degrees
    CGFloat angle = self.tickStartAngleDegrees + (self.tickDistance * ((val-self.minGaugeNumber) / gaugeRangeLocal));
    
    //Transform the layer to the correct angle along the z-plane.
	needleLayer.transform = CATransform3DMakeRotation(DEGREES_TO_RADIANS(angle), 0.0f, 0.0f, 1.0f);
    
    [needleLayer setNeedsDisplay];
}

- (void)drawTicksOnArc:(CGContextRef)context
{
    gaugeRange = maxGaugeNumber - minGaugeNumber; //The range of the config numbers
    int angleRange = 0; //should ALWAYS start at 0 - forces the ticks to start at self.tickStartAngleDegrees
    
    while(self.minGaugeNumber <= self.maxGaugeNumber){ //traverse the range of config'd numbers
        
        //Setup the lenth of the tick depending on if it's a major or minor tick.
        if(angleRange % incrementPerLargeTick == 0){
            tickLineLength = 10; //Major tick
        }else{
            tickLineLength = 5; //Minor tick
        }
        
        //setup the range for this tick.
        angle_Range.startRange = 0; //This sets up where the angle begins. must be used in conjunction with the end range!
        angle_Range.endRange   = tickStartAngleDegrees+(tickDistance * angleRange)/gaugeRange; //0 degress is East. xxx+(yyy.f * angleRange)/gaugeRange.
        //x = degrees clock wise to start. y = how far to go
        
        float actualLineAngle = angle_Range.endRange - angle_Range.startRange;
        float startAngle = actualLineAngle - 0.25f; //Width of the ticks
        float endAngle = actualLineAngle + 0.25f; //width of the ticks.
        
        startAngle =  DEGREES_TO_RADIANS(startAngle);
        endAngle = DEGREES_TO_RADIANS(endAngle);
        UIBezierPath *aPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(DIAMETER/2, DIAMETER/2)
                                                             radius:(TICK_ARC_RADIUS+tickLineLength/2) //Sets the radius based on the tick length;
                                                         startAngle:startAngle
                                                           endAngle:endAngle
                                                          clockwise:YES];
        
        //Draw the ticks.
        CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
        [shapeLayer setPath: [aPath CGPath]];
        shapeLayer.lineWidth = tickLineLength; //sets the tick length;
        [shapeLayer setStrokeColor:[[UIColor grayColor] CGColor]];
        [shapeLayer setFillColor:[[UIColor clearColor] CGColor]];
        [shapeLayer setMasksToBounds:NO];
        [self.layer addSublayer:shapeLayer];
        [aPath closePath];
        
        
        //Draw numbers on major ticks
        if(tickLineLength == 10){
            NSString * drawNumber = [NSString stringWithFormat:@"%d",abs(self.minGaugeNumber)]; //cast decimal to string
            [self drawCurvedText:drawNumber atAngle:DEGREES_TO_RADIANS(actualLineAngle) withContext:context]; //draw the number at the major ticks.
        }
        
        //Increments based on the assumption there are 4 minor ticks plus one major. each increment is set in a property.
        angleRange = angleRange + incrementPerLargeTick/5; //Loop through each degree, set a major or minor tick.
        self.minGaugeNumber = self.minGaugeNumber + incrementPerLargeTick/5;
    }
}

- (void) drawCurvedText:(NSString *)text atAngle:(float)angle withContext:(CGContextRef)context
{
    CGPoint centerPoint = CGPointMake(DIAMETER / 2, DIAMETER / 2);
    char* fontName = (char*)[self.menuItemsFont.fontName UTF8String];
    
    CGContextSelectFont(context, fontName, 18, kCGEncodingMacRoman);
    
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, centerPoint.x, centerPoint.y);
    
    [self drawStringAtContext:context string:text atAngle:angle withRadius:TICK_ARC_RADIUS+12];
    
    CGContextRestoreGState(context);
}

- (void) drawStringAtContext:(CGContextRef)context string:(NSString*)text atAngle:(float)angle withRadius:(float)radius
{
    CGSize textSize = [text sizeWithAttributes:@{self.menuItemsFont:[UIFont systemFontOfSize:14.0f]}];
    
    float perimeter = 2 * M_PI * radius;
    float textAngle = textSize.width / perimeter * -2 * M_PI;
    
    angle += (textAngle / 2);
    angle += DEGREES_TO_RADIANS(-.75);
    
    
    for (int index = 0; index < [text length]; index++)
    {
        NSRange range = {index, 1};
        NSString* letter = [text substringWithRange:range];
        char* c = (char*)[letter UTF8String];
        CGSize charSize = [letter sizeWithAttributes:@{self.menuItemsFont:[UIFont systemFontOfSize:14.0f]}];
        charSize.width += 2;
        
        float x = radius * cos(angle);
        float y = radius * sin(angle);
        
        float letterAngle = (charSize.width / perimeter * 2 * M_PI)
        ;
        
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, x, y);
        CGContextRotateCTM(context, (angle + 0.5 * M_PI));
        
        CGContextScaleCTM(context, 1.0, -1.0);
        
        CGContextShowTextAtPoint(context, 0, 0, c, strlen(c));
        CGContextRestoreGState(context);
        
        angle += letterAngle;
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
    [[UIColor darkGrayColor] setFill]; //Controls the color of the numbers.
    
    //controls the look of the arc NOT placement.
    UIBezierPath *aPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(DIAMETER/2, DIAMETER/2)
                                                         radius:TICK_ARC_RADIUS //Controls the size of the tick arc
                                                     startAngle:0
                                                       endAngle:DEGREES_TO_RADIANS(360)
                                                      clockwise:YES];
    
    // If you have content to draw after the shape,
    // save the current state before changing the transform.
    CGContextSaveGState(context);
    
    aPath.lineWidth = lineWidth;
    
    //controls the placement of the arc.
    //CGContextTranslateCTM(context, DIAMETER/2, DIAMETER/2);
    
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
    //Gauge init
    lineWidth = 1;
    self.minGaugeNumber = 0;
    self.maxGaugeNumber = 100;
    self.gaugeType = 2;
    self.gaugeLabel = @"Boost/Vac";
    self.incrementPerLargeTick = 10;
    self.tickStartAngleDegrees = 135;
    self.tickDistance = 270;
    self.menuItemsFont = [UIFont fontWithName:@"Helvetica" size:14];
    
    //needle init
    needleBuilder_ = [[NeedleBuilder alloc] init];
	self.needleBuilder.needleColor = [UIColor orangeColor];
	self.needleBuilder.needleWidth = 6.0;
	self.needleBuilder.needleLength = 0.65;
    
    //needle layer init
	needleLayer = [CALayer layer];
	needleLayer.bounds = self.bounds;
	needleLayer.position = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.width / 2.0);
	needleLayer.needsDisplayOnBoundsChange = YES;
	needleLayer.delegate = self.needleBuilder;
	[self.layer addSublayer:needleLayer];
	[needleLayer setNeedsDisplay];
    
    //initialize the gauge to the lowest value.
    self.value = self.minGaugeNumber;
    
}


@end
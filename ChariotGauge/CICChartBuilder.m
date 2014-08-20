//
//  CICChartBuilder.m
//  ChariotGauge
//
//  Created by Mike on 8/19/14.
//  Copyright (c) 2014 Chariot Instruments. All rights reserved.
//

#import "CICChartBuilder.h"

@implementation CICChartBuilder

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (int)generateRand:(int)minNum withMaxNum:(int)maxNum
{
    int randNum = 0;
    randNum = rand() % (maxNum - minNum) + minNum;
    
    return randNum;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

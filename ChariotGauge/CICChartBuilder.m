//
//  CICChartBuilder.m
//  ChariotGauge
//
//  Created by Mike on 8/18/14.
//  Copyright (c) 2014 Chariot Instruments. All rights reserved.
//

#import "CICChartBuilder.h"

@implementation CICChartBuilder



- (int)generateRand:(int)minNum withMaxNum:(int)maxNum
{
    int randNum = 0;
    randNum = rand() % (maxNum - minNum) + minNum;
    
    return randNum;
}

@end

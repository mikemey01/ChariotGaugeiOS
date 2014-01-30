//
//  CICCalculateData.m
//  ChariotGauge
//
//  Created by Mike on 1/24/14.
//  Copyright (c) 2014 Chariot Instruments. All rights reserved.
//

#import "CICCalculateData.h"

#define ATMOSPHERIC 101.325
#define PSI_TO_INHG 2.03625437
#define KPA_TO_PSI  0.14503773773020923
#define KPA_TO_INHG 0.295299830714

@implementation CICCalculateData

@synthesize sensorMaxValue;

/* Calc functions */

-(float) calcWideBand:(float)val
{
    return val;
}

-(float) calcBoost:(float)val
{
    float vOut;
    float kpa=0;
    float psi=0;
    
    vOut = (val*5.00)/1024;
    kpa = ((vOut/5.00)+.04)/.004;
    psi = (kpa - ATMOSPHERIC) * KPA_TO_PSI;
    
    if(psi < 0){
        psi = psi * PSI_TO_INHG;
    }
    
    if(psi > self.sensorMaxValue){
        self.sensorMaxValue = psi;
    }
    
    return psi;
}

-(float) calcOil:(float)val
{
    return val;
}

-(float) calcTemp:(float)val
{
    return val;
}

/* Helper Functions */



@end

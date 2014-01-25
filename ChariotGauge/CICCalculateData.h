//
//  CICCalculateData.h
//  ChariotGauge
//
//  Created by Mike on 1/24/14.
//  Copyright (c) 2014 Chariot Instruments. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CICCalculateData : NSObject{
    
    float sensorMaxValue;
}

@property (nonatomic, assign) float sensorMaxValue;

-(float) calcWideBand:(float)val;
-(float) calcBoost:(float)val;
-(float) calcOil:(float)val;
-(float) calcTemp:(float)val;

@end

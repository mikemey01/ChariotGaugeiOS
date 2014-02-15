//
//  CICCalculateData.h
//  ChariotGauge
//
//  Created by Mike on 1/24/14.
//  Copyright (c) 2014 Chariot Instruments. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CICCalculateData : NSObject{
    
    CGFloat sensorMaxValue;
    
    //Prefs vars
    NSString *pressureUnits;
    NSString *widebandUnits;
    NSString *widebandFuelType;
    NSString *temperatureUnits;
    CGFloat wbLowVolts;
    CGFloat wbHighVolts;
    CGFloat wbLowAFR;
    CGFloat wbHighAFR;
    CGFloat wbVoltRange;
    CGFloat wbAFRRange;
    CGFloat wbStoich;
    CGFloat oilLowVolts;
    CGFloat oilHighVolts;
    CGFloat oilLowPSI;
    CGFloat oilHighPSI;
    CGFloat oilLowOhms;
    CGFloat oilHighOhms;
    CGFloat oilBiasResistor;
    CGFloat oilVoltRange;
    CGFloat oilPSIRange;
    
    CGFloat tempOne;
    CGFloat tempTwo;
    CGFloat tempThree;
    CGFloat tempOhmsOne;
    CGFloat tempOhmsTwo;
    CGFloat tempOhmsThree;
    CGFloat tempBiasResistor;
    CGFloat a;
    CGFloat b;
    CGFloat c;
    
}

@property (nonatomic, assign) CGFloat sensorMaxValue;

-(CGFloat) calcWideBand:(NSInteger)val;
-(CGFloat) calcBoost:(NSInteger)val;
-(CGFloat) calcOil:(NSInteger)val;
-(CGFloat) calcTemp:(NSInteger)val;
-(CGFloat) calcVolts:(NSInteger)val;

-(CGFloat)getResistance:(CGFloat)ADC;
-(CGFloat)getTemperature:(CGFloat)res;
-(CGFloat)getF:(CGFloat)tempIn;
-(void)initSHHCoefficients;

-(void) initStoich;
-(void) initPrefs;

@end

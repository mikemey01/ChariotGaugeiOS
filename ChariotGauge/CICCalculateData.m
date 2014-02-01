//
//  CICCalculateData.m
//  ChariotGauge
//
//  Created by Mike on 1/24/14.
//  Copyright (c) 2014 Chariot Instruments. All rights reserved.
//

#import "CICCalculateData.h"
#import <math.h>

#define ATMOSPHERIC 101.325
#define PSI_TO_INHG 2.03625437
#define KPA_TO_PSI  0.14503773773020923
#define KPA_TO_INHG 0.295299830714

@implementation CICCalculateData

@synthesize sensorMaxValue;

/* Calc functions */

-(CGFloat) calcWideBand:(NSInteger)val
{
    float vOut;
    float vPercentage;
    float o2=0;
    
    vOut = (val*wbVoltRange)/1024;
    vPercentage = vOut / wbVoltRange;
    o2 = wbLowAFR + (wbAFRRange * vPercentage);
    
    if([widebandUnits isEqualToString:@"Lambda"]){
        o2 = o2/wbStoich;
    }
    
    if(o2 > self.sensorMaxValue){
        self.sensorMaxValue = o2;
    }
    
    return o2;
}

-(CGFloat) calcBoost:(NSInteger)val
{
    float vOut;
    float kpa=0;
    float psi=0;
    
    vOut = (val*5.00)/1024;
    kpa = ((vOut/5.00)+.04)/.004;
    psi = (kpa - ATMOSPHERIC) * KPA_TO_PSI;
    
    if([pressureUnits isEqualToString:@"KPA"]){
        if(kpa > self.sensorMaxValue){
            self.sensorMaxValue = kpa;
        }
        return kpa;
    }else{
        if(psi < 0){
            psi = psi * PSI_TO_INHG;
        }
        
        if(psi > self.sensorMaxValue){
            self.sensorMaxValue = psi;
        }
        
        return psi;
    }
}

-(CGFloat) calcOil:(NSInteger)val
{
    CGFloat oil = 0;
    CGFloat vOut = 0;
    CGFloat vPercentage;
    
    vOut = (val*5.00)/1024; //get voltage
    
    vOut = vOut - oilLowVolts; //get on the same level as the oil pressure sensor
    if(vOut == 0){ //Remove divide by 0 errors.
        vOut = .01;
    }
    vPercentage = vOut / oilVoltRange; //find the percentage of the range we're at
    oil = vPercentage * oilPSIRange; //apply same percentage to range of oil.
    
    if(oil > self.sensorMaxValue){
        self.sensorMaxValue = oil;
    }
    //NSLog(@"oil: %f, vOut: %f, vPercentage: %f, inputVal: %i, oilPSIRange: %f", oil,vOut,vPercentage,val,oilPSIRange);
    return oil;
}

-(CGFloat) calcTemp:(NSInteger)val
{
    CGFloat res;
    CGFloat temp;
    
    res = [self getResistance:val];
    temp = [self getTemperature:res];
    
    if([temperatureUnits isEqualToString:@"Fahrenheit"]){
        temp = [self getF:temp];
    }
    
    if(temp > self.sensorMaxValue){
        self.sensorMaxValue = temp;
    }
    
    return temp;
}

-(CGFloat) calcVolts:(NSInteger)val
{
    CGFloat volts = 0.0;
    
    //scale input adc to voltage using 10k/2k voltage divider.
    volts = .029326*val;
    
    if(volts > self.sensorMaxValue){
        self.sensorMaxValue = volts;
    }
    
    return volts;
}

/* Helper Functions */

-(CGFloat)getResistance:(CGFloat)ADC
{
    CGFloat numer;
    CGFloat denom;
    
    numer = tempBiasResistor*(ADC/1024);
    denom = fabsf((ADC/1024)-1);
    
    return numer / denom;;
}

-(CGFloat)getTemperature:(CGFloat)res
{
    CGFloat ret = 0.0f;
    ret = ((1/(a+(b*log(res))+(c*(pow((log(res)), 3)))))-273.15);
    return ret;
}

-(CGFloat)getF:(CGFloat)tempIn
{
    return (tempIn*1.8)+32;
}

-(void)initSHHCoefficients
{
    CGFloat numer;
    CGFloat denom;
    
    //Start with C
    numer = ((1/(tempOne+273.15)-1/(tempTwo+273.15))-(log(tempOhmsOne)-log(tempOhmsTwo))*(1/(tempOne+273.15)-1/(tempThree+273.15))/(log(tempOhmsOne)-log(tempOhmsThree)));
    denom = ((pow((log(tempOhmsOne)), 3)-pow((log(tempOhmsTwo)), 3) - (log(tempOhmsOne)-log(tempOhmsTwo))*(pow((log(tempOhmsOne)),3)-pow((log(tempOhmsThree)), 3))/(log(tempOhmsOne)-log(tempOhmsThree))));
    c = numer / denom;
    
    //Then B
    b = ((1/(tempOne+273.15)-1/(tempTwo+273.15))-c*(pow((log(tempOhmsOne)), 3)-pow((log(tempOhmsTwo)), 3)))/(log(tempOhmsOne)-log(tempOhmsTwo));
    
    //Finally A
    a = 1/(tempOne+273.15)-c*pow((log(tempOhmsOne)), 3)-b*log(tempOhmsOne);
}

-(void) initStoich
{
    if([widebandFuelType isEqualToString:@"Gasoline"]){
        wbStoich = 14.7f;
    }else if([widebandFuelType isEqualToString:@"Propane"]){
        wbStoich = 15.67f;
    }else if([widebandFuelType isEqualToString:@"Methanol"]){
        wbStoich = 6.47f;
    }else if([widebandFuelType isEqualToString:@"Diesel"]){
        wbStoich = 14.6f;
    }else if([widebandFuelType isEqualToString:@"Ethanol"]){
        wbStoich = 9.0f;
    }else if([widebandFuelType isEqualToString:@"E85"]){
        wbStoich = 9.76f;
    }else{
        wbStoich = 14.7f;
    }
}

/* Prefs Init */

-(void) initPrefs
{
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    
    //Wideband setup:
    widebandUnits = [standardDefaults stringForKey:@"wideband_afr_lambda"];
    widebandFuelType = [standardDefaults stringForKey:@"wideband_fuel_type"];
    wbLowVolts = (CGFloat)[[standardDefaults stringForKey:@"wideband_low_voltage"] floatValue];
    wbHighVolts = (CGFloat)[[standardDefaults stringForKey:@"wideband_high_voltage"] floatValue];
    wbLowAFR = (CGFloat)[[standardDefaults stringForKey:@"wideband_low_afr"] floatValue];
    wbHighAFR = (CGFloat)[[standardDefaults stringForKey:@"wideband_high_afr"] floatValue];
    wbVoltRange = wbHighVolts - wbLowVolts;
    wbAFRRange = wbHighAFR - wbLowAFR;
    [self initStoich];
    
    //Boost setup:
    pressureUnits = [standardDefaults stringForKey:@"boost_psi_kpa"];
    
    //Oil setup:
    oilLowOhms = (CGFloat)[[standardDefaults stringForKey:@"oil_low_ohms"] floatValue];
    oilHighOhms = (CGFloat)[[standardDefaults stringForKey:@"oil_high_ohms"] floatValue];
    oilLowPSI = (CGFloat) [[standardDefaults stringForKey:@"oil_low_psi"] floatValue];
    oilHighPSI = (CGFloat)[[standardDefaults stringForKey:@"oil_high_psi"] floatValue];
    oilBiasResistor = (CGFloat) [[standardDefaults stringForKey:@"oil_bias_resistor"] floatValue];
    oilLowVolts = (oilLowOhms/(oilBiasResistor+oilLowOhms))*5;
    oilHighVolts = (oilHighOhms/(oilBiasResistor+oilHighOhms))*5;
    oilVoltRange = oilHighVolts - oilLowVolts;
    oilPSIRange = oilHighPSI - oilLowPSI;
    
    //Temp setup:
    temperatureUnits = [standardDefaults stringForKey:@"temperature_celsius_fahrenheit"];
    tempOne = (CGFloat)[[standardDefaults stringForKey:@"temperature_temperature_one"] floatValue];
    tempTwo = (CGFloat)[[standardDefaults stringForKey:@"temperature_temperature_two"] floatValue];
    tempThree = (CGFloat)[[standardDefaults stringForKey:@"temperature_temperature_three"] floatValue];
    tempOhmsOne = (CGFloat)[[standardDefaults stringForKey:@"temperature_ohms_one"] floatValue];
    tempOhmsTwo = (CGFloat)[[standardDefaults stringForKey:@"temperature_ohms_two"] floatValue];
    tempOhmsThree = (CGFloat)[[standardDefaults stringForKey:@"temperature_ohms_three"] floatValue];
    tempBiasResistor = (CGFloat)[[standardDefaults stringForKey:@"temperature_bias_resistor"] floatValue];
    a = 0.0f;
    b = 0.0f;
    c = 0.0f;
    
}



@end

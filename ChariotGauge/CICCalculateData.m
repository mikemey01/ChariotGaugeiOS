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

-(float) calcBoost:(float)val
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

-(float) calcOil:(float)val
{
    double oil = 0;
    double vOut = 0;
    double vPercentage;
    
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
    
    return oil;
}

-(float) calcTemp:(float)val
{
    return val;
}

-(float) calcVolts:(float)val
{
    return val;
}

/* Helper Functions */

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
    
}



@end

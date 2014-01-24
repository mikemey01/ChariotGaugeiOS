//
//  CICSingleGaugeViewController.m
//  ChariotGauge
//
//  Created by Mike on 12/19/13.
//  Copyright (c) 2013 Chariot Instruments. All rights reserved.
//


#import "CICSingleGaugeViewController.h"
#import "CICGaugeBuilder.h"
#import "CICAppDelegate.h"
#import "CICBluetoothHandler.h"

#define ATMOSPHERIC 101.325
#define PSI_TO_INHG 2.03625437
#define KPA_TO_PSI  0.14503773773020923
#define KPA_TO_INHG 0.295299830714

@interface CICSingleGaugeViewController ()

@end

@implementation CICSingleGaugeViewController

@synthesize gaugeView, gaugeType, bluetooth;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(gaugeType==0){
        [self createWidebandGauge];
    }else if(gaugeType==1){
        [self createBoostGauge];
    }else if(gaugeType==2){
        [self createOilGauge];
    }else if(gaugeType==3){
        [self createTempGauge];
    }else{
        [self createBoostGauge];
    }
    
    [self.bluetooth setBtDelegate:self];
    
}

-(void) getLatestData:(NSMutableString *)newData
{
    newArray = [newData componentsSeparatedByString: @","];
    [self setGaugeValue:newArray];
    newArray = nil;
}

-(void) setGaugeValue:(NSArray *)array
{
    if(array.count > gaugeType){
        currentStringValue = [array objectAtIndex:gaugeType];
        currentIntergerValue = [currentStringValue integerValue];
        
        if(gaugeType==0){
            [self calculateWideband:currentIntergerValue];
        }else if(gaugeType==1){
            [self calculateBoost:currentIntergerValue];
        }else if(gaugeType==2){
            [self calculateOil:currentIntergerValue];
        }else if(gaugeType==3){
            [self calculateTemp:currentIntergerValue];
        }
    }
}

-(void) calculateWideband:(NSInteger)val
{
    
}

-(void) calculateBoost:(NSInteger)val
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
    
    [self.gaugeView setValue:psi];
    //NSLog(@"calcBoost: %f", psi);
    //self.gaugeView.value = 5;
}

-(void) calculateOil:(NSInteger)val
{
    
}

-(void) calculateTemp:(NSInteger)val
{
    
}


//Handles portrait only mode.
- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
//End handling portrait only mode.


-(void)createWidebandGauge
{
    [self.gaugeView initializeGauge]; 
    self.gaugeView.minGaugeNumber = 5.0f;
    self.gaugeView.maxGaugeNumber = 25.0f;
    self.gaugeView.gaugeLabel = @"Gas Wideband \n(AFR)";
    self.gaugeView.incrementPerLargeTick = 5;
    self.gaugeView.tickStartAngleDegrees = 180;
    self.gaugeView.tickDistance = 180;
    self.gaugeView.lineWidth = 1;
    self.gaugeView.value = self.gaugeView.minGaugeNumber;
    self.gaugeView.menuItemsFont = [UIFont fontWithName:@"Futura" size:18];
}

-(void)createBoostGauge
{
    [self.gaugeView initializeGauge];
    self.gaugeView.minGaugeNumber = -30.0f;
    self.gaugeView.maxGaugeNumber = 25.0f;
    self.gaugeView.gaugeLabel = @"Boost/Vac \n(PSI/inHG)";
    self.gaugeView.incrementPerLargeTick = 5;
    self.gaugeView.tickStartAngleDegrees = 135;
    self.gaugeView.tickDistance = 270;
    self.gaugeView.lineWidth = 1;
    self.gaugeView.value = self.gaugeView.minGaugeNumber;
    self.gaugeView.menuItemsFont = [UIFont fontWithName:@"Futura" size:18];
}

-(void)createOilGauge
{
    [self.gaugeView initializeGauge];
    self.gaugeView.minGaugeNumber = 0.0f;
    self.gaugeView.maxGaugeNumber = 100.0f;
    self.gaugeView.gaugeLabel = @"Oil Pressure \n(PSI)";
    self.gaugeView.incrementPerLargeTick = 10;
    self.gaugeView.tickStartAngleDegrees = 135;
    self.gaugeView.tickDistance = 270;
    self.gaugeView.lineWidth = 1;
    self.gaugeView.value = self.gaugeView.minGaugeNumber;
    self.gaugeView.menuItemsFont = [UIFont fontWithName:@"Futura" size:18];
}

-(void)createTempGauge
{
    [self.gaugeView initializeGauge];
    self.gaugeView.minGaugeNumber = -35.0f;
    self.gaugeView.maxGaugeNumber = 105.0f;
    self.gaugeView.gaugeLabel = @"Temperature \n(ºF)";
    self.gaugeView.incrementPerLargeTick = 20;
    self.gaugeView.tickStartAngleDegrees = 135;
    self.gaugeView.tickDistance = 270;
    self.gaugeView.lineWidth = 1;
    self.gaugeView.value = self.gaugeView.minGaugeNumber;
    self.gaugeView.menuItemsFont = [UIFont fontWithName:@"Futura" size:18];
}

- (void)viewDidUnload
{
    self.gaugeView = nil;
}

- (void)didReceiveMemoryWarning
{
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

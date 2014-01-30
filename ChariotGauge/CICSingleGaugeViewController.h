//
//  CICSingleGaugeViewController.h
//  ChariotGauge
//
//  Created by Mike on 12/19/13.
//  Copyright (c) 2013 Chariot Instruments. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CICGaugeBuilder.h"
#import "CICHomeScreenViewController.h"
#import "CICBluetoothHandler.h"
#import "CICCalculateData.h"

@class CICGaugeBuilder, CICSingleGaugeViewController;

@interface CICSingleGaugeViewController : UIViewController <BluetoothDelegate>{
    CICGaugeBuilder *gaugeView;
    CICBluetoothHandler *bluetooth;
    NSArray *newArray;
    NSString *currentStringValue;
    NSInteger currentIntergerValue;
    CICCalculateData *calcData;
    
    //Prefs vars
    NSString *pressureUnits;
    NSString *widebandUnits;
}

@property GaugeType gaugeType;
@property (nonatomic, retain) IBOutlet CICGaugeBuilder *gaugeView;
@property (nonatomic, retain) CICBluetoothHandler *bluetooth;

-(void)createWidebandGauge;
-(void)createBoostGauge;
-(void)createOilGauge;
-(void)createTempGauge;
-(void)initPrefs;

-(void) setGaugeValue:(NSArray *)array;
@end
//
//  CICDualGaugeViewController.h
//  ChariotGauge
//
//  Created by Mike on 12/29/13.
//  Copyright (c) 2013 Chariot Instruments. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CICGaugeBuilder.h"
#import "CICHomeScreenViewController.h"
#import "CICBluetoothHandler.h"
#import "CICCalculateData.h"

@class CICGaugeBuilder;

@interface CICDualGaugeViewController : UIViewController <BluetoothDelegate>{
    CICGaugeBuilder *firstGauge;
    CICGaugeBuilder *secondGauge;
    UIView *firstGaugeView;
    CICCalculateData *calcData;
    CICBluetoothHandler *bluetooth;
    NSArray *newArray;
    NSString *currentStringValue;
    NSInteger currentIntergerValue;
    
    //Prefs vars
    NSString *pressureUnits;
    NSString *widebandUnits;
    NSString *widebandFuelType;
    NSString *temperatureUnits;
    NSString *gaugeOneType;
    NSString *gaugeTwoType;
}

@property (nonatomic, retain) CICBluetoothHandler *bluetooth;
@property GaugeType gaugeType;
@property (nonatomic, retain) IBOutlet CICGaugeBuilder *firstGauge;
@property (nonatomic, retain) IBOutlet CICGaugeBuilder *secondGauge;

-(void)createBoostGauge:(CICGaugeBuilder *) gaugeView;
-(void)createWidebandGauge:(CICGaugeBuilder *) gaugeView;
-(void)createTempGauge:(CICGaugeBuilder *) gaugeView;
-(void)createOilGauge:(CICGaugeBuilder *) gaugeView;

@end

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
    CICCalculateData *calcDataOne;
    CICCalculateData *calcDataTwo;
    UIView *firstGaugeView;
    //CICCalculateData *calcData;
    CICBluetoothHandler *bluetooth;
    NSArray *newArray;
    NSString *currentStringValue;
    NSInteger currentIntergerValue;
    
    //Bar button stuff
    UIBarButtonItem *maxButton;
    UIBarButtonItem *resetButton;
    BOOL isPaused;
    
    //Prefs vars
    NSString *pressureUnits;
    NSString *widebandUnits;
    NSString *widebandFuelType;
    NSString *temperatureUnits;
    NSString *gaugeOneType;
    NSString *gaugeTwoType;
    
    //volt gauge
    UILabel *voltLabel;
    UILabel *voltLabelNumbers;
    CICCalculateData *calcDataVolts;
}

@property (nonatomic, retain) CICBluetoothHandler *bluetooth;
@property GaugeType gaugeType;
@property (nonatomic, retain) IBOutlet CICGaugeBuilder *firstGauge;
@property (nonatomic, retain) IBOutlet CICGaugeBuilder *secondGauge;

-(void)createBoostGauge:(CICGaugeBuilder *) gaugeView :(CICCalculateData *) calcData;
-(void)createWidebandGauge:(CICGaugeBuilder *) gaugeView :(CICCalculateData *) calcData;
-(void)createTempGauge:(CICGaugeBuilder *) gaugeView :(CICCalculateData *) calcData;
-(void)createOilGauge:(CICGaugeBuilder *) gaugeView :(CICCalculateData *) calcData;
-(void)createVoltGauge;
-(void)maxButtonAction;
-(void)resetButtonAction;
-(void)initPrefs;
-(void)createVoltGauge;

@end

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

@class CICGaugeBuilder;

@interface CICSingleGaugeViewController : UIViewController{
    CICGaugeBuilder *gaugeView;
}

@property GaugeType gaugeType;
@property (nonatomic, retain) IBOutlet CICGaugeBuilder *gaugeView;

-(void)createWidebandGauge;
-(void)createBoostGauge;
-(void)createOilGauge;
-(void)createTempGauge;
@end
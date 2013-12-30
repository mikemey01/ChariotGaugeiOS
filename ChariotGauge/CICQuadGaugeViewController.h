//
//  CICQuadGaugeViewController.h
//  ChariotGauge
//
//  Created by Mike on 12/30/13.
//  Copyright (c) 2013 Chariot Instruments. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CICGaugeBuilder.h"

@class CICGaugeBuilder;

@interface CICQuadGaugeViewController : UIViewController{
    CICGaugeBuilder *firstGauge;
    CICGaugeBuilder *secondGauge;
    CICGaugeBuilder *thirdGauge;
    CICGaugeBuilder *fourthGauge;
}

@property (nonatomic, retain) IBOutlet CICGaugeBuilder *firstGauge;
@property (nonatomic, retain) IBOutlet CICGaugeBuilder *secondGauge;
@property (nonatomic, retain) IBOutlet CICGaugeBuilder *thirdGauge;
@property (nonatomic, retain) IBOutlet CICGaugeBuilder *fourthGauge;

-(void)createFirstGauge;
-(void)createSecondGauge;
-(void)createThirdGauge;
-(void)createFourthGauge;

@end

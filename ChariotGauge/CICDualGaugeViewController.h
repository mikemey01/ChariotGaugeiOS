//
//  CICDualGaugeViewController.h
//  ChariotGauge
//
//  Created by Mike on 12/29/13.
//  Copyright (c) 2013 Chariot Instruments. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CICGaugeBuilder.h"

@class CICGaugeBuilder;

@interface CICDualGaugeViewController : UIViewController{
    CICGaugeBuilder *firstGauge;
    CICGaugeBuilder *secondGauge;
    UIView *firstGaugeView;
}

@property (nonatomic, retain) IBOutlet CICGaugeBuilder *firstGauge;
@property (nonatomic, retain) IBOutlet CICGaugeBuilder *secondGauge;
@property (nonatomic, retain) IBOutlet UIView *firstGaugeView;

-(void)adjustViewSize;


@end

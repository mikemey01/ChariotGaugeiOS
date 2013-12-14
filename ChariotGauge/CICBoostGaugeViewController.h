//
//  CICBoostGaugeViewController.h
//  ChariotGauge
//
//  Created by Mike on 12/13/13.
//  Copyright (c) 2013 Chariot Instruments. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CICGaugeBuilder;

@interface CICBoostGaugeViewController : UIViewController{
    CICGaugeBuilder *boostGauge;
}

@property(nonatomic, retain) CICGaugeBuilder *boostGauge;

@end

//
//  CICChartViewController.h
//  ChariotGauge
//
//  Created by Mike on 8/19/14.
//  Copyright (c) 2014 Chariot Instruments. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CICChartBuilder.h"

@interface CICChartViewController : UIViewController

@property (nonatomic, retain) IBOutlet CICChartBuilder *chartView;

@end

//
//  CICBoostGaugeViewController.m
//  ChariotGauge
//
//  Created by Mike on 12/13/13.
//  Copyright (c) 2013 Chariot Instruments. All rights reserved.
//

#import "CICBoostGaugeViewController.h"
#import "CICGaugeBuilder.h"
#import "CICAppDelegate.h"


@interface CICBoostGaugeViewController ()

@end

@implementation CICBoostGaugeViewController

@synthesize boostGauge;

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.boostGauge initializeGauge]; //NECESSARY
    self.boostGauge.minGaugeNumber = -30;
    self.boostGauge.maxGaugeNumber = 25;
    self.boostGauge.gaugeLabel = @"Boost/Vac";
    self.boostGauge.incrementPerLargeTick = 5;
    self.boostGauge.tickStartAngleDegrees = 135;
    self.boostGauge.tickDistance = 270;
    self.boostGauge.menuItemsFont = [UIFont fontWithName:@"Helvetica" size:14];
    self.boostGauge.lineWidth = 1;
    self.boostGauge.value = self.boostGauge.minGaugeNumber;
    
}

- (void)viewDidUnload
{
    self.boostGauge = nil;
}

- (void)didReceiveMemoryWarning
{
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

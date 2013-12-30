//
//  CICDualGaugeViewController.m
//  ChariotGauge
//
//  Created by Mike on 12/29/13.
//  Copyright (c) 2013 Chariot Instruments. All rights reserved.
//

#import "CICDualGaugeViewController.h"
#import "CICGaugeBuilder.h"
#import "CICAppDelegate.h"

@interface CICDualGaugeViewController ()

@end

@implementation CICDualGaugeViewController

@synthesize firstGauge, secondGauge;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self.firstGauge initializeGauge]; //NECESSARY
    self.firstGauge.minGaugeNumber = 5;
    self.firstGauge.maxGaugeNumber = 25;
    self.firstGauge.gaugeLabel = @"Boost/Vac";
    self.firstGauge.incrementPerLargeTick = 5;
    self.firstGauge.tickStartAngleDegrees = 180;
    self.firstGauge.tickDistance = 180;
    self.firstGauge.menuItemsFont = [UIFont fontWithName:@"Helvetica" size:14];
    self.firstGauge.lineWidth = 1;
    self.firstGauge.value = self.firstGauge.minGaugeNumber;
    
    [self.secondGauge initializeGauge]; //NECESSARY
    self.secondGauge.minGaugeNumber = 5;
    self.secondGauge.maxGaugeNumber = 25;
    self.secondGauge.gaugeLabel = @"Boost/Vac";
    self.secondGauge.incrementPerLargeTick = 5;
    self.secondGauge.tickStartAngleDegrees = 180;
    self.secondGauge.tickDistance = 180;
    self.secondGauge.menuItemsFont = [UIFont fontWithName:@"Helvetica" size:14];
    self.secondGauge.lineWidth = 1;
    self.secondGauge.value = self.secondGauge.minGaugeNumber;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

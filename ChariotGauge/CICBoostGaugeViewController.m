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

@synthesize gaugeView;

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
    [self.gaugeView initializeGauge]; //NECESSARY
    self.gaugeView.minGaugeNumber = -30;
    self.gaugeView.maxGaugeNumber = 25;
    self.gaugeView.gaugeLabel = @"Boost/Vac";
    self.gaugeView.incrementPerLargeTick = 5;
    self.gaugeView.tickStartAngleDegrees = 135;
    self.gaugeView.tickDistance = 270;
    self.gaugeView.menuItemsFont = [UIFont fontWithName:@"Helvetica" size:14];
    self.gaugeView.lineWidth = 1;
    self.gaugeView.value = self.gaugeView.minGaugeNumber;
    
}

- (void)viewDidUnload
{
    self.gaugeView = nil;
}

- (void)didReceiveMemoryWarning
{
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
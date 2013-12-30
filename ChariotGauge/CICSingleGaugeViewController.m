//
//  CICSingleGaugeViewController.m
//  ChariotGauge
//
//  Created by Mike on 12/19/13.
//  Copyright (c) 2013 Chariot Instruments. All rights reserved.
//


#import "CICSingleGaugeViewController.h"
#import "CICGaugeBuilder.h"
#import "CICAppDelegate.h"


@interface CICSingleGaugeViewController ()

@end

@implementation CICSingleGaugeViewController

@synthesize gaugeView, gaugeType;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(gaugeType==0){
        [self createWidebandGauge];
    }else if(gaugeType==1){
        [self createBoostGauge];
    }else if(gaugeType==2){
        [self createOilGauge];
    }else if(gaugeType==3){
        [self createTempGauge];
    }else{
        [self createBoostGauge];
    }
    
    
    
}

//Handles portrait only mode.
- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
//End handling portrait only mode.


-(void)createWidebandGauge
{
    [self.gaugeView initializeGauge]; //NECESSARY
    self.gaugeView.minGaugeNumber = 5;
    self.gaugeView.maxGaugeNumber = 25;
    self.gaugeView.gaugeLabel = @"Boost/Vac";
    self.gaugeView.incrementPerLargeTick = 5;
    self.gaugeView.tickStartAngleDegrees = 180;
    self.gaugeView.tickDistance = 180;
    self.gaugeView.menuItemsFont = [UIFont fontWithName:@"Helvetica" size:14];
    self.gaugeView.lineWidth = 1;
    self.gaugeView.value = self.gaugeView.minGaugeNumber;
}

-(void)createBoostGauge
{
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

-(void)createOilGauge
{
    [self.gaugeView initializeGauge]; //NECESSARY
    self.gaugeView.minGaugeNumber = 0;
    self.gaugeView.maxGaugeNumber = 100;
    self.gaugeView.gaugeLabel = @"Boost/Vac";
    self.gaugeView.incrementPerLargeTick = 10;
    self.gaugeView.tickStartAngleDegrees = 135;
    self.gaugeView.tickDistance = 270;
    self.gaugeView.menuItemsFont = [UIFont fontWithName:@"Helvetica" size:14];
    self.gaugeView.lineWidth = 1;
    self.gaugeView.value = self.gaugeView.minGaugeNumber;
}

-(void)createTempGauge
{
    [self.gaugeView initializeGauge]; //NECESSARY
    self.gaugeView.minGaugeNumber = -35;
    self.gaugeView.maxGaugeNumber = 105;
    self.gaugeView.gaugeLabel = @"Boost/Vac";
    self.gaugeView.incrementPerLargeTick = 20;
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

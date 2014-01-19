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

@synthesize firstGauge, secondGauge, firstGaugeView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


//Force landscape right for dual gauge.
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeRight;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Handles forcing landscape orientation NEEDS WORK
    UIViewController *mVC = [[UIViewController alloc] init];
    [self presentModalViewController:mVC animated:NO];
    if (![mVC isBeingDismissed])
        [self dismissModalViewControllerAnimated:YES];
    
    [self adjustViewSize];
	
    [self.firstGauge initializeGauge]; //NECESSARY
    self.firstGauge.minGaugeNumber = -30;
    self.firstGauge.maxGaugeNumber = 25;
    self.firstGauge.gaugeLabel = @"Boost/Vac \n(PSI)";
    self.firstGauge.incrementPerLargeTick = 5;
    self.firstGauge.tickStartAngleDegrees = 135;
    self.firstGauge.tickDistance = 270;
    self.firstGauge.lineWidth = 1;
    self.firstGauge.value = self.firstGauge.minGaugeNumber;
    
    [self.secondGauge initializeGauge]; //NECESSARY
    self.secondGauge.minGaugeNumber = 5;
    self.secondGauge.maxGaugeNumber = 25;
    self.secondGauge.gaugeLabel = @"Gas Wideband \n(AFR)";
    self.secondGauge.incrementPerLargeTick = 5;
    self.secondGauge.tickStartAngleDegrees = 180;
    self.secondGauge.tickDistance = 180;
    self.secondGauge.lineWidth = 1;
    self.secondGauge.value = self.secondGauge.minGaugeNumber;
}

-(void)adjustViewSize
{
    CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
    NSLog(@"%f", screenRect.size.width); //4s size: 300
    NSLog(@"%f", screenRect.size.height); //4s size: 480
    
    //firstGauge.frame.size = screenRect.size;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

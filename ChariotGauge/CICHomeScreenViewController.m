//
//  CICHomeScreenViewController.m
//  ChariotGauge
//
//  Created by Mike on 12/22/13.
//  Copyright (c) 2013 Chariot Instruments. All rights reserved.
//

#import "CICHomeScreenViewController.h"
#import "CICSingleGaugeViewController.h"

@interface CICHomeScreenViewController ()

@end

@implementation CICHomeScreenViewController

@synthesize gaugeType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    CICSingleGaugeViewController *gaugeController = (CICSingleGaugeViewController *)segue.destinationViewController;
    
    //TODO: Need to add handling for multi-gauge displays.
    
    if([segue.identifier isEqualToString:@"widebandSegue"]){
        gaugeController.gaugeType = wideband;
    }else if([segue.identifier isEqualToString:@"boostSegue"]){
        gaugeController.gaugeType = boost;
    }else if([segue.identifier isEqualToString:@"oilSegue"]){
        gaugeController.gaugeType = oil;
    }else if([segue.identifier isEqualToString:@"tempSegue"]){
        gaugeController.gaugeType = temp;
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


-(IBAction)widebandButtonPress:(id)sender
{
    gaugeType = wideband;
}

-(IBAction)boostButtonPress:(id)sender
{
    gaugeType = boost;
}

-(IBAction)oilButtonPress:(id)sender
{
    gaugeType = oil;
}

-(IBAction)tempButtonPress:(id)sender
{
    gaugeType = temp;
}

-(IBAction)dualButtonPress:(id)sender
{
    gaugeType = dual;
}

-(IBAction)quadButtonPress:(id)sender
{
    gaugeType = quad;
}

-(IBAction)connectButtonPress:(id)sender
{
    [bluetooth startScan];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Instatiate bluetooth handler.
    bluetooth = [[CICBluetoothHandler alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

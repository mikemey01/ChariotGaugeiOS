//
//  CICHomeScreenViewController.m
//  ChariotGauge
//
//  Created by Mike on 12/22/13.
//  Copyright (c) 2013 Chariot Instruments. All rights reserved.
//

#import "CICHomeScreenViewController.h"
#import "CICSingleGaugeViewController.h"
#import "CICDualGaugeViewController.h"
#import "CICQuadGaugeViewController.h"

@interface CICHomeScreenViewController ()

@end

@implementation CICHomeScreenViewController

@synthesize gaugeType, bluetooth, connectLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"widebandSegue"]){
        CICSingleGaugeViewController *gaugeController = (CICSingleGaugeViewController *)segue.destinationViewController;
        gaugeController.gaugeType = wideband;
        gaugeController.bluetooth = self.bluetooth;
    }else if([segue.identifier isEqualToString:@"boostSegue"]){
        CICSingleGaugeViewController *gaugeController = (CICSingleGaugeViewController *)segue.destinationViewController;
        gaugeController.gaugeType = boost;
        gaugeController.bluetooth = self.bluetooth;
    }else if([segue.identifier isEqualToString:@"oilSegue"]){
        CICSingleGaugeViewController *gaugeController = (CICSingleGaugeViewController *)segue.destinationViewController;
        gaugeController.gaugeType = oil;
        gaugeController.bluetooth = self.bluetooth;
    }else if([segue.identifier isEqualToString:@"tempSegue"]){
        CICSingleGaugeViewController *gaugeController = (CICSingleGaugeViewController *)segue.destinationViewController;
        gaugeController.gaugeType = temp;
        gaugeController.bluetooth = self.bluetooth;
    }else if([segue.identifier isEqualToString:@"dualSegue"]){
        CICDualGaugeViewController *gaugeController = (CICDualGaugeViewController *)segue.destinationViewController;
        gaugeController.gaugeType = dual;
        gaugeController.bluetooth = self.bluetooth;
    }else if([segue.identifier isEqualToString:@"quadSegue"]){
        CICQuadGaugeViewController *gaugeController = (CICQuadGaugeViewController *)segue.destinationViewController;
        gaugeController.gaugeType = quad;
        gaugeController.bluetooth = self.bluetooth;
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
    if(self.connect){
        connectLabel.text = @"Connecting..";
        [self.bluetooth startScan];
        //TODO: Use delegate to push central manager's state to handle connect label's text.
            connectLabel.text = @"Connected!";
        //}
    }else{
        connectLabel.text = @"Disconnecting..";
        [self.bluetooth disconnectBluetooth];
        connectLabel.text = @"Connect";
    }
    self.connect = (!self.connect);
}

-(IBAction)settingsButtonPress:(id)sender
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.connect = YES;
    connectLabel.text = @"Connect";
    
    //Instatiate bluetooth handler.
    self.bluetooth = [[CICBluetoothHandler alloc] init];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

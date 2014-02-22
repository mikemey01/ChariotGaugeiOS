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

@synthesize gaugeType, bluetooth, connectLabel, actionSheet;

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
    
    self.connect = YES;
    connectLabel.text = @"Connect";
    
    //Instatiate bluetooth handler.
    self.bluetooth = [[CICBluetoothHandler alloc] init];
    
    [self.bluetooth setPeriphDelegate:self];
    
    self.periphArray = [[NSMutableArray alloc] init];
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
        connectLabel.text = @"Scanning..";
        [self.bluetooth startScan];
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

-(void)getLatestPeriph:(NSString *)periphName
{
    [self.periphArray addObject:periphName];
    [self createActionSheet];
}

-(void)createActionSheet
{
    [self.actionSheet dismissWithClickedButtonIndex:0 animated:NO];
    self.actionSheet = nil;
    self.actionSheet = [[UIActionSheet alloc] init];
    self.actionSheet.title = @"Illustrations";
    self.actionSheet.delegate = self;
    self.actionSheet.tag = 1;
    for(NSString *string in self.periphArray){
        [self.actionSheet addButtonWithTitle:string];
    }
    
    self.actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
    [self.actionSheet showInView:self.view];
    
    //TODO: WHEN CANCEL OR A CONTROLLER IS SELECTED CLEAR THE periphArray!!!
    
//    [NSTimer scheduledTimerWithTimeInterval:2.0
//                                     target:self
//                                   selector:@selector(addButtonToActionSheet)
//                                   userInfo:nil
//                                    repeats:NO];
}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (popup.tag) {
        case 1: {
            switch (buttonIndex) {
                case 0:
                    if(self.actionSheet.cancelButtonIndex == 0){
                        NSLog(@"Cancel button clicked");
                    }
                    NSLog(@"first button click");
                    break;
                case 1:
                    NSLog(@"second button clicked");
                    break;
                case 2:
                    NSLog(@"third button clicked");
                    break;
                case 3:
                    NSLog(@"fourth button clicked");
                    break;
                case 4:
                    NSLog(@"fifth button clicked");
                    break;
                default:
                    NSLog(@"default triggered");
                    break;
            }
            break;
        }
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

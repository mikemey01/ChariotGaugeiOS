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

@synthesize gaugeType, bluetooth, connectLabel, actionSheet, periphArray, scanTimer, stateString;

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
    
    self.isConnected = NO;
    connectLabel.text = @"Connect";
    self.stateString = [[NSString alloc] init];
    
    //Instatiate bluetooth handler.
    self.bluetooth = [[CICBluetoothHandler alloc] init];
    [self.bluetooth setPeriphDelegate:self];
    [self.bluetooth setStateDelegate:self];
    self.bluetooth.failedConnectCount = 0;
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
    if(!self.isConnected && !([self.connectLabel.text isEqualToString:@"Scanning.."])){
        self.periphArray = [[NSMutableArray alloc] init];
        //connectLabel.text = @"Scanning..";
        [self.bluetooth startScan];
        [self startTimer];
    }else{
        [self stopTimer];
        connectLabel.text = @"Disconnecting..";
        [self.bluetooth disconnectBluetooth];
        connectLabel.text = @"Connect";
        self.isConnected = NO;
    }
    //self.isConnected = (!self.isConnected);
}

-(IBAction)settingsButtonPress:(id)sender
{
    
}

-(void)startTimer
{
    self.scanTimer = [NSTimer scheduledTimerWithTimeInterval:7.0
                                                      target:self
                                                    selector:@selector(didNotFindController)
                                                    userInfo:nil
                                                     repeats:NO];
}

-(void)stopTimer
{
    [self.scanTimer invalidate];
    self.scanTimer = nil;
}

-(void)didNotFindController
{
    if(self.periphArray.count < 1){
        [self.bluetooth stopScan];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Chariot Gauge"
                                                        message:@"Could not find a Chariot Gauge controller to connect to"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [self.bluetooth disconnectBluetooth];
        self.connectLabel.text = @"Connect";
        self.isConnected = NO;
        [self.actionSheet dismissWithClickedButtonIndex:0 animated:NO];
        self.actionSheet = nil;
    }
}

-(void)getLatestPeriph:(NSString *)periphName
{
    if(periphName == nil){
        periphName = @"Chariot Gauge";
    }
    if([periphName isEqualToString:@"HMSoft"]){
        periphName = @"Chariot Gauge";
    }
    [self.periphArray addObject:periphName];
    [self stopTimer];
    [self createActionSheet];
}

-(void)getLatestBluetoothState:(NSString *)latestStatus
{
    if([latestStatus isEqualToString:@"error"]){
        //go to error alert
        [self.bluetooth stopScan];
        [self stopTimer];
        [self.bluetooth disconnectBluetooth];
        self.isConnected = NO;
        self.connectLabel.text = @"Connect";
        return;
    }
    
    if([latestStatus isEqualToString:@"bluetoothOff"]){
        [self.bluetooth stopScan];
        [self stopTimer];
        [self.bluetooth disconnectBluetooth];
        self.isConnected = NO;
        self.connectLabel.text = @"Connect";
        return;
    }
    
    if([latestStatus isEqualToString:@"Connected!"]){
        self.isConnected = YES;
    }else{
        self.isConnected = NO;
    }
    
    self.connectLabel.text = latestStatus;
}

-(void)createActionSheet
{
    [self.actionSheet dismissWithClickedButtonIndex:0 animated:NO];
    self.actionSheet = nil;
    self.actionSheet = [[UIActionSheet alloc] init];
    self.actionSheet.title = @"Select a Chariot Gauge controller";
    self.actionSheet.delegate = self;
    self.actionSheet.tag = 1;
    for(NSString *string in self.periphArray){
        [self.actionSheet addButtonWithTitle:string];
    }
    
    self.actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
    [self.actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (popup.tag) {
        case 1: {
            switch (buttonIndex) {
                case 0:
                    if(self.actionSheet.cancelButtonIndex == 0){
                        [self.bluetooth stopScan];
                        self.connectLabel.text = @"Connect";
                        self.isConnected = NO;
                    }else{
                        [self.bluetooth connectSelectedPeripheral:0];
                    }
                    self.periphArray = nil;
                    break;
                case 1:
                    if(self.actionSheet.cancelButtonIndex == 1){
                        [self.bluetooth stopScan];
                        self.connectLabel.text = @"Connect";
                        self.isConnected = NO;
                    }else{
                        [self.bluetooth connectSelectedPeripheral:1];
                    }
                    self.periphArray = nil;
                    break;
                case 2:
                    if(self.actionSheet.cancelButtonIndex == 2){
                        [self.bluetooth stopScan];
                        self.connectLabel.text = @"Connect";
                        self.isConnected = NO;
                    }else{
                        [self.bluetooth connectSelectedPeripheral:2];
                    }
                    self.periphArray = nil;
                    break;
                case 3:
                    if(self.actionSheet.cancelButtonIndex == 3){
                        [self.bluetooth stopScan];
                        self.connectLabel.text = @"Connect";
                        self.isConnected = NO;
                    }else{
                        [self.bluetooth connectSelectedPeripheral:3];
                    }
                    self.periphArray = nil;
                    break;
                case 4:
                    if(self.actionSheet.cancelButtonIndex == 4){
                        [self.bluetooth stopScan];
                        self.connectLabel.text = @"Connect";
                        self.isConnected = NO;
                    }else{
                        [self.bluetooth connectSelectedPeripheral:4];
                    }
                    self.periphArray = nil;
                    break;
                default:
                    NSLog(@"default triggered");
                    [self.bluetooth stopScan];
                    self.periphArray = nil;
                    self.isConnected = NO;
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

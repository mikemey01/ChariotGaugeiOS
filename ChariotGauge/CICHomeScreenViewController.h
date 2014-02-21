//
//  CICHomeScreenViewController.h
//  ChariotGauge
//
//  Created by Mike on 12/22/13.
//  Copyright (c) 2013 Chariot Instruments. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CICBluetoothHandler.h"
@import CoreBluetooth;

@interface CICHomeScreenViewController : UIViewController <UIActionSheetDelegate, PeriphDelegate>{
    CICBluetoothHandler *bluetooth;
    UILabel *connectLabel;
    UIActionSheet *actionSheet;
}

typedef enum {
    volts,
    boost,
    wideband,
    temp,
    oil,
    dual,
    quad
} GaugeType;

@property GaugeType gaugeType;
@property (nonatomic, assign) BOOL connectPressed;
@property (nonatomic, assign) BOOL connect;
@property (nonatomic, retain) CICBluetoothHandler *bluetooth;
@property (nonatomic, retain) IBOutlet UILabel *connectLabel;
@property (nonatomic, retain) UIActionSheet *actionSheet;

-(IBAction)widebandButtonPress:(id)sender;
-(IBAction)boostButtonPress:(id)sender;
-(IBAction)oilButtonPress:(id)sender;
-(IBAction)tempButtonPress:(id)sender;
-(IBAction)connectButtonPress:(id)sender;
-(IBAction)settingsButtonPress:(id)sender;

@end

//
//  CICHomeScreenViewController.h
//  ChariotGauge
//
//  Created by Mike on 12/22/13.
//  Copyright (c) 2013 Chariot Instruments. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CICBluetoothHandler.h"

@interface CICHomeScreenViewController : UIViewController{
    CICBluetoothHandler *bluetooth;
}

typedef enum {
    wideband,
    boost,
    oil,
    temp,
    dual,
    quad
} GaugeType;

@property GaugeType gaugeType;
@property (nonatomic, assign) BOOL connectPressed;
@property (nonatomic, assign) BOOL connect;

-(IBAction)widebandButtonPress:(id)sender;
-(IBAction)boostButtonPress:(id)sender;
-(IBAction)oilButtonPress:(id)sender;
-(IBAction)tempButtonPress:(id)sender;
-(IBAction)connectButtonPress:(id)sender;

@end

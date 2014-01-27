//
//  CICSettingsViewController.h
//  ChariotGauge
//
//  Created by Mike on 1/26/14.
//  Copyright (c) 2014 Chariot Instruments. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IASKAppSettingsViewController.h"

@class IASKAppSettingsViewController;

@interface CICSettingsViewController : UITableViewController <IASKSettingsDelegate, UITextViewDelegate>{
    IASKAppSettingsViewController *appSettingsViewController;
}

@property (nonatomic, retain) IBOutlet IASKAppSettingsViewController *appSettingsViewController;

@end

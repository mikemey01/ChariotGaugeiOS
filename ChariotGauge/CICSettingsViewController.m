//
//  CICSettingsViewController.m
//  ChariotGauge
//
//  Created by Mike on 1/26/14.
//  Copyright (c) 2014 Chariot Instruments. All rights reserved.
//

#import "CICSettingsViewController.h"
#import "IASKAppSettingsViewController.h"

@interface CICSettingsViewController ()

@end

@implementation CICSettingsViewController

@synthesize appSettingsViewController;

- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController*)sender {
    //[self dismissModalViewControllerAnimated:YES];
	
	// your code here to reconfigure the app for changed settings
}

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
	
    appSettingsViewController = [[IASKAppSettingsViewController alloc] init];
    appSettingsViewController.delegate = self;
    
    NSLog(@"got to dis");
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

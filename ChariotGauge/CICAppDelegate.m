//
//  CICAppDelegate.m
//  ChariotGauge
//
//  Created by Mike on 11/28/13.
//  Copyright (c) 2013 Chariot Instruments. All rights reserved.
//

#import "CICAppDelegate.h"
#import "CICGaugeBuilder.h"
#import "CICSingleGaugeViewController.h"

@implementation CICAppDelegate

@synthesize window, viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [self.window addSubview:viewController.view];
    [self.window makeKeyAndVisible];
    //[[UINavigationBar appearance] setBarTintColor:[UIColor lightGrayColor]];
    
    return YES;
}


@end

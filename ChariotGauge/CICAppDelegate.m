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

@synthesize window, viewController, navigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [self.window addSubview:viewController.view];
    [self.window makeKeyAndVisible];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    [self initDefaultPrefs];

    return YES;
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    NSUInteger orientations = UIInterfaceOrientationMaskAllButUpsideDown;
    
    if(self.window.rootViewController){
        UIViewController *presentedViewController = [[(UINavigationController *)self.window.rootViewController viewControllers] lastObject];
        orientations = [presentedViewController supportedInterfaceOrientations];
    }
    
    return orientations;
}

- (BOOL)shouldAutoRotate
{
    return YES;
}

-(void) initDefaultPrefs
{
    NSArray *keys = [NSArray arrayWithObjects:@"oil_low_psi", @"oil_high_psi", nil];
    NSArray *objects = [NSArray arrayWithObjects:@"0.0", @"80.0", nil];
    NSDictionary *defaults = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
//    NSDictionary* defaults = @{@"oil_high_ohms": @"180.0"};
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}



@end

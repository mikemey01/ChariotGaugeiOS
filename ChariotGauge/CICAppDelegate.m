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
    NSArray *keys = [NSArray arrayWithObjects:@"wideband_afr_lambda",
                                              @"wideband_fuel_type",
                                              @"wideband_low_voltage",
                                              @"wideband_high_voltage",
                                              @"wideband_low_afr",
                                              @"wideband_high_afr",
                                              @"boost_psi_kpa",
                                              @"oil_low_ohms",
                                              @"oil_high_ohms",
                                              @"oil_low_psi",
                                              @"oil_high_psi",
                                              @"oil_bias_resistor",
                                              @"temperature_celsius_fahrenheit",
                                              @"temperature_temperature_one",
                                              @"temperature_temperature_two",
                                              @"temperature_temperature_three",
                                              @"temperature_ohms_one",
                                              @"temperature_ohms_two",
                                              @"temperature_ohms_three",
                                              @"temperature_bias_resistor",
                                              @"twogauge_gauge_one",
                                              @"twogauge_gauge_two",
                                              @"general_show_volts",
                                              @"general_night_mode",
                                              @"oil_psi_bar",
                                              nil];
    NSArray *objects = [NSArray arrayWithObjects:@"AFR",
                                                 @"Gasoline",
                                                 @"0.0",
                                                 @"5.0",
                                                 @"7.35",
                                                 @"22.39",
                                                 @"PSI",
                                                 @"10.0",
                                                 @"180.0",
                                                 @"0.0",
                                                 @"80.0",
                                                 @"100.0",//oil bias resistor
                                                 @"Celsius",
                                                 @"-18.0",
                                                 @"4.0",
                                                 @"99.0",
                                                 @"25000.0",
                                                 @"7500.0",
                                                 @"185.0",
                                                 @"2000.0",
                                                 @"Boost",
                                                 @"Wideband",
                                                 [NSNumber numberWithBool:YES],
                                                 [NSNumber numberWithBool:NO],
                                                 @"PSI",
                                                 nil];
    NSDictionary *defaults = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
//    NSDictionary* defaults = @{@"oil_high_ohms": @"180.0"};
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}


@end

//
//  CICAppDelegate.h
//  ChariotGauge
//
//  Created by Mike on 11/28/13.
//  Copyright (c) 2013 Chariot Instruments. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CICHomeScreenViewController;
@class CICGaugeBuilder;

@interface CICAppDelegate : UIResponder <UIApplicationDelegate>{
    UIWindow *window;
    CICHomeScreenViewController *viewController;
    UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet CICHomeScreenViewController *viewController;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

-(void) initDefaultPrefs;

@end

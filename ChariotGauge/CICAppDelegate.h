//
//  CICAppDelegate.h
//  ChariotGauge
//
//  Created by Mike on 11/28/13.
//  Copyright (c) 2013 Chariot Instruments. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CICBoostGaugeViewController;
@class CICGaugeBuilder;

@interface CICAppDelegate : UIResponder <UIApplicationDelegate>{
    UIWindow *window;
    CICBoostGaugeViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet CICBoostGaugeViewController *viewController;

@end

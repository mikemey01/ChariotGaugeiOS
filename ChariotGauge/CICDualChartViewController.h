//
//  CICDualChartViewController.h
//  ChariotGauge
//
//  Created by Mike on 9/7/14.
//  Copyright (c) 2014 Chariot Instruments. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CICChartBuilder.h"
#import "CICBluetoothHandler.h"
#import "CICHomeScreenViewController.h"
#import "CorePlot-CocoaTouch.h"

@class CICChartBuilder, CICDualChartViewController;

@interface CICDualChartViewController : UIViewController <BluetoothDelegate>{
    CICChartBuilder *chartView;
    CICBluetoothHandler *bluetooth;
    CICPlotBuilder *_localPlotBuilderOne;
    CICPlotBuilder *_localPlotBuilderTwo;
    NSTimer *dataTimer;
}

@property GaugeType gaugeType;
@property (nonatomic, retain) IBOutlet CICChartBuilder *chartView;
@property (nonatomic, retain) CICBluetoothHandler *bluetooth;

@end
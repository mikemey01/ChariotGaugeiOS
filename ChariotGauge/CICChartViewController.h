//
//  CICChartViewController.h
//  ChariotGauge
//
//  Created by Mike on 8/19/14.
//  Copyright (c) 2014 Chariot Instruments. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CICChartBuilder.h"
#import "CICBluetoothHandler.h"
#import "CICHomeScreenViewController.h"
#import "CorePlot-CocoaTouch.h"
#import "CICCalculateData.h"

@class CICChartBuilder, CICChartViewController;

@interface CICChartViewController : UIViewController <BluetoothDelegate>{
    CICChartBuilder *chartView;
    CICBluetoothHandler *bluetooth;
    CICPlotBuilder *_localPlotBuilderOne;
    NSTimer *dataTimer;
    
    CICCalculateData *calcData;
    CICCalculateData *calcDataVolts;
    
}

@property GaugeType gaugeType;
@property (nonatomic, retain) IBOutlet CICChartBuilder *chartView;
@property (nonatomic, retain) CICBluetoothHandler *bluetooth;

@end



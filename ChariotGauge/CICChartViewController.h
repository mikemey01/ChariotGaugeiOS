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
#import "CICPlotBuilder.h"

@class CICChartBuilder, CICChartViewController;

@interface CICChartViewController : UIViewController <BluetoothDelegate, CICSelectedPointDelegate>{
    
    //Chart/Plot Handling
    CICChartBuilder *chartView;
    CICPlotBuilder *_localPlotBuilderOne;
    CICPlotBuilder *_localPlotBuilderVolts;
    NSTimer *dataTimer;
    BOOL isPaused;
    
    //Bar buttons
    UIBarButtonItem *pauseButton;
    UIBarButtonItem *playButton;
    
    //Top ribbon labels
    UILabel *chartLabel1;
    UILabel *chartLabelData1;
    UILabel *chartVoltLabel;
    UILabel *chartVoltLabelData;
    
    //Data crunching
    CICCalculateData *calcData;
    CICCalculateData *calcDataVolts;
    CICBluetoothHandler *bluetooth;
    
    //Prefs vars
    NSString *pressureUnits;
    NSString *widebandUnits;
    NSString *widebandFuelType;
    NSString *temperatureUnits;
    NSString *oilPressureUnits;
    BOOL showVolts;
    BOOL isNightMode;
    
}

@property GaugeType gaugeType;
@property (nonatomic, retain) IBOutlet CICChartBuilder *chartView;
@property (nonatomic, retain) IBOutlet UILabel *chartLabel1;
@property (nonatomic, retain) IBOutlet UILabel *chartLabelData1;
@property (nonatomic, retain) IBOutlet UILabel *chartVoltLabel;
@property (nonatomic, retain) IBOutlet UILabel *chartVoltLabelData;
@property (nonatomic, retain) CICBluetoothHandler *bluetooth;

-(void)setDigitalLabel:(CGFloat)value withPlotIdentifier:(NSString *)plotIdentifier;

@end



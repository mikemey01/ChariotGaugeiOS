//
//  CICDualChartiPadViewController.h
//  ChariotGauge
//
//  Created by Mike on 10/25/14.
//  Copyright (c) 2014 Chariot Instruments. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CICChartBuilder.h"
#import "CICBluetoothHandler.h"
#import "CICHomeScreenViewController.h"
#import "CorePlot-CocoaTouch.h"
#import "CICCalculateData.h"
#import "CICPlotBuilder.h"

@class CICChartBuilder, CICDualChartiPadViewController;

@interface CICDualChartiPadViewController : UIViewController <BluetoothDelegate, CICSelectedPointDelegate>{
    
    //Chart/Plot Handling
    CICChartBuilder *chartView;
    CICPlotBuilder *_localPlotBuilderOne;
    CICPlotBuilder *_localPlotBuilderTwo;
    CICPlotBuilder *_localPlotBuilderVolts;
    NSString *currentStringValue;
    NSInteger currentIntergerValue;
    BOOL isPaused;
    
    //Bar buttons
    UIBarButtonItem *pauseButton;
    UIBarButtonItem *playButton;
    
    //Top ribbon labels
    UILabel *chartLabel1;
    UILabel *chartLabelData1;
    UILabel *chartLabel2;
    UILabel *chartLabelData2;
    UILabel *chartVoltLabel;
    UILabel *chartVoltLabelData;
    
    //Data crunching
    CICCalculateData *calcData;
    CICCalculateData *calcDataTwo;
    CICCalculateData *calcDataVolts;
    CICBluetoothHandler *bluetooth;
    NSArray *newArray;
    
    //Prefs vars
    NSString *pressureUnits;
    NSString *widebandUnits;
    NSString *widebandFuelType;
    NSString *temperatureUnits;
    NSString *oilPressureUnits;
    NSString *gaugeOneType;
    NSString *gaugeTwoType;
    BOOL showVolts;
    BOOL isNightMode;
}

//Don't forget to assign the IBOutlets you dummy.

@property GaugeType gaugeType;
@property (nonatomic, retain) IBOutlet CICChartBuilder *chartView;
@property (nonatomic, retain) IBOutlet UILabel *chartLabel1;
@property (nonatomic, retain) IBOutlet UILabel *chartLabelData1;
@property (nonatomic, retain) IBOutlet UILabel *chartLabel2;
@property (nonatomic, retain) IBOutlet UILabel *chartLabelData2;
@property (nonatomic, retain) IBOutlet UILabel *chartVoltLabel;
@property (nonatomic, retain) IBOutlet UILabel *chartVoltLabelData;
@property (nonatomic, retain) CICBluetoothHandler *bluetooth;

-(void)setChartValue:(NSArray *)array;
-(void)addNewDataToPlot:(CICPlotBuilder *) plotBuilderIn withData:(CGFloat)newData;
-(void)setDigitalLabel:(CGFloat)value withPlotIdentifier:(NSString *)plotIdentifier;

@end

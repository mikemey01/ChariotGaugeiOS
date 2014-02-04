//
//  CICDualGaugeViewController.m
//  ChariotGauge
//
//  Created by Mike on 12/29/13.
//  Copyright (c) 2013 Chariot Instruments. All rights reserved.
//

#import "CICDualGaugeViewController.h"
#import "CICGaugeBuilder.h"
#import "CICAppDelegate.h"
#import "CICCalculateData.h"

@interface CICDualGaugeViewController ()

@end

@implementation CICDualGaugeViewController

@synthesize firstGauge, secondGauge, firstGaugeView, gaugeType, bluetooth;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


//Force landscape right for dual gauge.
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeRight;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initPrefs];
    
    //Handles forcing landscape orientation NEEDS WORK
    UIViewController *mVC = [[UIViewController alloc] init];
    [self presentModalViewController:mVC animated:NO];
    if (![mVC isBeingDismissed])
        [self dismissModalViewControllerAnimated:YES];
    
    //NSLog(@"gaugeOne: %@, gaugeTwo: %@", gaugeOneType, gaugeTwoType);
    
    if([gaugeOneType isEqualToString:@"Boost"]){
        [self createBoostGauge:self.firstGauge];
    }else if([gaugeOneType isEqualToString:@"Wideband"]){
        [self createWidebandGauge:self.firstGauge];
    }else if([gaugeOneType isEqualToString:@"Temperature"]){
        [self createTempGauge:self.firstGauge];
    }else if([gaugeOneType isEqualToString:@"Oil"]){
        [self createOilGauge:self.firstGauge];
    }
    
    if([gaugeTwoType isEqualToString:@"Boost"]){
        [self createBoostGauge:self.secondGauge];
    }else if([gaugeTwoType isEqualToString:@"Wideband"]){
        [self createWidebandGauge:self.secondGauge];
    }else if([gaugeTwoType isEqualToString:@"Temperature"]){
        [self createTempGauge:self.secondGauge];
    }else if([gaugeTwoType isEqualToString:@"Oil"]){
        [self createOilGauge:self.secondGauge];
    }
}

-(void)createBoostGauge:(CICGaugeBuilder *)gaugeView
{
    calcData = [[CICCalculateData alloc] init];
    [calcData initPrefs];
    [calcData initStoich];
    [calcData initSHHCoefficients];
    
    if([pressureUnits isEqualToString:@"PSI"]){
        [gaugeView initializeGauge];
        gaugeView.minGaugeNumber = -30.0f;
        gaugeView.maxGaugeNumber = 25.0f;
        gaugeView.gaugeLabel = @"Boost/Vac \n(PSI/inHG)";
        gaugeView.incrementPerLargeTick = 5;
        gaugeView.tickStartAngleDegrees = 135;
        gaugeView.tickDistance = 270;
    }else{
        [gaugeView initializeGauge];
        gaugeView.minGaugeNumber = 0.0f;
        gaugeView.maxGaugeNumber = 250.0f;
        gaugeView.gaugeLabel = @"Boost/Vac \n(KPA)";
        gaugeView.incrementPerLargeTick = 25;
        gaugeView.tickStartAngleDegrees = 135;
        gaugeView.tickDistance = 270;
    }
    gaugeView.lineWidth = 1;
    gaugeView.value = gaugeView.minGaugeNumber;
    gaugeView.menuItemsFont = [UIFont fontWithName:@"Futura" size:18];
    gaugeView.tickArcRadius = (gaugeView.gaugeWidth / 2) - 50;
    calcData.sensorMaxValue = gaugeView.minGaugeNumber;
}

-(void)createWidebandGauge:(CICGaugeBuilder *) gaugeView
{
    calcData = [[CICCalculateData alloc] init];
    [calcData initPrefs];
    [calcData initStoich];
    [calcData initSHHCoefficients];
    
    if([widebandUnits isEqualToString:@"Lambda"]){
        [gaugeView initializeGauge];
        gaugeView.minGaugeNumber = 0.0f;
        gaugeView.maxGaugeNumber = 2.0f;
        gaugeView.gaugeLabel = [widebandFuelType stringByAppendingString:@" Wideband \n(Lambda)"];
        gaugeView.incrementPerLargeTick = 1.0;
        gaugeView.tickStartAngleDegrees = 225;
        gaugeView.tickDistance = 90;
    }else{
        if([widebandFuelType isEqualToString:@"Gasoline"] || [widebandFuelType isEqualToString:@"Propane"] || [widebandFuelType isEqualToString:@"Diesel"]){
            [gaugeView initializeGauge];
            gaugeView.minGaugeNumber = 5.0f;
            gaugeView.maxGaugeNumber = 25.0f;
            gaugeView.gaugeLabel = [widebandFuelType stringByAppendingString:@" Wideband \n(AFR)"];
            gaugeView.incrementPerLargeTick = 5;
            gaugeView.tickStartAngleDegrees = 180;
            gaugeView.tickDistance = 180;
        }else if([widebandFuelType isEqualToString:@"Methanol"]){
            [gaugeView initializeGauge];
            gaugeView.minGaugeNumber = 3.0f;
            gaugeView.maxGaugeNumber = 8.0f;
            gaugeView.gaugeLabel = [widebandFuelType stringByAppendingString:@" Wideband \n(AFR)"];
            gaugeView.incrementPerLargeTick = 1.0;
            gaugeView.tickStartAngleDegrees = 200;
            gaugeView.tickDistance = 140;
        }else if([widebandFuelType isEqualToString:@"Ethanol"] || [widebandFuelType isEqualToString:@"E85"]){
            [gaugeView initializeGauge];
            gaugeView.minGaugeNumber = 5.0f;
            gaugeView.maxGaugeNumber = 12.0f;
            gaugeView.gaugeLabel = [widebandFuelType stringByAppendingString:@" Wideband \n(AFR)"];
            gaugeView.incrementPerLargeTick = 1.0;
            gaugeView.tickStartAngleDegrees = 180;
            gaugeView.tickDistance = 180;
        }else{
            [gaugeView initializeGauge];
            gaugeView.minGaugeNumber = 5.0f;
            gaugeView.maxGaugeNumber = 25.0f;
            gaugeView.gaugeLabel = [widebandFuelType stringByAppendingString:@" Wideband \n(AFR)"];
            gaugeView.incrementPerLargeTick = 5;
            gaugeView.tickStartAngleDegrees = 180;
            gaugeView.tickDistance = 180;
        }
    }
    gaugeView.lineWidth = 1;
    gaugeView.value = gaugeView.minGaugeNumber;
    gaugeView.menuItemsFont = [UIFont fontWithName:@"Futura" size:18];
    gaugeView.tickArcRadius = (gaugeView.gaugeWidth / 2) - 50;
    calcData.sensorMaxValue = gaugeView.minGaugeNumber;
}

-(void)createTempGauge:(CICGaugeBuilder *) gaugeView
{
    calcData = [[CICCalculateData alloc] init];
    [calcData initPrefs];
    [calcData initStoich];
    [calcData initSHHCoefficients];
    
    if([temperatureUnits isEqualToString:@"Fahrenheit"]){
        [gaugeView initializeGauge];
        gaugeView.minGaugeNumber = -20.0f;
        gaugeView.maxGaugeNumber = 220.0f;
        gaugeView.gaugeLabel = @"Temperature \n(ºF)";
        gaugeView.incrementPerLargeTick = 40;
        gaugeView.tickStartAngleDegrees = 135;
        gaugeView.tickDistance = 270;
    }else{
        [gaugeView initializeGauge];
        gaugeView.minGaugeNumber = -35.0f;
        gaugeView.maxGaugeNumber = 105.0f;
        gaugeView.gaugeLabel = @"Temperature \n(ºC)";
        gaugeView.incrementPerLargeTick = 20;
        gaugeView.tickStartAngleDegrees = 135;
        gaugeView.tickDistance = 270;
    }
    gaugeView.lineWidth = 1;
    gaugeView.value = gaugeView.minGaugeNumber;
    gaugeView.menuItemsFont = [UIFont fontWithName:@"Futura" size:18];
    gaugeView.tickArcRadius = (gaugeView.gaugeWidth / 2) - 50;
    calcData.sensorMaxValue = gaugeView.minGaugeNumber;
}

-(void)createOilGauge:(CICGaugeBuilder *) gaugeView
{
    calcData = [[CICCalculateData alloc] init];
    [calcData initPrefs];
    [calcData initStoich];
    [calcData initSHHCoefficients];
    
    [gaugeView initializeGauge];
    gaugeView.minGaugeNumber = 0.0f;
    gaugeView.maxGaugeNumber = 100.0f;
    gaugeView.gaugeLabel = @"Oil Pressure \n(PSI)";
    gaugeView.incrementPerLargeTick = 10;
    gaugeView.tickStartAngleDegrees = 135;
    gaugeView.tickDistance = 270;
    gaugeView.lineWidth = 1;
    gaugeView.value = gaugeView.minGaugeNumber;
    gaugeView.menuItemsFont = [UIFont fontWithName:@"Futura" size:18];
    gaugeView.tickArcRadius = (gaugeView.gaugeWidth / 2) - 50;
    calcData.sensorMaxValue = gaugeView.minGaugeNumber;
}

-(void) initPrefs
{
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    
    pressureUnits = [standardDefaults stringForKey:@"boost_psi_kpa"];
    widebandUnits = [standardDefaults stringForKey:@"wideband_afr_lambda"];
    widebandFuelType = [standardDefaults stringForKey:@"wideband_fuel_type"];
    temperatureUnits = [standardDefaults stringForKey:@"temperature_celsius_fahrenheit"];
    gaugeOneType = [standardDefaults stringForKey:@"twogauge_gauge_one"];
    gaugeTwoType = [standardDefaults stringForKey:@"twogauge_gauge_two"];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

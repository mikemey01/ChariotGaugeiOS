//
//  CICSingleGaugeViewController.m
//  ChariotGauge
//
//  Created by Mike on 12/19/13.
//  Copyright (c) 2013 Chariot Instruments. All rights reserved.
//


#import "CICSingleGaugeViewController.h"
#import "CICGaugeBuilder.h"
#import "CICAppDelegate.h"
#import "CICBluetoothHandler.h"
#import "CICCalculateData.h"

@interface CICSingleGaugeViewController ()

@end

@implementation CICSingleGaugeViewController

@synthesize gaugeView, gaugeType, bluetooth;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initPrefs];
    
    //set up bar button items
    maxButton = [[UIBarButtonItem alloc]
                 initWithTitle:@"Max"
                 style:UIBarButtonItemStyleBordered
                 target:self
                 action:@selector(maxButtonAction)];
    
    resetButton = [[UIBarButtonItem alloc]
                 initWithTitle:@"reset"
                 style:UIBarButtonItemStyleBordered
                 target:self
                 action:@selector(resetButtonAction)];
    
    //set the bar button items in the nav bar.
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:maxButton, resetButton, nil];
    
    //build selected gauge.
    if(gaugeType==0){
        [self createBoostGauge];
    }else if(gaugeType==1){
        [self createBoostGauge];
    }else if(gaugeType==2){
        [self createWidebandGauge];
    }else if(gaugeType==3){
        [self createTempGauge];
    }else if(gaugeType==4){
        [self createOilGauge];
    }else{
        [self createBoostGauge];
    }
    
    //Create volt gauge
    [self createVoltGauge];
    
    //set bluetooth delegate to self;
    [self.bluetooth setBtDelegate:self];
    
    //create CalculateData object and initialize it.
    calcData = [[CICCalculateData alloc] init];
    [calcData initPrefs];
    [calcData initStoich];
    [calcData initSHHCoefficients];
    
    calcDataVolts = [[CICCalculateData alloc]init];
    [calcDataVolts initPrefs];
    [calcDataVolts initStoich];
    [calcDataVolts initSHHCoefficients];
    
    
}

-(void) getLatestData:(NSMutableString *)newData
{
    if(!isPaused){
        newArray = [newData componentsSeparatedByString: @","];
        [self setGaugeValue:newArray];
        newArray = nil;
    }else{
        self.gaugeView.value = calcData.sensorMaxValue;
        [voltLabelNumbers setText:[NSString stringWithFormat:@"%.1f", calcDataVolts.sensorMaxValue]];
    }
}

-(void) setGaugeValue:(NSArray *)array
{
    if(array.count > gaugeType){
        currentStringValue = [array objectAtIndex:gaugeType];
        currentIntergerValue = [currentStringValue integerValue];
        
        if(gaugeType==0){
            self.gaugeView.value = [calcData calcVolts:currentIntergerValue];
        }else if(gaugeType==1){
            self.gaugeView.value = [calcData calcBoost:currentIntergerValue];
        }else if(gaugeType==2){
            self.gaugeView.value = [calcData calcWideBand:currentIntergerValue];
        }else if(gaugeType==3){
            self.gaugeView.value = [calcData calcTemp:currentIntergerValue];
        }else if(gaugeType==4){
            self.gaugeView.value = [calcData calcOil:currentIntergerValue];
        }
        
        //Set voltage value
        currentStringValue = [array objectAtIndex:0];
        currentIntergerValue = [currentStringValue integerValue];
        
        [voltLabelNumbers setText:[NSString stringWithFormat:@"%.1f", [calcDataVolts calcVolts:currentIntergerValue]]];
    }
}


//Handles portrait only mode.
- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
//End handling portrait only mode.


-(void)createWidebandGauge
{
    //Set nav bar title
    self.navigationItem.title = @"Wideband";
    
    if([widebandUnits isEqualToString:@"Lambda"]){
        [self.gaugeView initializeGauge];
        self.gaugeView.minGaugeNumber = 0.0f;
        self.gaugeView.maxGaugeNumber = 2.0f;
        self.gaugeView.gaugeLabel = [widebandFuelType stringByAppendingString:@" Wideband \n(Lambda)"];
        self.gaugeView.incrementPerLargeTick = 1.0;
        self.gaugeView.tickStartAngleDegrees = 225;
        self.gaugeView.tickDistance = 90;
    }else{
        if([widebandFuelType isEqualToString:@"Gasoline"] || [widebandFuelType isEqualToString:@"Propane"] || [widebandFuelType isEqualToString:@"Diesel"]){
            [self.gaugeView initializeGauge];
            self.gaugeView.minGaugeNumber = 5.0f;
            self.gaugeView.maxGaugeNumber = 25.0f;
            self.gaugeView.gaugeLabel = [widebandFuelType stringByAppendingString:@" Wideband \n(AFR)"];
            self.gaugeView.incrementPerLargeTick = 5;
            self.gaugeView.tickStartAngleDegrees = 180;
            self.gaugeView.tickDistance = 180;
        }else if([widebandFuelType isEqualToString:@"Methanol"]){
            [self.gaugeView initializeGauge];
            self.gaugeView.minGaugeNumber = 3.0f;
            self.gaugeView.maxGaugeNumber = 8.0f;
            self.gaugeView.gaugeLabel = [widebandFuelType stringByAppendingString:@" Wideband \n(AFR)"];
            self.gaugeView.incrementPerLargeTick = 1.0;
            self.gaugeView.tickStartAngleDegrees = 200;
            self.gaugeView.tickDistance = 140;
        }else if([widebandFuelType isEqualToString:@"Ethanol"] || [widebandFuelType isEqualToString:@"E85"]){
            [self.gaugeView initializeGauge];
            self.gaugeView.minGaugeNumber = 5.0f;
            self.gaugeView.maxGaugeNumber = 12.0f;
            self.gaugeView.gaugeLabel = [widebandFuelType stringByAppendingString:@" Wideband \n(AFR)"];
            self.gaugeView.incrementPerLargeTick = 1.0;
            self.gaugeView.tickStartAngleDegrees = 180;
            self.gaugeView.tickDistance = 180;
        }else{
            [self.gaugeView initializeGauge];
            self.gaugeView.minGaugeNumber = 5.0f;
            self.gaugeView.maxGaugeNumber = 25.0f;
            self.gaugeView.gaugeLabel = [widebandFuelType stringByAppendingString:@" Wideband \n(AFR)"];
            self.gaugeView.incrementPerLargeTick = 5;
            self.gaugeView.tickStartAngleDegrees = 180;
            self.gaugeView.tickDistance = 180;
        }
    }
    self.gaugeView.lineWidth = 1;
    self.gaugeView.value = self.gaugeView.minGaugeNumber;
    self.gaugeView.menuItemsFont = [UIFont fontWithName:@"Futura" size:18];
    self.gaugeView.tickArcRadius = (self.gaugeView.gaugeWidth / 2) - 50;
    calcData.sensorMaxValue = self.gaugeView.minGaugeNumber;
}

-(void)createBoostGauge
{
    //Set nav bar title
    self.navigationItem.title = @"Boost/Vac";
    
    if([pressureUnits isEqualToString:@"PSI"]){
        [self.gaugeView initializeGauge];
        self.gaugeView.minGaugeNumber = -30.0f;
        self.gaugeView.maxGaugeNumber = 25.0f;
        self.gaugeView.gaugeLabel = @"Boost/Vac \n(PSI/inHG)";
        self.gaugeView.incrementPerLargeTick = 5;
        self.gaugeView.tickStartAngleDegrees = 135;
        self.gaugeView.tickDistance = 270;
    }else{
        [self.gaugeView initializeGauge];
        self.gaugeView.minGaugeNumber = 0.0f;
        self.gaugeView.maxGaugeNumber = 250.0f;
        self.gaugeView.gaugeLabel = @"Boost/Vac \n(KPA)";
        self.gaugeView.incrementPerLargeTick = 25;
        self.gaugeView.tickStartAngleDegrees = 135;
        self.gaugeView.tickDistance = 270;
    }
    self.gaugeView.lineWidth = 1;
    self.gaugeView.value = self.gaugeView.minGaugeNumber;
    self.gaugeView.menuItemsFont = [UIFont fontWithName:@"Futura" size:18];
    self.gaugeView.tickArcRadius = (self.gaugeView.gaugeWidth / 2) - 50;
    calcData.sensorMaxValue = self.gaugeView.minGaugeNumber;
}

-(void)createOilGauge
{
    //Set nav bar title
    self.navigationItem.title = @"Oil Pressure";
    
    [self.gaugeView initializeGauge];
    self.gaugeView.minGaugeNumber = 0.0f;
    self.gaugeView.maxGaugeNumber = 100.0f;
    self.gaugeView.gaugeLabel = @"Oil Pressure \n(PSI)";
    self.gaugeView.incrementPerLargeTick = 10;
    self.gaugeView.tickStartAngleDegrees = 135;
    self.gaugeView.tickDistance = 270;
    self.gaugeView.lineWidth = 1;
    self.gaugeView.value = self.gaugeView.minGaugeNumber;
    self.gaugeView.menuItemsFont = [UIFont fontWithName:@"Futura" size:18];
    self.gaugeView.tickArcRadius = (self.gaugeView.gaugeWidth / 2) - 50;
    calcData.sensorMaxValue = self.gaugeView.minGaugeNumber;
}

-(void)createTempGauge
{
    //Set nav bar title
    self.navigationItem.title = @"Temperature";
    
    if([temperatureUnits isEqualToString:@"Fahrenheit"]){
        [self.gaugeView initializeGauge];
        self.gaugeView.minGaugeNumber = -20.0f;
        self.gaugeView.maxGaugeNumber = 220.0f;
        self.gaugeView.gaugeLabel = @"Temperature \n(ºF)";
        self.gaugeView.incrementPerLargeTick = 40;
        self.gaugeView.tickStartAngleDegrees = 135;
        self.gaugeView.tickDistance = 270;
    }else{
        [self.gaugeView initializeGauge];
        self.gaugeView.minGaugeNumber = -35.0f;
        self.gaugeView.maxGaugeNumber = 105.0f;
        self.gaugeView.gaugeLabel = @"Temperature \n(ºC)";
        self.gaugeView.incrementPerLargeTick = 20;
        self.gaugeView.tickStartAngleDegrees = 135;
        self.gaugeView.tickDistance = 270;
    }
    self.gaugeView.lineWidth = 1;
    self.gaugeView.value = self.gaugeView.minGaugeNumber;
    self.gaugeView.menuItemsFont = [UIFont fontWithName:@"Futura" size:18];
    self.gaugeView.tickArcRadius = (self.gaugeView.gaugeWidth / 2) - 50;
    calcData.sensorMaxValue = self.gaugeView.minGaugeNumber;
}

-(void)createVoltGauge
{
    CGSize sizeOfScreen = [[UIScreen mainScreen] bounds].size;
    
    UIFont *digitalFont = [UIFont fontWithName:@"LetsgoDigital-Regular" size:30.0f];
    voltLabel = [[UILabel alloc] initWithFrame:CGRectIntegral(CGRectMake(2.0f, sizeOfScreen.height-32.0f, sizeOfScreen.width/2, 30.0f))];
    [voltLabel setFont:digitalFont];
    [voltLabel setText:@"Volts"];
    
    voltLabelNumbers = [[UILabel alloc] initWithFrame:CGRectIntegral(CGRectMake(sizeOfScreen.width/2, sizeOfScreen.height-32.0f, sizeOfScreen.width/2-2, 30.0f))];
    voltLabelNumbers.textAlignment = NSTextAlignmentRight;
    [voltLabelNumbers setFont:digitalFont];
    [voltLabelNumbers setText:@"0.0"];
    
    [self.view addSubview:voltLabel];
    [self.view addSubview:voltLabelNumbers];
}

-(void)maxButtonAction
{
    isPaused = !isPaused;
}

-(void)resetButtonAction
{
    calcData.sensorMaxValue = self.gaugeView.minGaugeNumber;
}

-(void) initPrefs
{
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    
    pressureUnits = [standardDefaults stringForKey:@"boost_psi_kpa"];
    widebandUnits = [standardDefaults stringForKey:@"wideband_afr_lambda"];
    widebandFuelType = [standardDefaults stringForKey:@"wideband_fuel_type"];
    temperatureUnits = [standardDefaults stringForKey:@"temperature_celsius_fahrenheit"];
}

- (void)viewDidUnload
{
    self.gaugeView = nil;
}

- (void)didReceiveMemoryWarning
{
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

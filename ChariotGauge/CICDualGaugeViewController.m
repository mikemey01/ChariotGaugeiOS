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
#import "CICBluetoothHandler.h"

@interface CICDualGaugeViewController ()

@end

@implementation CICDualGaugeViewController

@synthesize firstGauge, secondGauge, gaugeType, bluetooth;

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
    
    //set up bar button items
    maxButton = [[UIBarButtonItem alloc]
                 initWithTitle:@"Max"
                 style:UIBarButtonItemStyleBordered
                 target:self
                 action:@selector(maxButtonAction)];
    
    resetButton = [[UIBarButtonItem alloc]
                   initWithTitle:@"Reset"
                   style:UIBarButtonItemStyleBordered
                   target:self
                   action:@selector(resetButtonAction)];
    
    //set the bar button items in the nav bar.
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:maxButton, resetButton, nil];
    
    //Handles forcing landscape orientation NEEDS WORK
    UIViewController *mVC = [[UIViewController alloc] init];
    [self presentModalViewController:mVC animated:NO];
    if (![mVC isBeingDismissed]){
        [self dismissModalViewControllerAnimated:YES];
    }
    
    //NSLog(@"gaugeOne: %@, gaugeTwo: %@", gaugeOneType, gaugeTwoType);
    
    if([gaugeOneType isEqualToString:@"Boost"]){
        [self createBoostGauge:self.firstGauge :calcDataOne];
    }else if([gaugeOneType isEqualToString:@"Wideband"]){
        [self createWidebandGauge:self.firstGauge :calcDataOne];
    }else if([gaugeOneType isEqualToString:@"Temperature"]){
        [self createTempGauge:self.firstGauge :calcDataOne];
    }else if([gaugeOneType isEqualToString:@"Oil"]){
        [self createOilGauge:self.firstGauge :calcDataOne];
    }
    
    if([gaugeTwoType isEqualToString:@"Boost"]){
        [self createBoostGauge:self.secondGauge :calcDataTwo];
    }else if([gaugeTwoType isEqualToString:@"Wideband"]){
        [self createWidebandGauge:self.secondGauge :calcDataTwo];
    }else if([gaugeTwoType isEqualToString:@"Temperature"]){
        [self createTempGauge:self.secondGauge :calcDataTwo];
    }else if([gaugeTwoType isEqualToString:@"Oil"]){
        [self createOilGauge:self.secondGauge :calcDataTwo];
    }
    
    //Create volt gauge
    if(showVolts){
        [self createVoltGauge];
    }
    
    [self.bluetooth setBtDelegate:self];
    
    if(isNightMode){
        [self.view setBackgroundColor:[UIColor colorWithRed:168.0/255.0 green:173.0/255.0 blue:190.0/255.0 alpha:1.0]];
    }else{
        [self.view setBackgroundColor:[UIColor whiteColor]];
    }
    
    calcDataOne = [[CICCalculateData alloc] init];
    [calcDataOne initPrefs];
    [calcDataOne initStoich];
    [calcDataOne initSHHCoefficients];
    
    calcDataTwo = [[CICCalculateData alloc] init];
    [calcDataTwo initPrefs];
    [calcDataTwo initStoich];
    [calcDataTwo initSHHCoefficients];
    
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
        self.firstGauge.value = calcDataOne.sensorMaxValue;
        self.secondGauge.value = calcDataTwo.sensorMaxValue;
        [voltLabelNumbers setText:[NSString stringWithFormat:@"%.1f", calcDataVolts.sensorMaxValue]];
    }
}

-(void) setGaugeValue:(NSArray *)array
{
    if(array.count >= 4){
        
        if([gaugeOneType isEqualToString:@"Boost"]){
            currentStringValue = [array objectAtIndex:1];
            currentIntergerValue = [currentStringValue integerValue];
            self.firstGauge.value = [calcDataOne calcBoost:currentIntergerValue];
        }else if([gaugeOneType isEqualToString:@"Wideband"]){
            currentStringValue = [array objectAtIndex:2];
            currentIntergerValue = [currentStringValue integerValue];
            self.firstGauge.value = [calcDataOne calcWideBand:currentIntergerValue];
        }else if([gaugeOneType isEqualToString:@"Temperature"]){
            currentStringValue = [array objectAtIndex:3];
            currentIntergerValue = [currentStringValue integerValue];
            self.firstGauge.value = [calcDataOne calcTemp:currentIntergerValue];
        }else if([gaugeOneType isEqualToString:@"Oil"]){
            currentStringValue = [array objectAtIndex:4];
            currentIntergerValue = [currentStringValue integerValue];
            self.firstGauge.value = [calcDataOne calcOil:currentIntergerValue];
        }
        
        if([gaugeTwoType isEqualToString:@"Boost"]){
            currentStringValue = [array objectAtIndex:1];
            currentIntergerValue = [currentStringValue integerValue];
            self.secondGauge.value = [calcDataTwo calcBoost:currentIntergerValue];
        }else if([gaugeTwoType isEqualToString:@"Wideband"]){
            currentStringValue = [array objectAtIndex:2];
            currentIntergerValue = [currentStringValue integerValue];
            self.secondGauge.value = [calcDataTwo calcWideBand:currentIntergerValue];
        }else if([gaugeTwoType isEqualToString:@"Temperature"]){
            currentStringValue = [array objectAtIndex:3];
            currentIntergerValue = [currentStringValue integerValue];
            self.secondGauge.value = [calcDataTwo calcTemp:currentIntergerValue];
        }else if([gaugeTwoType isEqualToString:@"Oil"]){
            currentStringValue = [array objectAtIndex:4];
            currentIntergerValue = [currentStringValue integerValue];
            self.secondGauge.value = [calcDataTwo calcOil:currentIntergerValue];
        }
        
        //Set voltage value
        currentStringValue = [array objectAtIndex:0];
        currentIntergerValue = [currentStringValue integerValue];
        
        [voltLabelNumbers setText:[NSString stringWithFormat:@"%.1f", [calcDataVolts calcVolts:currentIntergerValue]]];
    }
}

-(void)createBoostGauge:(CICGaugeBuilder *)gaugeView :(CICCalculateData *)calcData
{
    if([pressureUnits isEqualToString:@"PSI"]){
        [gaugeView initializeGauge];
        gaugeView.minGaugeNumber = -30.0f;
        gaugeView.maxGaugeNumber = 25.0f;
        gaugeView.gaugeLabel = @"Boost/Vac \n(PSI/inHG)";
        gaugeView.incrementPerLargeTick = 5;
        gaugeView.tickStartAngleDegrees = 135;
        gaugeView.tickDistance = 270;
        gaugeView.allowNegatives = NO;
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
    gaugeView.menuItemsFont = [UIFont fontWithName:@"Futura" size:16];
    gaugeView.tickArcRadius = (gaugeView.gaugeWidth / 2) - 40;
    gaugeView.needleBuilder.needleExtension = 10.0f;
    gaugeView.gaugeX = 0.0f;
    gaugeView.digitalFontSize = 30.0f;
    calcData.sensorMaxValue = gaugeView.minGaugeNumber;
}

-(void)createWidebandGauge:(CICGaugeBuilder *) gaugeView :(CICCalculateData *) calcData
{
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
            if([widebandFuelType isEqualToString:@"Gasoline"]){
                widebandFuelType = @"Gas";
            }
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
    gaugeView.menuItemsFont = [UIFont fontWithName:@"Futura" size:16];
    gaugeView.tickArcRadius = (gaugeView.gaugeWidth / 2) - 40;
    gaugeView.needleBuilder.needleExtension = 10.0f;
    gaugeView.digitalFontSize = 30.0f;
    calcData.sensorMaxValue = gaugeView.minGaugeNumber;
}

-(void)createTempGauge:(CICGaugeBuilder *) gaugeView :(CICCalculateData *) calcData
{
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
    gaugeView.menuItemsFont = [UIFont fontWithName:@"Futura" size:16];
    gaugeView.tickArcRadius = (gaugeView.gaugeWidth / 2) - 40;
    gaugeView.needleBuilder.needleExtension = 10.0f;
    gaugeView.digitalFontSize = 30.0f;
    calcData.sensorMaxValue = gaugeView.minGaugeNumber;
}

-(void)createOilGauge:(CICGaugeBuilder *) gaugeView :(CICCalculateData *) calcData
{
    [gaugeView initializeGauge];
    gaugeView.minGaugeNumber = 0.0f;
    gaugeView.maxGaugeNumber = 100.0f;
    gaugeView.gaugeLabel = @"Oil Pressure \n(PSI)";
    gaugeView.incrementPerLargeTick = 10;
    gaugeView.tickStartAngleDegrees = 135;
    gaugeView.tickDistance = 270;
    gaugeView.lineWidth = 1;
    gaugeView.value = gaugeView.minGaugeNumber;
    gaugeView.menuItemsFont = [UIFont fontWithName:@"Futura" size:16];
    gaugeView.tickArcRadius = (gaugeView.gaugeWidth / 2) - 40;
    gaugeView.needleBuilder.needleExtension = 10.0f;
    gaugeView.digitalFontSize = 30.0f;
    calcData.sensorMaxValue = gaugeView.minGaugeNumber;
}

-(void)createVoltGauge
{
    //Screen size, reverse them for landscape.
    CGSize sizeOfScreen = [[UIScreen mainScreen] bounds].size;
    CGFloat widthHolder = sizeOfScreen.width;
    sizeOfScreen.width = sizeOfScreen.height;
    sizeOfScreen.height = widthHolder;
    
    UIFont *digitalFont = [UIFont fontWithName:@"LetsgoDigital-Regular" size:20.0f];
    voltLabel = [[UILabel alloc] initWithFrame:CGRectIntegral(CGRectMake(0.0f, sizeOfScreen.height-44.0f, sizeOfScreen.width, 20.0f))];
    voltLabel.textAlignment = NSTextAlignmentCenter;
    [voltLabel setFont:digitalFont];
    [voltLabel setText:@"Volts"];
    
    voltLabelNumbers = [[UILabel alloc] initWithFrame:CGRectIntegral(CGRectMake(0.0f, sizeOfScreen.height-22.0f, sizeOfScreen.width, 20.0f))];
    voltLabelNumbers.textAlignment = NSTextAlignmentCenter;
    [voltLabelNumbers setFont:digitalFont];
    [voltLabelNumbers setText:@"0.0"];
    
    [self.view addSubview:voltLabel];
    [self.view addSubview:voltLabelNumbers];
}

-(void)maxButtonAction
{
    if(!isPaused){
        maxButton.tintColor = [UIColor redColor];
    }else{
        maxButton.tintColor = nil;
    }
    isPaused = !isPaused;
}

-(void)resetButtonAction
{
    calcDataOne.sensorMaxValue = self.firstGauge.minGaugeNumber;
    calcDataTwo.sensorMaxValue = self.secondGauge.minGaugeNumber;
    calcDataVolts.sensorMaxValue = 0.0f;
    maxButton.tintColor = nil;
    isPaused = NO;
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
    showVolts = [standardDefaults boolForKey:@"general_show_volts"];
    isNightMode = [standardDefaults boolForKey:@"general_night_mode"];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

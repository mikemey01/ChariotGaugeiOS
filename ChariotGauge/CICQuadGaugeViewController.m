//
//  CICQuadGaugeViewController.m
//  ChariotGauge
//
//  Created by Mike on 12/30/13.
//  Copyright (c) 2013 Chariot Instruments. All rights reserved.
//

#import "CICQuadGaugeViewController.h"

@interface CICQuadGaugeViewController ()

@end

@implementation CICQuadGaugeViewController

@synthesize firstGauge, secondGauge, thirdGauge, fourthGauge, gaugeType, bluetooth;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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
    
    [self createBoostGauge:firstGauge :calcDataOne];
    [self createWidebandGauge:secondGauge :calcDataTwo];
    [self createTempGauge:thirdGauge :calcDataThree];
    [self createOilGauge:fourthGauge :calcDataFour];
    
    [self createVoltGauge];
    
    [self.bluetooth setBtDelegate:self];
    
    calcDataOne = [[CICCalculateData alloc] init];
    [calcDataOne initPrefs];
    [calcDataOne initStoich];
    [calcDataOne initSHHCoefficients];
    
    calcDataTwo = [[CICCalculateData alloc] init];
    [calcDataTwo initPrefs];
    [calcDataTwo initStoich];
    [calcDataTwo initSHHCoefficients];
    
    calcDataThree = [[CICCalculateData alloc] init];
    [calcDataThree initPrefs];
    [calcDataThree initStoich];
    [calcDataThree initSHHCoefficients];
    
    calcDataFour = [[CICCalculateData alloc] init];
    [calcDataFour initPrefs];
    [calcDataFour initStoich];
    [calcDataFour initSHHCoefficients];
    
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
        self.thirdGauge.value = calcDataThree.sensorMaxValue;
        self.fourthGauge.value = calcDataFour.sensorMaxValue;
        [voltLabelNumbers setText:[NSString stringWithFormat:@"%.1f", calcDataVolts.sensorMaxValue]];
    }
}

-(void) setGaugeValue:(NSArray *)array
{
    if(array.count >= 3){
        
        //Set boost.
        currentStringValue = [array objectAtIndex:1];
        currentIntergerValue = [currentStringValue integerValue];
        self.firstGauge.value = [calcDataOne calcBoost:currentIntergerValue];
        
        //Set wideband.
        currentStringValue = [array objectAtIndex:2];
        currentIntergerValue = [currentStringValue integerValue];
        self.secondGauge.value = [calcDataTwo calcWideBand:currentIntergerValue];
        
        //Set temp.
        currentStringValue = [array objectAtIndex:3];
        currentIntergerValue = [currentStringValue integerValue];
        self.thirdGauge.value = [calcDataThree calcTemp:currentIntergerValue];
        
        //Set oil.
        currentStringValue = [array objectAtIndex:4];
        currentIntergerValue = [currentStringValue integerValue];
        self.fourthGauge.value = [calcDataFour calcOil:currentIntergerValue];
        
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
    gaugeView.menuItemsFont = [UIFont fontWithName:@"Futura" size:10];
    gaugeView.tickArcRadius = (gaugeView.gaugeWidth / 2) - 34;
    gaugeView.needleBuilder.needleExtension = 16.0f;
    gaugeView.gaugeX = 0.0f;
    gaugeView.digitalFontSize = 30.0f;
    gaugeView.gaugeLabelFont = [UIFont fontWithName:@"Helvetica" size:8.0f];
    gaugeView.needleBuilder.needleScaler = 0.5f;
    gaugeView.gaugeLabelHeight = 60.0f;
    gaugeView.kerningScaler = 0.60f;
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
    gaugeView.menuItemsFont = [UIFont fontWithName:@"Futura" size:10];
    gaugeView.tickArcRadius = (gaugeView.gaugeWidth / 2) - 34;
    gaugeView.needleBuilder.needleExtension = 16.0f;
    gaugeView.gaugeX = 0.0f;
    gaugeView.digitalFontSize = 30.0f;
    gaugeView.gaugeLabelFont = [UIFont fontWithName:@"Helvetica" size:8.0f];
    gaugeView.needleBuilder.needleScaler = 0.5f;
    gaugeView.gaugeLabelHeight = 60.0f;
    gaugeView.kerningScaler = 0.60f;
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
    gaugeView.menuItemsFont = [UIFont fontWithName:@"Futura" size:10];
    gaugeView.tickArcRadius = (gaugeView.gaugeWidth / 2) - 34;
    gaugeView.needleBuilder.needleExtension = 16.0f;
    gaugeView.gaugeX = 0.0f;
    gaugeView.digitalFontSize = 30.0f;
    gaugeView.gaugeLabelFont = [UIFont fontWithName:@"Helvetica" size:8.0f];
    gaugeView.needleBuilder.needleScaler = 0.5f;
    gaugeView.gaugeLabelHeight = 60.0f;
    gaugeView.kerningScaler = 0.60f;
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
    gaugeView.menuItemsFont = [UIFont fontWithName:@"Futura" size:10];
    gaugeView.tickArcRadius = (gaugeView.gaugeWidth / 2) - 34;
    gaugeView.needleBuilder.needleExtension = 16.0f;
    gaugeView.gaugeX = 0.0f;
    gaugeView.digitalFontSize = 30.0f;
    gaugeView.gaugeLabelFont = [UIFont fontWithName:@"Helvetica" size:8.0f];
    gaugeView.needleBuilder.needleScaler = 0.5f;
    gaugeView.gaugeLabelHeight = 60.0f;
    gaugeView.kerningScaler = 0.60f;
    calcData.sensorMaxValue = gaugeView.minGaugeNumber;
}

-(void)createVoltGauge
{
    CGSize sizeOfScreen = [[UIScreen mainScreen] bounds].size;
    
    UIFont *digitalFont = [UIFont fontWithName:@"LetsgoDigital-Regular" size:20.0f];
    voltLabel = [[UILabel alloc] initWithFrame:CGRectIntegral(CGRectMake(2.0f, sizeOfScreen.height-22.0f, sizeOfScreen.width/2, 20.0f))];
    [voltLabel setFont:digitalFont];
    [voltLabel setText:@"Volts"];
    
    voltLabelNumbers = [[UILabel alloc] initWithFrame:CGRectIntegral(CGRectMake(sizeOfScreen.width/2, sizeOfScreen.height-22.0f, sizeOfScreen.width/2-2, 20.0f))];
    voltLabelNumbers.textAlignment = NSTextAlignmentRight;
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
    calcDataThree.sensorMaxValue = self.thirdGauge.minGaugeNumber;
    calcDataFour.sensorMaxValue = self.fourthGauge.minGaugeNumber;
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
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  CICBluetoothHandler.m
//  ChariotGauge
//
//  Created by Mike on 1/12/14.
//  Copyright (c) 2014 Chariot Instruments. All rights reserved.
//

#import "CICBluetoothHandler.h"

@implementation CICBluetoothHandler

@synthesize connectPressed, stringConcat, btDelegate, periphDelegate, periphArray, stateDelegate, stateString, failedConnectCount, connectTimer;

-(void)startScan
{
    //Setup retry peripheral variables
    triedIndex = 0;
    indexAttempts = 0;
    
    //Set flag that the connect button has been pressed.
    self.connectPressed = YES;
    stringConcat = [NSMutableString stringWithString:@""];
    self.periphArray = [[NSMutableArray alloc] init];
    self.stateString = [[NSString alloc] init];
    
    //Make sure we're not already connected.
    if(self.peripheral.state != CBPeripheralStateConnected){
        //NSLog(@"starting scan/connect.");
        [self.stateDelegate getLatestBluetoothState:@"Scanning.."];
        CBCentralManager *centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
        self.centralManager = centralManager;
    }else{
        //NSLog(@"Already connected");
    }
}

-(void)stopScan
{
    [self.centralManager stopScan];
}

-(void)disconnectBluetooth
{
    if(self.peripheral.state == CBPeripheralStateConnected){
        //NSLog(@"disconnectBluetooth from BTH.");
        [self stopScan];
        if (self.peripheral.services != nil) {
            for (CBService *service in self.peripheral.services) {
                if (service.characteristics != nil) {
                    for (CBCharacteristic *characteristic in service.characteristics) {
                        if (characteristic.isNotifying) {
                            [self.peripheral setNotifyValue:NO forCharacteristic:characteristic];
                        }
                    }
                }
            }
        }
        [self.centralManager cancelPeripheralConnection:self.peripheral];
    }else{
        //NSLog(@"Not connected.");
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    //NSLog(@"Failed to connect %@", error.localizedDescription);
    [self.stateDelegate getLatestBluetoothState:@"error"];
    [self disconnectBluetooth];
}


/*
 CBCentralManagerDelegate - This is called with the CBPeripheral class as its main input parameter.
 This contains most of the information there is to know about a BLE peripheral.
*/
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    //NSLog(@"didDiscoverPeripheral BTH");
    [self addPeriphToArray:peripheral];
}

-(void)addPeriphToArray:(CBPeripheral *)periph
{
    if(!self.periphArray || ![self.periphArray count]){
        for(CBPeripheral *per in self.periphArray){
            if([periph.identifier isEqual:per.identifier]){
                return;
            }
        }
        [self.periphArray addObject:periph];
        [[self periphDelegate] getLatestPeriph:periph.name];
    }else{
        [self.periphArray addObject:periph];
        [[self periphDelegate] getLatestPeriph:periph.name];
    }
}

-(void)connectSelectedPeripheral:(NSUInteger)index
{
    if(self.periphArray.count >= index){
        triedIndex = index;
        indexAttempts = 1;
        [self.centralManager stopScan];
        [self.stateDelegate getLatestBluetoothState:@"Connecting.."];
        self.peripheral = [self.periphArray objectAtIndex:index];
        self.peripheral.delegate = self;
        [self.centralManager connectPeripheral:self.peripheral options:nil];
        //NSLog(@"peripheral name: %@", self.peripheral.name);
    }else{
        [self stopScan];
        [self.stateDelegate getLatestBluetoothState:@"Connect"];
    }
}

// method called whenever we have successfully connected to the BLE peripheral
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
	[peripheral setDelegate:self];
    [peripheral discoverServices:nil];
    [self startTimer];
}

-(void)startTimer
{
    self.connectTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                      target:self
                                                    selector:@selector(peripheralFailedToConnect)
                                                    userInfo:nil
                                                     repeats:NO];
}

-(void)stopTimer
{
    [self.connectTimer invalidate];
    self.connectTimer = nil;
    triedIndex = 0;
    indexAttempts = 0;
}

-(void)peripheralFailedToConnect
{
    //TODO: this needs more testing. try another index if the first doesn't work.
    if(indexAttempts == 1 && self.periphArray.count > 1){
        if(triedIndex == 1){triedIndex = 0;}
        if(triedIndex == 0){triedIndex = 1;}
        [self connectSelectedPeripheral:triedIndex];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Chariot Gauge"
                                                        message:@"Failed to Connect, please try again. If the problem persists you may need to restart the device."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [self.stateDelegate getLatestBluetoothState:@"Connect"];
    }
}

// CBPeripheralDelegate - Invoked when you discover the peripheral's available services.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if(error != nil){
        //NSLog(@"error in didDiscoverServices: %@", error);
        [self.stateDelegate getLatestBluetoothState:@"error"];
        [self stopTimer];
        return;
    }
    [self.stateDelegate getLatestBluetoothState:@"Service Found"];
	for (CBService *service in peripheral.services) {
		[peripheral discoverCharacteristics:nil forService:service];
        //NSLog(@"Services present on periph: %@", service);
	}
}

// Invoked when you discover the characteristics of a specified service.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if(error != nil){
        //NSLog(@"Error in didDisconverCharForService: %@", error);
        [self.stateDelegate getLatestBluetoothState:@"error"];
        [self stopTimer];
        return;
    }
    
    [self.stateDelegate getLatestBluetoothState:@"Characteristic Found"];
    for (CBCharacteristic *aChar in service.characteristics){
        //NSLog(@" characteristic present: %@", aChar);
        [self.peripheral setNotifyValue:YES forCharacteristic:aChar];
        [self.peripheral readValueForCharacteristic:aChar];
    }
}

// Invoked when you retrieve a specified characteristic's value, or when the peripheral device notifies your app that the characteristic's value has changed.
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(error != nil){
        [self.stateDelegate getLatestBluetoothState:@"error"];
        //NSLog(@"error in didUpdateValueForChar");
    }
    
    [self stopTimer];
    [self.stateDelegate getLatestBluetoothState:@"Connected!"];
    [self parseValue:characteristic];
}

- (void)parseValue:(CBCharacteristic *)characteristic
{
    NSData *_data = characteristic.value;
    for (int i = 0; i < _data.length; i++) {
        unsigned char _byte;
        [_data getBytes:&_byte range:NSMakeRange(i, 1)];
        if (_byte > 13 && _byte < 127) {
            [stringConcat appendFormat:@"%c", _byte];
        }else if(_byte == 10){
            [[self btDelegate] getLatestData:stringConcat];
            //NSLog(@"testing..%@", stringConcat);
            stringConcat = [NSMutableString stringWithString:@""];
        }
    }
}

// method called whenever the device state changes.
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
	// Determine the state of the peripheral
	if ([central state] == CBCentralManagerStatePoweredOff) {
		//NSLog(@"CoreBluetooth BLE hardware is powered off");
        if(connectPressed){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bluetooth Status" message:@"Bluetooth is turned off, please turn on in Settings" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [self.stateDelegate getLatestBluetoothState:@"bluetoothOff"];
        }
	}
	else if ([central state] == CBCentralManagerStatePoweredOn) {
		//NSLog(@"CoreBluetooth BLE hardware is powered on and ready");
        [self.centralManager scanForPeripheralsWithServices:nil options:nil];
	}
	else if ([central state] == CBCentralManagerStateUnauthorized) {
		//NSLog(@"CoreBluetooth BLE state is unauthorized");
	}
	else if ([central state] == CBCentralManagerStateUnknown) {
		//NSLog(@"CoreBluetooth BLE state is unknown");
	}
	else if ([central state] == CBCentralManagerStateUnsupported) {
		//NSLog(@"CoreBluetooth BLE hardware is unsupported on this platform");
	}
}


@end

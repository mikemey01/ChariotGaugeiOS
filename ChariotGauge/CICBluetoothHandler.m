//
//  CICBluetoothHandler.m
//  ChariotGauge
//
//  Created by Mike on 1/12/14.
//  Copyright (c) 2014 Chariot Instruments. All rights reserved.
//

#import "CICBluetoothHandler.h"

@implementation CICBluetoothHandler

@synthesize connectPressed, stringConcat, btDelegate, peripheralDictionary;

-(void)startScan
{
    //Set flag that the connect button has been pressed.
    self.connectPressed = YES;
    stringConcat = [NSMutableString stringWithString:@""];
    self.peripheralDictionary = [[NSMutableDictionary alloc] init]; //used for collecting peripherals if there are multiples.
    
    //Make sure we're not already connected.
    if(self.peripheral.state != CBPeripheralStateConnected){
        NSLog(@"starting scan/connect.");
        CBCentralManager *centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
        [centralManager scanForPeripheralsWithServices:nil options:nil];
        self.centralManager = centralManager;
    }else{
        NSLog(@"Already connected");
    }
}

-(void)stopScan
{
    [self.centralManager stopScan];
}

-(void)disconnectBluetooth
{
    if(self.peripheral.state == CBPeripheralStateConnected){
        NSLog(@"disconnecting.");
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
    }else{
        NSLog(@"Not connected.");
    }
    [self.centralManager cancelPeripheralConnection:self.peripheral];
    
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Failed to connect %@", error.localizedDescription);
    [self disconnectBluetooth];
}


/*
 CBCentralManagerDelegate - This is called with the CBPeripheral class as its main input parameter.
 This contains most of the information there is to know about a BLE peripheral.
*/
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSInteger numEntries;
    [self addPeripheralToDictionary:peripheral];
    numEntries = [self.peripheralDictionary count];
    if(numEntries == 1){
        [self connectSelectedPeripheral:peripheral];
    }else{
        //TODO: pop open UIActionSheet.
    }
}

-(void)addPeripheralToDictionary:(CBPeripheral *)peripheral
{
    NSString *peripheralUUID = [[NSString alloc] initWithString:[peripheral.identifier UUIDString]];
    [self.peripheralDictionary setObject:peripheral forKey:peripheralUUID];
}

-(void)connectSelectedPeripheral:(CBPeripheral *)peripheral
{
    [self.centralManager stopScan]; //Should keep scanning for a period of time.
    peripheral.delegate = self;
    self.peripheral = peripheral;
    [self.centralManager connectPeripheral:peripheral options:nil];
    NSLog(@"peripheral name: %@", peripheral.name);
}

// method called whenever we have successfully connected to the BLE peripheral
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@" connected status: connected: YES");
    
	[peripheral setDelegate:self];
    [peripheral discoverServices:nil];
}

// CBPeripheralDelegate - Invoked when you discover the peripheral's available services.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if(error != nil){
        NSLog(@"error in didDiscoverServices: %@", error);
    }
    
	for (CBService *service in peripheral.services) {
		[peripheral discoverCharacteristics:nil forService:service];
        NSLog(@"Services present on periph: %@", service);
	}
}

// Invoked when you discover the characteristics of a specified service.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if(error != nil){
        NSLog(@"Error in didDisconverCharForService: %@", error);
    }
    
    for (CBCharacteristic *aChar in service.characteristics)
    {
        NSLog(@" characteristic present: %@", aChar);
        [self.peripheral setNotifyValue:YES forCharacteristic:aChar];
        [self.peripheral readValueForCharacteristic:aChar];
    }
}

// Invoked when you retrieve a specified characteristic's value, or when the peripheral device notifies your app that the characteristic's value has changed.
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
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
		NSLog(@"CoreBluetooth BLE hardware is powered off");
        if(connectPressed){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bluetooth Status" message:@"Bluetooth is turned off, please turn on in Settings" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
	}
	else if ([central state] == CBCentralManagerStatePoweredOn) {
		NSLog(@"CoreBluetooth BLE hardware is powered on and ready");
	}
	else if ([central state] == CBCentralManagerStateUnauthorized) {
		NSLog(@"CoreBluetooth BLE state is unauthorized");
	}
	else if ([central state] == CBCentralManagerStateUnknown) {
		NSLog(@"CoreBluetooth BLE state is unknown");
	}
	else if ([central state] == CBCentralManagerStateUnsupported) {
		NSLog(@"CoreBluetooth BLE hardware is unsupported on this platform");
	}
}


@end

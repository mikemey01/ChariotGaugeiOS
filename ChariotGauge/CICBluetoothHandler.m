//
//  CICBluetoothHandler.m
//  ChariotGauge
//
//  Created by Mike on 1/12/14.
//  Copyright (c) 2014 Chariot Instruments. All rights reserved.
//

#import "CICBluetoothHandler.h"

@implementation CICBluetoothHandler

@synthesize connectPressed;

-(void)startScan
{
    //Set flag that the connect button has been pressed.
    self.connectPressed = YES;
    
    //Make sure we're not already connected.
    if(self.peripheral.state != CBPeripheralStateConnected){
        NSLog(@"starting scan/connect.");
        // Create centreal object
        CBCentralManager *centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:@{CBCentralManagerOptionShowPowerAlertKey:[NSNumber numberWithBool:NO]}];
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
        [self stopScan];
        [self.centralManager cancelPeripheralConnection:self.peripheral];
        NSLog(@"Disconnecting");
    }else{
        NSLog(@"Not Connected, can't disconnect");
    }
}


/*
 CBCentralManagerDelegate - This is called with the CBPeripheral class as its main input parameter.
 This contains most of the information there is to know about a BLE peripheral.
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
	NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
	if (![localName isEqual:@""]) { //if a device is found -- connect.
		[self.centralManager stopScan];
		self.peripheral = peripheral;
		peripheral.delegate = self;
		[self.centralManager connectPeripheral:peripheral options:nil];
        NSLog(@"peripheral name: %@", localName);
	}
}

// method called whenever we have successfully connected to the BLE peripheral
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
	[peripheral setDelegate:self];
    [peripheral discoverServices:nil];
	self.connected = [NSString stringWithFormat:@"Connected: %@", peripheral.state == CBPeripheralStateConnected ? @"YES" : @"NO"];
    
    NSLog(@" connected status: %@", self.connected);
}

// CBPeripheralDelegate - Invoked when you discover the peripheral's available services.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
	for (CBService *service in peripheral.services) {
		[peripheral discoverCharacteristics:nil forService:service];
	}
    
    NSLog(@"peripheral services: %@", peripheral.services);
}

// Invoked when you discover the characteristics of a specified service.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
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
    //TODO: DO NOTHING FOR NOW--
    
    NSString *uuid = [[NSString alloc]init];
    
    //uuid = characteristic.value;
    
    NSLog(@"characteristic data: %@", characteristic.value);
    
    
    //	// Updated value for heart rate measurement received
    //	if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:POLARH7_HRM_NOTIFICATIONS_SERVICE_UUID]]) { // 1
    //		// Get the Heart Rate Monitor BPM
    //		[self getHeartBPMData:characteristic error:error];
    //	}
    //	// Retrieve the characteristic value for manufacturer name received
    //    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:POLARH7_HRM_MANUFACTURER_NAME_UUID]]) {  // 2
    //		[self getManufacturerName:characteristic];
    //    }
    //	// Retrieve the characteristic value for the body sensor location received
    //	else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:POLARH7_HRM_BODY_LOCATION_UUID]]) {  // 3
    //		[self getBodyLocation:characteristic];
    //    }
    //
    //	// Add our constructed device information to our UITextView
    //	self.deviceInfo.text = [NSString stringWithFormat:@"%@\n%@\n%@\n", self.connected, self.bodyData, self.manufacturer];  // 4
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

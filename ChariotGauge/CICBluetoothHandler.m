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
//    if(self.peripheral.state == CBPeripheralStateConnected){
//        [self stopScan];
//        NSLog(@"Disconnecting");
//    }else{
//        NSLog(@"Not Connected, can't disconnect");
//    }
    // See if we are subscribed to a characteristic on the peripheral
    NSLog(@"disconnecting.");
    [self stopScan];
    if (self.peripheral.services != nil) {
        for (CBService *service in self.peripheral.services) {
            if (service.characteristics != nil) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    if (characteristic.isNotifying) {
                        [self.peripheral setNotifyValue:NO forCharacteristic:characteristic];
                        return;
                    }
                }
            }
        }
    }
    [self.centralManager cancelPeripheralConnection:self.peripheral];
    self.characteristic = nil;
    self.peripheral = nil;
    self.centralManager = nil;
    
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Failed to connect %@", error.localizedDescription);
    //[self cleanup];
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
		self.peripheral.delegate = self;
		[self.centralManager connectPeripheral:peripheral options:nil];
        NSLog(@"peripheral name: %@", localName);
	}
}

// method called whenever we have successfully connected to the BLE peripheral
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    //self.connected = [NSString stringWithFormat:@"Connected: %@", peripheral.state == CBPeripheralStateConnected ? @"YES" : @"NO"];
    NSLog(@" connected status: connected: YES");
    
	[peripheral setDelegate:self];
    [peripheral discoverServices:nil];
}

// CBPeripheralDelegate - Invoked when you discover the peripheral's available services.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSLog(@"Error: %@", error);
	//for (CBService *service in peripheral.services) {
		[peripheral discoverCharacteristics:nil forService:peripheral.services[0]];
	//}
    
    NSLog(@"peripheral services: %@", peripheral.services);
}

// Invoked when you discover the characteristics of a specified service.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSLog(@"Error: %@", error);
    //for (CBCharacteristic *aChar in service.characteristics)
    //{
        NSLog(@" characteristic present: %@", service.characteristics[0]);
        self.characteristic = service.characteristics[0];
        [self.peripheral setNotifyValue:YES forCharacteristic:self.characteristic];
        [self.peripheral readValueForCharacteristic:self.characteristic];
    //}
}

// Invoked when you retrieve a specified characteristic's value, or when the peripheral device notifies your app that the characteristic's value has changed.
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
    NSLog(@"stupid shit: %@", characteristic.value);
    NSLog(@"Error: %@", error);

//    NSData *_data = characteristic.value;
//    NSMutableString *_string = [NSMutableString stringWithString:@""];
//    for (int i = 0; i < _data.length; i++) {
//        unsigned char _byte;
//        [_data getBytes:&_byte range:NSMakeRange(i, 1)];
////        if(_byte != 44){
////            [_string appendFormat:@"%c", _byte];
////        }else{
////            [_string appendFormat:@"%c", 77];
////        }
//        if (_byte >= 32 && _byte < 127) {
//            [_string appendFormat:@"%c", _byte];
//        } else {
//            [_string appendFormat:@"[%d]", _byte];
//        }
//    }
//    NSLog(@"%@", _string);
    
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

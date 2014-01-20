//
//  CICBluetoothHandler.h
//  ChariotGauge
//
//  Created by Mike on 1/12/14.
//  Copyright (c) 2014 Chariot Instruments. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreBluetooth;

@interface CICBluetoothHandler : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>{
    BOOL connectPressed;
    NSString *stringValue;
    NSMutableString *stringConcat;
}

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) NSString   *connected;
@property (nonatomic, assign) BOOL connectPressed;

@property (nonatomic, retain) NSMutableString *stringConcat;

-(void)startScan;
-(void)stopScan;
-(void)disconnectBluetooth;
-(void)parseValue:(CBCharacteristic *)characteristic;


@end

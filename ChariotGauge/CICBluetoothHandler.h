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
}

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) NSString   *connected;
@property (nonatomic, assign) BOOL connectPressed;

-(void)startScan;
-(void)stopScan;
-(void)disconnectBluetooth;


@end

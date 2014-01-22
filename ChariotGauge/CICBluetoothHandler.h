//
//  CICBluetoothHandler.h
//  ChariotGauge
//
//  Created by Mike on 1/12/14.
//  Copyright (c) 2014 Chariot Instruments. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreBluetooth;

@protocol BluetoothDelegate <NSObject>
@required
- (void) getLatestData: (NSMutableString *)newData;
@end

@interface CICBluetoothHandler : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>{
    BOOL connectPressed;
    NSString *stringValue;
    NSMutableString *stringConcat;
    
    id <BluetoothDelegate> btDelegate;
}

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) NSString   *connected;
@property (nonatomic, assign) BOOL connectPressed;

@property (nonatomic, retain) NSMutableString *stringConcat;

@property (nonatomic, retain) id btDelegate;

-(void)startScan;
-(void)stopScan;
-(void)disconnectBluetooth;
-(void)parseValue:(CBCharacteristic *)characteristic;


@end

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

@protocol PeriphDelegate <NSObject>
@required
-(void)getLatestPeriph: (NSString *)periphName;
@end

@interface CICBluetoothHandler : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>{
    BOOL connectPressed;
    NSString *stringValue;
    NSMutableString *stringConcat;
    NSMutableArray *periphArray;
    
    id <BluetoothDelegate> btDelegate;
    id <PeriphDelegate> periphDelegate;
}

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) NSString   *connected;
@property (nonatomic, assign) BOOL connectPressed;
@property (nonatomic, retain) NSMutableString *stringConcat;
@property (nonatomic, retain) id btDelegate;
@property (nonatomic, retain) id periphDelegate;
@property (nonatomic, retain) NSMutableArray *periphArray;


-(void)startScan;
-(void)stopScan;
-(void)disconnectBluetooth;
-(void)parseValue:(CBCharacteristic *)characteristic;

-(void)addPeriphToArray:(CBPeripheral *)periph;
-(void)connectSelectedPeripheral:(NSUInteger)index;


@end

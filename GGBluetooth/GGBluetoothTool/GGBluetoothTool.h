//
//  GGBluetoothTool.h
//  GGBluetooth
//
//  Created by 洪冬介 on 2018/3/14.
//  Copyright © 2018年 洪冬介. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GGPeripheral.h"

@class GGBluetoothTool;
@protocol GGBluetoothToolDelegate<NSObject>

- (void)bluetoothTool:(GGBluetoothTool*)bluetoothTool discoverPeripheralDevices:(NSArray<GGPeripheral*>*)devices;

@end


@interface GGBluetoothTool : NSObject

@property (nonatomic, weak) id<GGBluetoothToolDelegate> delegate;


///扫描外设
- (void)discover;

///连接外设
- (void)connectPeripheral:(NSString*)identify;

///中心设备停止扫描
- (void)stopScan;
///断开某个外部设备的连接
- (void)disConnectionWithPeripheral:(CBPeripheral *)peripheral;

@end

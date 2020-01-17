//
//  GGPeripheral.h
//  GGBluetooth
//
//  Created by 洪冬介 on 2018/3/14.
//  Copyright © 2018年 洪冬介. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface GGPeripheral : NSObject

///设备名称
@property (nonatomic, copy) NSString *name;
///设备识别号
@property (nonatomic, copy) NSString *identifier;
///广播数据
@property (nonatomic, strong) NSDictionary *advertisementData;
///型号强度
@property (nonatomic, strong) NSNumber *RSSI;
///外部设备
@property (nonatomic, strong) CBPeripheral *peripheral;
///连接状态
@property (nonatomic, assign) BOOL isConnected;


@end

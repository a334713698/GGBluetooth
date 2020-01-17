//
//  GGBluetoothTool.m
//  GGBluetooth
//
//  Created by 洪冬介 on 2018/3/14.
//  Copyright © 2018年 洪冬介. All rights reserved.
//

#import "GGBluetoothTool.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface GGBluetoothTool()<CBCentralManagerDelegate,CBPeripheralDelegate>

//系统蓝牙设备管理对象，可以把他理解为主设备，通过他，可以去扫描和链接外设
@property (nonatomic, strong) CBCentralManager *manager;


////用于保存被发现设备的CBPeripheral数组
//@property (nonatomic, strong) NSMutableArray<CBPeripheral*> *peripherals;
@property (nonatomic, strong) CBPeripheral *connectedPeripheral;


//用于保存被发现设备字典(以identity为key)
@property (nonatomic, strong) NSMutableDictionary<NSString *, GGPeripheral*> *optionalPeripheralsDic;

@end


@implementation GGBluetoothTool{
    NSInteger _count;
}

#pragma mark - lazy load
//- (NSMutableArray *)peripherals{
//    if (!_peripherals) {
//        _peripherals = [NSMutableArray array];
//    }
//    return _peripherals;
//}

- (NSMutableDictionary<NSString *, GGPeripheral*> *)optionalPeripheralsDic{
    if (!_optionalPeripheralsDic) {
        _optionalPeripheralsDic = [NSMutableDictionary dictionary];
    }
    return _optionalPeripheralsDic;
}


#pragma mark - initialize




#pragma mark - Method
///扫描外设
- (void)discover{
    //初始化并设置委托和线程队列，最好一个线程的参数可以为nil，默认会就main线程
    self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
}

///连接外设
- (void)connectPeripheral:(NSString*)identify{
    
    /*
     一个主设备最多能连7个外设，每个外设最多只能给一个主设备连接,连接成功，失败，断开会进入各自的委托
     */
    
    CBPeripheral* peripheral = self.optionalPeripheralsDic[identify].peripheral;
    
    //找到的设备必须持有它，否则CBCentralManager中也不会保存peripheral，那么CBPeripheralDelegate中的方法也不会被调用！！
//    [self.peripherals addObject:peripheral];
    
    self.connectedPeripheral = peripheral;
    
    //连接设备
    [self.manager connectPeripheral:peripheral options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];

}

///停止扫描
- (void)stopScan{
    [self.manager stopScan];
}
///断开连接
- (void)disConnectionWithPeripheral:(CBPeripheral *)peripheral{
    [self.manager cancelPeripheralConnection:peripheral];
}

///收集被扫描到的设备
- (void)addingOptionalPeripherals:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    NSString* identity = peripheral.identifier.UUIDString;
    GGPeripheral* gg_peripheral = self.optionalPeripheralsDic[identity];
    if (!gg_peripheral) {
        gg_peripheral = [GGPeripheral new];
        gg_peripheral.identifier = identity;
        [self.optionalPeripheralsDic setValue:gg_peripheral forKey:identity];
    }
    gg_peripheral.name = peripheral.name;
    gg_peripheral.advertisementData = advertisementData;
    gg_peripheral.RSSI = RSSI;
    gg_peripheral.peripheral = peripheral;
    
    if (self.optionalPeripheralsDic.allKeys.count && _count != self.optionalPeripheralsDic.allKeys.count) {
        _count = self.optionalPeripheralsDic.allKeys.count;
        //返回设备数组allValues
        if ([self.delegate respondsToSelector:@selector(bluetoothTool:discoverPeripheralDevices:)]) {
            [self.delegate bluetoothTool:self discoverPeripheralDevices:self.optionalPeripheralsDic.allValues];
        }
    }
}

#pragma mark - 主设备的委托 CBCentralManagerDelegate
/**
 *  1.扫描外设（discover）
 */


// 扫描外设的方法我们放在centralManager成功打开的委托中，因为只有设备成功打开，才能开始扫描，否则会报错。
-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    
    switch (central.state) {
        case CBManagerStateUnknown:
            NSLog(@">>>CBManagerStateUnknown");
            break;
        case CBManagerStateResetting:
            NSLog(@">>>CBManagerStateResetting");
            break;
        case CBManagerStateUnsupported:
            NSLog(@">>>CBManagerStateUnsupported");
            break;
        case CBManagerStateUnauthorized:
            NSLog(@">>>CBManagerStateUnauthorized");
            break;
        case CBManagerStatePoweredOff:
            NSLog(@">>>CBManagerStatePoweredOff");
            break;
        case CBManagerStatePoweredOn:
            NSLog(@">>>CBManagerStatePoweredOn");
            //开始扫描周围的外设
            /*
             第一个参数nil就是扫描周围所有的外设，扫描到外设后会进入
             - (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI;
             */
            [self.manager scanForPeripheralsWithServices:nil options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
            
            break;
        default:
            break;
    }
    
}

/**
 *  2.连接外设(connect)
 */

// 扫描到设备会进入方法
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    
    NSLog(@"================================");
    NSLog(@"名称:%@",peripheral.name);
    NSLog(@"识别号:%@",peripheral.identifier.UUIDString);
    NSLog(@"广播数据:%@",advertisementData);
    NSLog(@"信号强度:%@",RSSI);
    
    if (peripheral.identifier.UUIDString) {
        [self addingOptionalPeripherals:peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI];
    }
}

// 连接到Peripherals-失败
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@">>>连接到名称为（%@）的设备-失败,原因:%@",[peripheral name],[error localizedDescription]);
}

// Peripherals断开连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@">>>外设连接断开连接 %@: %@\n", [peripheral name], [error localizedDescription]);
    [self connectPeripheral:self.connectedPeripheral.identifier.UUIDString];
}

// 连接到Peripherals-成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    NSLog(@">>>连接到名称为（%@）的设备-成功",peripheral.name);
    
    //设置的peripheral委托CBPeripheralDelegate
    //@interface ViewController : UIViewController<CBCentralManagerDelegate,CBPeripheralDelegate>
    [peripheral setDelegate:self];
    //扫描外设Services，成功后会进入方法：-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    [peripheral discoverServices:nil];
    
    [self stopScan];
}


#pragma mark - 外设的委托 CBPeripheralDelegate
/**
 *  3.扫描外设中的服务和特征(discover)
 */

// 扫描到Services
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    //  NSLog(@">>>扫描到服务：%@",peripheral.services);
    if (error)
    {
        NSLog(@">>>Discovered services for %@ with error: %@", peripheral.name, [error localizedDescription]);
        return;
    }
    
    for (CBService *service in peripheral.services) {
        NSLog(@"%@",service.UUID);
        //扫描每个service的Characteristics，扫描到后会进入方法：
        //-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
        [peripheral discoverCharacteristics:nil forService:service];
    }
    
}

// 扫描到Characteristics
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if (error)
    {
        NSLog(@"error Discovered characteristics for %@ with error: %@", service.UUID, [error localizedDescription]);
        return;
    }
    
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        NSLog(@"service:%@ 的 Characteristic: %@",service.UUID,characteristic.UUID);
    }
    
//    //获取Characteristic的值，读到数据会进入方法：
//    //-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
//    for (CBCharacteristic *characteristic in service.characteristics){
//        {
//            [peripheral readValueForCharacteristic:characteristic];
//        }
//    }
//
//    //搜索Characteristic的Descriptors，读到数据会进入方法：
//    //-(void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
//    for (CBCharacteristic *characteristic in service.characteristics){
//        [peripheral discoverDescriptorsForCharacteristic:characteristic];
//    }
    for (CBCharacteristic *characteristic in service.characteristics){
        //获取Characteristic的值，读到数据会进入方法：
        //-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
        [peripheral readValueForCharacteristic:characteristic];
        
        //搜索Characteristic的Descriptors，读到数据会进入方法：
        //-(void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
        [peripheral discoverDescriptorsForCharacteristic:characteristic];
    }
    
    
}

// 获取的charateristic的值
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    //打印出characteristic的UUID和值
    //!注意，value的类型是NSData，具体开发时，会根据外设协议制定的方式去解析数据
    NSLog(@"characteristic uuid:%@  value:%@",characteristic.UUID,characteristic.value);
    
    NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];

    NSLog(@"characteristic.value：%@",stringFromData);
}

// 搜索到Characteristic的Descriptors
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
    //打印出Characteristic和他的Descriptors
    NSLog(@"characteristic uuid:%@",characteristic.UUID);
    for (CBDescriptor *d in characteristic.descriptors) {
        NSLog(@"Descriptor uuid:%@",d.UUID);
        
        [peripheral readValueForDescriptor:d];
    }
}

// 获取到Descriptors的值
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error{
    //打印出DescriptorsUUID 和value
    //这个descriptor都是对于characteristic的描述，一般都是字符串，所以这里我们转换成字符串去解析
    NSLog(@"characteristic uuid:%@  value:%@",[NSString stringWithFormat:@"%@",descriptor.UUID],descriptor.value);
}

#pragma mark - 其他 Other（自定义方法）
/**
 *  4.把数据写到Characteristic中
 */
//写数据
-(void)writeCharacteristic:(CBPeripheral *)peripheral
            characteristic:(CBCharacteristic *)characteristic
                     value:(NSData *)value{
    
    //打印出 characteristic 的权限，可以看到有很多种，这是一个NS_OPTIONS，就是可以同时用于好几个值，常见的有read，write，notify，indicate，知知道这几个基本就够用了，前连个是读写权限，后两个都是通知，两种不同的通知方式。
    /*
     typedef NS_OPTIONS(NSUInteger, CBCharacteristicProperties) {
     CBCharacteristicPropertyBroadcast                                                = 0x01,
     CBCharacteristicPropertyRead                                                    = 0x02,
     CBCharacteristicPropertyWriteWithoutResponse                                    = 0x04,
     CBCharacteristicPropertyWrite                                                    = 0x08,
     CBCharacteristicPropertyNotify                                                    = 0x10,
     CBCharacteristicPropertyIndicate                                                = 0x20,
     CBCharacteristicPropertyAuthenticatedSignedWrites                                = 0x40,
     CBCharacteristicPropertyExtendedProperties                                        = 0x80,
     CBCharacteristicPropertyNotifyEncryptionRequired NS_ENUM_AVAILABLE(NA, 6_0)        = 0x100,
     CBCharacteristicPropertyIndicateEncryptionRequired NS_ENUM_AVAILABLE(NA, 6_0)    = 0x200
     };
     
     */
    NSLog(@"%lu", (unsigned long)characteristic.properties);
    
    
    //只有 characteristic.properties 有write的权限才可以写
    if(characteristic.properties & CBCharacteristicPropertyWrite){
        /*
         最好一个type参数可以为CBCharacteristicWriteWithResponse或type:CBCharacteristicWriteWithResponse,区别是是否会有反馈
         */
        [peripheral writeValue:value forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
    }else{
        NSLog(@"该字段不可写！");
    }
}



/**
 *  5.订阅Characteristic的通知
 */
//设置通知
-(void)notifyCharacteristic:(CBPeripheral *)peripheral
             characteristic:(CBCharacteristic *)characteristic{
    //设置通知，数据通知会进入：didUpdateValueForCharacteristic方法
    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"~~");
}

//取消通知
-(void)cancelNotifyCharacteristic:(CBPeripheral *)peripheral
                   characteristic:(CBCharacteristic *)characteristic{
    
    [peripheral setNotifyValue:NO forCharacteristic:characteristic];
}

////停止扫描并断开连接
//-(void)disconnectPeripheral:(CBCentralManager *)centralManager
//                 peripheral:(CBPeripheral *)peripheral{
//    //停止扫描
//    [centralManager stopScan];
//    //断开连接
//    [centralManager cancelPeripheralConnection:peripheral];
//}

@end

//
//  GNRBlueToothManager.m
//  BlueToothDemo
//
//  Created by LvYuan on 2017/4/19.
//  Copyright © 2017年 UUPaotui. All rights reserved.
//
/**
 1. 建立中心角色
 2. 扫描外设（discover）
 3. 连接外设(connect)
 4. 扫描外设中的服务和特征(discover)
 - 4.1 获取外设的services
 - 4.2 获取外设的Characteristics,获取Characteristics的值，获取Characteristics的Descriptor和Descriptor的值
 5. 与外设做数据交互(explore and interact)
 6. 订阅Characteristic的通知
 7. 断开连接(disconnect)
 */

#import "GNRBLECentralManager.h"

@interface GNRBLECentralManager ()<CBCentralManagerDelegate,CBPeripheralDelegate>

@property (nonatomic, strong)NSMutableArray <CBUUID *>* serivices;//当前搜索的serviceUUIDs

@property (nonatomic, strong)CBUUID * currentServiceUUID;
@property (nonatomic, strong)CBUUID * currentCharacteristicUUID;

@property (nonatomic, copy)GNRBLEScanSucceeBlock scanBlock;
@property (nonatomic, copy)GNRBLEScanErrorBlock errorBlock;
@property (nonatomic, copy)GNRBLEConnectCompletion connectCompletion;

@property (nonatomic, copy)GNRBLEDiscoverServiceCompletion discoverServiceCompletion;
@property (nonatomic, copy)GNRBLEDiscoverCharacteristicCompletion characteristicCompletion;
@property (nonatomic, copy)GNRBLEReadCharacteristicCompletion readValueCompletion;
@property (nonatomic, copy)GNRBLENotifyCompletion notifyCompletion;
@property (nonatomic, strong)CBCentralManager * centralManager;//设备中心管理者
@property (nonatomic, strong)NSMutableArray <GNRPeripheral *>* peripherals;//外设

@end

@implementation GNRBLECentralManager

+ (instancetype)manager{
    static GNRBLECentralManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init{
    self = [super init];
    if (self) {
    }
    return self;
}

//getter
- (NSMutableArray *)peripherals{
    if (!_peripherals) {
        _peripherals = [NSMutableArray array];
    }
    return _peripherals;
}

//扫描
- (instancetype)starScanPeripheralSuccee:(GNRBLEScanSucceeBlock)block error:(GNRBLEScanErrorBlock)errorBlock{
    _scanBlock = nil;
    _scanBlock = [block copy];
    _errorBlock = nil;
    _errorBlock = [errorBlock copy];
    [self setup];
    return self;
}

//链接该设备
- (instancetype)connect:(GNRPeripheral *)peripheral
       services:(NSArray <NSString *>*)services
     completion:(GNRBLEConnectCompletion)completion{
    _connectCompletion = nil;
    _connectCompletion = [completion copy];
    [self connect:peripheral.peripheral services:services];
    return self;
}

/**
 扫描特征
 */
- (instancetype)scanCharacteristicForPeripheral:(GNRPeripheral *)peripheral
                            serviceUUID:(NSString *)serviceUUID
                     characteristicUUID:(NSString *)characteristicUUID
              discoverServiceCompletion:(GNRBLEDiscoverServiceCompletion)completion
       discoverCharacteristicCompletion:(GNRBLEDiscoverCharacteristicCompletion)discoverCharacteristicCompletion{
    _discoverServiceCompletion = nil;
    _discoverServiceCompletion = [completion copy];
    _characteristicCompletion = nil;
    _characteristicCompletion = [discoverCharacteristicCompletion copy];
    _currentServiceUUID = [CBUUID UUIDWithString:serviceUUID];
    _currentCharacteristicUUID = [CBUUID UUIDWithString:characteristicUUID];
    [self sacnServicesForPeripheral:peripheral];
    return self;
}

/**
 读取特征值
 */
- (instancetype)readValueForPeripheral:(GNRPeripheral *)peripheral
            characteristicUUID:(NSString *)characteristicUUID
                    completion:(GNRBLEReadCharacteristicCompletion)completion;{
    _readValueCompletion = nil;
    _readValueCompletion = [completion copy];
    GNRCharacteristic * chara = peripheral.notifyChara;
    if (chara) {
        [peripheral.peripheral readValueForCharacteristic:chara.characteristic];//读取特征值
    }
    return self;
}

- (void)setup{
    _centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
}

//扫描设备
- (void)scanForPeripherals{
    //扫描有指定服务的设备
    [self.centralManager scanForPeripheralsWithServices:_serivices options:nil];
}

//连接设备
- (void)connect:(CBPeripheral*)peripheral services:(NSArray *)services{
    _serivices = [NSMutableArray array];
    [services enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj length]) {
            CBUUID* UUID = [CBUUID UUIDWithString:obj];
            [_serivices addObject:UUID];
        }
    }];
    [self.centralManager connectPeripheral:peripheral options:nil];
}

//扫描服务
- (void)sacnServicesForPeripheral:(GNRPeripheral *)peripheral{
    if (_currentServiceUUID) {
        [peripheral.peripheral setDelegate:self];
        [peripheral.peripheral discoverServices:@[_currentServiceUUID]];
    }
}

//扫描特征
- (void)scanCharacteristicForPeripheral:(CBPeripheral *)peripheral service:(CBService *)service{
    if (_currentCharacteristicUUID) {
        [peripheral discoverCharacteristics:@[_currentCharacteristicUUID] forService:service];
    }
}

//订阅该设备的通知
- (instancetype)notifyCharacteristic:(GNRPeripheral *)per
                          completion:(GNRBLENotifyCompletion)notifyCompletion{
    _notifyCompletion = nil;
    _notifyCompletion = [notifyCompletion copy];
    [self setNotifyValue:YES peripheral:per];
    return self;
}

- (void)setNotifyValue:(BOOL)value peripheral:(GNRPeripheral *)per{
    if (per.notifyChara.characteristic) {
        [per.peripheral setNotifyValue:value forCharacteristic:per.notifyChara.characteristic];
    }
}

+ (NSData *)newData{
    return [NSData data];
}

- (GNRPeripheral *)getPerModelForPeripheral:(CBPeripheral *)peripheral{
    for (GNRPeripheral * per in self.peripherals) {
        if ([per.identifier isEqualToString: peripheral.identifier.UUIDString]) {
            return per;
        }
    }
    return nil;
}

//MARK: - 向设备的特征中写数据
-(void)writeCharacteristic:(CBPeripheral *)peripheral
            characteristic:(CBCharacteristic *)characteristic
                     value:(NSData *)value{
    CBCharacteristicProperties properties = characteristic.properties;
    NSLog(@"该特征字段权限 %lu", (unsigned long)properties);//特征字段权限
    if(properties & CBCharacteristicPropertyWrite){//可写
        [peripheral writeValue:value forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];//有响应
    }else{
        NSLog(@"该字段不可写！");
    }
}

#pragma mark - 蓝牙状态更新回调
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    NSString * domain = nil;
    switch (central.state) {
        case CBCentralManagerStateUnknown:
            domain = @"CBCentralManagerStateUnknown";
            break;
        case CBCentralManagerStateResetting:
            domain = @"CBCentralManagerStateResetting";
            break;
        case CBCentralManagerStateUnsupported:
            domain = @"CBCentralManagerStateResetting";
            break;
        case CBCentralManagerStateUnauthorized:
            domain = @"CBCentralManagerStateUnauthorized";
            break;
        case CBCentralManagerStatePoweredOff:
            domain = @"CBCentralManagerStatePoweredOff";
            break;
        case CBCentralManagerStatePoweredOn:
            break;
        default:
            break;
    }
    if (central.state==CBCentralManagerStatePoweredOn) {
        NSLog(@">>>CBCentralManagerStatePoweredOn");
        [self scanForPeripherals];
    }else{
        if (_errorBlock) {
            NSError * error = [NSError errorWithDomain:domain code:central.state userInfo:nil];
            _errorBlock(error);
        }
    }
}

- (BOOL)containsPerModel:(CBPeripheral *)per{
    __block BOOL isExsit = NO;
    if (per) {
        [self.peripherals enumerateObjectsUsingBlock:^(GNRPeripheral * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.peripheral.identifier.UUIDString isEqualToString:per.identifier.UUIDString]) {
                isExsit = YES;
            }
        }];
    }
    return isExsit;
}

#pragma mark - 扫描设备回调
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(nonnull CBPeripheral *)peripheral advertisementData:(nonnull NSDictionary<NSString *,id> *)advertisementData RSSI:(nonnull NSNumber *)RSSI{
    NSLog(@"didDiscoverPeripheral");
    NSLog(@"peripheral %@ %@",peripheral.name,peripheral.identifier.UUIDString);
    if ([peripheral.name hasPrefix:NamePrefix_Peripheral]&&//名字有指定的前缀
        ![self containsPerModel:peripheral]&&//缓存中不存在
        peripheral) {//peripheral 不为nil
        GNRPeripheral * perModel = [GNRBLEHelper getNewMyPeripheral:peripheral];
        [self.peripherals addObject:perModel];
        if (_scanBlock) {
            _scanBlock(self.peripherals);
        }
    }
}

#pragma mark - 设备连接回调
//连接到Peripheral-成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    //连接到改设备
    GNRPeripheral * per = [self getPerModelForPeripheral:peripheral];
    if (per) {
        if (_connectCompletion&&per) {
            _connectCompletion(per,nil);
        }
    }
}

//连接到Peripheral-失败
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    //连接失败
    GNRPeripheral * per = [self getPerModelForPeripheral:peripheral];
    if (per) {
        if (_connectCompletion&&per) {
            _connectCompletion(per,error);
        }
    }
}

//断开连接Peripheral
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@">>>外设连接断开连接 %@: %@\n", [peripheral name], [error localizedDescription]);
}

#pragma mark - 扫描服务回调
//扫描到服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    GNRPeripheral * perModel = [self getPerModelForPeripheral:peripheral];
    if (error){
        if (_discoverServiceCompletion&&perModel) {
            _discoverServiceCompletion(perModel,error);
        }
        return;
    }
    for (CBService *service in peripheral.services) {
        if ([service.UUID.UUIDString isEqualToString:_currentServiceUUID.UUIDString]) {
            NSLog(@"服务UUID %@",service.UUID);
            [perModel.serviceStore addService:service];//增加到缓存
            [self scanCharacteristicForPeripheral:peripheral service:service];
            if (_discoverServiceCompletion&&perModel) {
                _discoverServiceCompletion(perModel,nil);
            }
            break;
        }
    }
}

#pragma mark - 扫描特征回调
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    GNRPeripheral * perModel = [self getPerModelForPeripheral:peripheral];
    if (error){
        if (_characteristicCompletion&&perModel) {
            _characteristicCompletion(perModel,error);
        }
        return;
    }
    for (CBCharacteristic *characteristic in service.characteristics){
        NSLog(@"特征UUID %@",characteristic.UUID.UUIDString);
        if ([characteristic.UUID.UUIDString isEqualToString:_currentCharacteristicUUID.UUIDString]) {
            GNRService * serModel = [perModel.serviceStore isExsit:service];
            GNRCharacteristic * chara = [serModel addCharacteristic:characteristic];
            perModel.notifyChara = chara;
//            [peripheral readValueForCharacteristic:characteristic];//读取特征值
            if (_characteristicCompletion&&perModel) {
                _characteristicCompletion(perModel,nil);
            }
            break;
        }
    }
}

//读取到特征值
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    GNRPeripheral * perModel = [self getPerModelForPeripheral:peripheral];
    if (error){
        if (_readValueCompletion&&perModel) {
            _readValueCompletion(nil,error);
        }
        return;
    }
    if ([characteristic.UUID.UUIDString isEqualToString:_currentCharacteristicUUID.UUIDString]) {
        NSLog(@"characteristic uuid:%@  value:%@",characteristic.UUID,characteristic.value);
        [perModel updateValue:characteristic.value characteristic:characteristic];//更新值
        
        if (_notifyCompletion) {
            _notifyCompletion(perModel,nil);
        }
        
        if (_readValueCompletion&&perModel) {
            _readValueCompletion(characteristic.value,nil);
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error{
    NSLog(@"didUpdateNotificationStateForCharacteristic");
    
}

#pragma mark - 以下暂时不用以后可以扩展
//搜索到Characteristic的Descriptors
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"characteristic uuid:%@",characteristic.UUID);
    for (CBDescriptor *d in characteristic.descriptors) {
        NSLog(@"Descriptor uuid:%@",d.UUID);
    }
}

//获取到Descriptors的值
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error{
    //打印出DescriptorsUUID 和value
    //这个descriptor都是对于characteristic的描述，一般都是字符串，所以这里我们转换成字符串去解析
    NSLog(@"characteristic uuid:%@  value:%@",[NSString stringWithFormat:@"%@",descriptor.UUID],descriptor.value);
}

@end

//
//  GNRPeripheralManager.m
//  BlueToothDemo
//
//  Created by LvYuan on 2017/4/20.
//  Copyright © 2017年 UUPaotui. All rights reserved.
//

#import "GNRBELPeripheralManager.h"

@interface GNRBELPeripheralManager ()<CBPeripheralManagerDelegate>
@property (nonatomic, strong)NSTimer * timer;
@property (nonatomic, assign)NSInteger serviceCount;
@property (nonatomic, strong)CBPeripheralManager * peripheralManger;//外设管理者
@property (nonatomic, strong)NSString * perName;

@property (nonatomic, copy)GNRBELOpenPeripheralSucceeBlock openSucceeBlock;
@property (nonatomic, copy)GNRBELOpenPeripheralErrorBlock openErrorBlock;

@end

@implementation GNRBELPeripheralManager

+ (instancetype)manager{
    static GNRBELPeripheralManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

//初始化外设管理者
- (void)setup{
    _peripheralManger = [[CBPeripheralManager alloc]initWithDelegate:self queue:nil];
}

//初始化服务
- (void)setUpServices{

    /*
        心跳服务 特征
     */
    CBUUID * characteristicRateUUID = [CBUUID UUIDWithString:UUID_Characteristic_Notify_Time];
    CBMutableCharacteristic * rateCharacteristic = [[CBMutableCharacteristic alloc]initWithType:characteristicRateUUID properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
    
    CBUUID * serviceRateUUID = [CBUUID UUIDWithString:UUID_Service_Notify_HeartRate];
    CBMutableService * service1 = [[CBMutableService alloc]initWithType:serviceRateUUID primary:YES];
    [service1 setCharacteristics:@[rateCharacteristic]];
    
    /*
        用户信息服务 特征
     */
    CBUUID * charaUserNameReadUUID = [CBUUID UUIDWithString:UUID_Characteristic_NickName];
    NSData * data = [@"Fuck" dataUsingEncoding:NSUTF8StringEncoding];
    CBMutableCharacteristic *readCharacteristic = [[CBMutableCharacteristic alloc]initWithType:charaUserNameReadUUID properties:CBCharacteristicPropertyRead value:data permissions:CBAttributePermissionsReadable];

    CBUUID * serviceProfileInfoUUID = [CBUUID UUIDWithString:UUID_Service_Read_ProfileInfo];
    CBMutableService * service2 = [[CBMutableService alloc]initWithType:serviceProfileInfoUUID primary:YES];
    [service2 setCharacteristics:@[readCharacteristic]];
    
    [self.peripheralManger addService:service1];
    [self.peripheralManger addService:service2];
}

- (NSString *)perName{
    NSString * name = NamePrefix_Peripheral;
    NSString * nickName = @"魔笛";
    if (nickName.length) {
        return [NSString stringWithFormat:@"%@%@",name,nickName];
    }
    return name;
}

//开始广播
- (void)startAdvertising{
    //广播两个服务 并设置 设备名
    CBUUID * serviceProfileInfoUUID = [CBUUID UUIDWithString:UUID_Service_Read_ProfileInfo];
    CBUUID * serviceNotifyUUID = [CBUUID UUIDWithString:UUID_Service_Notify_HeartRate];

    [self.peripheralManger startAdvertising:@{
                                             CBAdvertisementDataServiceUUIDsKey:@[serviceProfileInfoUUID,serviceNotifyUUID],
                                             CBAdvertisementDataLocalNameKey : self.perName
                                             }];
}

//开启设备回调
- (void)openPeripheralSuccee:(GNRBELOpenPeripheralSucceeBlock)succeeBlock error:(GNRBELOpenPeripheralErrorBlock)errorBlock{
    _openSucceeBlock = nil;
    _openSucceeBlock = [succeeBlock copy];
    _openErrorBlock = nil;
    _openErrorBlock = [errorBlock copy];
    [self setup];
}

#pragma mark - 状态改变回调
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{
    NSString * domain = nil;
    switch (peripheral.state) {
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
            [self setUpServices];//开始配置服务
            break;
        default:
            break;
    }
    
    if (domain) {
        NSError * error = [NSError errorWithDomain:domain code:peripheral.state userInfo:nil];
        if (_openErrorBlock) {
            _openErrorBlock(error);
        }
    }
}

#pragma mark - 添加了服务回调
- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error{
    if (error==nil) {
        _serviceCount++;
    }
    if (_serviceCount==2) {
        //添加两个服务后才开始广播
        [self startAdvertising];
    }
    NSLog(@"didAddService");
}

#pragma mark - 已经开始广播
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error{
    if (error) {
        NSLog(@"error %@",error.localizedDescription);
    }else{
        if (_openSucceeBlock) {
            _openSucceeBlock(peripheral);
        }
    }
    NSLog(@"advertisiong");
}

#pragma mark - 对central的操作的响应
//订阅
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic{
    NSLog(@"订阅 %@",characteristic.UUID);
    [self startSendNotify:characteristic];
}

- (void)startSendNotify:(CBCharacteristic*)characteristic{
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(sendData:) userInfo:characteristic  repeats:YES];
}

//发送数据，发送当前时间的秒数
- (BOOL)sendData:(NSTimer *)t {
    CBMutableCharacteristic *characteristic = t.userInfo;
    NSDateFormatter *dft = [[NSDateFormatter alloc]init];
    [dft setDateFormat:@"ss"];
    NSLog(@"当前时间戳 %@",[dft stringFromDate:[NSDate date]]);
    //执行回应Central通知数据
    return  [self.peripheralManger updateValue:[[dft stringFromDate:[NSDate date]] dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:(CBMutableCharacteristic *)characteristic onSubscribedCentrals:nil];
    
}
//取消了定阅
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic{
    NSLog(@"取消订阅 %@",characteristic.UUID);
    [_timer invalidate];
}

//读取请求
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request{
    NSLog(@"didReceiveReadRequest");
    if (request.characteristic.properties & CBCharacteristicPropertyRead) {//是否有权限读取数据
        NSData * data = request.characteristic.value;
        [request setValue:data];
        //对请求做出成功响应
        [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
    }else{
        //没有读取权限的响应
        [peripheral respondToRequest:request withResult:CBATTErrorReadNotPermitted];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests{
    NSLog(@"didReceiveWriteRequests");
    CBATTRequest * request = requests[0];
    if (request.characteristic.properties & CBCharacteristicPropertyWrite) {//有写入的权限
        CBMutableCharacteristic * c = (CBMutableCharacteristic *)request.characteristic;
        c.value = request.value;
        [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
    }else{
        [peripheral respondToRequest:request withResult:CBATTErrorWriteNotPermitted];//没有写权限
    }
}

@end

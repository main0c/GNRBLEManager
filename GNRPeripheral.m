//
//  GNRPeripheral.m
//  BlueToothDemo
//
//  Created by LvYuan on 2017/4/20.
//  Copyright © 2017年 UUPaotui. All rights reserved.
//

#import "GNRPeripheral.h"

@implementation GNRCharacteristic

- (NSString *)identifier{
    return self.characteristic.UUID.UUIDString?:@"";
}

@end

@implementation GNRService

- (NSString *)identifier{
    return self.service.UUID.UUIDString?:@"";
}

- (instancetype)init{
    if (self = [super init]) {
        _characteristics = [NSMutableArray array];
    }
    return self;
}

- (GNRCharacteristic *)isExsit:(CBCharacteristic *)chara{
    for (GNRCharacteristic * cha in _characteristics) {
        if ([cha.characteristic.UUID.UUIDString isEqualToString:chara.UUID.UUIDString]) {
            return cha;
        }
    }
    return nil;
}

- (GNRCharacteristic *)addCharacteristic:(CBCharacteristic *)characteristic{
    if (characteristic==nil) {
        return nil;
    }
    GNRCharacteristic * chara = [self isExsit:characteristic];
    if (chara==nil) {
        chara = [GNRCharacteristic new];
        chara.characteristic = characteristic;
        [_characteristics addObject:chara];
    }else{
        chara.characteristic = characteristic;
    }
    return chara;
}

- (void)removeCharacteristic:(CBCharacteristic *)characteristic{
    if (characteristic==nil) {
        return;
    }
    GNRCharacteristic * chara = [self isExsit:characteristic];
    if (chara) {
        [_characteristics removeObject:chara];
    }
}

@end

@implementation GNRServiceStore

- (GNRCharacteristic *)characteristicForServiceUUID:(NSString *)serviceUUID characteristicUUID:(NSString *)characteristicUUID{
    for (GNRService * service in self.services) {
        if ([service.service.UUID.UUIDString isEqualToString:serviceUUID]) {
            for (GNRCharacteristic * chara in service.characteristics) {
                if ([chara.characteristic.UUID.UUIDString isEqualToString:characteristicUUID]) {
                    return chara;
                }
            }
        }
    }
    return nil;
}

- (instancetype)init{
    if (self = [super init]) {
        _services = [NSMutableArray array];
    }
    return self;
}

- (GNRService *)isExsit:(CBService *)service{
    for (GNRService * ser in _services) {
        if ([service.UUID.UUIDString isEqualToString:ser.service.UUID.UUIDString]) {
            return ser;
        }
    }
    return nil;
}

- (GNRService *)addService:(CBService *)service{
    if (service==nil) {
        return nil;
    }
    GNRService * cSer = [self isExsit:service];
    if (cSer==nil) {
        cSer = [GNRService new];
        cSer.service = service;
        [_services addObject:cSer];
    }else{
        cSer.service = service;
    }
    return cSer;
}

- (void)removeService:(CBService *)service{
    if (service==nil) {
        return;
    }
    GNRService * cSer = [self isExsit:service];
    if (cSer) {
        [_services addObject:cSer];
    }
}

@end

@implementation GNRPeripheral

- (instancetype)init{
    if (self = [super init]) {
        _serviceStore = [[GNRServiceStore alloc]init];
    }
    return self;
}

- (NSString *)name{
    return self.peripheral.name?:@"未知";
}

- (NSString *)identifier{
    return self.peripheral.identifier.UUIDString?:@"";
}

- (BOOL)isNotifyCharacteristic:(NSString *)charaUUID{
    if (charaUUID) {
        return YES;
    }
    return NO;
}

//更新该特征的缓存值
- (GNRCharacteristic *)updateValue:(id)value characteristic:(CBCharacteristic *)characteristic{
    for (GNRService *ser in _serviceStore.services) {
        for (GNRCharacteristic * chara in ser.characteristics) {
            if ([chara.identifier isEqualToString:characteristic.UUID.UUIDString]) {//找到了
                chara.value = value;
                return chara;
            }
        }
    }
    return nil;
}

@end

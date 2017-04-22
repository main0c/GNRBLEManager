//
//  GNRBlueToothManager.h
//  BlueToothDemo
//
//  Created by LvYuan on 2017/4/19.
//  Copyright © 2017年 UUPaotui. All rights reserved.
//

/***********
 
 这个类作用是将这个App作为一个蓝牙主设备
 
 **********/

#import <Foundation/Foundation.h>
#import "GNRBLEHeader.h"

@interface GNRBLECentralManager : NSObject

+ (instancetype)manager;


/**
 启动主设备并且开始扫描

 @param block 扫描成功的回调
 @param errorBlock 扫描失败的回调
 */
- (instancetype)starScanPeripheralSuccee:(GNRBLEScanSucceeBlock)block
                                   error:(GNRBLEScanErrorBlock)errorBlock;


/**
 链接该设备

 @param peripheral 需要链接的设备
 @param services 该设备所拥有的服务数组
 @param completion 链接设备的回调
 */
- (instancetype)connect:(GNRPeripheral *)peripheral
               services:(NSArray <NSString *>*)services
             completion:(GNRBLEConnectCompletion)completion;


/**
 扫描特征
 
 @param peripheral 该设备
 @param serviceUUID 服务UUID
 @param characteristicUUID 特征UUID
 @param completion 扫描到该服务的回调
 @param discoverCharacteristicCompletion 扫描到改特征的回调
 */
- (instancetype)scanCharacteristicForPeripheral:(GNRPeripheral *)peripheral
                                    serviceUUID:(NSString *)serviceUUID
                             characteristicUUID:(NSString *)characteristicUUID
                      discoverServiceCompletion:(GNRBLEDiscoverServiceCompletion)completion
               discoverCharacteristicCompletion:(GNRBLEDiscoverCharacteristicCompletion)discoverCharacteristicCompletion;


/**
 读取特征值
 
 @param peripheral 该设备
 @param characteristic 该特征
 @param completion 读取到该特征值的回调
 */
- (instancetype)readValueForPeripheral:(GNRPeripheral *)peripheral
                        characteristic:(GNRCharacteristic *)characteristic
                            completion:(GNRBLEReadCharacteristicCompletion)completion;

//订阅该设备的心跳服务
- (instancetype)notifyCharacteristic:(GNRPeripheral *)per
                      notify_characteristic:(GNRCharacteristic *)notify_characteristic
                          completion:(GNRBLENotifyCompletion)notifyCompletion;


@end

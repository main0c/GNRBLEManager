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

@property (nonatomic, copy)GNRBLEScanSucceeBlock scanBlock;//扫描成功
@property (nonatomic, copy)GNRBLEScanErrorBlock errorBlock;//扫描失败
@property (nonatomic, copy)GNRBLEConnectBlock connectBlock;//连接回调
@property (nonatomic, copy)GNRBLEDisConnectBlock disConnectBlock;//断开连接回调
@property (nonatomic, copy)GNRBLEDiscoverServiceCompletion discoverServiceCompletion;//发现服务
@property (nonatomic, copy)GNRBLEDiscoverCharacteristicCompletion characteristicCompletion;//发现特征
@property (nonatomic, copy)GNRBLEReadCharacteristicCompletion readValueCompletion;
@property (nonatomic, copy)GNRBLENotifyCompletion notifyCompletion;

@property (nonatomic, strong)NSMutableArray <CBUUID *>* serivices;//当前搜索的serviceUUIDs
@property (nonatomic, strong)CBCentralManager * centralManager;//设备中心管理者
@property (nonatomic, strong)NSMutableArray <GNRPeripheral *>* peripherals;//外设

+ (instancetype)manager;


/**
 启动主设备并且开始扫描周边
 
 @param services 指定的服务数组
 @param block 扫描成功的回调
 @param errorBlock 扫描失败的回调
 */
- (instancetype)starScanPeripheralForServices:(NSArray <NSString *>*)services
                                       succee:(GNRBLEScanSucceeBlock)block
                                        error:(GNRBLEScanErrorBlock)errorBlock;


/**
 连接该设备 并扫描该的服务及特征
 
 @param peripheral 需要扫描的设备
 */
- (instancetype)connectForPeripheral:(GNRPeripheral *)peripheral
                   connectCompletion:(GNRBLEConnectBlock)connectBlock
                disconnectCompletion:(GNRBLEDisConnectBlock)disconnectBlock;

/**
 读取特征值
 
 @param peripheral 该设备 且 需要指定 serviceUUID charaUUID
 @param completion 读取到该特征值的回调
 */
- (instancetype)readValueForPeripheral:(GNRPeripheral *)peripheral
                            completion:(GNRBLEReadCharacteristicCompletion)completion;

//订阅该设备的通知
- (instancetype)notifyPeripheral:(GNRPeripheral *)per
                          completion:(GNRBLENotifyCompletion)notifyCompletion;

@end

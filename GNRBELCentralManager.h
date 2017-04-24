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
#import "GNRBELHeader.h"

@interface GNRBELCentralManager : NSObject
@property (nonatomic, copy)GNRBELScanSucceeBlock scanBlock;//扫描成功
@property (nonatomic, copy)GNRBELScanErrorBlock errorBlock;//扫描失败
@property (nonatomic, copy)GNRBELConnectBlock connectBlock;//连接回调
@property (nonatomic, copy)GNRBELDisConnectBlock disConnectBlock;//断开连接回调
@property (nonatomic, copy)GNRBELDiscoverServiceCompletion discoverServiceCompletion;//发现服务
@property (nonatomic, copy)GNRBELDiscoverCharacteristicCompletion characteristicCompletion;//发现特征
@property (nonatomic, copy)GNRBELReadCharacteristicCompletion readValueCompletion;
@property (nonatomic, copy)GNRBELNotifyCompletion notifyCompletion;
+ (instancetype)manager;


/**
 启动主设备并且开始扫描周边
 
 @param services 指定的服务数组
 @param block 扫描成功的回调
 @param errorBlock 扫描失败的回调
 */
- (instancetype)starScanPeripheralForServices:(NSArray <NSString *>*)services
                                       succee:(GNRBELScanSucceeBlock)block
                                        error:(GNRBELScanErrorBlock)errorBlock;


/**
 连接该设备 并扫描该的服务及特征
 
 @param peripheral 需要扫描的设备
 */
- (instancetype)connectForPeripheral:(GNRPeripheral *)peripheral
                          completion:(GNRBELConnectBlock)connectBlock;

/**
 读取特征值
 
 @param peripheral 该设备 且 需要指定 serviceUUID charaUUID
 @param completion 读取到该特征值的回调
 */
- (instancetype)readValueForPeripheral:(GNRPeripheral *)peripheral
                            completion:(GNRBELReadCharacteristicCompletion)completion;

//订阅该设备的通知
- (instancetype)notifyPeripheral:(GNRPeripheral *)per
                          completion:(GNRBELNotifyCompletion)notifyCompletion;

@end

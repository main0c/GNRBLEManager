//
//  GNRBELHeader.h
//  BlueToothDemo
//
//  Created by LvYuan on 2017/4/20.
//  Copyright © 2017年 UUPaotui. All rights reserved.
//

#ifndef GNRBELHeader_h
#define GNRBELHeader_h

#import <CoreBluetooth/CoreBluetooth.h>
#import "GNRPeripheral.h"
#import "GNRBELHelper.h"

#define NamePrefix_Peripheral @"MD_"

#define UUID_Service_Notify_HeartRate @"FFF0" //该服务用于主动向主设备发送当前时间戳 即心跳
#define UUID_Service_Read_ProfileInfo @"FFF1" //该服务用于读取设备用户信息

#define UUID_Characteristic_Notify_Time @"FFF3" //用于读取当前时间戳
#define UUID_Characteristic_NickName @"FFF4" //用户昵称

/********
 
 central manager block
 
 ********/

//扫描设备成功
typedef void(^GNRBELScanSucceeBlock)(NSMutableArray <GNRPeripheral *>* peripherals);
//扫描失败
typedef void(^GNRBELScanErrorBlock)(NSError * error);
//连接该设备回调
typedef void(^GNRBELConnectBlock)(GNRPeripheral * peripheral,NSError * error);
//断开连接
typedef void(^GNRBELDisConnectBlock)(GNRPeripheral * peripheral,NSError * error);
//搜索到该外设的指定的服务
typedef void(^GNRBELDiscoverServiceCompletion)(GNRPeripheral * peripheral,GNRService * service,NSError * error);
//搜索到该外设的指定服务的指定特征
typedef void(^GNRBELDiscoverCharacteristicCompletion)(GNRPeripheral * peripheral,GNRCharacteristic * characteristic,NSError * error);
//读外设的特征值回调
typedef void(^GNRBELReadCharacteristicCompletion)(id result,NSError * error);
//订阅设备的通知
typedef void(^GNRBELNotifyCompletion)(GNRPeripheral * peripheral,NSError * error);

/********
 
 peripheral manager block
 
 ********/
//开启外设成功回调
typedef void(^GNRBELOpenPeripheralSucceeBlock)(CBPeripheralManager * perManager);
//开启外设失败回调
typedef void(^GNRBELOpenPeripheralErrorBlock)(NSError * error);


#endif /* GNRBELHeader_h */

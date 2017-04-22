//
//  GNRBLEHeader.h
//  BlueToothDemo
//
//  Created by LvYuan on 2017/4/20.
//  Copyright © 2017年 UUPaotui. All rights reserved.
//

#ifndef GNRBLEHeader_h
#define GNRBLEHeader_h

#import <CoreBluetooth/CoreBluetooth.h>
#import "GNRPeripheral.h"
#import "GNRBLEHelper.h"

#define NamePrefix_Peripheral @"MD_"

#define UUID_Service_Notify_HeartRate @"FFF0" //该服务用于主动向主设备发送当前时间戳 即心跳
#define UUID_Service_Read_ProfileInfo @"FFF1" //该服务用于读取设备用户信息

#define UUID_Characteristic_Notify_Time @"FFF3" //用于读取当前时间戳
#define UUID_Characteristic_NickName @"FFF4" //用户昵称

/********
 
 central manager block
 
 ********/

//扫描设备成功
typedef void(^GNRBLEScanSucceeBlock)(NSMutableArray <GNRPeripheral *>* peripherals);
//扫描失败
typedef void(^GNRBLEScanErrorBlock)(NSError * error);
//连接到指定的外设
typedef void(^GNRBLEConnectCompletion)(GNRPeripheral * peripheral,NSError * error);
//搜索到该外设的指定的服务
typedef void(^GNRBLEDiscoverServiceCompletion)(GNRService * service,NSError * error);
//搜索到该外设的指定服务的指定特征
typedef void(^GNRBLEDiscoverCharacteristicCompletion)(GNRCharacteristic * characteristic,NSError * error);
//读外设的特征值回调
typedef void(^GNRBLEReadCharacteristicCompletion)(id result,NSError * error);
//订阅设备的通知
typedef void(^GNRBLENotifyCompletion)(id value,NSError * error);

/********
 
 peripheral manager block
 
 ********/
//开启外设成功回调
typedef void(^GNRBLEOpenPeripheralSucceeBlock)(CBPeripheralManager * perManager);
//开启外设失败回调
typedef void(^GNRBLEOpenPeripheralErrorBlock)(NSError * error);


#endif /* GNRBLEHeader_h */

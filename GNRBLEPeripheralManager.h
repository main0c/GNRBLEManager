//
//  GNRPeripheralManager.h
//  BlueToothDemo
//
//  Created by LvYuan on 2017/4/20.
//  Copyright © 2017年 UUPaotui. All rights reserved.
//

/***********

 这个类是将此app作为一个虚拟蓝牙外设
 
 ***********/

#import <Foundation/Foundation.h>
#import "GNRBLEHeader.h"

@interface GNRBLEPeripheralManager : NSObject
@property (nonatomic, strong, readonly)NSString * name;//设备名字
@property (nonatomic, strong)CBPeripheralManager * peripheralManger;//外设管理者

+ (instancetype)manager;

//开启设备回调
- (void)openPeripheralForName:(NSString *)name succee:(GNRBLEOpenPeripheralSucceeBlock)succeeBlock error:(GNRBLEOpenPeripheralErrorBlock)errorBlock;

//开始广播
- (void)startAdvertising;
//停止广播
- (void)stopAdvertising;

- (void)stopService;//关闭服务

@end

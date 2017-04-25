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

+ (instancetype)manager;

//开启设备回调
- (void)openPeripheralSuccee:(GNRBLEOpenPeripheralSucceeBlock)succeeBlock error:(GNRBLEOpenPeripheralErrorBlock)errorBlock;

@end

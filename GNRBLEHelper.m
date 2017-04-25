//
//  GNRBLEHelper.m
//  BlueToothDemo
//
//  Created by LvYuan on 2017/4/20.
//  Copyright © 2017年 UUPaotui. All rights reserved.
//

#import "GNRBLEHelper.h"

@implementation GNRBLEHelper

+ (GNRPeripheral *)getNewMyPeripheral:(CBPeripheral *)per{
    GNRPeripheral * perModel= nil;
    if (per) {
        perModel = [GNRPeripheral new];
        perModel.peripheral = per;
    }
    return perModel;
}

@end

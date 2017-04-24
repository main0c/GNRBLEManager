//
//  GNRBELHelper.m
//  BlueToothDemo
//
//  Created by LvYuan on 2017/4/20.
//  Copyright © 2017年 UUPaotui. All rights reserved.
//

#import "GNRBELHelper.h"

@implementation GNRBELHelper

+ (GNRPeripheral *)getNewMyPeripheral:(CBPeripheral *)per{
    GNRPeripheral * perModel= nil;
    if (per) {
        perModel = [GNRPeripheral new];
        perModel.peripheral = per;
    }
    return perModel;
}

@end

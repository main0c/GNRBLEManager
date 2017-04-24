//
//  GNRBELHelper.h
//  BlueToothDemo
//
//  Created by LvYuan on 2017/4/20.
//  Copyright © 2017年 UUPaotui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GNRBELHeader.h"

@interface GNRBELHelper : NSObject

+ (GNRPeripheral *)getNewMyPeripheral:(CBPeripheral *)per;

@end

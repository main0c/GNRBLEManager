//
//  ViewController.m
//  BlueToothDemo
//
//  Created by LvYuan on 2017/4/19.
//  Copyright © 2017年 UUPaotui. All rights reserved.
//

#import "ViewController.h"
#import "GNRBLECentralManager.h"
#import "GNRBLEPeripheralManager.h"

@interface ViewController ()<UITableViewDataSource,
UITableViewDelegate>
{
    NSMutableArray * dicoverdPeripherals;//已发现的设备
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化中心角色
    dicoverdPeripherals = [NSMutableArray array];

    [[GNRBLECentralManager manager] starScanPeripheralForServices:@[UUID_Service_Notify_HeartRate,UUID_Service_Read_ProfileInfo] succee:^(NSMutableArray<GNRPeripheral *> *peripherals) {
        dicoverdPeripherals = peripherals.mutableCopy;
        [self.tableView reloadData];
    } error:^(NSError *error) {
        if (error) {
            [self showAlertMsg:error.domain];
        }
    }];
    
    [[GNRBLEPeripheralManager manager] openPeripheralForName:@"" succee:^(CBPeripheralManager *perManager) {
        self.title = @"开始广播";

    } error:^(NSError *error) {
        NSLog(@"open error %@",error.localizedDescription);
    }];

}

- (void)connect:(GNRPeripheral *)per{
    GNRBLECentralManager * manager = [GNRBLECentralManager manager];
    
    //链接到设备回调
    [[GNRBLECentralManager manager] connectForPeripheral:per connectCompletion:^(GNRPeripheral *peripheral, NSError *error) {
        if (error) {
            NSLog(@"conncet error %@",error.localizedDescription);
        }else{
            NSLog(@"connect peripheral UUID %@",peripheral.identifier);
        }
    } disconnectCompletion:^(GNRPeripheral *peripheral, NSError *error) {
        if (error) {
            NSLog(@"disconncet error %@",error.localizedDescription);
        }else{
            NSLog(@"disconnect peripheral UUID %@",peripheral.identifier);
            peripheral.connectState = NO;
        }
    }];
    
    //扫描到特征的回调
    manager.characteristicCompletion = ^(GNRPeripheral * peripheral,GNRCharacteristic * chara,NSError * error){
        if (error) {
            NSLog(@"discover chara error %@",error.localizedDescription);
        }else{
            NSLog(@"discover chara %@",chara.identifier);
            if ([chara.identifier isEqualToString:UUID_Characteristic_Notify_Time]) {
                //订阅该特征
                [self subscribeForPeripheral:per];
            }else if ([chara.identifier isEqualToString:UUID_Characteristic_NickName]) {
                //读取用户信息
                [self readProfileForPeripheral:per];
            }
        }
    };
    
    
}

//读取特征值
- (void)readProfileForPeripheral:(GNRPeripheral *)per{
    [[GNRBLECentralManager manager] readValueForPeripheral:per completion:^(id result, NSError *error) {
        if (error) {
            NSLog(@"read Value error %@",error);
        }else{
            NSLog(@"read value %@",result);
        }
    }];
}

//订阅
- (void)subscribeForPeripheral:(GNRPeripheral *)per{
    [[GNRBLECentralManager manager] notifyPeripheral:per completion:^(GNRPeripheral *peripheral, NSError *error) {
        if (error) {
            NSLog(@"sub notify error %@",error);
        }else{
            NSLog(@"sub notify value %@",per.notifyCharacteristic.value);
            peripheral.connectState = YES;
        }
    }];
}

#pragma mark - table delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dicoverdPeripherals.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell==nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    GNRPeripheral * per = dicoverdPeripherals[indexPath.row];
    cell.textLabel.text = per.name;
    cell.detailTextLabel.text = per.identifier;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    GNRPeripheral * per = dicoverdPeripherals[indexPath.row];
    [self connect:per];
}

- (void)subPer:(GNRPeripheral *)per{
    [[GNRBLECentralManager manager] notifyPeripheral:per completion:^(GNRPeripheral *peripheral, NSError *error) {
        if (error) {
            
        }else{
            NSLog(@"time %@",[[NSString alloc] initWithData:peripheral.notifyCharacteristic.value encoding:NSUTF8StringEncoding]);
        }
    }];
}


- (void)readValue:(GNRPeripheral *)per{
    [[GNRBLECentralManager manager] readValueForPeripheral:per completion:^(id result, NSError *error) {
        if (error) {
            [self showAlertMsg:error.localizedDescription];
        }else{
            [self showAlertMsg:@"读取特征值成功"];
            NSLog(@"DATA %@",[[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding]);
            [self.tableView reloadData];
        }
    }];
}


- (void)showAlertMsg:(NSString *)msg{
    UIAlertView * alertV = [[UIAlertView alloc]initWithTitle:msg message:nil delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles: nil];
    [alertV show];
}

@end

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
#if 1
    [[GNRBLECentralManager manager] starScanPeripheralSuccee:^(NSMutableArray<CBPeripheral *> *peripherals) {
        dicoverdPeripherals = peripherals.mutableCopy;
        [self.tableView reloadData];
    } error:^(NSError *error) {
        if (error) {
            [self showAlertMsg:error.domain];
        }
    }];
#else
    [[GNRBLEPeripheralManager manager] openPeripheralSuccee:^(CBPeripheralManager *perManager) {
       self.title = @"开始广播";
    } error:^(NSError *error) {
        if (error) {
            [self showAlertMsg:error.domain];
        }
    }];
#endif
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
    
    [[GNRBLECentralManager manager] connect:per services:@[UUID_Service_Read_ProfileInfo] completion:^(GNRPeripheral *peripheral, NSError *error) {
        if (error) {
            [self showAlertMsg:error.localizedDescription];
        }else{
            [self showAlertMsg:@"链接成功"];
            [self scanService:peripheral];
        }
    }];
    
}

- (void)subPer:(GNRPeripheral *)per{
    [[GNRBLECentralManager manager] notifyCharacteristic:per completion:^(GNRPeripheral *peripheral, NSError *error) {
        if (error) {
            
        }else{
            NSLog(@"time %@",[[NSString alloc] initWithData:peripheral.notifyChara.value encoding:NSUTF8StringEncoding]);
        }
    }];
}

- (void)scanService:(GNRPeripheral *)per{
    [[GNRBLECentralManager manager] scanCharacteristicForPeripheral:per serviceUUID:UUID_Service_Read_ProfileInfo characteristicUUID:UUID_Characteristic_NickName discoverServiceCompletion:^(GNRPeripheral *peripheral, NSError *error) {
        if (error) {
            [self showAlertMsg:error.localizedDescription];
        }else{
            [self showAlertMsg:@"扫描服务成功"];
            
        }
    } discoverCharacteristicCompletion:^(GNRPeripheral *peripheral, NSError *error) {
        if (error) {
            [self showAlertMsg:error.localizedDescription];
        }else{
            [self showAlertMsg:@"扫描特征成功"];
            [self readValue:per];
//            [self subPer:peripheral];

        }
    }];
}

- (void)readValue:(GNRPeripheral *)per{
    [[GNRBLECentralManager manager]readValueForPeripheral:per characteristicUUID:UUID_Characteristic_NickName completion:^(id result, NSError *error) {
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

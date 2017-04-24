//
//  ViewController.m
//  BlueToothDemo
//
//  Created by LvYuan on 2017/4/19.
//  Copyright © 2017年 UUPaotui. All rights reserved.
//

#import "ViewController.h"
#import "GNRBELCentralManager.h"
#import "GNRBELPeripheralManager.h"

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
    GNRBELCentralManager * manager = [GNRBELCentralManager manager];
#if 1
    [manager starScanPeripheralForServices:@[UUID_Service_Read_ProfileInfo,UUID_Service_Notify_HeartRate] succee:^(NSMutableArray<GNRPeripheral *> *peripherals) {
        dicoverdPeripherals = peripherals.mutableCopy;
        [self.tableView reloadData];
    } error:^(NSError *error) {
        if (error) {
            [self showAlertMsg:error.domain];
        }
    }];
    
    manager.discoverServiceCompletion = ^(GNRPeripheral * peripheral,GNRService * service,NSError * error){
        if (error) {
            
        }else{
            
        }
    };
    
    manager.characteristicCompletion = ^(GNRPeripheral * peripheral,GNRCharacteristic * chara,NSError * error){
        if (error) {
            
        }else{
            
        }
    };
    
#else
    [[GNRBELPeripheralManager manager] openPeripheralSuccee:^(CBPeripheralManager *perManager) {
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
    [[GNRBELCentralManager manager] connectForPeripheral:per completion:^(GNRPeripheral *peripheral, NSError *error) {
        if (error) {
            
        }else{
            
        }
    }];
}

- (void)subPer:(GNRPeripheral *)per{
    [[GNRBELCentralManager manager] notifyPeripheral:per completion:^(GNRPeripheral *peripheral, NSError *error) {
        if (error) {
            
        }else{
            NSLog(@"time %@",[[NSString alloc] initWithData:peripheral.notifyCharacteristic.value encoding:NSUTF8StringEncoding]);
        }
    }];
}


- (void)readValue:(GNRPeripheral *)per{
    [[GNRBELCentralManager manager] readValueForPeripheral:per completion:^(id result, NSError *error) {
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

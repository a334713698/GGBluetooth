//
//  ViewController.m
//  GGBluetooth
//
//  Created by 洪冬介 on 2018/3/14.
//  Copyright © 2018年 洪冬介. All rights reserved.
//

#import "ViewController.h"
#import "GGBluetooth.h"
#import "GGPeripheralCell.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,GGBluetoothToolDelegate>

@property (nonatomic, strong) GGBluetoothTool *bluetoothTool;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<GGPeripheral*>* optionDevices;


@end

@implementation ViewController

#pragma mark - lazy load
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        [self.view addSubview:_tableView];
        _tableView.backgroundColor = [UIColor lightGrayColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0.01, 10)];
        if ([[[UIDevice currentDevice] systemVersion] doubleValue] > 11.0) {
            _tableView.estimatedSectionHeaderHeight = 10;
            _tableView.estimatedSectionFooterHeight = 0.01;
        };
    }
    return _tableView;
}


#pragma mark - view func
- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.bluetoothTool = [[GGBluetoothTool alloc] init];
    self.bluetoothTool.delegate = self;
    [self.bluetoothTool discover];

    self.tableView.hidden = NO;
    
}


#pragma mark - GGBluetoothToolDelegate
- (void)bluetoothTool:(GGBluetoothTool*)bluetoothTool discoverPeripheralDevices:(NSArray<GGPeripheral*>*)devices{
    self.optionDevices = devices;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.optionDevices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GGPeripheral* model = self.optionDevices[indexPath.row];
    GGPeripheralCell* cell = [[GGPeripheralCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@""];
    cell.nameLabel.text = model.name ? :@"(N/A)";
    cell.identifyLabel.text = model.identifier;
    cell.rssiLabel.text = [NSString stringWithFormat:@"%@",model.RSSI];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cell：%ld-%ld",indexPath.section,indexPath.row);
    
    GGPeripheral* model = self.optionDevices[indexPath.row];
    NSLog(@"被选择的设备：%@",model.name);
    [self.bluetoothTool connectPeripheral:model.identifier];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return GGPeripheralCell_Height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 12;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}

#pragma mark - SEL


#pragma mark - Method



@end

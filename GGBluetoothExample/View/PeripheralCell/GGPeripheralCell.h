//
//  GGPeripheralCell.h
//  GGBluetooth
//
//  Created by 洪冬介 on 2018/3/14.
//  Copyright © 2018年 洪冬介. All rights reserved.
//

#import <UIKit/UIKit.h>

#define GGPeripheralCell_Height 60

@interface GGPeripheralCell : UITableViewCell

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *identifyLabel;
@property (nonatomic, strong) UILabel *rssiLabel;


@end

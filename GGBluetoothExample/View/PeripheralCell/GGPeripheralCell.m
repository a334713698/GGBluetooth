//
//  GGPeripheralCell.m
//  GGBluetooth
//
//  Created by 洪冬介 on 2018/3/14.
//  Copyright © 2018年 洪冬介. All rights reserved.
//

#import "GGPeripheralCell.h"

@implementation GGPeripheralCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews{
    _nameLabel = [UILabel new];
    [self addSubview:_nameLabel];
    _nameLabel.font = [UIFont systemFontOfSize:15];
    _nameLabel.text  = @"name";
    _nameLabel.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width / 2.0, GGPeripheralCell_Height/2);
    
    _identifyLabel = [UILabel new];
    [self addSubview:_identifyLabel];
    _identifyLabel.font = [UIFont systemFontOfSize:15];
    _identifyLabel.text  = @"identifyLabel";
    _identifyLabel.frame = CGRectMake(0, GGPeripheralCell_Height/2, [UIScreen mainScreen].bounds.size.width, GGPeripheralCell_Height/2);

    
    _rssiLabel = [UILabel new];
    [self addSubview:_rssiLabel];
    _rssiLabel.font = [UIFont systemFontOfSize:15];
    _rssiLabel.text  = @"RSSI";
    _rssiLabel.textAlignment = NSTextAlignmentRight;
    _rssiLabel.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, GGPeripheralCell_Height);

}

@end

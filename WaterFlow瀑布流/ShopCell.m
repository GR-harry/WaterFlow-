//
//  ShopCell.m
//  WaterFlow瀑布流
//
//  Created by apple on 15/4/9.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "ShopCell.h"
#import "Shop.h"
#import "UIImageView+WebCache.h"
@interface ShopCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *price;

@end
@implementation ShopCell

- (void)awakeFromNib {
    // Initialization code
}
- (void)setShop:(Shop *)shop
{
    _shop = shop;
    
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:shop.img]];
    self.price.text = shop.price;
}
@end

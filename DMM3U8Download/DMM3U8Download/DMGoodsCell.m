//
//  DMGoodsCell.m
//  DMM3U8Download
//
//  Created by lbq on 2017/8/22.
//  Copyright © 2017年 lbq. All rights reserved.
//

#import "DMGoodsCell.h"
#import <UIImageView+WebCache.h>
@interface DMGoodsCell()

@property (weak, nonatomic) IBOutlet UIImageView *goodsImageView;

@end
@implementation DMGoodsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setGoods:(DMGoodsModel *)goods
{
    _goods = goods;
    [self.goodsImageView sd_setImageWithURL:[NSURL URLWithString:goods.image]];
}

@end

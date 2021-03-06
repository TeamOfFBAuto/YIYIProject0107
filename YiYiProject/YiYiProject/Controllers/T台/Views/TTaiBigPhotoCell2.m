//
//  TTaiBigPhotoCell2.m
//  YiYiProject
//
//  Created by lichaowei on 15/4/20.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "TTaiBigPhotoCell2.h"
#import "TPlatModel.h"
#import "AnchorPiontView.h"

@implementation TTaiBigPhotoCell2

- (void)awakeFromNib {
    // Initialization code
    
    [self.zanBackView addCornerRadius:5.f];//赞按钮圆角
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellWithModel:(TPlatModel *)aModel
{
    NSString *imageUrl = aModel.image[@"url"];
    CGFloat image_width = [aModel.image[@"width"]floatValue];
    CGFloat image_height = [aModel.image[@"height"]floatValue];
    
    self.bigImageView.height = [LTools heightForImageHeight:image_height imageWidth:image_width showWidth:DEVICE_WIDTH];
    [self.bigImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:nil];
    
    self.bigImageView.imageUrls = @[imageUrl];//imageView对应的图集url
    self.bigImageView.infoId = aModel.tt_id;//imageView对应的信息id
    
    self.zanBtn.selected = aModel.is_like == 1 ? YES : NO;
    
//    self.toolView.top = self.bigImageView.bottom - 35/2.f;
//    
//    NSString *userImageUrl = aModel.uinfo[@"photo"];
//    
//    _iconImageView.layer.cornerRadius = 35/2.f;
//    _iconImageView.clipsToBounds = YES;
//    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:userImageUrl] placeholderImage:DEFAULT_HEADIMAGE];
//    self.nameLabel.text = aModel.uinfo[@"user_name"];
}

@end

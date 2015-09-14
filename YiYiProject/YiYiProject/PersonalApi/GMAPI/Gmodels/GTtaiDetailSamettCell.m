//
//  GTtaiDetailSamettCell.m
//  YiYiProject
//
//  Created by gaomeng on 15/8/24.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "GTtaiDetailSamettCell.h"
#import "ButtonProperty.h"

@implementation GTtaiDetailSamettCell

-(void)loadCustomViewWithModel:(id)theModel{
    
   
    
    
    self.backGroudView = [[UIView alloc]init];
    self.backGroudView.backgroundColor = [UIColor redColor];
    _backGroudView.clipsToBounds = YES;
    [self addSubview:_backGroudView];
    
    //大图 大图放置赞
    self.photoView = [[UIImageView alloc] init];
    _photoView.contentMode = UIViewContentModeScaleAspectFill;
    _photoView.clipsToBounds = YES;
    _photoView.userInteractionEnabled =  YES;
    [_backGroudView addSubview:_photoView];
    
    self.likeBackBtn = [ButtonProperty buttonWithType:UIButtonTypeCustom];
    [_likeBackBtn addCornerRadius:3.f];
    _likeBackBtn.backgroundColor = [UIColor colorWithHexString:@"fdf8f9"];
    [_photoView addSubview:_likeBackBtn];
    
    _likeBackBtn.alpha = 0.8;
    
    
    self.like_label = [[UILabel alloc]init];
    _like_label.backgroundColor = [UIColor clearColor];
    _like_label.font = [UIFont systemFontOfSize:10];
    _like_label.textAlignment = NSTextAlignmentCenter;
    _like_label.textColor = [UIColor colorWithHexString:@"df81a3"];
    [_likeBackBtn addSubview:_like_label];
    
    
    self.like_btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_like_btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [_like_btn setImage:[UIImage imageNamed:@"danpin_zan_normal"] forState:UIControlStateNormal];
    [_like_btn setImage:[UIImage imageNamed:@"danpin_zan_selected"] forState:UIControlStateSelected];
    [_likeBackBtn addSubview:_like_btn];
    _like_btn.userInteractionEnabled = NO;
    

    
    [self setCellWithModel222:theModel];
    
    
}


- (void)setCellWithModel222:(TPlatModel *)aModel
{
    NSString *imageurl;
    NSDictionary *image = (NSDictionary *)aModel.image;
    if (image && [image isKindOfClass:[NSDictionary class]]) {
        
        imageurl = image[@"url"];
        
    }
    
    [self.photoView l_setImageWithURL:[NSURL URLWithString:imageurl] placeholderImage:DEFAULT_YIJIAYI];
    self.photoView.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
    
    self.like_btn.selected = aModel.is_like == 1 ? YES : NO;
    
    NSString *zanNum = [NSString stringWithFormat:@"%d",[aModel.tt_like_num intValue]];
    self.like_label.text = zanNum;
    
    [self layoutSubviews];
    
}



- (void)layoutSubviews {
    
    _backGroudView.frame = CGRectMake(0, 0, self.width, self.height);
    
    CGFloat infoHeight = 0.f;//infoView高度
    
    CGRect aBound = self.bounds;
    aBound.size.height -= infoHeight;
    self.photoView.frame = CGRectInset(aBound, 0, 0);
    
    
    CGFloat top_likeBackBtn = _photoView.height - 5 - 17;//赞 背景view
    
    //赞view
    CGFloat likeBackBtnWidth = 40;
    self.likeBackBtn.frame = CGRectMake(_photoView.width - 5 - likeBackBtnWidth, top_likeBackBtn, likeBackBtnWidth, 17);
    self.like_btn.frame = CGRectMake(0, 0, 17, 17);
    self.like_label.frame = CGRectMake(_like_btn.right, 0, likeBackBtnWidth - _like_btn.width, 17);
    
}

@end

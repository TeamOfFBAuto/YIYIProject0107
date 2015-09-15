//
//  GTtaiListCustomTableViewCell.m
//  YiYiProject
//
//  Created by gaomeng on 15/8/12.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "GTtaiListCustomTableViewCell.h"
#import "AnchorPiontView.h"
#import "GTtaiListViewController.h"

@implementation GTtaiListCustomTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



-(CGFloat)loadCustomViewWithModel:(TPlatModel*)model index:(NSIndexPath*)indexPath{
    
    NSString *imageUrl = model.image[@"url"];
    CGFloat image_width = [model.image[@"width"]floatValue];
    CGFloat image_height = [model.image[@"height"]floatValue];
    
    //图片缩放
    float rate;
    if (image_width == 0.0 || image_height == 0.0) {
        image_width = image_height;
    }else
    {
        rate = image_height/image_width;
    }
    CGFloat imageHeight = (DEVICE_WIDTH-10) * rate;
    
    self.maodianImv = [[PropertyImageView alloc]initWithFrame:CGRectMake(5, 5, DEVICE_WIDTH-10, imageHeight)];
    self.maodianImv.userInteractionEnabled = YES;
    self.maodianImv.layer.borderWidth = 0.5;
    self.maodianImv.layer.borderColor = [RGBCOLOR(220, 221, 223)CGColor];
    [self.maodianImv l_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:DEFAULT_YIJIAYI];
 
    //imageView对应的图集url
    if (imageUrl) {
        self.maodianImv.imageUrls = @[imageUrl];
    }else
    {
        self.maodianImv.imageUrls = nil;
    }
    self.maodianImv.infoId = model.tt_id;//imageView对应的信息id
    self.maodianImv.aModel = model;
    [self.contentView addSubview:self.maodianImv];
    
    
    //图片下面view
    UIView *downView = [[UIView alloc]initWithFrame:CGRectMake(5, CGRectGetMaxY(self.maodianImv.frame), self.maodianImv.frame.size.width, 60)];
    [self.contentView addSubview:downView];
    
    //活动
    UILabel *huodongLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, downView.frame.size.width-10, downView.frame.size.height*0.5)];
    huodongLabel.font = [UIFont systemFontOfSize:12];
    huodongLabel.textColor = RGBCOLOR(36, 37, 38);
    
    if ([model.activity isKindOfClass:[NSDictionary class]]) {
        NSString *huodong_str = [model.activity stringValueForKey:@"activity_title"];
        huodongLabel.text = huodong_str;
        
    }else{
        huodongLabel.text = @"暂无活动";
    }
    
    
    [downView addSubview:huodongLabel];
    
    //分割线
    UIView *midLine = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(huodongLabel.frame), downView.frame.size.width, 0.5)];
    midLine.backgroundColor = RGBCOLOR(220, 221, 223);
    [downView addSubview:midLine];
    
    UIView *leftLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0.5, downView.frame.size.height)];
    leftLine.backgroundColor = RGBCOLOR(220, 221, 223);
    [downView addSubview:leftLine];
    
    UIView *rightLine = [[UIView alloc]initWithFrame:CGRectMake(downView.frame.size.width-0.5, 0, 0.5, downView.frame.size.height)];
    rightLine.backgroundColor = RGBCOLOR(220, 221, 223);
    [downView addSubview:rightLine];
    
    UIView *downLine = [[UIView alloc]initWithFrame:CGRectMake(0, downView.frame.size.height-0.5, downView.frame.size.width, 0.5)];
    downLine.backgroundColor = RGBCOLOR(220, 221, 223);
    [downView addSubview:downLine];
    
    
    //距离 商场名称 赞
    CGFloat width = (DEVICE_WIDTH-10)/4.0;
    UIView *distanceView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(midLine.frame), width, huodongLabel.frame.size.height)];
    
    UIButton *distanceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [distanceBtn setFrame:distanceView.bounds];
    
    NSString *distance = model.distance;
    NSInteger distance_int = [distance integerValue];
    NSString *distance_str;
    if (distance_int>=1000) {
        distance_str = [NSString stringWithFormat:@"%.1fkm",distance_int*0.001];
    }else{
        distance_str = [NSString stringWithFormat:@"%.1fm",distance_int*1.0];
    }
    
    distanceBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [distanceBtn setImage:[UIImage imageNamed:@"activity_location.png"] forState:UIControlStateNormal];
    [distanceBtn setTitle:distance_str forState:UIControlStateNormal];
    [distanceBtn setTitleColor:RGBCOLOR(36, 37, 38) forState:UIControlStateNormal];
    [distanceBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 10, 0, width-30)];
    [distanceBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [distanceView addSubview:distanceBtn];
    [downView addSubview:distanceView];
    
    
    
    UILabel *storeNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(distanceView.frame), distanceView.frame.origin.y, 2*width, distanceView.frame.size.height)];
    storeNameLabel.textAlignment = NSTextAlignmentCenter;
    storeNameLabel.text = model.mall_name;
    storeNameLabel.font = [UIFont systemFontOfSize:12];
    storeNameLabel.textColor = RGBCOLOR(36, 37, 38);
    [downView addSubview:storeNameLabel];
    
    self.likeBackBtn = [ButtonProperty buttonWithType:UIButtonTypeCustom];
    _likeBackBtn.frame = CGRectMake(CGRectGetMaxX(storeNameLabel.frame), distanceView.frame.origin.y, distanceView.frame.size.width, distanceView.frame.size.height);
    [downView addSubview:_likeBackBtn];
    
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
    
    //赞view
    CGFloat likeBackBtnWidth = 40;
    self.like_btn.frame = CGRectMake(10, _likeBackBtn.height / 2.f - 17 / 2.f, 17, 17);
    self.like_label.frame = CGRectMake(_like_btn.right, _likeBackBtn.height / 2.f - 17 / 2.f, likeBackBtnWidth - _like_btn.width, 17);
    self.like_btn.selected = model.is_like == 1 ? YES : NO;
    self.like_label.text = [self zanNumStringForNum:model.tt_like_num];
    
    //小分割线
    UIView *line_l = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(distanceView.frame), (downView.frame.size.height*1.5 - 12)*0.5, 0.5, 12)];
    line_l.backgroundColor = RGBCOLOR(220, 221, 223);
    [downView addSubview:line_l];
    UIView *line_r = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(storeNameLabel.frame), line_l.frame.origin.y, 0.5, 12)];
    line_r.backgroundColor = RGBCOLOR(220, 221, 223);
    [downView addSubview:line_r];
    
    CGFloat cell_height = CGRectGetMaxY(downView.frame);
    
    return cell_height;
    
}

/**
 *  赞数量大于1000显示 k
 *
 *  @param zanNum
 *
 *  @return
 */
- (NSString *)zanNumStringForNum:(NSString *)zanNum
{
    int num = [zanNum intValue];
    if (num >= 1000) {
        
        return [NSString stringWithFormat:@"%.1fk",num * 0.001];
    }
    return zanNum;
}

@end

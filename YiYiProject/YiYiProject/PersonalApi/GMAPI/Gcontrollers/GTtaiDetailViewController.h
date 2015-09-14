//
//  GTtaiDetailViewController.h
//  YiYiProject
//
//  Created by gaomeng on 15/8/14.
//  Copyright (c) 2015年 lcw. All rights reserved.
//


//T台详情

#import "MyViewController.h"

@class GgetStoreYouhuiquanViewController;

@interface GTtaiDetailViewController : MyViewController


@property(nonatomic,assign)BOOL isTPlatPush;//是否是t台过来

@property(nonatomic,strong)NSString *tPlat_id;//T台id

@property(nonatomic,strong)TPlatModel *theModel;//单品model 给聊天界面传递
@property(nonatomic,strong)UILabel *likeNumLabel;//赞数字label
@property(nonatomic,strong)UIButton *likeBtn;//赞按钮

//分享
@property (strong, nonatomic) UIImageView *bigImageView;

//定位信息
@property(nonatomic,strong)NSDictionary *locationDic;


@end

//
//  PublishActivityController.h
//  YiYiProject
//
//  Created by lichaowei on 15/6/2.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "MyViewController.h"
#import "ActivityModel.h"

/**
 *  发布活动下一步
 */
@interface PublishActivityController : MyViewController

@property(nonatomic,strong)ActivityModel *theEditActivityModel;//上个界面传过来的需要编辑的活动model
@property(nonatomic,assign)BOOL isChangeCover;//是否更改了封面图
@property(nonatomic,assign)BOOL isEditActivity;//是否是编辑活动

/**
 *  发布活动上一级页面传参数
 *
 *  @param title     活动标题
 *  @param aImage    活动封面
 *  @param startTime 开始时间
 *  @param endTime   结束时间
 */
- (void)setActivityTitle:(NSString *)title
              coverImage:(UIImage *)aImage
               startTime:(NSString *)startTime
                 endTime:(NSString *)endTime
                  shopId:(NSString *)shopId;

@property(nonatomic,retain)UIViewController *shopViewController;//店铺页面


@end

//
//  CouponModel.h
//  YiYiProject
//
//  Created by lichaowei on 15/9/10.
//  Copyright (c) 2015年 lcw. All rights reserved.
//
/**
 *  优惠券model
 */
#import "BaseModel.h"

@interface CouponModel : BaseModel

@property(nonatomic,retain)NSString *coupon_id;
@property(nonatomic,retain)NSString *type;//1满减 2打折 3：新人优惠
@property(nonatomic,retain)NSString *full_money;//满多少钱
@property(nonatomic,retain)NSString *minus_money;//减多少钱
@property(nonatomic,retain)NSNumber *discount_num;//折扣
@property(nonatomic,retain)NSString *status;// 1正常 9不可用
@property(nonatomic,retain)NSString *add_time;
@property(nonatomic,retain)NSString *total_num;
@property(nonatomic,retain)NSString *remain_num;
@property(nonatomic,retain)NSString *receive_start_time;//开始领时间
@property(nonatomic,retain)NSString *receive_end_time;//结束领取时间
@property(nonatomic,retain)NSString *use_start_time;//使用开始时间
@property(nonatomic,retain)NSString *use_end_time;//使用结束时间
@property(nonatomic,retain)NSString *shop_id;
@property(nonatomic,retain)NSString *color;//1=>红色    2=>黄色    3=>蓝色
@property(nonatomic,retain)NSString *enable_receive;//1=>可以领取  0=>不可以领取
@property(nonatomic,retain)NSString *newer_money;//新人减钱多少
@property(nonatomic,retain)NSString *is_use;//是否使用
@property(nonatomic,retain)NSNumber *is_commmend;//是否推荐

@property(nonatomic,assign)BOOL isUsed;//是否被选中使用

@end

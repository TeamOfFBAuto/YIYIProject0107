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
@property(nonatomic,retain)NSString *type;//1满减 2打折
@property(nonatomic,retain)NSString *full_money;//满多少钱
@property(nonatomic,retain)NSString *minus_money;//减多少钱
@property(nonatomic,retain)NSString *discount_num;//折扣
@property(nonatomic,retain)NSString *status;// 1正常 9不可用
@property(nonatomic,retain)NSString *add_time;
@property(nonatomic,retain)NSString *total_num;
@property(nonatomic,retain)NSString *remain_num;
@property(nonatomic,retain)NSString *receive_start_time;//开始领时间
@property(nonatomic,retain)NSString *receive_end_time;//结束领取时间
@property(nonatomic,retain)NSString *use_start_time;//使用开始时间
@property(nonatomic,retain)NSString *use_end_time;//使用结束时间
@property(nonatomic,retain)NSString *shop_id;

@end

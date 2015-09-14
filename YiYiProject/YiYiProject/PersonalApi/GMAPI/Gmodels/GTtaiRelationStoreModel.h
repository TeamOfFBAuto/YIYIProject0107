//
//  GTtaiRelationStoreModel.h
//  YiYiProject
//
//  Created by gaomeng on 15/8/24.
//  Copyright (c) 2015年 lcw. All rights reserved.
//


//T台详情关联商场model

#import "BaseModel.h"

#import "CouponModel.h"//优惠券model

@interface GTtaiRelationStoreModel : BaseModel

@property(nonatomic,strong)NSString *brand_name;//品牌名
@property(nonatomic,strong)NSString *mall_name;//商场名
@property(nonatomic,strong)NSString *distance;//距离
@property(nonatomic,strong)NSDictionary *image;//商场下的单品 (锚点)
@property(nonatomic,strong)NSDictionary *activity;//活动 有活动时有此字段
@property(nonatomic,strong)NSMutableArray *isChoose;//是否选择
@property(nonatomic,strong)NSString *shop_id;//店铺id
@property(nonatomic,strong)NSArray *coupon_list;//优惠券列表
@property(nonatomic,strong)NSMutableArray *coupon_model_array;//优惠券model数组



@end

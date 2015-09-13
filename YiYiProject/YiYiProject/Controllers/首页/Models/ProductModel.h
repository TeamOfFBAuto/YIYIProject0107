//
//  WorthBuyModel.h
//  YiYiProject
//
//  Created by lichaowei on 14/12/16.
//  Copyright (c) 2014年 lcw. All rights reserved.
//

#import "BaseModel.h"
/**
 *  产品model
 */
@interface ProductModel : BaseModel

@property(nonatomic,retain)NSString *product_id;
@property(nonatomic,retain)NSString *distance;
@property(nonatomic,retain)NSString *mall_id;
@property(nonatomic,retain)NSString *longitude;
@property(nonatomic,retain)NSString *latitude;
@property(nonatomic,retain)NSString *mall_name;//店铺名或者商场名
@property(nonatomic,retain)NSString *mall_type;//店铺类型 2//精品店 3//品牌店 1//大商场
@property(nonatomic,retain)NSString *product_name;//品牌名
@property(nonatomic,retain)NSString *product_price;//打折后价格
@property(nonatomic,retain)NSString *original_price;//原价
@property(nonatomic,assign)CGFloat discount_num;
@property(nonatomic,retain)NSString *product_gender;
@property(nonatomic,retain)NSString *product_like_num;//赞数量
@property(nonatomic,retain)NSString *product_fav_num;//收藏数量
@property(nonatomic,retain)NSString *product_brand_id;
@property(nonatomic,retain)NSString *product_brand_name;//品牌名
@property(nonatomic,retain)NSString *product_share_num;
@property(nonatomic,retain)NSString *product_sku;//货号
@property(nonatomic,retain)NSString *product_hostsale;
@property(nonatomic,retain)NSString *product_add_time;
@property(nonatomic,retain)NSArray *imagelist;//图片数组
@property(nonatomic,retain)NSString *product_mall_id;
@property(nonatomic,retain)NSString *product_shop_id;//单品所在店铺
@property(nonatomic,retain)NSString *product_tag;
@property(nonatomic,retain)NSString *product_status;
@property(nonatomic,retain)NSString *product_hotsale;
@property(nonatomic,assign)NSInteger is_favor;
@property(nonatomic,assign)NSInteger is_like;
@property(nonatomic,retain)NSDictionary *brand_info;
@property(nonatomic,retain)NSDictionary *mall_info;
@property(nonatomic,retain)NSArray *images;//图片数组(单品详情)
@property(nonatomic,strong)NSString *product_new;
@property(nonatomic,retain)NSString *favor_id;
@property(nonatomic,retain)NSString *product_state;
@property(nonatomic,retain)NSString *fav_time;//收藏时间
@property(nonatomic,retain)NSString *uid;//收藏的人
@property(nonatomic,retain)NSString *product_view_num;//浏览数
@property(nonatomic,strong)NSString *shop_type;//店铺类型
@property(nonatomic,strong)NSString *auto_down_time;//自动下架时间
@property(nonatomic,strong)NSString *product_type;//分类
@property(nonatomic,strong)NSString *product_type_name;//分类name

//新版本0812添加
@property(nonatomic,retain)NSArray *tag;//标签
@property(nonatomic,retain)NSArray *sameStyleArray;//同款单品列表
@property(nonatomic,retain)NSString *brand_name;//品牌名字
@property(nonatomic,retain)NSDictionary *official_pic;//官方固定介绍图
@property(nonatomic,retain)NSDictionary *official_activity;//官方活动

//支付相关
@property(nonatomic,retain)NSString *product_num;//单品个数
@property(nonatomic,retain)NSString *weight;//重量单位 g
@property(nonatomic,retain)NSString *cover_pic;//单品封面
@property(nonatomic,retain)NSString *is_seckill;//是否秒杀
@property(nonatomic,retain)NSArray *coupon_list;//优惠券列表


//购物车
@property(nonatomic,retain)NSString *cart_pro_id;//购物车id
@property(nonatomic,retain)NSString *color_id;//颜色id
@property(nonatomic,retain)NSString *size_id;//尺寸id
@property(nonatomic,retain)NSString *add_time;
@property(nonatomic,retain)NSDictionary *small_cover_pic;//小封面图
@property(nonatomic,retain)NSString *size;//尺寸name
@property(nonatomic,retain)NSString *color;//颜色name
@property(nonatomic,assign)BOOL isSelected;//购物车中判断是否选择


//颜色
@property(nonatomic,strong)NSDictionary *colorDic;//color_id color_name
//尺寸
@property(nonatomic,strong)NSDictionary *sizeDic;//size_id size_name
//数量
@property(nonatomic,assign)NSInteger tnum;
//是否选择过颜色
@property(nonatomic,assign)BOOL ischooseColor;
//是否选择过尺寸
@property(nonatomic,assign)BOOL ischooseSize;
//是否勾选该单品
@property(nonatomic,assign)BOOL isChoose;

//跳转颜色尺码选择需要添加的productmodel属性
@property(nonatomic,strong)NSDictionary *product_cover_pic;//封面图dic 字段src
@property(nonatomic,strong)NSString *product_type_name;//单品类型



@end

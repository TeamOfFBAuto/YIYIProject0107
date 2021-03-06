//
//  MailInfoModel.h
//  YiYiProject
//
//  Created by lichaowei on 15/1/22.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "BaseModel.h"
/**
 *  店铺model
 */
@interface MailInfoModel : BaseModel

@property(nonatomic,retain)NSString *id;
@property(nonatomic,retain)NSString *uid;
@property(nonatomic,retain)NSString *mall_id;
@property(nonatomic,retain)NSString *brand_id;
@property(nonatomic,retain)NSString *floor;
@property(nonatomic,retain)NSString *doorno;
@property(nonatomic,retain)NSString *shop_mobile;
@property(nonatomic,strong)NSString *shop_phone;//店铺联系电话
@property(nonatomic,retain)NSString *status;
@property(nonatomic,retain)NSString *address;
@property(nonatomic,retain)NSString *logo;
@property(nonatomic,retain)NSString *shop_name;
@property(nonatomic,strong)NSString *latitude;
@property(nonatomic,strong)NSString *longitude;
@property(nonatomic,strong)NSString *mall_name;
@property(nonatomic,strong)NSString *mall_type;
@property(nonatomic,strong)NSString *shop_view_num;//访客
@property(nonatomic,strong)NSString *attend_num;//店铺粉丝

@end

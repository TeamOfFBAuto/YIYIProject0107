//
//  YIYIChatViewController.h
//  YiYiProject
//
//  Created by lichaowei on 14/12/26.
//  Copyright (c) 2014年 lcw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductModel.h"
#import "RCChatViewController.h"


@interface YIYIChatViewController : RCChatViewController


@property(nonatomic,strong)UILabel *GTitleLabel;//标题Label


@property(nonatomic,strong)ProductModel *theModel;//产品

@property(nonatomic,strong)NSString *orderInfo;//订单信息

@property(nonatomic,assign)BOOL isProductDetailVcPush;//是否从产品详情页跳转过来的

@property (nonatomic,assign)BOOL lastPageNavigationHidden;//上一个navigationBar是否是隐藏

@end

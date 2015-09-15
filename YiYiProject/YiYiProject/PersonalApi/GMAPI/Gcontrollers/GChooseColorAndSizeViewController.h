//
//  GChooseColorAndSizeViewController.h
//  YiYiProject
//
//  Created by gaomeng on 15/9/8.
//  Copyright (c) 2015年 lcw. All rights reserved.
//


//选择颜色尺码

#import <UIKit/UIKit.h>
@class GTtaiDetailViewController;

typedef enum{
    CHOOSETYPE_LIJIGOUMAI = 0,//立即购买
    CHOOSETYPE_GOUWUCHE//加入购物车
}CHOOSETYPE;


@interface GChooseColorAndSizeViewController : MyViewController


//必传属性
@property(nonatomic,assign)CHOOSETYPE theType;
@property(nonatomic,strong)NSArray *productModelArray;//产品model数组 需要添加的字段参看productModel

@property(nonatomic,assign)UIViewController *lastVc;

-(void)jisuanPrice;

@end

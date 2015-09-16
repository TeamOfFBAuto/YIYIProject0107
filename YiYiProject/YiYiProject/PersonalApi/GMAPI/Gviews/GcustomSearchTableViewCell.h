//
//  GcustomSearchTableViewCell.h
//  YiYiProject
//
//  Created by gaomeng on 15/3/29.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

//搜索结果自定义cell
#import <UIKit/UIKit.h>
@class GsearchViewController;

typedef enum{
    GSEARCHTYPE_NONE = 0,
    GSEARCHTYPE_PINPAI,//品牌
    GSEARCHTYPE_SHANGPU,//商铺
    GSEARCHTYPE_DANPIN//单品
}GSEARCHTYPE;


@interface GcustomSearchTableViewCell : UITableViewCell


@property(nonatomic,assign)GSEARCHTYPE theType;//类型
@property(nonatomic,assign)GsearchViewController *delegate;

@property(nonatomic,assign)BOOL isHaveKeyWord;//是否有关键字


-(CGFloat)loadCustomViewWithData:(NSDictionary*)theData indexPath:(NSIndexPath*)theIndex showDidtance:(BOOL)isShow;



@end

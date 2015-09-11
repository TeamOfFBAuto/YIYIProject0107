//
//  CoupeView.h
//  YiYiProject
//
//  Created by lichaowei on 15/9/10.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

/**
 *  获取优惠券view
 */
#import <UIKit/UIKit.h>

typedef void(^COUPEBLOCK)(NSDictionary *params);

@interface CoupeView : UIView{
    NSArray *_coupeArray;
}

@property(nonatomic,copy)COUPEBLOCK coupeBlock;

-(instancetype)initWithCouponArray:(NSArray *)couponArray;

- (void)show;



@end

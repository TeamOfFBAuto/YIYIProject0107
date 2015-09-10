//
//  CoupeView.m
//  YiYiProject
//
//  Created by lichaowei on 15/9/10.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "CoupeView.h"
#import "CouponModel.h"
#import "ButtonProperty.h"

@implementation CoupeView

-(instancetype)initWithCouponArray:(NSArray *)couponArray
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        
        self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
        
        CGFloat left = [LTools fitWidth:25];
        CGFloat aWidth = DEVICE_WIDTH - left * 2;
        
        NSArray *coupeList = couponArray;
        
        _coupeArray = couponArray;
        
        UIView *listView = [[UIView alloc]initWithFrame:CGRectMake(left, 0, aWidth, 0)];
        [self addSubview:listView];
        listView.backgroundColor = [UIColor whiteColor];
        [listView addCornerRadius:5.f];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, listView.width, [LTools fitHeight:40]) title:@"领取优惠劵" font:15 align:NSTextAlignmentCenter textColor:[UIColor blackColor]];
        [listView addSubview:titleLabel];
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, titleLabel.bottom, listView.width, 0.5)];
        line.backgroundColor = DEFAULT_LINE_COLOR;
        [listView addSubview:line];
        
        CGFloat bottom = line.bottom;
        CGFloat top = line.bottom;
        NSInteger count = coupeList.count;
        for (int i = 0; i < count; i ++) {
            CouponModel *aModel = [[CouponModel alloc]initWithDictionary:coupeList[i]];
            UIView *aView = [self coupeViewWithCoupeModel:aModel frame:CGRectMake(0, top + [LTools fitHeight:50] * i, listView.width, [LTools fitHeight:50])];
            [listView addSubview:aView];
            bottom = aView.bottom;
        }
        
        UIButton *closeBtn = [[UIButton alloc]initWithframe:CGRectMake(0,bottom + [LTools fitHeight:15], [LTools fitWidth:173], [LTools fitHeight:25]) buttonType:UIButtonTypeCustom normalTitle:@"暂不领取" selectedTitle:nil target:self action:@selector(clickToCloseCoupeView)];
        [listView addSubview:closeBtn];
        closeBtn.backgroundColor = [UIColor colorWithHexString:@"999999"];
        [closeBtn addCornerRadius:5.f];
        [closeBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        closeBtn.centerX = listView.width / 2.f;
        
        listView.height = closeBtn.bottom + [LTools fitHeight:15];
        listView.centerY = DEVICE_HEIGHT / 2.f;
        
    }
    return self;
}

- (UIView *)coupeViewWithCoupeModel:(CouponModel *)aModel
                              frame:(CGRect)frame
{
    UIView *view = [[UIView alloc]initWithFrame:frame];
    
    UIImage *aImage = [LTools imageForCoupeColorId:aModel.color];
    
    //券
    UIButton *btn = [[UIButton alloc]initWithframe:CGRectMake([LTools fitWidth:10], [LTools fitHeight:8] , [LTools fitWidth:88], [LTools fitHeight:35]) buttonType:UIButtonTypeCustom normalTitle:nil selectedTitle:nil nornalImage:aImage selectedImage:nil target:self action:nil];
    [view addSubview:btn];
    
    NSString *title_minus = [NSString stringWithFormat:@"￥%@",aModel.minus_money];
    NSString *title_full = [NSString stringWithFormat:@"满%@即可使用",aModel.full_money];
    
    CGFloat aHeight = btn.height / 2.f - 5;
    UILabel *minusLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, btn.width - 10, aHeight) title:title_minus font:8 align:NSTextAlignmentCenter textColor:[UIColor whiteColor]];
    [btn addSubview:minusLabel];
    UILabel *fullLabel = [[UILabel alloc]initWithFrame:CGRectMake(minusLabel.left, minusLabel.bottom, minusLabel.width, aHeight) title:title_full font:8 align:NSTextAlignmentCenter textColor:[UIColor whiteColor]];
    [btn addSubview:fullLabel];
    
    NSString *title1 = [NSString stringWithFormat:@"满%@减%@",aModel.full_money,aModel.minus_money];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(btn.right + 5, btn.top, [LTools fitWidth:140], btn.height / 2.f) title:title1 font:8 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"5c5c5c"]];
    [view addSubview:label];
    
    NSString *title2 = [NSString stringWithFormat:@"有效期:%@-%@",[LTools timeString:aModel.use_start_time withFormat:@"yyyy.MM.dd"],[LTools timeString:aModel.use_end_time withFormat:@"yyyy.MM.dd"]];
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(btn.right + 5, label.bottom, [LTools fitWidth:140], btn.height / 2.f) title:title2 font:8 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"ababab"]];
    [view addSubview:label2];
    
    //点击获取优惠劵
    CGFloat aWidth = [LTools fitWidth:55];
    
    ButtonProperty *btn_get = [ButtonProperty buttonWithType:UIButtonTypeCustom];
    btn_get.frame = CGRectMake(view.width - [LTools fitWidth:10] - aWidth, [LTools fitHeight:16], aWidth, [LTools fitHeight:20]);
    [btn_get setImage:[UIImage imageNamed:@"youhui_lingqu"] forState:UIControlStateNormal];
    [btn_get setImage:[UIImage imageNamed:@"youhui_yilingqu"] forState:UIControlStateSelected];
    [btn_get addTarget:self action:@selector(clickToGetCoupe:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btn_get];
    btn_get.object = aModel;
    
    int isGet = [aModel.enable_receive intValue];
    btn_get.selected = !isGet;
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, btn.bottom + btn.top, view.width, 0.5)];
    line.backgroundColor = DEFAULT_LINE_COLOR;
    [view addSubview:line];
    
    return view;
}

- (void)setCoupeBlock:(COUPEBLOCK)coupeBlock
{
    _coupeBlock = coupeBlock;
}

/**
 *  获取优惠券
 *
 *  @param sender
 */
- (void)clickToGetCoupe:(ButtonProperty *)sender
{
    CouponModel *aModel = sender.object;
    if (aModel && [aModel isKindOfClass:[CouponModel class]]) {
        
        if (self.coupeBlock) {
            NSDictionary *params = @{@"button":sender,
                                     @"model":aModel};
            self.coupeBlock(params);
        }
    }
}

- (void)show
{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
}

/**
 *  关闭领取优惠券界面
 */
- (void)clickToCloseCoupeView
{
    [self removeFromSuperview];
}

@end

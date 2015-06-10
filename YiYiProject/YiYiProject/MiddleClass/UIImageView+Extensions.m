//
//  UIImageView+Extensions.m
//  YiYiProject
//
//  Created by lichaowei on 15/5/6.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "UIImageView+Extensions.h"

@implementation UIImageView (Extensions)


- (void)addTaget:(id)target action:(SEL)selector tag:(int)tag
{
    self.userInteractionEnabled = YES;
    UIButton *personalButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [personalButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    personalButton.frame = self.bounds;
    personalButton.tag = tag;
    [self addSubview:personalButton];
}

- (void)addCornerRadius:(CGFloat)radius
{
    self.layer.cornerRadius = radius;
    self.clipsToBounds = YES;
}

- (void)addRoundCorner
{
    [self addCornerRadius:self.width/2.f];
}

/**
 *  加默认文字
 *
 *  @param placeHolder 默认文字
 */
- (void)addPlaceHolder:(NSString *)placeHolder
           holderTextColor:(UIColor *)holderTextColor
{
    UILabel *label = [[UILabel alloc]initWithFrame:self.bounds];
    label.text = placeHolder;
    [self.superview addSubview:label];
    label.font = [UIFont systemFontOfSize:14.f];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = holderTextColor;
    [self.superview bringSubviewToFront:self];
    
}

/**
 *  加默认文字
 *
 *  @param placeHolder 默认文字
 */
- (void)setImageWithURL:(NSURL *)imageURL
        placeHolderText:(NSString *)placeHolderText
        backgroundColor:(UIColor *)backColor
        holderTextColor:(UIColor *)holderTextColor
{
    __block UILabel *label = [[UILabel alloc]initWithFrame:self.bounds];
    [self addSubview:label];
    label.font = [UIFont systemFontOfSize:14.f];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = holderTextColor;
    self.backgroundColor = backColor;
    
    __block UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.frame = self.bounds;
    [self addSubview:indicator];
    indicator.center = CGPointMake(self.width/2.f, self.height/2.f);
    [indicator startAnimating];
    
    [self sd_setImageWithURL:imageURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        if (error) {
            //加载失败显示placeHolderText
            label.text = placeHolderText;
        }else
        {
            //加载成功移除label
            label.hidden = YES;
            [label removeFromSuperview];
            label = nil;
        }
        [indicator stopAnimating];
    }];
    
}


@end

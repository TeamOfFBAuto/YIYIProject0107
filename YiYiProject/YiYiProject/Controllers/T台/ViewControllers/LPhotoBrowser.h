//
//  LPhotoBrowser.h
//  YiYiProject
//
//  Created by lichaowei on 15/4/20.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "MJPhotoBrowser.h"
#import "TPlatModel.h"

///图片浏览器,继承自 MJPhotoBrowser
@interface LPhotoBrowser : MJPhotoBrowser

@property(nonatomic,retain)NSString *tt_id;

@property(nonatomic,assign)TPlatModel *t_model;

@property(nonatomic,assign)UIImageView *showImageView;

@end

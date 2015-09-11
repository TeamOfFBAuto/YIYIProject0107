//
//  GChooseColorSizeTableViewCell.h
//  YiYiProject
//
//  Created by gaomeng on 15/9/8.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

//颜色尺码选择自定义cell

#import <UIKit/UIKit.h>
@class GChooseColorAndSizeViewController;

@interface GChooseColorSizeTableViewCell : UITableViewCell

@property(nonatomic,strong)NSDictionary *netDataDic;
@property(nonatomic,assign)GChooseColorAndSizeViewController *delegate;

-(void)loadCustomViewWithIndexPath:(NSIndexPath*)theIndexPath netDatamodel:(NSDictionary *)dic;


@end

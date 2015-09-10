//
//  GChooseColorSizeTableViewCell.h
//  YiYiProject
//
//  Created by gaomeng on 15/9/8.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

//颜色尺码选择自定义cell

#import <UIKit/UIKit.h>

@interface GChooseColorSizeTableViewCell : UITableViewCell


-(void)loadCustomViewWithIndexPath:(NSIndexPath*)theIndexPath netDatamodel:(NSDictionary *)dic productModel:(ProductModel*)thePmodel;


@end

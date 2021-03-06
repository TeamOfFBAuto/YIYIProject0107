//
//  EditMyInfoViewController.h
//  YiYiProject
//
//  Created by 王龙 on 15/1/3.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "MyViewController.h"
#import "EditInfoView.h"
@class MineViewController;
@interface EditMyInfoViewController : MyViewController <UIScrollViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,UITextFieldDelegate>
{
    UIScrollView *infoScrollView;
    EditInfoView *infoView;
    UIDatePicker *datePicker;
    //日期数据源
    NSMutableArray *yearArray;
    NSArray *monthArray;
    NSMutableArray *DaysArray;
    NSDictionary *infoDic;  //用户信息
    UIView *dateView;
}

@property(nonatomic,assign)MineViewController *delegate;


@end

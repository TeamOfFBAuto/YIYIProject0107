//
//  MyYiChuViewController.h
//  YiYiProject
//
//  Created by szk on 14/12/27.
//  Copyright (c) 2014年 lcw. All rights reserved.
//

#import "MyViewController.h"
#import "ZYQAssetPickerController.h"

@interface MyYiChuViewController : MyViewController<UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,ZYQAssetPickerControllerDelegate>

//@property(nonatomic,strong)NSMutableArray *listArray;

@property(nonatomic,strong)UITableView *mainTabV;


@end

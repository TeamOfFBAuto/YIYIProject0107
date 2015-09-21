//
//  GTtaiDetailViewController.m
//  YiYiProject
//
//  Created by gaomeng on 15/8/14.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "GTtaiDetailViewController.h"

#import "CycleScrollView1.h"//上下滚动
#import "MessageDetailController.h"//活动详情
#import "LShareSheetView.h"//分享
#import "LWaterFlow2.h"//瀑布流


#import "TPlatModel.h"//T台model

#import "GTtaiRelationStoreModel.h"//关联商场model

#import "GTtaiDetailModel.h"//T台详情model

#import "GTtaiDetailSamettCell.h"//T台详情同款T台推荐cell

#import "AnchorPiontView.h"//锚点

#import "CycleScrollView1.h"//竖着的轮播图
#import "UILabel+GautoMatchedText.h"

#import "GBtn.h"

#import "TTaiCommentViewController.h"//评论页面

#import "GwebViewController.h"//webview

#import "GMoreTtaiSameStroViewController.h"//有T台锚点单品的更多商场

#import "ButtonProperty.h"//带属性的button
#import "GmyTtaiViewController.h"//点击标签跳转

#import "GChooseColorAndSizeViewController.h"//选择颜色尺寸

#import "GgetStoreYouhuiquanViewController.h"//领取优惠券

#import "ShoppingCarController.h"//购物车


@interface GTtaiDetailViewController ()<UIScrollViewDelegate,PSWaterFlowDelegate,PSCollectionViewDataSource,GgetllocationDelegate,UITableViewDataSource,UITableViewDelegate>
{
    
    
    UIButton *_collectButton;//收藏 与 取消收藏
    UIButton *_heartButton;//赞 与 取消赞
    MBProgressHUD *_loading;
    
    UILabel *_backLabel;//释放返回
    UILabel *_zanNumLabel;//赞数量label
    UILabel *_commentNumLabel;//评论数量label
    NSArray *_image_urls;//图片链接数组
    
    int _count;//网络请求完成个数
    
    
    LTools *_tool_detail;
    LTools *_tool_relationShop;
    
    LWaterFlow2 *_collectionView;//瀑布流
    
    
    NSString *_lat;
    NSString *_long;
    
    
    
    
    
    //headerView
    UIView *_tabHeaderView;
    UITableView *_tabHeaderTableView;
    
    //T台详情model
    TPlatModel *_ttaiDetailModel;
    
    //关联的商场数据
    NSMutableArray *_relationStoreArray;//里面装的是GTtaiRelationStoreModel
    NSArray *_relationStoreProductChooseArray;
    
    
    CycleScrollView1 *_topScrollView1;//轮播图
    
    
    //缩放tablview
    int _isOpen[10];
    
    
    //没有tableview时候的header高度
    CGFloat _noTabHeaderHeight;
    
    
    
    UIView *_tableFooterView;//官方活动view
    
    BOOL _isHaveMoreStoreData;//是否有更多商场
    
    NSMutableArray *_tmpArray;
    
    
    
    NSDictionary *_shopInfo;//店铺信息
    
    NSMutableArray *_allProductArray;//所有关联商场的单品
    
    UILabel *_shopCarNumLabel;
    UIButton *_carBtn;
    
    
}
@end

@implementation GTtaiDetailViewController


- (void)dealloc
{
    NSLog(@"dealloc %@",self);
    [_tool_detail cancelRequest];
    [_tool_relationShop cancelRequest];
    _heartButton = nil;
    _collectButton = nil;
    
    _collectionView.waterDelegate = nil;
    _collectionView.quitView = nil;
    _collectionView = nil;
     [self removeObserver:self forKeyPath:@"_count"];
    
    
    [[NSNotificationCenter defaultCenter]removeObserver:self forKeyPath:NOTIFICATON_UPDATESHOPCAR_NUM];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    if (self.isTPlatPush) {
        
        self.navigationController.navigationBarHidden = YES;
        
        [[UIApplication sharedApplication]setStatusBarHidden:NO];
    }
    
    self.navigationController.navigationBarHidden = NO;
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:self.lastPageNavigationHidden animated:animated];
    
    if (_collectionView.reloading) {
        [_collectionView loadFail];
    }
    
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    
    _isHaveMoreStoreData = NO;
    
    [self addObserver:self forKeyPath:@"_count" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getshopcarNum) name:NOTIFICATON_UPDATESHOPCAR_NUM object:nil];
    
    
    for (int i=0; i<10; i++) {
        _isOpen[i]=0;
    }
    _isOpen[0] = 1;
    
    _noTabHeaderHeight = 0;
    
    [self creatPubuLiu];
    
    [self creatDownView];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - MyMethod




/**
 *  根据6的屏幕计算比例宽度
 *
 *  @param aWidth 6上的宽
 *
 *  @return 等比例的宽
 */
- (CGFloat)fitWidth:(CGFloat)aWidth
{
    return (aWidth * DEVICE_WIDTH) / 375;
}


/**
 *  底部工具栏
 */
- (void)creatDownView
{
    //购物车
    
    _carBtn = [[UIButton alloc]initWithframe:CGRectMake(DEVICE_WIDTH - 15 - 45, DEVICE_HEIGHT - 64 - 50 - 5 - 45, 45, 45) buttonType:UIButtonTypeCustom normalTitle:nil selectedTitle:nil nornalImage:[UIImage imageNamed:@"danpinxq_gouwuche"] selectedImage:nil target:self action:@selector(clickToShoppingCar)];
    
    
    [self.view addSubview:_carBtn];
    
    _shopCarNumLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    _shopCarNumLabel.textColor = [UIColor whiteColor];
    _shopCarNumLabel.backgroundColor = RGBCOLOR(255, 126, 170);
    _shopCarNumLabel.layer.cornerRadius = 5;
    _shopCarNumLabel.layer.borderColor = [RGBCOLOR(255, 126, 170)CGColor];
    _shopCarNumLabel.layer.borderWidth = 0.5f;
    _shopCarNumLabel.layer.masksToBounds = YES;
    _shopCarNumLabel.font = [UIFont systemFontOfSize:11];
    _shopCarNumLabel.textAlignment = NSTextAlignmentCenter;
    [_carBtn addSubview:_shopCarNumLabel];
    
    
    
    //导航按钮
    
    UIView *bottom = [[UIView alloc]initWithFrame:CGRectMake(0, DEVICE_HEIGHT - 64 - 50, DEVICE_WIDTH, 50)];
    bottom.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"danpinxq_dibu"]];
    [self.view addSubview:bottom];
    
    //购物车和立即购买按钮宽度
    CGFloat aWidth = [self fitWidth:100];
    
    //电话、聊天、店铺按钮宽度
    CGFloat aWidth_other = (DEVICE_WIDTH - aWidth * 2) / 3.f;
    
    //电话
    UIButton *phoneBtn = [[UIButton alloc]initWithframe:CGRectMake(0, 0, aWidth_other, bottom.height) buttonType:UIButtonTypeCustom nornalImage:[UIImage imageNamed:@"danpinxq_dianhua2"] selectedImage:nil target:self action:@selector(clickToPhone:)];
    [bottom addSubview:phoneBtn];
    
    //聊天
    UIButton *chatBtn = [[UIButton alloc]initWithframe:CGRectMake(phoneBtn.right, 0, aWidth_other, bottom.height) buttonType:UIButtonTypeCustom nornalImage:[UIImage imageNamed:@"danpinxq_lianximaijia2"] selectedImage:nil target:self action:@selector(clickToPrivateChat:)];
    [bottom addSubview:chatBtn];
    
    //店铺
    UIButton *shopBtn = [[UIButton alloc]initWithframe:CGRectMake(chatBtn.right, 0,aWidth_other, bottom.height) buttonType:UIButtonTypeCustom nornalImage:[UIImage imageNamed:@"danpinxq_jiarudianpu"] selectedImage:nil target:self action:@selector(clickToStore:)];
    [bottom addSubview:shopBtn];
    
    //加入购物车
    
    UIButton *shopCarBtn = [[UIButton alloc]initWithframe:CGRectMake(shopBtn.right, 0, aWidth, bottom.height) buttonType:UIButtonTypeCustom normalTitle:@"加入购物车" selectedTitle:nil target:self action:@selector(clickToAddToShoppingCar)];
    [shopCarBtn.titleLabel setFont:[UIFont systemFontOfSize:13]];
    shopCarBtn.backgroundColor = [UIColor colorWithHexString:@"ffc480"];
    [bottom addSubview:shopCarBtn];
    
    //立即购买
    UIButton *buyBtn = [[UIButton alloc]initWithframe:CGRectMake(shopCarBtn.right, 0, aWidth, bottom.height) buttonType:UIButtonTypeCustom normalTitle:@"立即购买" selectedTitle:nil target:self action:@selector(clickToBuy)];
    [buyBtn.titleLabel setFont:[UIFont systemFontOfSize:13]];
    buyBtn.backgroundColor = [UIColor colorWithHexString:@"ff7eaa"];
    [bottom addSubview:buyBtn];
}


/**
 *  加入购物车
 */
- (void)clickToAddToShoppingCar
{
    
    
    //判断是否登录
    if ([LTools cacheBoolForKey:LOGIN_SERVER_STATE] == NO) {
        
        LoginViewController *login = [[LoginViewController alloc]init];
        
        UINavigationController *unVc = [[UINavigationController alloc]initWithRootViewController:login];
        
        [self presentViewController:unVc animated:YES completion:nil];
        
        return;
    }
    
    
    _allProductArray = [NSMutableArray arrayWithCapacity:1];
    
    for (GTtaiRelationStoreModel *model  in _relationStoreArray) {
        for (int i = 0; i<model.isChoose.count; i++) {
            NSString *isc = model.isChoose[i];
            if ([isc isEqualToString:@"1"]) {
                NSArray *img_detail = [model.image arrayValueForKey:@"img_detail"];
                NSDictionary *dd = img_detail[i];
                ProductModel *modl = [[ProductModel alloc]initWithDictionary:dd];
                [_allProductArray addObject:modl];
            }
        }
    }
    
    if (_allProductArray.count == 0) {
        [GMAPI showAutoHiddenMBProgressWithText:@"请勾选您需要的商品" addToView:self.view];
        return;
    }
    
    GChooseColorAndSizeViewController *cc = [[GChooseColorAndSizeViewController alloc]init];
    cc.theType = CHOOSETYPE_GOUWUCHE;
    cc.productModelArray = _allProductArray;
    [self.navigationController pushViewController:cc animated:YES];
}

/**
 *  立即购买
 */
- (void)clickToBuy
{
    
    
    //判断是否登录
    if ([LTools cacheBoolForKey:LOGIN_SERVER_STATE] == NO) {
        
        LoginViewController *login = [[LoginViewController alloc]init];
        
        UINavigationController *unVc = [[UINavigationController alloc]initWithRootViewController:login];
        
        [self presentViewController:unVc animated:YES completion:nil];
        
        return;
    }
    
    
    _allProductArray = [NSMutableArray arrayWithCapacity:1];
    
    for (GTtaiRelationStoreModel *model  in _relationStoreArray) {
        for (int i = 0; i<model.isChoose.count; i++) {
            NSString *isc = model.isChoose[i];
            if ([isc isEqualToString:@"1"]) {
                NSArray *img_detail = [model.image arrayValueForKey:@"img_detail"];
                NSDictionary *dd = img_detail[i];
                ProductModel *modl = [[ProductModel alloc]initWithDictionary:dd];
                [_allProductArray addObject:modl];
            }
        }
    }
    
    if (_allProductArray.count == 0) {
        [GMAPI showAutoHiddenMBProgressWithText:@"请勾选您需要的商品" addToView:self.view];
        return;
    }
    
    GChooseColorAndSizeViewController *cc = [[GChooseColorAndSizeViewController alloc]init];
    cc.theType = CHOOSETYPE_LIJIGOUMAI;
    cc.productModelArray = _allProductArray;
    cc.lastVc = self;
    [self.navigationController pushViewController:cc animated:YES];
}

/**
 *  跳转购物车
 */
- (void)clickToShoppingCar
{
    ShoppingCarController *order = [[ShoppingCarController alloc]init];
    order.hidesBottomBarWhenPushed = YES;
    order.lastPageNavigationHidden = YES;
    [self.navigationController pushViewController:order animated:YES];
}

//进入店铺
- (void)clickToStore:(id)sender {
    
    
    
    
    int shop_type = [[_shopInfo stringValueForKey:@"shop_type"] intValue];
    NSString *storeId;
    NSString *storeName;
    
    if (shop_type == ShopType_pinpaiDian) {
        
        storeId = [_shopInfo stringValueForKey:@"shop_id"];
        storeName = [_shopInfo stringValueForKey:[_shopInfo stringValueForKey:@"mall_name"]];
        NSString *brandName = [_shopInfo stringValueForKey:[_shopInfo stringValueForKey:@"brand_name"]];//品牌店需要brandName
        
        [MiddleTools pushToStoreDetailVcWithId:storeId shopType:shop_type storeName:storeName brandName:brandName fromViewController:self lastNavigationHidden:NO hiddenBottom:NO isTPlatPush:NO];
        
    }else if (shop_type == ShopType_jingpinDian || shop_type == ShopType_mall){
        
        storeId = [_shopInfo stringValueForKey:@"mall_id"];
        storeName = [_shopInfo stringValueForKey:@"shop_name"];
        
        [MiddleTools pushToStoreDetailVcWithId:storeId shopType:shop_type storeName:storeName brandName:@" " fromViewController:self lastNavigationHidden:NO hiddenBottom:NO isTPlatPush:NO];
    }
}




/**
 *  电话
 *
 *  @param sender
 */
- (void)clickToPhone:(UIButton *)sender
{
    NSString *phoneNum = _shopInfo[@"shop_phone"];
    
    if (phoneNum.length > 0) {
        
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"拨号" message:phoneNum delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [al show];
    }else
    {
        [LTools showMBProgressWithText:@"抱歉!该商家暂未填写有效联系方式" addToView:self.view];
    }
}

/**
 *  联系卖家
 *
 *  @param sender
 */
- (void)clickToPrivateChat:(UIButton *)sender
{
    BOOL rong_login = [LTools cacheBoolForKey:LOGIN_RONGCLOUD_STATE];
    
    //服务器登陆成功
    if ([LTools isLogin:self]) {
        
        //融云登陆成功
        if (rong_login) {
            
            NSString *useriId;
            NSString *userName;
            NSString *shop_type;
            NSString *brand_name;
            NSString *mall_name;
            YIYIChatViewController *contact = [[YIYIChatViewController alloc]init];
            
            
            if ([_shopInfo isKindOfClass:[NSDictionary class]]) {
                
                useriId = _shopInfo[@"uid"];
                userName = _shopInfo[@"mall_name"];
                shop_type = _shopInfo[@"shop_type"];
                if ([shop_type intValue] == 3) {//商场店
                    brand_name = _shopInfo[@"brand_name"];//品牌名
                    mall_name = _shopInfo[@"mall_name"];//商城名
                    NSString *aaa = [NSString stringWithFormat:@"%@.%@",brand_name,mall_name];
                    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:aaa];
                    NSInteger pinpaiNameLength = brand_name.length;
                    NSInteger storeNameLength = mall_name.length;
                    [title addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0,pinpaiNameLength+1)];
                    [title addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17*GscreenRatio_320] range:NSMakeRange(0,pinpaiNameLength)];
                    [title addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(240, 173, 184) range:NSMakeRange(pinpaiNameLength+1, storeNameLength)];
                    [title addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13*GscreenRatio_320] range:NSMakeRange(pinpaiNameLength+1, storeNameLength)];
                    contact.GTitleLabel.textAlignment = NSTextAlignmentCenter;
                    contact.GTitleLabel.attributedText = title;
                }else{
                    userName = userName;
                    contact.GTitleLabel.text = userName;
                    contact.GTitleLabel.textColor = RGBCOLOR(251, 108, 157);
                }
                
            }
            
            contact.currentTarget = useriId;
            contact.portraitStyle = RCUserAvatarCycle;
            contact.enableSettings = NO;
            contact.conversationType = ConversationType_PRIVATE;
            
            contact.theModel = nil;
            contact.isProductDetailVcPush = YES;
            
            
            [self.navigationController pushViewController:contact animated:YES];
        }else
        {
            NSLog(@"服务器登陆成功了,融云未登陆");
            
            
            AppDelegate * appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appdelegate loginToRongCloud];
            
        }
        
    }
}


-(void)updateShopCarNumAndFrame{
    if ([_shopCarNumLabel.text intValue] == 0) {
        _shopCarNumLabel.hidden = YES;
    }else{
        _shopCarNumLabel.hidden = NO;
        [_shopCarNumLabel setMatchedFrame4LabelWithOrigin:CGPointMake(0, 0) height:11 limitMaxWidth:45];
        CGFloat with = _shopCarNumLabel.frame.size.width + 5;
        [_shopCarNumLabel setFrame:CGRectMake(_carBtn.bounds.size.width - with, -2, with, 11)];
        
    }
}


#pragma mark - 请求网络数据

//获取购物车数量
-(void)getshopcarNum{
    
    NSString *url = [NSString stringWithFormat:@"%@&authcode=%@",GET_SHOPPINGCAR_NUM,[GMAPI getAuthkey]];
    
    NSLog(@"获取购物车数量url %@",url);
    
    LTools *aa = [[LTools alloc]initWithUrl:url isPost:NO postData:nil];
    [aa requestCompletion:^(NSDictionary *result, NSError *erro) {
        
        if (_shopCarNumLabel) {
            _shopCarNumLabel.text = [NSString stringWithFormat:@"%d",[result intValueForKey:@"num"]];
            [self updateShopCarNumAndFrame];
        }
    } failBlock:^(NSDictionary *result, NSError *erro) {
        
    }];
}



//请求T台详情数据
-(void)prepareNetDataForTtaiDetail{
    if (_tool_detail) {
        [_tool_detail cancelRequest];
    }
    
    NSString *url = [NSString stringWithFormat:@"%@&authcode=%@&tt_id=%@&&page=%d&count=%d",TTAI_DETAIL_V2,[GMAPI getAuthkey],self.tPlat_id,_collectionView.pageNum,L_PAGE_SIZE];
    
    
    _tool_detail = [[LTools alloc]initWithUrl:url isPost:NO postData:nil];
    
    [_tool_detail requestCompletion:^(NSDictionary *result, NSError *erro) {
        
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if ([result isKindOfClass:[NSDictionary class]]) {
            
            _shopInfo = @{
                          @"shop_type":[result stringValueForKey:@"shop_type"],
                          @"shop_phone":[result stringValueForKey:@"shop_phone"],
                          @"mall_name":[result stringValueForKey:@"mall_name"],
                          @"brand_name":[result stringValueForKey:@"brand_name"],
                          @"uid":[result stringValueForKey:@"uid"],
                          @"shop_name":[result stringValueForKey:@"shop_name"],
                          @"mall_id":[result stringValueForKey:@"mall_id"],
                          @"shop_id":[result stringValueForKey:@"shop_id"]
                          };
            
            NSArray *same_tts = [result arrayValueForKey:@"same_tts"];
            _tmpArray = [NSMutableArray arrayWithCapacity:1];
            for (NSDictionary *dic in same_tts) {
                TPlatModel *model = [[TPlatModel alloc]initWithDictionary:dic];
                [_tmpArray addObject:model];
            }
            
            _ttaiDetailModel = [[TPlatModel alloc]initWithDictionary:result];
            
            
        }
        
        [self setValue:[NSNumber numberWithInt:_count + 1] forKeyPath:@"_count"];
        
        [self createNavigationbarTools];//导航条
        
        
    } failBlock:^(NSDictionary *failDic, NSError *erro) {
        
        NSLog(@"failBlock == %@",failDic[RESULT_INFO]);
        

        [_collectionView loadFail];
        
    }];
}


//请求T台详情数据
-(void)prepareMoreNetDataForTtaiDetail{
    if (_tool_detail) {
        [_tool_detail cancelRequest];
    }
    
    NSString *url = [NSString stringWithFormat:@"%@&authcode=%@&tt_id=%@&&page=%d&count=%d",TTAI_DETAIL_V2,[GMAPI getAuthkey],self.tPlat_id,_collectionView.pageNum,L_PAGE_SIZE];
    
    
    _tool_detail = [[LTools alloc]initWithUrl:url isPost:NO postData:nil];
    
    [_tool_detail requestCompletion:^(NSDictionary *result, NSError *erro) {
        
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if ([result isKindOfClass:[NSDictionary class]]) {
            
            NSArray *same_tts = [result arrayValueForKey:@"same_tts"];
            _tmpArray = [NSMutableArray arrayWithCapacity:1];
            for (NSDictionary *dic in same_tts) {
                TPlatModel *model = [[TPlatModel alloc]initWithDictionary:dic];
                [_tmpArray addObject:model];
            }
            _ttaiDetailModel = [[TPlatModel alloc]initWithDictionary:result];
             [_collectionView reloadData:_tmpArray pageSize:L_PAGE_SIZE];
            _ttaiDetailModel.same_tts = _collectionView.dataArray;
            
        }
        
    } failBlock:^(NSDictionary *failDic, NSError *erro) {
        
        NSLog(@"failBlock == %@",failDic[RESULT_INFO]);
        [_collectionView loadFail];
        
    }];
}


//请求T台关联的商场
-(void)prepareNetDataForStore{
    
    NSString *longitude = [self.locationDic stringValueForKey:@"long"];
    NSString *latitude = [self.locationDic stringValueForKey:@"lat"];
    
    NSString *url = [NSString stringWithFormat:@"%@&longitude=%@&latitude=%@&tt_id=%@page=%d&count=6",TTAI_STORE,longitude,latitude,self.tPlat_id,_collectionView.pageNum];

    _tool_relationShop = [[LTools alloc]initWithUrl:url isPost:NO postData:nil];
    
    [_tool_relationShop requestCompletion:^(NSDictionary *result, NSError *erro) {
        
        
        
        NSArray *list = result[@"list"];
        
        _relationStoreArray = [NSMutableArray arrayWithCapacity:1];
        
        
        for (int i = 0;i<list.count;i++) {
            NSDictionary *dic = list[i];
            GTtaiRelationStoreModel *amodel = [[GTtaiRelationStoreModel alloc]initWithDictionary:dic];
            amodel.isChoose = [NSMutableArray arrayWithCapacity:1];
            NSDictionary *image = amodel.image;
            if ([[image stringValueForKey:@"have_detail"]intValue] == 1) {
                for (int j = 0; j<[image arrayValueForKey:@"img_detail"].count; j++) {
                    if (i == 0) {
                        [amodel.isChoose addObject:@"1"];
                    }else{
                        [amodel.isChoose addObject:@"0"];
                    }
                    
                    
                }
            }
            [_relationStoreArray addObject:amodel];
            
            
        }
        
        if (_relationStoreArray.count >= 6) {
            _isHaveMoreStoreData = YES;
        }else{
            _isHaveMoreStoreData = NO;
        }
        
       
        
        
        [self setValue:[NSNumber numberWithInt:_count + 1] forKeyPath:@"_count"];
        
    } failBlock:^(NSDictionary *failDic, NSError *erro) {
        
        NSLog(@"failBlock == %@",failDic[RESULT_INFO]);
        

        [_collectionView loadFail];
        
    }];
}

/**
 *  赞 取消赞 收藏 取消收藏
 *
 *  @param action_type
 */
- (void)networkForActionType:(ACTION_TYPE)action_type
{
    
    //线上T台收藏为get请求
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    __weak typeof(self)weakSelf = self;
    
    NSString *api;
    if (action_type == Action_like_yes) {
        api = TTAI_ZAN;
    }else if (action_type == Action_Collect_yes){
        api = TTAI_COLLECT_ADD1;
    }else if (action_type == Action_like_no){
        api = TTAI_ZAN_CANCEL;
    }else if (action_type == Action_Collect_no){
        api = TTAI_COLLECT_CANCEL1;
    }
    
    NSString *post = [NSString stringWithFormat:@"tt_id=%@&authcode=%@",self.tPlat_id,[GMAPI getAuthkey]];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *url = api;//post
    if (action_type == Action_Collect_yes || action_type == Action_Collect_no) {
        url = [NSString stringWithFormat:@"%@&%@",api,post];//get
        LTools *tool = [[LTools alloc]initWithUrl:url isPost:NO postData:postData];
        [tool requestCompletion:^(NSDictionary *result, NSError *erro) {
            
            NSLog(@"result %@",result);
            
            if (action_type == Action_like_yes) {
                
                [weakSelf updateZanState:YES];
                
                
            }else if (action_type == Action_Collect_yes){
                
                _collectButton.selected = YES;
                //关注T台通知
                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_GUANZHU_TTai object:nil userInfo:@{@"state":[NSNumber numberWithBool:YES]}];
                
            }else if (action_type == Action_like_no){
                
                
                [weakSelf updateZanState:NO];
                
                
            }else if (action_type == Action_Collect_no){
                
                _collectButton.selected = NO;
                //关注T台通知
                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_GUANZHU_TTai object:nil userInfo:@{@"state":[NSNumber numberWithBool:NO]}];
            }
            
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
        } failBlock:^(NSDictionary *failDic, NSError *erro) {
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
            NSLog(@"failBlock == %@",failDic[RESULT_INFO]);
            
        }];
        
    }else{
        LTools *tool = [[LTools alloc]initWithUrl:url isPost:YES postData:postData];
        [tool requestCompletion:^(NSDictionary *result, NSError *erro) {
            
            NSLog(@"result %@",result);
            
            if (action_type == Action_like_yes) {
                
                [weakSelf updateZanState:YES];
                
                
            }else if (action_type == Action_Collect_yes){
                
                _collectButton.selected = YES;
                //关注T台通知
                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_GUANZHU_TTai object:nil userInfo:@{@"state":[NSNumber numberWithBool:YES]}];
                
            }else if (action_type == Action_like_no){
                
                
                [weakSelf updateZanState:NO];
                
                
            }else if (action_type == Action_Collect_no){
                
                _collectButton.selected = NO;
                //关注T台通知
                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_GUANZHU_TTai object:nil userInfo:@{@"state":[NSNumber numberWithBool:NO]}];
            }
            
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
        } failBlock:^(NSDictionary *failDic, NSError *erro) {
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
            NSLog(@"failBlock == %@",failDic[RESULT_INFO]);
            
        }];
    }
}


#pragma mark - 定位

- (void)getCurrentLocation
{

    __weak typeof(self)weakSelf = self;
    
    [[GMAPI appDeledate]startDingweiWithBlock:^(NSDictionary *dic) {
        
        [weakSelf theLocationDictionary:dic];
    }];
    
    
    
}
- (void)theLocationDictionary:(NSDictionary *)dic{
    
    NSLog(@"----》定位成功");
    self.locationDic = [GMAPI sharedManager].theLocationDic;
    _lat = [self.locationDic stringValueForKey:@"lat"];
    _long = [self.locationDic stringValueForKey:@"long"];
    //请求单品详情
    [self prepareNetDataForTtaiDetail];
    //请求关联商场
    [self prepareNetDataForStore];
    
    
}


-(void)theLocationFaild:(NSDictionary *)dic{
    
    NSLog(@"----》定位失败");
    
    self.locationDic = [GMAPI sharedManager].theLocationDic;
    _lat = [self.locationDic stringValueForKey:@"lat"];
    _long = [self.locationDic stringValueForKey:@"long"];
    //请求单品详情
    [self prepareNetDataForTtaiDetail];
    //请求关联商场
    [self prepareNetDataForStore];
}

#pragma mark - 事件处理


//收藏
-(void)clickToCollect:(UIButton*)sender{
    
    if ([LTools isLogin:self]) {
        
        if (sender.selected) {
            
            [self networkForActionType:Action_Collect_no];
        }else
        {
            [self networkForActionType:Action_Collect_yes];
        }
        
    }
    
}

/*
 分享
 */

- (void)clickToZhuanFa:(UIButton *)sender
{
    NSString *safeString = [LTools safeString:self.theModel.tPlat_name];
    NSString *title = safeString.length > 0 ? safeString : @"衣加衣—穿衣管家";
    
    NSString *content = [LTools isEmpty:_ttaiDetailModel.tt_content] ? @"随时逛商场，美衣送到家。线上浏览，在家试穿" : _ttaiDetailModel.tt_content;

    NSString *productString = [NSString stringWithFormat:SHARE_TPLAT_DETAIL,self.tPlat_id];
    
    [[LShareSheetView shareInstance] showShareContent:content title:title shareUrl:productString shareImage:self.bigImageView.image targetViewController:self];
    [[LShareSheetView shareInstance]actionBlock:^(NSInteger buttonIndex, Share_Type shareType) {
        
        if (shareType == Share_QQ) {
            
            NSLog(@"Share_QQ");
            
        }else if (shareType == Share_QQZone){
            
            NSLog(@"Share_QQZone");
            
        }else if (shareType == Share_WeiBo){
            
            NSLog(@"Share_WeiBo");
            
        }else if (shareType == Share_WX_HaoYou){
            
            NSLog(@"Share_WX_HaoYou");
            
        }else if (shareType == Share_WX_PengYouQuan){
            
            NSLog(@"Share_WX_PengYouQuan");
            
        }
        
    }];
    
    [[LShareSheetView shareInstance]shareResult:^(Share_Result result, Share_Type type) {
        
        if (result == Share_Success) {
            
            //分享 + 1
            NSLog(@"分享成功");
            
            [self zhuanFaTTaiDetail];
            
        }else
        {
            //分享失败
            
            NSLog(@"分享失败");
        }
        
    }];
}

// 转发 + 1

- (void)zhuanFaTTaiDetail
{
    NSString *authkey = [GMAPI getAuthkey];
    
    if (authkey.length == 0) {
        return;
    }
    
    NSString *post = [NSString stringWithFormat:@"tt_id=%@&authcode=%@",self.tPlat_id,authkey];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSString *url = TTAI_ZHUANFA_ADD;
    
    LTools *tool = [[LTools alloc]initWithUrl:url isPost:YES postData:postData];
    [tool requestCompletion:^(NSDictionary *result, NSError *erro) {
        
        NSLog(@"-->%@",result);
        
    } failBlock:^(NSDictionary *failDic, NSError *erro) {
        
    }];
}


/**
 *  评论页面
 *
 *  @param sender
 */
- (void)clickToComment:(UIButton *)sender
{
    
    TTaiCommentViewController *commentList = [[TTaiCommentViewController alloc]init];
    commentList.tt_id = self.tPlat_id;
    commentList.commentType = COMMENTTYPE_TPlat;
    commentList.t_model = _ttaiDetailModel;
    
    commentList.updateParamsBlock = ^(NSDictionary *params){
        
        BOOL result = [params[@"result"]boolValue];
        if (result) {
            
            //            [weakSelf networkForCommentList:YES];//更新评论
        }
    };
    
    
    
//    CATransition *transition = [CATransition animation];
//    
//    transition.duration = 0.7f;
//    
//    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    
//    transition.type = @"oglFlip";
//    
//    transition.subtype = kCATransitionFromLeft;
//    
//    transition.delegate = self;
//    
//    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    
    
    [self.navigationController pushViewController:commentList animated:YES];
}


/*
 是否喜欢
 */
- (void)clickToLike:(UIButton *)sender
{
    
    if ([LTools isLogin:self]) {
        
        [LTools animationToBigger:_heartButton duration:0.2 scacle:1.5];
        
        if (_heartButton.selected) {
            
            [self networkForActionType:Action_like_no];
        }else
        {
            [self networkForActionType:Action_like_yes];
        }
    }
}


/**
 *  同品牌推荐 赞与取消赞
 */
- (void)clickToZan:(ButtonProperty *)sender
{
    [MiddleTools zanTPlatWithParams:sender.object viewController:self resultBlock:nil];
}


-(void)clickToMoreStore{
    
    GMoreTtaiSameStroViewController *cc = [[GMoreTtaiSameStroViewController alloc]init];
    cc.tPlat_id = self.tPlat_id;
    cc.locationDic = self.locationDic;
    [self.navigationController pushViewController:cc animated:YES];
    
}


-(void)pushToGuanfanghuodong{
    
    // 1 为外链 url为外链地址
    
    if ([[_ttaiDetailModel.official_act stringValueForKey:@"redirect_type"]intValue] == 1) {
        GwebViewController *ccc = [[GwebViewController alloc]init];
        ccc.urlstring = [_ttaiDetailModel.official_act stringValueForKey:@"url"];
        ccc.isSaoyisao = YES;
        ccc.hidesBottomBarWhenPushed = YES;
        UINavigationController *navc = [[UINavigationController alloc]initWithRootViewController:ccc];
        [self presentViewController:navc animated:YES completion:^{
            
        }];
    }else if ([[_ttaiDetailModel.official_act stringValueForKey:@"redirect_type"]intValue] == 0){
        NSString *activityId = [_ttaiDetailModel.official_act stringValueForKey:@"activity_id"];
        MessageDetailController *detail = [[MessageDetailController alloc]init];
        detail.isActivity = YES;
        detail.msg_id = activityId;
        detail.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:detail animated:YES];
    }
}

-(void)yjyPicClicked{
    
    // 1 为外链 url为外链地址
    if ([[_ttaiDetailModel.official_pic stringValueForKey:@"redirect_type"]intValue] == 1) {
        GwebViewController *ccc = [[GwebViewController alloc]init];
        ccc.urlstring = [_ttaiDetailModel.official_pic stringValueForKey:@"url"];
        ccc.isSaoyisao = YES;
        ccc.hidesBottomBarWhenPushed = YES;
        UINavigationController *navc = [[UINavigationController alloc]initWithRootViewController:ccc];
        [self presentViewController:navc animated:YES completion:^{
            
        }];
    }else{
        
    }
}


//计算缩放tableview的高度
-(CGFloat)jisuanTabHeight{
    
   
    
    CGFloat height = 0;
    NSInteger count1 = 0;
    NSInteger tCount = _relationStoreArray.count;
    
    NSLog(@"_relationStoreArray.count %ld",(long)tCount);
    
    for (int i = 0; i<tCount; i++) {
        GTtaiRelationStoreModel *model = _relationStoreArray[i];
        if ([[model.image stringValueForKey:@"have_detail"]intValue] == 1) {
            count1 = [model.image arrayValueForKey:@"img_detail"].count;
        }else{
            count1 = 0;
        }
        
        if (_isOpen[i] == 1) {//打开状态
            height += (count1*60+30);
            if (model.activity) {
                CGFloat p_width = [[model.activity stringValueForKey:@"width"] floatValue];
                CGFloat p_height = [[model.activity stringValueForKey:@"height"]floatValue];
                CGFloat n_height = DEVICE_WIDTH/p_width * p_height;
                height += n_height;
            }
        }else{
            height += 30;
        }
    }

    height += (_tableFooterView.frame.size.height+5);
    
    NSLog(@"%s",__FUNCTION__);
    NSLog(@"_noTabHeaderHeight %f",_noTabHeaderHeight);
    NSLog(@"_tableFooterView_height %f",_tableFooterView.frame.size.height);
    NSLog(@"计算tableivew高度 %f",height);
    
    
    return height;
}

/**
 *  监控 单品详情 和 相似单品都请求完再显示 监控tableview的contentSize
 */
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    if ([keyPath isEqualToString:@"contentSize"]) {
                
        return;
    }
    
    NSNumber *num = [change objectForKey:@"new"];
    
    
    NSLog(@"日日日%d",[num intValue]);
    
    if ([num intValue] >= 2 && _relationStoreArray) {
        
        
        NSLog(@"_relationStoreArray.count:  %lu",(unsigned long)_relationStoreArray.count);
        
        [self loadCustomHeaderView];
        
        //同款推荐
        [_collectionView reloadData:_tmpArray pageSize:L_PAGE_SIZE];
        
    }
}

-(void)GchooseBtnClicked:(GBtn *)sender{
    
    
    
    sender.selected = !sender.selected;
    
    GTtaiRelationStoreModel *model = _relationStoreArray[sender.theIndex.section];
    if ([model.isChoose[sender.theIndex.row]intValue] == 1) {
        model.isChoose[sender.theIndex.row] = @"0";
    }else{
        model.isChoose[sender.theIndex.row] = @"1";
    }
    NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:sender.theIndex.section];
    [_tabHeaderTableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    
    
}

/**
 *  更新赞的状态
 *
 *  @param isZan 是否赞
 */
- (void)updateZanState:(BOOL)isZan
{
    _heartButton.selected = isZan;

    int incremNum = isZan ? 1 : -1;
    NSString *zanSum = NSStringFromInt([_ttaiDetailModel.tt_like_num intValue] + incremNum);
    
    _ttaiDetailModel.tt_like_num = zanSum;
    _zanNumLabel.text = [self zanNumStringForNum:zanSum];

    //同步数据
    self.likeNumLabel.text = _zanNumLabel.text;
    self.likeBtn.selected = isZan;
    self.theModel.tt_like_num = zanSum;
    self.theModel.is_like = isZan ? 1 : 0;
}

#pragma mark - 创建视图

//创建瀑布流
-(void)creatPubuLiu{
    _collectionView = [[LWaterFlow2 alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64 - 50) waterDelegate:self waterDataSource:self noHeadeRefresh:NO noFooterRefresh:NO];
    [self.view addSubview:_collectionView];
    //    _collectionView.backgroundColor = [UIColor clearColor];
    //    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_collectionView showRefreshHeader:YES];
}



//创建收藏分享按钮
- (void)createNavigationbarTools
{
    
    UIButton *rightView=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 190, 44)];
    rightView.backgroundColor=[UIColor clearColor];
    
    //收藏的
    _collectButton = [[UIButton alloc]initWithframe:CGRectMake(74, 0, 44, 44) buttonType:UIButtonTypeCustom nornalImage:[UIImage imageNamed:@"productDetail_collect_normal"] selectedImage:[UIImage imageNamed:@"productDetail_collect_selected"] target:self action:@selector(clickToCollect:)];
    _collectButton.center = CGPointMake(rightView.width / 2.f, _collectButton.center.y);
    [_collectButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    
    _collectButton.selected = _ttaiDetailModel.is_favor == 1 ? YES : NO;
    
    //分享
    
    UIButton *shareButton = [[UIButton alloc] initWithframe:CGRectMake(rightView.width - 44, 0, 44, 44) buttonType:UIButtonTypeCustom nornalImage:[UIImage imageNamed:@"product_share"] selectedImage:nil target:self action:@selector(clickToZhuanFa:)];
    [shareButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    
    [rightView addSubview:shareButton];
    [rightView addSubview:_collectButton];
    
    UIBarButtonItem *comment_item=[[UIBarButtonItem alloc]initWithCustomView:rightView];
    
    self.navigationItem.rightBarButtonItem = comment_item;
    
}


//加载headerView
-(void)loadCustomHeaderView{
    //头部
    
    CGFloat height = 0.0f;
    
    _tabHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, height)];
    _tabHeaderView.backgroundColor = [UIColor whiteColor];
    
    //锚点图片相关
    if (!_ttaiDetailModel) {
        return;
    }
    CGFloat img_width = [[_ttaiDetailModel.image stringValueForKey:@"width"]floatValue];
    CGFloat img_height  = [[_ttaiDetailModel.image stringValueForKey:@"height"]floatValue];
    UIImageView *bigTtaiView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_WIDTH/img_width*img_height)];
    
    bigTtaiView.userInteractionEnabled = YES;
    [bigTtaiView l_setImageWithURL:[NSURL URLWithString:[_ttaiDetailModel.image stringValueForKey:@"url"]] placeholderImage:DEFAULT_YIJIAYI];
    
    [_tabHeaderView addSubview:bigTtaiView];
    
    self.bigImageView = bigTtaiView;//用于分享
    
    if ([[_ttaiDetailModel.image stringValueForKey:@"have_detail"]intValue] == 1) {
        NSArray *img_detail = [_ttaiDetailModel.image arrayValueForKey:@"img_detail"];
        for (NSDictionary *dic in img_detail) {
            [self createbuttonWithModel:dic imageView:bigTtaiView];
        }
    }
    
    height = bigTtaiView.frame.size.height;
    
    //拍摄地 T台content 相关view
    UIView *view1 = [[UIView alloc]initWithFrame:CGRectMake(0, height, DEVICE_WIDTH, 0)];
    [_tabHeaderView addSubview:view1];
    
    UIImageView *icon = [[UIImageView alloc]initWithFrame:CGRectMake(10, 5 + 1.5, 14, 12)];
    icon.image = [UIImage imageNamed:@"Ttaixq_paishe"];
    [view1 addSubview:icon];
    
    UILabel *paishedi = [[UILabel alloc]initWithFrame:CGRectMake(icon.right + 5, 5, DEVICE_WIDTH - 15 - icon.right, 15)];
    paishedi.font = [UIFont systemFontOfSize:12];
    paishedi.numberOfLines = 1;
    paishedi.textColor = RGBCOLOR(134, 135, 136);
    if (![LTools isEmpty:_ttaiDetailModel.photo_mall_name]) {
        paishedi.text = [NSString stringWithFormat:@"拍摄于 %@",_ttaiDetailModel.photo_mall_name];
    }else{
        [paishedi setFrame:CGRectMake(10, 5, DEVICE_WIDTH-20, 0)];
    }
    [view1 addSubview:paishedi];
    
    
    UILabel *miaoshuLabel = [[UILabel alloc]initWithFrame:CGRectMake(paishedi.frame.origin.x, CGRectGetMaxY(paishedi.frame)+5, paishedi.frame.size.width, 35)];
    [view1 addSubview:miaoshuLabel];
    miaoshuLabel.font = [UIFont systemFontOfSize:12];
    miaoshuLabel.textColor = [UIColor blackColor];
    miaoshuLabel.numberOfLines = 2;
    if (![LTools isEmpty:_ttaiDetailModel.tt_content]) {
        miaoshuLabel.text = _ttaiDetailModel.tt_content;
        [miaoshuLabel setMatchedFrame4LabelWithOrigin:CGPointMake(paishedi.frame.origin.x, CGRectGetMaxY(paishedi.frame)+5) width: paishedi.frame.size.width];
    }else{
        [miaoshuLabel setFrame:CGRectZero];
    }
    
    
    NSLog(@"paishedi.frame.size.height %f  miaoshuLabel.frame.size.height %f",paishedi.frame.size.height,miaoshuLabel.frame.size.height);
    
    if (paishedi.frame.size.height == 0 && miaoshuLabel.frame.size.height == 0) {
        [view1 setHeight:paishedi.frame.size.height+miaoshuLabel.frame.size.height+0.5];
    }else{
        [view1 setHeight:paishedi.frame.size.height+miaoshuLabel.frame.size.height+15];
    }
    
    
    height+=view1.frame.size.height;
    

    //分割线
    UIView *fenLine = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(view1.frame), DEVICE_WIDTH, 0.5)];
    fenLine.backgroundColor = RGBCOLOR(220, 221, 223);
    [_tabHeaderView addSubview:fenLine];
    
    //评论轮播+喜欢+标签+衣加衣固定图 的view
    UIView *view2 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(fenLine.frame), DEVICE_WIDTH, 180)];
    [_tabHeaderView addSubview:view2];
    
    
    NSMutableArray *viewsArray = [NSMutableArray arrayWithCapacity:1];
    for (NSDictionary *dic in _ttaiDetailModel.reply) {
        UIView *replyView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH - 40*3, 40)];
        UILabel *ll = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, replyView.frame.size.width, replyView.frame.size.height)];
        ll.font = [UIFont systemFontOfSize:12];
        ll.textColor = [UIColor blackColor];
        ll.text = [NSString stringWithFormat:@"%@:%@",[dic stringValueForKey:@"repost_user"],[dic stringValueForKey:@"repost_content"]];
        [replyView addSubview:ll];
        [viewsArray addObject:replyView];
    }
    _topScrollView1 = [[CycleScrollView1 alloc] initWithFrame:CGRectMake(10, 6, DEVICE_WIDTH -10 - 40*3, 40) animationDuration:3];
    _topScrollView1.scrollView.showsHorizontalScrollIndicator = FALSE;
    _topScrollView1.isPageControlHidden = YES;
    _topScrollView1.fetchContentViewAtIndex = ^UIView *(NSInteger pageIndex){
        return viewsArray[pageIndex];
    };
    NSInteger count = viewsArray.count;
    _topScrollView1.totalPagesCount = ^NSInteger(void){
        return count;
    };
    __weak typeof (self)bself = self;
    _topScrollView1.TapActionBlock = ^(NSInteger pageIndex){
        
        [bself cycleScrollDidClickedWithIndex:pageIndex];
    };
    [view2 addSubview:_topScrollView1];
    if (count == 0) {
        _topScrollView1.hidden = YES;
    }else{
        _topScrollView1.hidden = NO;
    }
    
    //评论
    UIButton *pinglunBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [pinglunBtn setFrame:CGRectMake(CGRectGetMaxX(_topScrollView1.frame)+15, 6, 40, 40)];
    pinglunBtn.layer.borderWidth = 0.5;
    pinglunBtn.layer.borderColor = [RGBCOLOR(247, 76, 139)CGColor];
    pinglunBtn.layer.cornerRadius = 20;
    [pinglunBtn setImage:[UIImage imageNamed:@"Ttaixq_pinglun2"] forState:UIControlStateNormal];
    [pinglunBtn addTarget:self action:@selector(clickToComment:) forControlEvents:UIControlEventTouchUpInside];
    [view2 addSubview:pinglunBtn];
    
    _commentNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 25, 40, 10) title:_ttaiDetailModel.tt_comment_num font:10 align:NSTextAlignmentCenter textColor:DEFAULT_TEXTCOLOR];
    [pinglunBtn addSubview:_commentNumLabel];
    
    //喜欢
    UIButton *likeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [likeBtn setFrame:CGRectMake(CGRectGetMaxX(pinglunBtn.frame)+15, pinglunBtn.frame.origin.y, 40, 40)];
    likeBtn.layer.borderWidth = 0.5;
    likeBtn.layer.borderColor = [RGBCOLOR(247, 76, 139)CGColor];
    likeBtn.layer.cornerRadius = 20;
    [likeBtn addTarget:self action:@selector(clickToLike:) forControlEvents:UIControlEventTouchUpInside];
    [view2 addSubview:likeBtn];
    
    _heartButton = [[UIButton alloc]initWithframe:CGRectMake(0, 5, 40, 20) buttonType:UIButtonTypeCustom nornalImage:[UIImage imageNamed:@"Ttai_zan_normal"] selectedImage:[UIImage imageNamed:@"Ttai_zan_selected"] target:self action:nil];
    [likeBtn addSubview:_heartButton];
    _heartButton.userInteractionEnabled = NO;
    _heartButton.selected = _ttaiDetailModel.is_like == 1 ? YES : NO;
    
    NSString *zanString = [self zanNumStringForNum:_ttaiDetailModel.tt_like_num];
    _zanNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, _heartButton.bottom, 40, 10) title:zanString font:10 align:NSTextAlignmentCenter textColor:DEFAULT_TEXTCOLOR];
    [likeBtn addSubview:_zanNumLabel];
    
    
    UIView *fenLine1 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_topScrollView1.frame)+6, DEVICE_WIDTH, 0.5)];
    fenLine1.backgroundColor = fenLine.backgroundColor;
    [view2 addSubview:fenLine1];
    
    UIScrollView *tagScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(fenLine1.frame), DEVICE_WIDTH, 30)];
    tagScrollView.showsHorizontalScrollIndicator = NO;
    tagScrollView.showsVerticalScrollIndicator = NO;
    [view2 addSubview:tagScrollView];
    NSMutableArray *tagsNameArray = [NSMutableArray arrayWithCapacity:1];
    for (NSDictionary *dic in _ttaiDetailModel.tags) {
        NSString *tag_name = [dic stringValueForKey:@"tag_name"];
        [tagsNameArray addObject:tag_name];
    }
    
    CGFloat tagScrollViewContentWidth = 10;
    NSMutableArray *tagWidthArray = [NSMutableArray arrayWithCapacity:1];
    
    CGFloat last_x = 10.0f;
    
    for (int i = 0; i<tagsNameArray.count; i++) {
        NSString *tagName = tagsNameArray[i];
        UILabel *tagLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        tagLabel.textColor = RGBCOLOR(243, 75, 137);
        tagLabel.text = tagName;
        tagLabel.font = [UIFont systemFontOfSize:12];
        [tagLabel setMatchedFrame4LabelWithOrigin:CGPointMake(last_x, 8) height:12 limitMaxWidth:DEVICE_WIDTH];
        [tagLabel setWidth:tagLabel.width +15];
        [tagWidthArray addObject:[NSString stringWithFormat:@"%f",tagLabel.frame.size.width]];
        last_x += tagLabel.frame.size.width+10;
        tagLabel.layer.borderColor = [RGBCOLOR(243, 75, 137)CGColor];
        tagLabel.textAlignment = NSTextAlignmentCenter;
        tagLabel.layer.cornerRadius = 7;
        tagLabel.layer.borderWidth = 0.5;
        tagLabel.tag = i+10000;
        [tagLabel addTapGestureTarget:self action:@selector(tagLabelClicked:) tag:i+10000];
        [tagScrollView addSubview:tagLabel];
        
        tagScrollViewContentWidth += (tagLabel.frame.size.width +10);
        
    }
    [tagScrollView setContentSize:CGSizeMake(tagScrollViewContentWidth, 30)];
    if (tagWidthArray.count == 0) {
        [tagScrollView setFrame:CGRectMake(0, CGRectGetMaxY(fenLine1.frame), DEVICE_WIDTH, 0)];
    }
    
    UIView *fenLine2 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(tagScrollView.frame), DEVICE_WIDTH, 0.5)];
    fenLine2.backgroundColor = fenLine.backgroundColor;
    [view2 addSubview:fenLine2];
    
    CGFloat kuan_yjyImage = [[_ttaiDetailModel.official_pic stringValueForKey:@"width"]floatValue];
    CGFloat gao_yjyImage = [[_ttaiDetailModel.official_pic stringValueForKey:@"height"]floatValue];
    
    UIImageView *yjyPic;
    
    if (!_ttaiDetailModel.official_pic) {
        yjyPic = [[UIImageView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(fenLine2.frame)+5, DEVICE_WIDTH, 0)];
    }else{
        yjyPic = [[UIImageView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(fenLine2.frame)+5, DEVICE_WIDTH, DEVICE_WIDTH/kuan_yjyImage*gao_yjyImage)];
        [yjyPic sd_setImageWithURL:[NSURL URLWithString:[_ttaiDetailModel.official_pic stringValueForKey:@"cover_pic"]] placeholderImage:nil];
        [yjyPic addTaget:self action:@selector(yjyPicClicked) tag:0];
    }
    
    [view2 addSubview:yjyPic];
    
    UIView *fenLine3 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(yjyPic.frame)+5, DEVICE_WIDTH, 0.5)];
    fenLine3.backgroundColor = fenLine.backgroundColor;
    [view2 addSubview:fenLine3];
    
    
    //优惠券
    UILabel *title_youhuiquan = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(fenLine3.frame), (DEVICE_WIDTH-20) *0.5, 35)];
    title_youhuiquan.text = @"优惠券";
    title_youhuiquan.font = [UIFont systemFontOfSize:12];
    [view2 addSubview:title_youhuiquan];
    
    //领取优惠券
    UILabel *youhuiquan_lingqu = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(title_youhuiquan.frame), title_youhuiquan.frame.origin.y, title_youhuiquan.frame.size.width, title_youhuiquan.frame.size.height)];
    youhuiquan_lingqu.text = @"点击领取店铺优惠券";
    youhuiquan_lingqu.textColor = RGBCOLOR(244, 76, 139);
    youhuiquan_lingqu.font = [UIFont systemFontOfSize:12];
    youhuiquan_lingqu.textAlignment = NSTextAlignmentRight;
    [youhuiquan_lingqu addTapGestureTarget:self action:@selector(lingquyouhuiquan) tag:0];
    [view2 addSubview:youhuiquan_lingqu];
    
    
    UIView *fenLine44 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(title_youhuiquan.frame), DEVICE_WIDTH, 0.5)];
    fenLine44.backgroundColor = fenLine.backgroundColor;
    [view2 addSubview:fenLine44];
    
    
    [view2 setHeight:CGRectGetMaxY(fenLine44.frame)];
    
    
    height +=view2.frame.size.height;
    
    _noTabHeaderHeight = height;
    
   
    
    
    CGFloat official_act_width = [_ttaiDetailModel.official_act[@"width"] floatValue];
    CGFloat official_act_height = [_ttaiDetailModel.official_act[@"height"] floatValue];
    
    
    //同品牌推荐image高度
    CGFloat tongpinpaituijian_height = DEVICE_WIDTH/750.0*84;
    
    NSLog(@"%f",tongpinpaituijian_height);
    
    //更多按钮和官方活动图
    if (!_ttaiDetailModel.official_act) {
        _tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 35+tongpinpaituijian_height)];//35为更多按钮的高度
    }else{
         _tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_WIDTH/official_act_width * official_act_height+35+tongpinpaituijian_height)];//35为更多按钮的高度
    }
   
    
    //更多按钮
    UIButton *moreStoreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreStoreBtn setFrame:CGRectMake(DEVICE_WIDTH - 60, 7, 45, 20)];
    [moreStoreBtn setTitle:@"更多" forState:UIControlStateNormal];
    [moreStoreBtn setTitleColor: RGBCOLOR(244, 76, 139) forState:UIControlStateNormal];
    moreStoreBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    moreStoreBtn.layer.borderWidth = 0.5;
    moreStoreBtn.layer.cornerRadius = 10;
    moreStoreBtn.layer.borderColor = [RGBCOLOR(244, 76, 139)CGColor];
    [moreStoreBtn addTarget:self action:@selector(clickToMoreStore) forControlEvents:UIControlEventTouchUpInside];
    if (!_isHaveMoreStoreData) {
        
        if (!_ttaiDetailModel.official_act) {
            _tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH,tongpinpaituijian_height)];//35为更多按钮的高度
            [moreStoreBtn setFrame:CGRectZero];
        }else{
            [_tableFooterView setFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_WIDTH/official_act_width * official_act_height + tongpinpaituijian_height)];
            [moreStoreBtn setFrame:CGRectZero];
        }
        
    }
    
    [_tableFooterView addSubview:moreStoreBtn];
    _tableFooterView.backgroundColor = [UIColor whiteColor];
    
    UIView *fenLine4 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(moreStoreBtn.frame)+5, DEVICE_WIDTH, 0.5)];
    fenLine4.backgroundColor = fenLine.backgroundColor;
    [_tableFooterView addSubview:fenLine4];
    
    
    UIImageView *guanwanghuodongImv;
    if (!_ttaiDetailModel.official_act) {
        guanwanghuodongImv = [[UIImageView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(fenLine4.frame), DEVICE_WIDTH, 0)];
    }else{
        guanwanghuodongImv = [[UIImageView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(fenLine4.frame), DEVICE_WIDTH, DEVICE_WIDTH/official_act_width * official_act_height)];
        [guanwanghuodongImv l_setImageWithURL:[NSURL URLWithString:_ttaiDetailModel.official_act[@"cover_pic"]] placeholderImage:DEFAULT_YIJIAYI];
        [guanwanghuodongImv addTaget:self action:@selector(pushToGuanfanghuodong) tag:0];
    }
    
    [_tableFooterView addSubview:guanwanghuodongImv];
    
    
    
    UIImageView *lineImage = [[UIImageView alloc]initWithFrame:CGRectMake(0,CGRectGetMaxY(guanwanghuodongImv.frame), DEVICE_WIDTH, 40)];
    lineImage.image = [UIImage imageNamed:@"ttai_tuijian.png"];
    lineImage.contentMode = UIViewContentModeCenter;
    [_tableFooterView addSubview:lineImage];
    
    
    
    
    CGFloat jjj = [self jisuanTabHeight];
    
//    height +=jjj;
    height = jjj+ _noTabHeaderHeight;
    
    
    //header上的可缩放tableview
    _tabHeaderTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(view2.frame), DEVICE_WIDTH, jjj) style:UITableViewStyleGrouped];
    _tabHeaderTableView.delegate = self;
    _tabHeaderTableView.dataSource = self;
    _tabHeaderTableView.tableFooterView = _tableFooterView;
    [_tabHeaderView addSubview:_tabHeaderTableView];
    
    [_tabHeaderTableView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    [_tabHeaderView setHeight:height];
    
    _collectionView.headerView = _tabHeaderView;
    
    
    
}


-(void)lingquyouhuiquan{
    NSLog(@"%s",__FUNCTION__);

    
    //判断是否登录
    if ([LTools cacheBoolForKey:LOGIN_SERVER_STATE] == NO) {
        
        LoginViewController *login = [[LoginViewController alloc]init];
        
        UINavigationController *unVc = [[UINavigationController alloc]initWithRootViewController:login];
        
        [self presentViewController:unVc animated:YES completion:nil];
        
        return;
    }
    
    
    GgetStoreYouhuiquanViewController *cc = [[GgetStoreYouhuiquanViewController alloc]init];
    cc.tPlat_id = self.tPlat_id;
    cc.locationDic = self.locationDic;
    [self.navigationController pushViewController:cc animated:YES];
    
    
}


-(void)tagLabelClicked:(UITapGestureRecognizer*)sender{
    int index = (int)sender.view.tag - 10000;
    NSDictionary *dic = _ttaiDetailModel.tags[index];
    NSLog(@"%@",dic);
    
    GmyTtaiViewController *cc = [[GmyTtaiViewController alloc]init];
    cc.isTTaiDetailTagPush = YES;
    cc.tagId = [dic stringValueForKey:@"tag_id"];
    cc.tagName = [dic stringValueForKey:@"tag_name"];
    [self.navigationController pushViewController:cc animated:YES];
    
}

-(void)createbuttonWithModel:(NSDictionary*)maodian_detail imageView:(UIView *)imageView{
    
    NSString *productId = maodian_detail[@"product_id"];
    
    NSInteger product_id = [productId integerValue];
    
    float dx=[maodian_detail[@"img_x"] floatValue];
    float dy=[maodian_detail[@"img_y"] floatValue];
    
    
    __weak typeof(self)weakSelf = self;
    if (product_id>0) {
        //说明是单品
        
//        NSString *title = maodian_detail[@"product_name"];
        NSString *title = _ttaiDetailModel.brand_name;
        CGPoint point = CGPointMake(dx * imageView.width, dy * imageView.height);
        AnchorPiontView *pointView = [[AnchorPiontView alloc]initWithAnchorPoint:point title:title price:[maodian_detail stringValueForKey:@"product_price"]];
        [imageView addSubview:pointView];
        pointView.infoId = productId;
        pointView.infoName = title;
        
        [pointView setAnchorBlock:^(NSString *infoId,NSString *infoName,ShopType shopType){
            
            [weakSelf turnToDanPinInfoId:infoId infoName:infoName];
        }];
        
        
    }
    
}

//点击锚点跳转到单品
-(void)turnToDanPinInfoId:(NSString *)infoId
                 infoName:(NSString *)infoName
{
    [MiddleTools pushToProductDetailWithId:infoId fromViewController:self lastNavigationHidden:NO hiddenBottom:YES];
}


-(void)cycleScrollDidClickedWithIndex:(NSInteger)index{
    NSLog(@"%ld",index);
}


/*
 原图
 */
- (NSString *)originalImageForArr:(NSArray *)imagesArr
{
    if (imagesArr.count >= 1) {
        
        NSDictionary *imageDic = imagesArr[0];
        NSDictionary *originalImage = imageDic[@"original"];
        
        
        return originalImage[@"src"];
    }
    
    return @"";
}


/**
 *  赞数量大于1000显示 k
 *
 *  @param zanNum
 *
 *  @return
 */
- (NSString *)zanNumStringForNum:(NSString *)zanNum
{
    int num = [zanNum intValue];
    if (num >= 1000) {
        
        return [NSString stringWithFormat:@"%.1fk",num * 0.001];
    }
    return zanNum;
}

#pragma - mark PSWaterFlowDelegate <NSObject>

- (void)waterLoadNewDataForWaterView:(PSCollectionView *)waterView
{
    
    
    [self getshopcarNum];
    
    _count = 0;
    [self getCurrentLocation];
    
    
}
- (void)waterLoadMoreDataForWaterView:(PSCollectionView *)waterView
{
    [self prepareMoreNetDataForTtaiDetail];
}





- (void)waterDidSelectRowAtIndexPath:(NSInteger)index collectionViewCell:(PSCollectionViewCell *)cell
{
    
    
    
    TPlatModel *model = _collectionView.dataArray[index];
    
    GTtaiDetailSamettCell *t_cell = (GTtaiDetailSamettCell*)cell;
    NSDictionary *params = nil;
    if (t_cell.like_btn && t_cell.like_label ) {
        params = @{@"button":t_cell.like_btn,
                                 @"label":t_cell.like_label,
                                 @"model":model};
    }
    
    [MiddleTools pushToTPlatDetailWithInfoId:model.tt_id fromViewController:self lastNavigationHidden:NO hiddenBottom:YES extraParams:params updateBlock:nil];
    
}

- (void)waterScrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

- (void)waterScrollViewDidEndDragging:(UIScrollView *)scrollView
{
    
}

#pragma mark - PSCollectionViewDataSource <NSObject>

- (NSInteger)numberOfRowsInCollectionView:(PSCollectionView *)collectionView
{
    return _collectionView.dataArray.count;
}

- (PSCollectionViewCell *)collectionView:(PSCollectionView *)collectionView1 cellForRowAtIndex:(NSInteger)index
{
    
    GTtaiDetailSamettCell *cell = (GTtaiDetailSamettCell*)[collectionView1 dequeueReusableViewForClass:[GTtaiDetailSamettCell class]];
    
    if (!cell) {
        cell = [[GTtaiDetailSamettCell alloc]init];
    }
    
    
    for (UIView*view in cell.subviews) {
        [view removeFromSuperview];
    }

    TPlatModel *amodel = _collectionView.dataArray[index];
    [cell loadCustomViewWithModel:amodel];
    
    //设置button参数
    
    NSDictionary *params = @{@"button":cell.like_btn,
                             @"label":cell.like_label,
                             @"model":amodel};
    NSLog(@"设置button参数%@",params);
    cell.likeBackBtn.object = params;
    [cell.likeBackBtn addTarget:self action:@selector(clickToZan:) forControlEvents:UIControlEventTouchUpInside];
    
    
    return cell;
}

- (CGFloat)collectionView:(PSCollectionView *)collectionView heightForRowAtIndex:(NSInteger)index
{
    CGFloat imageH = 0.f;
    TPlatModel *aMode = _collectionView.dataArray[index];
    
    NSDictionary *image = (NSDictionary *)aMode.image;
    if (image && [image isKindOfClass:[NSDictionary class]]) {
        
        
        float image_width = [image[@"width"]floatValue];
        float image_height = [image[@"height"]floatValue];
        
        if (image_width == 0.0) {
            image_width = image_height;
        }
        float rate = image_height/image_width;
        
        imageH = (DEVICE_WIDTH - 6)/2.0*rate;
        
    }
    
    
    return imageH;
    
}




#pragma mark - UITableViewDelegate && UITableViewDataSource

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
    }
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    GTtaiRelationStoreModel *amodel = _relationStoreArray[indexPath.section];
    NSDictionary *image = amodel.image;
    if ([[image stringValueForKey:@"have_detail"]intValue] == 1) {
        NSArray *img_detail = [image arrayValueForKey:@"img_detail"];
        NSDictionary *dic = img_detail[indexPath.row];
        
        
        
        //选择button
        GBtn *chooseBtn = [GBtn buttonWithType:UIButtonTypeCustom];
        [chooseBtn setFrame:CGRectMake(0, 8, 35, 44)];
        [chooseBtn setImage:[UIImage imageNamed:@"Ttaixq_xuanze_xuanzhong.png"] forState:UIControlStateSelected];
        [chooseBtn setImage:[UIImage imageNamed:@"Ttaixq_xuanze1.png"] forState:UIControlStateNormal];
        chooseBtn.theIndex = indexPath;
        [chooseBtn addTarget:self action:@selector(GchooseBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//        chooseBtn.backgroundColor = [UIColor orangeColor];
        if ([amodel.isChoose[indexPath.row] intValue] == 1) {
            chooseBtn.selected = YES;
        }else{
            chooseBtn.selected = NO;
        }
        
        [cell.contentView addSubview:chooseBtn];
        
        
        
        NSDictionary *product_cover_pic = [dic dictionaryValueForKey:@"product_cover_pic"];
        NSString *imvUrl = [product_cover_pic stringValueForKey:@"src"];

        UIImageView *picImv = [[UIImageView alloc]initWithFrame:CGRectMake(35, 8, 44, 44)];
        [picImv l_setImageWithURL:[NSURL URLWithString:imvUrl] placeholderImage:DEFAULT_YIJIAYI];
        [cell.contentView addSubview:picImv];
        
        UILabel *productNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(picImv.frame)+10, picImv.frame.origin.y, DEVICE_WIDTH - CGRectGetMaxX(picImv.frame)-10, picImv.frame.size.height*0.5)];
        productNameLabel.font = [UIFont systemFontOfSize:12];
        productNameLabel.text = [NSString stringWithFormat:@"%@:%@",[dic stringValueForKey:@"product_type_name"],[dic stringValueForKey:@"product_name"]];
        [cell.contentView addSubview:productNameLabel];
        
        UILabel *priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(productNameLabel.frame.origin.x, CGRectGetMaxY(productNameLabel.frame), productNameLabel.frame.size.width, productNameLabel.frame.size.height)];
        priceLabel.font = [UIFont systemFontOfSize:12];
        priceLabel.textColor = RGBCOLOR(249, 165, 196);
        priceLabel.text = [NSString stringWithFormat:@"￥%@",[dic stringValueForKey:@"product_price"]];
        [cell.contentView addSubview:priceLabel];
        
        
    }else{
        
    }

    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger count = _relationStoreArray.count;
    if (count>5) {
        count = 5;
    }
    return count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger count = 0;
    GTtaiRelationStoreModel *amodel = _relationStoreArray[section];
    NSDictionary *image = amodel.image;
    if ([[image stringValueForKey:@"have_detail"]intValue] == 1) {
        count = [image arrayValueForKey:@"img_detail"].count;
    }else{
        count = 0;
    }
    
    
    if (_isOpen[section] == 0) {
        count = 0;
    }else{
        
    }
    
    
    return count;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    CGFloat height = 0;
    NSString *url;
    
//    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, height)];
//    view.backgroundColor = [UIColor redColor];
    
    UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectZero];
    
    GTtaiRelationStoreModel *model = _relationStoreArray[section];
    if (model.activity) {//有活动
        url = [model.activity stringValueForKey:@"cover_pic"];
        CGFloat p_width = [[model.activity stringValueForKey:@"width"]floatValue];
        CGFloat p_height = [[model.activity stringValueForKey:@"height"]floatValue];
        height = DEVICE_WIDTH/p_width * p_height;
        
        
        [imv setHeight:height];
        
        [imv l_setImageWithURL:[NSURL URLWithString:url] placeholderImage:DEFAULT_YIJIAYI];
        
        [imv addTapGestureTarget:self action:@selector(viewForFooterInSectionClicked:) tag:(int)(section + 1000)];
        
//        [view addSubview:imv];
        
        
    }
    
    
    
    
    return imv;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    CGFloat height = 0.01;
    GTtaiRelationStoreModel *model = _relationStoreArray[section];
    if (model.activity) {//有活动
        CGFloat p_width = [[model.activity stringValueForKey:@"width"]floatValue];
        CGFloat p_height = [[model.activity stringValueForKey:@"height"]floatValue];
        height = DEVICE_WIDTH/p_width * p_height;
    }
    
    if (_isOpen[section] != 1) {
        height = 0.01;
    }
    
    
    return height;
    
}


-(void)viewForFooterInSectionClicked:(UITapGestureRecognizer*)sender{
    
    NSInteger tt = sender.view.tag-1000;
    GTtaiRelationStoreModel *model = _relationStoreArray[tt];
    if ([[model.activity stringValueForKey:@"redirect_type"]intValue] == 1) {//外链活动
        GwebViewController *ccc = [[GwebViewController alloc]init];
        ccc.urlstring = [model.activity stringValueForKey:@"url"];
        ccc.isSaoyisao = YES;
        ccc.hidesBottomBarWhenPushed = YES;
        UINavigationController *navc = [[UINavigationController alloc]initWithRootViewController:ccc];
        [self presentViewController:navc animated:YES completion:^{
            
        }];
    }else if ([[model.activity stringValueForKey:@"redirect_type"]intValue] == 0){//跳转应用内活动
        NSString *activityId = [model.activity stringValueForKey:@"id"];
        MessageDetailController *detail = [[MessageDetailController alloc]init];
        detail.isActivity = YES;
        detail.msg_id = activityId;
        detail.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:detail animated:YES];
    }
    
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 30)];
    view.backgroundColor = [UIColor whiteColor];
    view.tag = section+10;
    [view addTaget:self action:@selector(viewForHeaderInSectionClicked:) tag:view.tag];
    UILabel *ttLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, DEVICE_WIDTH*0.6, 30)];
    
    
    
    GTtaiRelationStoreModel *amodel = _relationStoreArray[section];
    NSString *distance;
    if ([amodel.distance integerValue]>=1000) {
        distance = [NSString stringWithFormat:@"%.1fkm",[amodel.distance floatValue]*0.001];
    }else{
        distance = [NSString stringWithFormat:@"%.1fm",[amodel.distance floatValue]];
    }
    ttLabel.text = [NSString stringWithFormat:@"%@-%@ %@",amodel.brand_name,amodel.mall_name,distance];
    ttLabel.font = [UIFont systemFontOfSize:12];
    [view addSubview:ttLabel];
    
    
    CGFloat totlePrice = 0;
    NSArray *img_detail = [amodel.image arrayValueForKey:@"img_detail"];
    for (int i = 0; i<img_detail.count; i++) {
        if ([amodel.isChoose[i] integerValue] == 1) {
            NSDictionary *dic = img_detail[i];
            totlePrice += [[dic stringValueForKey:@"product_price"] floatValue];
        }
    }
    
    UILabel *totlePriceLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(ttLabel.frame)+5, ttLabel.frame.origin.y, DEVICE_WIDTH *0.3, 30)];
    totlePriceLabel.font = [UIFont systemFontOfSize:10];
    totlePriceLabel.textAlignment = NSTextAlignmentCenter;
    totlePriceLabel.textColor = DEFAULT_TEXTCOLOR;
    totlePriceLabel.text = [NSString stringWithFormat:@"搭配价￥%.1f",totlePrice];
    [view addSubview:totlePriceLabel];
    
    
    UIView *downLine = [[UIView alloc]initWithFrame:CGRectMake(0, 29.5, DEVICE_WIDTH, 0.5)];
    downLine.backgroundColor = RGBCOLOR(220, 221, 223);
    [view addSubview:downLine];
    
    
    
    UIButton *jiantouBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [jiantouBtn setFrame:CGRectMake(DEVICE_WIDTH-30, 0, 30, 30)];
    jiantouBtn.userInteractionEnabled = NO;
    [view addSubview:jiantouBtn];
    
    
    if ( !_isOpen[view.tag-10]) {
        downLine.hidden = NO;
        [jiantouBtn setImage:[UIImage imageNamed:@"buy_jiantou_d.png"] forState:UIControlStateNormal];
    }else{
        downLine.hidden = YES;
        [jiantouBtn setImage:[UIImage imageNamed:@"buy_jiantou_u.png"] forState:UIControlStateNormal];
    }
    
    
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}









-(void)viewForHeaderInSectionClicked:(UIView*)sender{
    
    NSLog(@"%s",__FUNCTION__);
    _isOpen[sender.tag - 10] = !_isOpen[sender.tag - 10];
    NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:sender.tag-10];
    
    
    CGFloat newHeight = 0;//新高度

    
    newHeight = [self jisuanTabHeight];
    
    newHeight += _noTabHeaderHeight;
    
    
    [_tabHeaderView setHeight:newHeight];
    
    
    
    [UIView animateWithDuration:0.0 animations:^{
        [_tabHeaderTableView reloadData];
        CGRect r = _tabHeaderTableView.frame;
        r.size.height = _tabHeaderTableView.contentSize.height;
        _tabHeaderTableView.frame = r;
        _collectionView.headerView = _tabHeaderView;
    }];
    
    
    
    
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%s",__FUNCTION__);
    
    
    GTtaiRelationStoreModel *model = _relationStoreArray[indexPath.section];
    NSArray *img_detail = [model.image arrayValueForKey:@"img_detail"];
    NSDictionary *dic = img_detail[indexPath.row];
    NSString *product_id = [dic stringValueForKey:@"product_id"];
    
    [MiddleTools pushToProductDetailWithId:product_id fromViewController:self lastNavigationHidden:NO hiddenBottom:YES];
    
    
}


@end

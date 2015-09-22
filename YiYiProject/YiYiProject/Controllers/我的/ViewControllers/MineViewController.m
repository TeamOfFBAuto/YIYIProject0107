//
//  MineViewController.m
//  YiYiProject
//
//  Created by lichaowei on 14/12/10.
//  Copyright (c) 2014年 lcw. All rights reserved.
//

#import "MineViewController.h"
#import "LoginViewController.h"
#import "GTableViewCell.h"
#import "MLImageCrop.h"
#import "GcustomActionSheet.h"
#import "AFNetworking.h"
#import "GeditUserInfoViewController.h"
#import "GMapViewController.h"//测试地图vc

#import "GmyMainViewController.h"//我的主页
#import "MyYiChuViewController.h"//我的衣橱
#import "MyConcernController.h"//我的关注
#import "MessageListController.h"//消息中心
#import "MyBodyViewController.h"//我的体型
#import "MyMatchViewController.h"//我的搭配
#import "MySettingsViewController.h" //设置
#import "EditMyInfoViewController.h"  //编辑资料
#import "ShenQingDianPuViewController.h"
#import "MyShopViewController.h"//我的店铺
#import "MyYiChuViewController.h"//我的衣橱
#import "LShareSheetView.h"

#import "ParallaxHeaderView.h"
#import "UIImage+ImageEffects.h"
#import "NSDictionary+GJson.h"

#import "UserInfo.h"

#import "GScanViewController.h"//扫一扫
#import "GwebViewController.h"//web界面
#import "GmyTtaiViewController.h"//我的T台
#import "GMyWalletViewController.h"//我的钱包

#import "ShoppingCarController.h"//我的购物车
#import "OrderViewController.h"//我的订单
#import "ShoppingAddressController.h"//收货地址

typedef enum{
    USERFACE = 0,//头像
    USERBANNER,//banner
    USERIMAGENULL,
}CHANGEIMAGETYPE;

#define CROPIMAGERATIO_USERBANNER 748.0/420 //banner 图片裁剪框宽高比
#define CROPIMAGERATIO_USERFACE 1.0//头像 图片裁剪框宽高比例

#define UPIMAGECGSIZE_USERBANNER CGSizeMake(1080,1080*0.4687)//需要上传的banner的分辨率
#define UPIMAGECGSIZE_USERFACE CGSizeMake(200,200)//需要上传的头像的分辨率

@interface MineViewController ()<UITableViewDataSource,UITableViewDelegate,GcustomActionSheetDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,MLImageCropDelegate>
{
    UITableView *_tableView;//主tableview
    CHANGEIMAGETYPE _changeImageType;
    NSArray *_tabelViewCellTitleArray;//title文字数组
    NSArray *_logoImageArray;//title前面的logo图数组
    NSDictionary *_customInfo_tabelViewCell;//cell数据源
    ParallaxHeaderView *_backView;//banner
    
    UserInfo *_userInfo;//用户信息model
    
    BOOL _getUserinfoSuccess;//加载用户数据是否成功
    
    UIActivityIndicatorView *_hud;
    
    UIButton *_qiandaoBtn;//签到按钮
    
    UIButton *_editBtn;//编辑按钮
    

    UIView *_qiandaoSuccessViewBgView;//签到成功的黑色背景图
    UIImageView *_qiandaoSuccessView_imvbgimage;//背景图上面的图片背景
    UIButton *_qiandaoSuccessView_closeBtn;//签到成功关闭按钮
    UIImageView *_zhu_imv;//小猪
    
    CGFloat _lastOffsetY;
    
    int _unreadNum;//未读消息条数
    
    UILabel *_unreadLabel;//未读消息label
    
    UILabel *_fensiNumLabel;//粉丝数目
    UILabel *_guanzhuNumLabel;//关注数目
    UILabel *_ttaiNumLabel;//T台数目
    
    UIView *_fensiView;
    UIView *_guanzhuView;
    UIView *_ttaiView;
    
    
    BOOL _isChangeBanner;//是否修改banner willappaer里判断是否请求个人信息
    
    UIImageView *_theBlackBackView;
}
@end

@implementation MineViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    if (_isChangeBanner) {
        
    }else{
//        [self GgetUserInfo];//更新用户数据
    }
    
    _isChangeBanner = NO;
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (IOS7_OR_LATER) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.myTitleLabel.text = @"我的";
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeNull WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    [self chuShiHuaView];
    
    //获取未读消息条数
    
    _unreadNum = [self unreadMessageNum];
    [self getUnreadMessageNum];
    
    //判断是否登录
    if ([LTools cacheBoolForKey:LOGIN_SERVER_STATE] == NO) {
        
        LoginViewController *login = [[LoginViewController alloc]init];
        
        UINavigationController *unVc = [[UINavigationController alloc]initWithRootViewController:login];
        
        [self presentViewController:unVc animated:YES completion:nil];
        
        
    }else{
        
        NSDictionary *dic = [GMAPI getUserInfoCache];
        NSString *nowtime = [GMAPI getNowTime];
        NSString *cacheTime = [dic stringValueForKey:@"theDayTime"];
        if ([nowtime isEqualToString:cacheTime]) {
            [self cacheUserInfo];
        }else{
            [self GgetUserInfo];
        }
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//初始化view
-(void)chuShiHuaView{
    
    
    //初始化相关
    _changeImageType = USERIMAGENULL;
    
    
    //---lcw:和店铺相关暂时去掉----
    
//    _logoImageArray = @[[UIImage imageNamed:@"my_shoucang.png"],
//                        [UIImage imageNamed:@"my_wallet.png"],
//                        [UIImage imageNamed:@"my_store.png"],
//                        [UIImage imageNamed:@"my_message.png"],
//                        [UIImage imageNamed:@"my_friends.png"],
//                        [UIImage imageNamed:@"my_saoma.png"],
//                        [UIImage imageNamed:@"my_setting.png"]];
//    
//    
//    _tabelViewCellTitleArray = @[@"我的收藏",
//                                 @"我的钱包",
//                                 @"我是店主，申请衣+衣店铺",
//                                 @"消息中心",
//                                 @"邀请好友",
//                                 @"扫一扫",
//                                 @"设置"
//                                 ];
    //----end----
    
    _logoImageArray = @[[UIImage imageNamed:@"my_shoucang.png"],
                        [UIImage imageNamed:@"my_wallet.png"],
                        [UIImage imageNamed:@"my_gouwuche"],
                        [UIImage imageNamed:@"my_dingdan"],
                        [UIImage imageNamed:@"my_dizhi"],
                        [UIImage imageNamed:@"my_message.png"],
                        [UIImage imageNamed:@"my_friends.png"],
                        [UIImage imageNamed:@"my_saoma.png"],
                        [UIImage imageNamed:@"my_setting.png"]];
    
    
    _tabelViewCellTitleArray = @[@"我的收藏",
                                 @"我的钱包",
                                 @"我的购物车",
                                 @"我的订单",
                                 @"我的地址",
                                 @"消息中心",
                                 @"邀请好友",
                                 @"扫一扫",
                                 @"设置"
                                 ];
    
    
    _customInfo_tabelViewCell = @{@"titleLogo":_logoImageArray,
                                  @"titleArray":_tabelViewCellTitleArray
                                  };
    
    if (_tableView) {
        [_tableView reloadData];
        return;
    }
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT-49) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableHeaderView = [self creatTableViewHeaderView];
    _tableView.backgroundColor = RGBCOLOR(242, 242, 242);
    [self.view addSubview:_tableView];
    
    
    
    //通知相关=====
    
    //登录成功
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(GgetUserInfo) name:NOTIFICATION_LOGIN object:nil];
    
    //退出登录
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(GLogoutAction) name:NOTIFICATION_LOGOUT object:nil];
    
    //---lcw:和店铺相关暂时去掉----
    
    //店铺提交申请 改变成审核中状态
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeTheTitleAndPicArray_shenhe) name:NOTIFICATION_SHENQINGDIANPU_SUCCESS object:nil];
    
    //接收审核结果
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(GgetUserInfo) name:NOTIFICATION_SHENQINGDIANPU_STATE object:nil];
    
    //---end------
    
    //从后台转到前台更新用户数据
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(GgetUserInfo) name:NOTIFICATION_APPENTERFOREGROUND object:nil];
    
    //粉丝 关注 T台 上面的三个数字发生变化的时候
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(GgetUserInfo) name:NOTIFICATION_MINEVC_THREENUMLABEL object:nil];
}


//退出登录成功后的页面调整

-(void)GLogoutAction{
    
    [self setUpuserInfoViewWithLoginState:[LTools cacheBoolForKey:LOGIN_SERVER_STATE]];
    [self chuShiHuaView];
}

//请求到userinfo之后根据shopman参数判断是否拥有店铺 调整 标题和图标二维数组
-(void)changeTheTitleAndPicArray_dianzhu{//已经是店主

    
    _logoImageArray = @[[UIImage imageNamed:@"my_shoucang.png"],
                        [UIImage imageNamed:@"my_wallet.png"],
                        [UIImage imageNamed:@"my_store.png"],
                        [UIImage imageNamed:@"my_message.png"],
                        [UIImage imageNamed:@"my_friends.png"],
                        [UIImage imageNamed:@"my_saoma.png"],
                        [UIImage imageNamed:@"my_setting.png"]];
    
    
    _tabelViewCellTitleArray = @[@"我的收藏",
                                 @"我的钱包",
                                 @"我的店铺",
                                 @"消息中心",
                                 @"邀请好友",
                                 @"扫一扫",
                                 @"设置",
                                 ];
    
    
    _customInfo_tabelViewCell = @{@"titleLogo":_logoImageArray,
                                  @"titleArray":_tabelViewCellTitleArray
                                  };
    _userInfo.shopman = @"2";
    [_tableView reloadData];
}

-(void)changeTheTitleAndPicArray_shenhe{//正在审核
    _logoImageArray = @[[UIImage imageNamed:@"my_shoucang.png"],
                        [UIImage imageNamed:@"my_wallet.png"],
                        [UIImage imageNamed:@"my_store.png"],
                        [UIImage imageNamed:@"my_message.png"],
                        [UIImage imageNamed:@"my_friends.png"],
                        [UIImage imageNamed:@"my_saoma.png"],
                        [UIImage imageNamed:@"my_setting.png"]];
    
    
    _tabelViewCellTitleArray = @[@"我的收藏",
                                 @"我的钱包",
                                 @"店铺审核中",
                                 @"消息中心",
                                 @"邀请好友",
                                 @"扫一扫",
                                 @"设置"
                                 ];
    
    
    _customInfo_tabelViewCell = @{@"titleLogo":_logoImageArray,
                                  @"titleArray":_tabelViewCellTitleArray
                                  };
    _userInfo.shopman = @"1";
    [_tableView reloadData];
}


-(void)cacheUserInfo{
    //本地存储model
    
    NSDictionary *dic = [GMAPI getUserInfoCache];
    _userInfo = [[UserInfo alloc]initWithDictionary:dic];
    
    _getUserinfoSuccess = YES;
    
    if ([_userInfo.is_sign intValue] == 0) {//未签到
        _qiandaoBtn.userInteractionEnabled = YES;
        _qiandaoBtn.selected = NO;
    }else if ([_userInfo.is_sign intValue] == 1){//已签到
        _qiandaoBtn.userInteractionEnabled = NO;
        _qiandaoBtn.selected = YES;
    }
    
    _qiandaoBtn.hidden = NO;
    
    //---lcw:和店铺相关暂时去掉----
    
//    if ([_userInfo.shopman intValue] == 2) {//已经是店主
//        [self changeTheTitleAndPicArray_dianzhu];
//    }else if ([_userInfo.shopman intValue]==1){//正在审核
//        [self changeTheTitleAndPicArray_shenhe];
//    }
    //---end-----
    
    NSString *name = [dic stringValueForKey:@"user_name"];
    if ([name isEqualToString:@"(null)"] || name == nil) {
        name = @" ";
    }
    NSString *score = [dic stringValueForKey:@"score"];
    if ([score isEqualToString:@"(null)"] || score == nil) {
        score = @" ";
    }
    self.userNameLabel.text = [NSString stringWithFormat:@"昵称:%@",name];
    self.userScoreLabel.text = [NSString stringWithFormat:@"积分:%@",score];
    self.jifen = score;
    
    user_bannerUrl = [dic stringValueForKey:@"user_banner"];
    UIImage *pim;
    if ([GMAPI getUserBannerImage]) {
        pim = [GMAPI getUserBannerImage];
    }else{
        pim = [UIImage imageNamed:@"my_bg.png"];
    }
    if (user_bannerUrl.length>0) {
        [_backView.imageView sd_setImageWithURL:[NSURL URLWithString:user_bannerUrl] placeholderImage:pim completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [GMAPI setUserBannerImageWithData:UIImagePNGRepresentation(_backView.imageView.image)];
        }];
    }
    
    
    
    NSString *userFaceUrl = [NSString stringWithFormat:@"%@",[dic stringValueForKey:@"photo"]];
    headImageUrl = userFaceUrl;
    
    
    [self.userFaceImv sd_setImageWithURL:[NSURL URLWithString:userFaceUrl] placeholderImage:[UIImage imageNamed:@"grzx150_150.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [GMAPI setUserFaceImageWithData:UIImagePNGRepresentation(self.userFaceImv.image)];
    }];
    
    
    _fensiNumLabel.text = [dic stringValueForKey:@"fans_num"];
    _guanzhuNumLabel.text = _userInfo.attentions_num;
    _ttaiNumLabel.text = [dic stringValueForKey:@"tt_num"];
    
    [_tableView reloadData];
    
}



//网络请求获取用户信息
-(void)GgetUserInfo{
    
    
    if ([GMAPI getAuthkey].length == 0) {
        return;
    }
    
    
    _getUserinfoSuccess = NO;
    
    if (!_hud) {
        _hud = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _hud.frame = CGRectMake(20, 35, 0, 0);
    }
    [self.view addSubview:_hud];
    [_hud startAnimating];
    
    
    
    NSString *URLstr = [NSString stringWithFormat:@"%@&authcode=%@&extra=%@",PERSON_GETUSERINFO,[GMAPI getAuthkey],@"tt_num"];
    
    
    LTools *cc = [[LTools alloc]initWithUrl:URLstr isPost:NO postData:nil];
    [cc requestCompletion:^(NSDictionary *result, NSError *erro) {
        
        NSLog(@"请求的个人信息：%@",result);
        
        _getUserinfoSuccess = YES;
        
        [self setUpuserInfoViewWithLoginState:[LTools cacheBoolForKey:LOGIN_SERVER_STATE]];
        
        [_hud stopAnimating];
        
        NSDictionary *dic = [result dictionaryValueForKey:@"user_info"];
        NSMutableDictionary *dic_m = [NSMutableDictionary dictionaryWithDictionary:dic];
        NSString *theTime = [GMAPI getNowTime];
        [dic_m setValue:theTime forKey:@"theDayTime"];
        dic = (NSDictionary *)dic_m;
        
        
        _userInfo = [[UserInfo alloc]initWithDictionary:dic];
        
        
        //本地存储model
        [GMAPI setUserInfoCacheWithDic:dic];
        
        if ([_userInfo.is_sign intValue] == 0) {//未签到
            _qiandaoBtn.userInteractionEnabled = YES;
            _qiandaoBtn.selected = NO;
        }else if ([_userInfo.is_sign intValue] == 1){//已签到
            _qiandaoBtn.userInteractionEnabled = NO;
            _qiandaoBtn.selected = YES;
        }

        //---lcw:和店铺相关暂时去掉----
        
//        if ([_userInfo.shopman intValue] == 2) {//已经是店主
//            [self changeTheTitleAndPicArray_dianzhu];
//        }else if ([_userInfo.shopman intValue]==1){//正在审核
//            [self changeTheTitleAndPicArray_shenhe];
//        }
        
        //---end---
        
        NSString *name = [dic stringValueForKey:@"user_name"];
        if ([name isEqualToString:@"(null)"] || name == nil) {
            name = @" ";
        }
        NSString *score = [dic stringValueForKey:@"score"];
        if ([score isEqualToString:@"(null)"] || score == nil) {
            score = @" ";
        }
        self.userNameLabel.text = [NSString stringWithFormat:@"昵称:%@",name];
        self.userScoreLabel.text = [NSString stringWithFormat:@"积分:%@",score];
        self.jifen = score;
        
        user_bannerUrl = [dic stringValueForKey:@"user_banner"];
        UIImage *pim;
        if ([GMAPI getUserBannerImage]) {
            pim = [GMAPI getUserBannerImage];
        }else{
            pim = [UIImage imageNamed:@"my_bg.png"];
        }
        if (user_bannerUrl.length>0) {
            [_backView.imageView sd_setImageWithURL:[NSURL URLWithString:user_bannerUrl] placeholderImage:pim completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [GMAPI setUserBannerImageWithData:UIImagePNGRepresentation(_backView.imageView.image)];
            }];
        }
        
        
        
        NSString *userFaceUrl = [NSString stringWithFormat:@"%@",[dic stringValueForKey:@"photo"]];
        headImageUrl = userFaceUrl;
        
        
        [self.userFaceImv sd_setImageWithURL:[NSURL URLWithString:userFaceUrl] placeholderImage:[UIImage imageNamed:@"grzx150_150.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [GMAPI setUserFaceImageWithData:UIImagePNGRepresentation(self.userFaceImv.image)];
        }];
        
        
        _fensiNumLabel.text = [dic stringValueForKey:@"fans_num"];
        _guanzhuNumLabel.text = _userInfo.attentions_num;
        _ttaiNumLabel.text = [dic stringValueForKey:@"tt_num"];
        
        [_tableView reloadData];
        
    } failBlock:^(NSDictionary *failDic, NSError *erro) {
        if (!_getUserinfoSuccess) {
            
        }
    }];
    
}



///创建用户头像banner的view
-(UIView *)creatTableViewHeaderView{
    //底层view
    _backView = [ParallaxHeaderView parallaxHeaderViewWithCGSize:CGSizeMake(DEVICE_WIDTH, DEVICE_WIDTH*420/748.0)];
    _backView.headerImage = DEFAULT_BANNER_IMAGE;
    
    NSLog(@"%@",NSStringFromCGRect(_backView.frame));
    
    
    //标题
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake((DEVICE_WIDTH-50.00)*0.5, 33, 50, 17)];
    //    titleLabel.backgroundColor = [UIColor redColor];
    titleLabel.font = [UIFont systemFontOfSize:16*GscreenRatio_320];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"我的";
    titleLabel.textColor = [UIColor whiteColor];
    [_backView addSubview:titleLabel];
    
    
    
    //头像
    self.userFaceImv = [[UIImageView alloc]initWithFrame:CGRectMake(20*GscreenRatio_320, _backView.frame.size.height - 125, 50, 50)];
    [self.userFaceImv setImage:[UIImage imageNamed:@"grzx150_150.png"]];
    self.userFaceImv.layer.cornerRadius = 25;
    self.userFaceImv.layer.masksToBounds = YES;
    NSLog(@"%@",NSStringFromCGRect(self.userFaceImv.frame));
    
    //昵称
    self.userNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.userFaceImv.frame)+10, self.userFaceImv.frame.origin.y+6, DEVICE_WIDTH-CGRectGetMaxX(self.userFaceImv.frame)-10-17, 14)];
    self.userNameLabel.text = @"昵称：";
    self.userNameLabel.font = [UIFont systemFontOfSize:14*GscreenRatio_320];
    self.userNameLabel.textColor = [UIColor whiteColor];

    //积分
    self.userScoreLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.userNameLabel.frame.origin.x, CGRectGetMaxY(self.userNameLabel.frame)+10, 150, self.userNameLabel.frame.size.height)];
    self.userScoreLabel.font = [UIFont systemFontOfSize:14*GscreenRatio_320];
    self.userScoreLabel.text = @"积分：";
    self.userScoreLabel.textColor = [UIColor whiteColor];
    
    
    
    //签到
    _qiandaoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_qiandaoBtn setFrame:CGRectMake(DEVICE_WIDTH-60, CGRectGetMaxY(_backView.frame)-120, 50, 40)];
    [_qiandaoBtn addTarget:self action:@selector(gQiandao:) forControlEvents:UIControlEventTouchUpInside];
    [_backView addSubview:_qiandaoBtn];
    
    
    [_qiandaoBtn setImage:[UIImage imageNamed:@"gqiandao_up.png"] forState:UIControlStateNormal];
    [_qiandaoBtn setImage:[UIImage imageNamed:@"gqiandao_down.png"] forState:UIControlStateSelected];
    
    
    
    [_backView.imageView setImage:[UIImage imageNamed:@"my_bg.png"]];

    
    _theBlackBackView = [[UIImageView alloc]initWithFrame:_backView.imageView.bounds];
    [_theBlackBackView setImage:[UIImage imageNamed:@"my_top_bg.png"]];
    [_backView.imageView addSubview:_theBlackBackView];
    
    CGFloat dddd = DEVICE_WIDTH/3;
    CGFloat yyyy = _backView.frame.size.height-50;
    
    //粉丝
    _fensiView = [[UIView alloc]initWithFrame:CGRectMake(0, yyyy, dddd, 50)];
    _fensiNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, dddd, 25)];
    _fensiNumLabel.text = @"";
    _fensiNumLabel.textAlignment = NSTextAlignmentCenter;
    _fensiNumLabel.font = [UIFont systemFontOfSize:13];
    [_fensiView addSubview:_fensiNumLabel];
    _fensiNumLabel.textColor = [UIColor whiteColor];
    UILabel *fensit = [[UILabel alloc]initWithFrame:CGRectMake(0, 25, dddd, 25)];
    fensit.textAlignment = NSTextAlignmentCenter;
    fensit.text = @"粉丝";
    fensit.font = [UIFont systemFontOfSize:13];
    fensit.textColor = [UIColor whiteColor];
    [_fensiView addSubview:fensit];
    [_backView addSubview:_fensiView];
    
    //关注
    _guanzhuView = [[UIView alloc]initWithFrame:CGRectMake(dddd, yyyy, dddd, 50)];
    _guanzhuNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, dddd, 25)];
    _guanzhuNumLabel.text = @"";
    _guanzhuNumLabel.textColor = [UIColor whiteColor];
    _guanzhuNumLabel.textAlignment = NSTextAlignmentCenter;
    _guanzhuNumLabel.font = [UIFont systemFontOfSize:13];
    
    UILabel *guanzhut = [[UILabel alloc]initWithFrame:CGRectMake(0, 25, dddd, 25)];
    guanzhut.textColor = [UIColor whiteColor];
    guanzhut.text = @"关注";
    guanzhut.font = [UIFont systemFontOfSize:13];
    guanzhut.textAlignment = NSTextAlignmentCenter;
    [_guanzhuView addSubview:guanzhut];
    [_guanzhuView addSubview:_guanzhuNumLabel];
    [_backView addSubview:_guanzhuView];
    
    //T台
    _ttaiView = [[UIView alloc]initWithFrame:CGRectMake(2*dddd, yyyy, dddd, 50)];
    _ttaiNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, dddd, 25)];
    _ttaiNumLabel.text = @"";
    _ttaiNumLabel.textColor = [UIColor whiteColor];
    _ttaiNumLabel.textAlignment = NSTextAlignmentCenter;
    _ttaiNumLabel.font = [UIFont systemFontOfSize:13];
    UILabel *ttt = [[UILabel alloc]initWithFrame:CGRectMake(0, 25, dddd, 25)];
    ttt.textAlignment = NSTextAlignmentCenter;
    ttt.font = [UIFont systemFontOfSize:13];
    ttt.text = @"T台";
    ttt.textColor = [UIColor whiteColor];
    [_ttaiView addSubview:ttt];
    [_ttaiView addSubview:_ttaiNumLabel];
    [_backView addSubview:_ttaiView];
    
    [_fensiView addTaget:self action:@selector(fensiClicked) tag:0];
    [_guanzhuView addTaget:self action:@selector(guanzuClicked) tag:0];
    [_ttaiView addTaget:self action:@selector(ttaiClicked) tag:0];

    
    
    //手势
    UITapGestureRecognizer *ddd = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(userBannerClicked)];
    _backView.imageView.userInteractionEnabled = YES;
    [_backView.imageView addGestureRecognizer:ddd];
    UITapGestureRecognizer *eee = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(userFaceClicked)];
    self.userFaceImv.userInteractionEnabled = YES;
    [self.userFaceImv addGestureRecognizer:eee];
    
    
    //添加视图
    [_backView addSubview:self.userFaceImv];
    [_backView addSubview:self.userNameLabel];
    [_backView addSubview:self.userScoreLabel];
    
    
    
    _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_loginBtn setFrame:CGRectMake(0, 0, 80, 35)];
    _loginBtn.layer.borderWidth = 1;
    _loginBtn.layer.cornerRadius = 5;
    _loginBtn.layer.borderColor = [[UIColor whiteColor]CGColor];
    _loginBtn.layer.masksToBounds = YES;
    [_loginBtn setTitle:@"登录/注册" forState:UIControlStateNormal];
    _loginBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [_loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    CGPoint theLoginCenter = _backView.center;
    theLoginCenter.y+=25;
    
    _loginBtn.center = theLoginCenter;
    _loginBtn.hidden = YES;
    [_loginBtn addTarget:self action:@selector(presentLoginVc) forControlEvents:UIControlEventTouchUpInside];
    [_backView addSubview:_loginBtn];
    
    
    [self setUpuserInfoViewWithLoginState:[LTools cacheBoolForKey:LOGIN_SERVER_STATE]];
    
    
    
    return _backView;
}


#pragma mark - 事件处理

//粉丝 关注 T台点击跳转
-(void)fensiClicked{
    NSLog(@"%s",__FUNCTION__);
    NSString *userId = [GMAPI getUid];
    
    [MiddleTools pushToUserListWithObjectId:userId listType:User_MyFansList forViewController:self lastNavigationHidden:YES hiddenBottom:YES updateParmsBlock:^(NSDictionary *params) {
        
    }];
}

/**
 *  跳转至关注列表
 */
-(void)guanzuClicked{
    NSLog(@"%s",__FUNCTION__);
    NSString *userId = [GMAPI getUid];
    [MiddleTools pushToUserListWithObjectId:userId listType:User_MyConcernList forViewController:self lastNavigationHidden:YES hiddenBottom:YES updateParmsBlock:^(NSDictionary *params) {
        
    }];
}

/**
 *  跳转至t台列表
 */
-(void)ttaiClicked{
    NSLog(@"%s",__FUNCTION__);
    GmyTtaiViewController *ccc = [[GmyTtaiViewController alloc]init];
    ccc.hidesBottomBarWhenPushed = YES;
    ccc.lastPageNavigationHidden = YES;
    [self.navigationController pushViewController:ccc animated:YES];
    
}

//修改顶部信息view登录未登录状态
-(void)setUpuserInfoViewWithLoginState:(BOOL)theState{
    if (theState) {//登录
        self.userNameLabel.hidden = NO;
        self.userScoreLabel.hidden = NO;
        self.userFaceImv.hidden = NO;
        _editBtn.hidden = NO;
        _loginBtn.hidden = YES;
        _qiandaoBtn.hidden = !_getUserinfoSuccess;
        _fensiView.hidden = NO;
        _guanzhuView.hidden = NO;
        _ttaiView.hidden = NO;
    }else{//未登录
        
        
        [_backView.imageView setImage:[UIImage imageNamed:@"my_bg.png"]];
        self.userNameLabel.hidden = YES;
        self.userScoreLabel.hidden = YES;
        self.userFaceImv.hidden = YES;
        _editBtn.hidden = YES;
        _qiandaoBtn.hidden = YES;
        _loginBtn.hidden = NO;
        _fensiView.hidden = YES;
        _guanzhuView.hidden = YES;
        _ttaiView.hidden = YES;
        
    }
}


//签到
-(void)gQiandao:(UIButton *)sender{
    
    if ([LTools cacheBoolForKey:LOGIN_SERVER_STATE] == NO || !_getUserinfoSuccess) {
        return;
    }
    
    if (sender.selected == YES) {//已经签到
        
    }else if (sender.selected == NO){//未签到
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        NSString *url = [NSString stringWithFormat:@"%@&authcode=%@",GQIANDAO,[GMAPI getAuthkey]];
        LTools *ccc = [[LTools alloc]initWithUrl:url isPost:NO postData:nil];
        [ccc requestCompletion:^(NSDictionary *result, NSError *erro) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            NSLog(@"%@",result);
            
            NSString *errorcode = result[@"errorcode"];
            
            if ([errorcode intValue] == 0) {
                sender.selected = YES;
                
                NSString *scroe = [NSString stringWithFormat:@"%d",[result intValueForKey:@"the_score"]];
                [self showTheQiandaoSuccessView:scroe];
                
                [self GgetUserInfo];
            }else{
                sender.selected = NO;
            }
            
            
            
            
        } failBlock:^(NSDictionary *failDic, NSError *erro) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            sender.selected = NO;
        }];
    }
    
    
}



-(void)showTheQiandaoSuccessView:(NSString *)theScore{
    //黑色背景
    _qiandaoSuccessViewBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    _qiandaoSuccessViewBgView.backgroundColor = [UIColor blackColor];
    _qiandaoSuccessViewBgView.alpha = 0.8;
    [[[UIApplication sharedApplication]keyWindow] addSubview:_qiandaoSuccessViewBgView];
    
    //图片背景
    _qiandaoSuccessView_imvbgimage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH-30, DEVICE_WIDTH-30)];
    _qiandaoSuccessView_imvbgimage.center = _qiandaoSuccessViewBgView.center;
    [_qiandaoSuccessView_imvbgimage setImage:[UIImage imageNamed:@"gxiaozhu_bg.png"]];
    [[[UIApplication sharedApplication]keyWindow] addSubview:_qiandaoSuccessView_imvbgimage];
    
    //得分lable
    UILabel *scoreLabel = [[UILabel alloc]initWithFrame:CGRectMake(203.0f/345 *(DEVICE_WIDTH-30), 78.0f/345*(DEVICE_WIDTH-30), 18, 16)];
    scoreLabel.backgroundColor = [UIColor orangeColor];
    scoreLabel.textColor = RGBCOLOR(251, 110, 43);
    scoreLabel.font = [UIFont systemFontOfSize:14];
    if (DEVICE_WIDTH<=320) {
        scoreLabel.font = [UIFont systemFontOfSize:11];
        [scoreLabel setFrame:CGRectMake(203.0f/345 *(DEVICE_WIDTH-30), 77.0f/345*(DEVICE_WIDTH-30), 15, 16)];
    }
    scoreLabel.backgroundColor = RGBCOLOR(239, 239, 239);
    scoreLabel.text = theScore;
    scoreLabel.textAlignment = NSTextAlignmentCenter;
    [_qiandaoSuccessView_imvbgimage addSubview:scoreLabel];
    
    //小猪
    _zhu_imv = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 50*GscreenRatio_320, 50*GscreenRatio_320)];
    
    _zhu_imv.center = CGPointMake((DEVICE_WIDTH-30)*0.5, (DEVICE_WIDTH-30)*0.5+30*GscreenRatio_320);
    [_zhu_imv setImage:[UIImage imageNamed:@"gqiandao_zhu.png"]];
    [_qiandaoSuccessView_imvbgimage addSubview:_zhu_imv];
    
    
    //关闭按钮
    _qiandaoSuccessView_closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_qiandaoSuccessView_closeBtn setFrame:CGRectMake(CGRectGetMaxX(_qiandaoSuccessView_imvbgimage.frame)-35, _qiandaoSuccessView_imvbgimage.frame.origin.y-35, 35, 35)];
    [_qiandaoSuccessView_closeBtn setImage:[UIImage imageNamed:@"gqiandaoguanbi.png"] forState:UIControlStateNormal];
    [_qiandaoSuccessViewBgView addSubview:_qiandaoSuccessView_closeBtn];
    [_qiandaoSuccessView_closeBtn addTarget:self action:@selector(removeTheQiandaoSuccessView) forControlEvents:UIControlEventTouchUpInside];
    [[[UIApplication sharedApplication]keyWindow] addSubview:_qiandaoSuccessView_closeBtn];
    
    [UIView animateWithDuration:0.5 animations:^{
        [_zhu_imv setFrame:CGRectMake(0, 0, 150*GscreenRatio_320, 150*GscreenRatio_320)];
        _zhu_imv.center = CGPointMake((DEVICE_WIDTH-30)*0.5, (DEVICE_WIDTH-30)*0.5+30*GscreenRatio_320);
    } completion:^(BOOL finished) {
        [self huangdong];
    }];
    
    
}


-(void)removeTheQiandaoSuccessView{
    [_qiandaoSuccessViewBgView removeFromSuperview];
    [_qiandaoSuccessView_imvbgimage removeFromSuperview];
    [_qiandaoSuccessView_closeBtn removeFromSuperview];
    
}


-(void)huangdong{
    // 晃动次数
    static int numberOfShakes = 4;
    // 晃动幅度（相对于总宽度）
    static float vigourOfShake = 0.04f;
    // 晃动延续时常（秒）
    static float durationOfShake = 0.5f;
    CAKeyframeAnimation *shakeAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    // 方法一：绘制路径
    CGRect frame = _zhu_imv.frame;
    // 创建路径
    CGMutablePathRef shakePath = CGPathCreateMutable();
    // 起始点
    CGPathMoveToPoint(shakePath, NULL, CGRectGetMidX(frame), CGRectGetMidY(frame));
    for (int index = 0; index < numberOfShakes; index++)
    {
        // 添加晃动路径 幅度由大变小
        CGPathAddLineToPoint(shakePath, NULL, CGRectGetMidX(frame) - frame.size.width * vigourOfShake*(1-(float)index/numberOfShakes),CGRectGetMidY(frame));
        CGPathAddLineToPoint(shakePath, NULL,  CGRectGetMidX(frame) + frame.size.width * vigourOfShake*(1-(float)index/numberOfShakes),CGRectGetMidY(frame));
    }
    // 闭合
    CGPathCloseSubpath(shakePath);
    shakeAnimation.path = shakePath;
    shakeAnimation.duration = durationOfShake;
    // 释放
    CFRelease(shakePath);
    
    [_zhu_imv.layer addAnimation:shakeAnimation forKey:kCATransition];
}


//跳转个人设置界面
-(void)clickToSettings{
    
    //判断是否登录
    if ([LTools cacheBoolForKey:LOGIN_SERVER_STATE] == NO) {
        
        LoginViewController *login = [[LoginViewController alloc]init];
        
        UINavigationController *unVc = [[UINavigationController alloc]initWithRootViewController:login];
        
        [self presentViewController:unVc animated:YES completion:nil];
        
        
        return;
        
    }

    if (!_getUserinfoSuccess) {
        return;
    }
    
    MySettingsViewController *mySettingVC = [[MySettingsViewController alloc]init];
    mySettingVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:mySettingVC animated:YES];
}

#pragma mark 数据处理

/**
 *  tabbar上显示的未读消息数
 *
 *  @return 返回显示的个数
 */
- (int)unreadMessageNum
{
    UINavigationController *unvc = [[LTools appDelegate].rootViewController.viewControllers objectAtIndex:3];
    int num = [unvc.tabBarItem.badgeValue intValue];
    
    return num > 0 ? num : 0;
}

/**
 *  注册通知,获取未读消息条数
 */
- (void)getUnreadMessageNum
{
    UINavigationController *unvc = [[LTools appDelegate].rootViewController.viewControllers objectAtIndex:3];
//    int num = [unvc.tabBarItem.badgeValue intValue];
    
    [unvc.tabBarItem addObserver:self forKeyPath:@"badgeValue" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
//    NSLog(@"observeValueForKeyPath %@",change);
    
    if ([keyPath isEqualToString:@"badgeValue"]) {
        
        id new = [change objectForKey:@"new"];
        
        int newNum = 0.f;
        if ([new isKindOfClass:[NSNull class]]) {
            
            newNum = 0;
        }else
        {
            newNum = [new intValue];
        }
        
        NSLog(@"mine未读消息 %d",newNum);
        
        _unreadNum = newNum > 0 ? newNum : 0;
        
        [_tableView reloadData];
    }
}

#pragma mark 事件处理

/**
 *  views赋值
 *
 *  @param userInfoDic 用户信息字典
 */
//- (void)setViewsWithDataInfo:(NSDictionary *)userInfoDic
//{
//    _userInfo = [[UserInfo alloc]initWithDictionary:userInfoDic];
//    
//    if ([_userInfo.is_sign intValue] == 0) {//未签到
//        _qiandaoBtn.userInteractionEnabled = YES;
//        _qiandaoBtn.selected = NO;
//    }else if ([_userInfo.is_sign intValue] == 1){//已签到
//        _qiandaoBtn.userInteractionEnabled = NO;
//        _qiandaoBtn.selected = YES;
//    }
//    
//    if ([_userInfo.shopman intValue] == 2) {//已经是店主
//        [self changeTheTitleAndPicArray_dianzhu];
//    }else if ([_userInfo.shopman intValue]==1){//正在审核
//        [self changeTheTitleAndPicArray_shenhe];
//    }
//    
//    NSString *name = [userInfoDic stringValueForKey:@"user_name"];
//    NSString *score = [userInfoDic stringValueForKey:@"score"];
//    self.userNameLabel.text = [NSString stringWithFormat:@"昵称:%@",name];
//    self.userScoreLabel.text = [NSString stringWithFormat:@"积分:%@",score];
//    
//    user_bannerUrl = [userInfoDic stringValueForKey:@"user_banner"];
//    [_backView.imageView sd_setImageWithURL:[NSURL URLWithString:user_bannerUrl] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//        [GMAPI setUserBannerImageWithData:UIImagePNGRepresentation(_backView.imageView.image)];
//    }];
//    
//    NSString *userFaceUrl = [NSString stringWithFormat:@"%@",[userInfoDic stringValueForKey:@"photo"]];
//    headImageUrl = userFaceUrl;
//    
//    
//    [self.userFaceImv sd_setImageWithURL:[NSURL URLWithString:userFaceUrl] placeholderImage:[UIImage imageNamed:@"grzx150_150.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//        [GMAPI setUserFaceImageWithData:UIImagePNGRepresentation(self.userFaceImv.image)];
//    }];
//    
//    [_tableView reloadData];
//}

- (void)clickToShare:(UIButton *)sender
{
    [[LShareSheetView shareInstance] showShareContent:@"我在使用衣+衣,我们一起来用吧!" title:nil shareUrl:@"http://a.app.qq.com/o/simple.jsp?pkgname=com.yijiayi.yijiayi" shareImage:[UIImage imageNamed:@"about_icon"] targetViewController:self];
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
}


#pragma mark - UITableViewDelegate && UITableViewDataSource


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _tabelViewCellTitleArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 56;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}



-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 10)];
    view.backgroundColor = RGBCOLOR(242, 242, 242);
    return view;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"identifier";
    GTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[GTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
//    cell.separatorInset = UIEdgeInsetsMake(0,0,0,0);//上左下右
    
    NSString *title = _tabelViewCellTitleArray[indexPath.row];
    
    if ([title isEqualToString:@"消息中心"]) {
        
        //消息中心
        
        if (_unreadNum > 0) {
            
            UILabel *unreadLabel = [[UILabel alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 28 - 30, 18, 20, 20)];
            [unreadLabel addRoundCorner];
            unreadLabel.backgroundColor = RGBCOLOR(255, 30, 29);
            unreadLabel.textColor = [UIColor whiteColor];
            unreadLabel.text = [NSString stringWithFormat:@"%d",_unreadNum];
            unreadLabel.textAlignment = NSTextAlignmentCenter;
            unreadLabel.font = [UIFont systemFontOfSize:14];
            [cell.contentView addSubview:unreadLabel];
            
            CGFloat aWidth = [LTools widthForText:NSStringFromInt(_unreadNum) font:14];
            
            if (_unreadNum <= 9) {
                
                aWidth = 20;
                
            }else
            {
                aWidth = ((aWidth < 20) ? 20 : aWidth) + 10;
            }
            
            unreadLabel.width = aWidth;
            
        }
        
    }
        
    [cell creatCustomViewWithGcellType:GPERSON indexPath:indexPath customObject:_customInfo_tabelViewCell];
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //判断是否登录
    if ([LTools cacheBoolForKey:LOGIN_SERVER_STATE] == NO) {
        
        LoginViewController *login = [[LoginViewController alloc]init];
        
        UINavigationController *unVc = [[UINavigationController alloc]initWithRootViewController:login];
        
        [self presentViewController:unVc animated:YES completion:nil];
        
        return;
    }
    
    if (!_getUserinfoSuccess) {
        return;
    }
    
    NSString *title = _tabelViewCellTitleArray[indexPath.row];

    if ([title isEqualToString:@"我的收藏"]) {
        
        MyConcernController *concern = [[MyConcernController alloc]init];
        concern.hidesBottomBarWhenPushed = YES;
        concern.lastPageNavigationHidden = YES;
        [self.navigationController pushViewController:concern animated:YES];
        
    }else if ([title isEqualToString:@"我的钱包"])
    {
        GMyWalletViewController *ccc = [[GMyWalletViewController alloc]init];
        ccc.hidesBottomBarWhenPushed = YES;
        ccc.lastPageNavigationHidden = YES;
        ccc.jifen = self.jifen;
        [self.navigationController pushViewController:ccc animated:YES];
        
    }else if ([title isEqualToString:@"我的购物车"]){
        
        ShoppingCarController *order = [[ShoppingCarController alloc]init];
        order.hidesBottomBarWhenPushed = YES;
        order.lastPageNavigationHidden = YES;
        [self.navigationController pushViewController:order animated:YES];
        
    }else if ([title isEqualToString:@"我的订单"]){
        
        OrderViewController *order = [[OrderViewController alloc]init];
        order.hidesBottomBarWhenPushed = YES;
        order.lastPageNavigationHidden = YES;
        [self.navigationController pushViewController:order animated:YES];
        
    }else if ([title isEqualToString:@"我的地址"]){
        
        ShoppingAddressController *shopping = [[ShoppingAddressController alloc]init];
        shopping.hidesBottomBarWhenPushed = YES;
        shopping.lastPageNavigationHidden = YES;
        [self.navigationController pushViewController:shopping animated:YES];
        
    }else if ([title isEqualToString:@"消息中心"]){
        
        MessageListController *messageList = [[MessageListController alloc]init];
        messageList.hidesBottomBarWhenPushed = YES;
        messageList.lastPageNavigationHidden = YES;
        [self.navigationController pushViewController:messageList animated:YES];
        
    }else if ([title isEqualToString:@"邀请好友"]){
        
        [self clickToShare:nil];
        
    }else if ([title isEqualToString:@"扫一扫"]){
        
        [self saoyisaoClicked];
        
    }else if ([title isEqualToString:@"设置"]){
        
        [self clickToSettings];
    }
    
//    switch (indexPath.row) {
//            
//        case 0://我的收藏
//        {
//            MyConcernController *concern = [[MyConcernController alloc]init];
//            concern.hidesBottomBarWhenPushed = YES;
//            concern.lastPageNavigationHidden = YES;
//            [self.navigationController pushViewController:concern animated:YES];
//        }
//            break;
//        case 1://我的钱包
//        {
//            GMyWalletViewController *ccc = [[GMyWalletViewController alloc]init];
//            ccc.hidesBottomBarWhenPushed = YES;
//            ccc.lastPageNavigationHidden = YES;
//            ccc.jifen = self.jifen;
//            [self.navigationController pushViewController:ccc animated:YES];
//            
//        }
//            break;
//////        case 2://申请店铺/我的店铺
//////        {
//////            int shopMan = [_userInfo.shopman intValue];
//////            
//////            if (shopMan == 2) {
//////                NSLog(@"店主");
//////                MyShopViewController *shop = [[MyShopViewController alloc]init];
//////                shop.userInfo = _userInfo;
//////                shop.lastPageNavigationHidden = YES;
//////                shop.hidesBottomBarWhenPushed = YES;
//////                [self.navigationController pushViewController:shop animated:YES];
//////            }else if (shopMan == 1){
//////                NSLog(@"店铺申请");
//////                [LTools showMBProgressWithText:@"您已申请店铺,正在审核中..." addToView:self.view];
//////            }else if (shopMan == 0){
//////                NSLog(@"普通");
//////                ShenQingDianPuViewController *_shenqingVC = [[ShenQingDianPuViewController alloc]init];
//////                _shenqingVC.hidesBottomBarWhenPushed = YES;
//////                _shenqingVC.lastPageNavigationHidden = YES;
//////                [self.navigationController pushViewController:_shenqingVC animated:YES];
//////            }
//////        }
////            break;
//        case 2://消息中心
//        {
//            MessageListController *messageList = [[MessageListController alloc]init];
//            messageList.hidesBottomBarWhenPushed = YES;
//            messageList.lastPageNavigationHidden = YES;
//            [self.navigationController pushViewController:messageList animated:YES];
//            
//        }
//            break;
//        case 3://邀请好友
//        {
//            [self clickToShare:nil];
//            
//        }
//            break;
//        case 4://扫一扫
//        {
//            [self saoyisaoClicked];
//            
//        }
//            break;
//        case 5://设置
//        {
//            [self clickToSettings];
//        }
//            break;
//        default:
//            break;
//    }
    
}

-(void)saoyisaoClicked{
    NSLog(@"扫一扫");
    
    GScanViewController *ccc = [[GScanViewController alloc]init];
    ccc.delegate = self;
    [self presentViewController:ccc animated:YES completion:^{
        
    }];
    
}

///编辑资料
-(void)goToEdit{
    
    if (!_getUserinfoSuccess) {
        return;
    }
    
    if ([LTools isLogin:self]) {
        //编辑
        EditMyInfoViewController *editInfoVC = [[EditMyInfoViewController alloc] init];
        editInfoVC.delegate = self;
        editInfoVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:editInfoVC animated:YES];
    }
}


//修改banner&&头像
-(void)userBannerClicked{
    NSLog(@"点击用户banner");
    if (!_getUserinfoSuccess) {
        return;
    }
    
    
    //判断是否登录
    if ([LTools cacheBoolForKey:LOGIN_SERVER_STATE] == NO) {
        
        return;
        
    }
    
    _changeImageType = USERBANNER;
    GcustomActionSheet *aaa = [[GcustomActionSheet alloc]initWithTitle:nil
                                                          buttonTitles:@[@"更换背景图片"]
                                                     buttonTitlesColor:[UIColor blackColor]
                                                           buttonColor:[UIColor whiteColor]
                                                           CancelTitle:@"取消"
                                                      cancelTitelColor:[UIColor whiteColor]
                                                           CancelColor:RGBCOLOR(253, 144, 39)
                                                       actionBackColor:RGBCOLOR(236, 236, 236)];
    aaa.tag = 90;
    aaa.delegate = self;
    [aaa showInView:self.view.window WithAnimation:YES];
    
    
}
-(void)userFaceClicked{
    NSLog(@"点击头像");
    if (!_getUserinfoSuccess) {
        return;
    }
    
    
    [self goToEdit];
    
//    _changeImageType = USERFACE;
//    GcustomActionSheet *aaa = [[GcustomActionSheet alloc]initWithTitle:nil
//                                                          buttonTitles:@[@"更换头像"]
//                                                     buttonTitlesColor:[UIColor blackColor]
//                                                           buttonColor:[UIColor whiteColor]
//                                                           CancelTitle:@"取消"
//                                                      cancelTitelColor:[UIColor whiteColor]
//                                                           CancelColor:RGBCOLOR(253, 144, 39)
//                                                       actionBackColor:RGBCOLOR(236, 236, 236)];
//    aaa.tag = 91;
//    aaa.delegate = self;
//    [aaa showInView:self.view.window WithAnimation:YES];
}




#pragma mark - GcustomActionSheetDelegate

///隐藏或显示tabbar
-(void)gHideTabBar:(BOOL)hidden{
    
    //    [UIView beginAnimations:nil context:NULL];
    //    [UIView setAnimationDuration:0.5];
    
    
    
    [UIView animateWithDuration:0.5 animations:^{
        if (hidden) {
            NSLog(@"加等 %f",self.tabBarController.tabBar.top);
            
            self.tabBarController.tabBar.top = DEVICE_HEIGHT;
        }else{
            NSLog(@"减等 %f",self.tabBarController.tabBar.top);
            self.tabBarController.tabBar.top = DEVICE_HEIGHT-49;
        }
    } completion:^(BOOL finished) {
        
    }];
    
    
    //    [UIView commitAnimations];
    
    
    //    self.tabBarController.tabBar.hidden = hidden;//无动画
}

-(void)gActionSheet:(GcustomActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    _isChangeBanner = YES;
    
    NSLog(@"buttonIndex:%ld",(long)buttonIndex);
    
    //图片选择器
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    if (actionSheet.tag == 90) {//banner
        if (buttonIndex == 1) {//修改
            [self presentViewController:picker animated:YES completion:^{
                
            }];
        }
    }else if (actionSheet.tag == 91){//头像
        if (buttonIndex == 1) {//修改
            [self presentViewController:picker animated:YES completion:^{
                
            }];
        }
    }
    
}

#pragma mark- 缩放图片
//按比例缩放
-(UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    if (image.size.width>750) {
        scaleSize = 750.0/image.size.width;
    }else{
        scaleSize = 1;
    }
    
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width*scaleSize,image.size.height*scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height *scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

//按像素缩放
-(UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}
#pragma mark - UIImagePickerControllerDelegate 拍照选择照片协议方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSLog(@"%s",__FUNCTION__);
    [UIApplication sharedApplication].statusBarHidden = NO;
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:@"public.image"]) {
        
        //压缩图片 不展示原图
        UIImage *originImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        //按比例缩放
        UIImage *scaleImage = [self scaleImage:originImage toScale:0.3];
        
        
        //将图片传递给截取界面进行截取并设置回调方法（协议）
        MLImageCrop *imageCrop = [[MLImageCrop alloc]init];
        imageCrop.delegate = self;
        
        //按像素缩放  //设置缩放比例
        if (_changeImageType == USERBANNER) {
            imageCrop.ratioOfWidthAndHeight = CROPIMAGERATIO_USERBANNER;
        }else if (_changeImageType == USERFACE){
            imageCrop.ratioOfWidthAndHeight = 1;
        }
        
        imageCrop.image = scaleImage;
        //[imageCrop showWithAnimation:NO];
        picker.navigationBar.hidden = YES;
        [picker pushViewController:imageCrop animated:YES];
        
    }
}


#pragma mark - MLImageCropDelegate
- (void)cropImage:(UIImage*)cropImage forOriginalImage:(UIImage*)originalImage
{
    
    if (_changeImageType == USERBANNER) {
        UIImage *doneImage = [self scaleToSize:cropImage size:UPIMAGECGSIZE_USERBANNER];//按像素缩放
        self.userBanner = doneImage;
        self.userUploadImagedata = UIImageJPEGRepresentation(self.userBanner, 0.8);
        [GMAPI setUserBannerImageWithData:self.userUploadImagedata];//存储到本地
        _backView.headerImage = [GMAPI getUserBannerImage];//及时更新banner
        [GMAPI setUpUserBannerYes];//设置是否上传标志位
    }else if (_changeImageType == USERFACE){
        UIImage *doneImage = [self scaleToSize:cropImage size:UPIMAGECGSIZE_USERFACE];//按像素缩放
        self.userFace = doneImage;
        self.userUploadImagedata = UIImagePNGRepresentation(self.userFace);
        [GMAPI setUserFaceImageWithData:self.userUploadImagedata];//存储到本地
        [self.userFaceImv setImage:[GMAPI getUserFaceImage]];//及时更新face
        [GMAPI setUpUserFaceYes];//设置是否上传标志位
    }
    
    
    //ASI上传
    [self upLoadImage];
    
    [_tableView reloadData];
    
}

//上传
-(void)upLoadImage{
    
    //上传的url
    NSString *uploadImageUrlStr = @"";
    
    if (_changeImageType == USERBANNER) {//banner
        uploadImageUrlStr = PERSON_CHANGEUSERBANNER;
    }else if (_changeImageType == USERFACE){//头像
        uploadImageUrlStr = POST_UPDATEMYINFO_URL;
    }
    
    //设置接收响应类型为标准HTTP类型(默认为响应类型为JSON)
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    AFHTTPRequestOperation  * o2= [manager
                                   POST:uploadImageUrlStr
                                   parameters:@{
                                                @"authcode":[GMAPI getAuthkey]
                                                }
                                   constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
                                   {
                                       //开始拼接表单
                                       //获取图片的二进制形式
                                       NSData * data= self.userUploadImagedata;
                                       
                                       NSLog(@"%ld",(unsigned long)data.length);
                                       
                                       //将得到的二进制图片拼接到表单中
                                       /**
                                        *  data,指定上传的二进制流
                                        *  name,服务器端所需参数名
                                        *  fileName,指定文件名
                                        *  mimeType,指定文件格式
                                        */
                                       [formData appendPartWithFileData:data name:@"pic" fileName:@"icon.jpg" mimeType:@"image/jpg"];
                                       //多用途互联网邮件扩展（MIME，Multipurpose Internet Mail Extensions）
                                   }
                                   success:^(AFHTTPRequestOperation *operation, id responseObject)
                                   {
                                       
                                       [GMAPI showAutoHiddenMBProgressWithText:@"更改成功" addToView:self.view];
                                       
                                       NSLog(@"%@",responseObject);
                                       
                                       NSError * myerr;
                                       
                                       NSDictionary *mydic=[NSJSONSerialization JSONObjectWithData:(NSData *)responseObject options:NSJSONReadingAllowFragments error:&myerr];
                                       
                                       
                                       NSLog(@"%@",mydic);
                                       
                                       if (_changeImageType == USERBANNER) {
                                           [GMAPI setUpUserBannerNo];
                                       }else if (_changeImageType == USERFACE){
                                           [GMAPI setUpUserFaceNo];
                                       }
                                       
                                   }
                                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       
                                       [GMAPI showAutoHiddenMBProgressWithText:@"更改失败,联网自动上传" addToView:self.view];
                                       
                                       
                                       NSLog(@"%@",error);
                                       
                                       
                                       if (_changeImageType == USERBANNER) {
                                           [GMAPI setUpUserBannerYes];
                                       }else if (_changeImageType == USERFACE){
                                           [GMAPI setUpUserFaceYes];
                                       }
                                   }];
    //设置上传操作的进度
    [o2 setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        
    }];
    
    
}



#pragma mark -
#pragma mark UISCrollViewDelegate



-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    if (scrollView == _tableView) {
        
        if (!_getUserinfoSuccess) {
            
            [self GgetUserInfo];
            
            NSLog(@"scrollViewDidEndDragging");

        }
    }
}






- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    if (scrollView == _tableView)
    {
        // pass the current offset of the UITableView so that the ParallaxHeaderView layouts the subViews.
        [(ParallaxHeaderView *)_tableView.tableHeaderView layoutHeaderViewForScrollViewOffset:scrollView.contentOffset];
        [_theBlackBackView setFrame:_backView.imageView.bounds];
        //加载数据菊花 偏移量<-85 并且是下拉
        if (scrollView.contentOffset.y < -90) {
            
            if ([GMAPI getAuthkey].length != 0) {
                
                [_hud startAnimating];

            }
            _getUserinfoSuccess = NO;
            
        }
    }

    
}






//扫一扫跳转的页面
-(void)gScanvcPushWithString:(NSString *)string{
    GwebViewController *ccc = [[GwebViewController alloc]init];
    ccc.urlstring = string;
    ccc.isSaoyisao = YES;
    ccc.hidesBottomBarWhenPushed = YES;
    UINavigationController *navc = [[UINavigationController alloc]initWithRootViewController:ccc];
    [self presentViewController:navc animated:YES completion:^{
        
    }];
}



//跳出登录界面
-(void)presentLoginVc{
    LoginViewController *login = [[LoginViewController alloc]init];
    UINavigationController *unVc = [[UINavigationController alloc]initWithRootViewController:login];
    [self presentViewController:unVc animated:YES completion:nil];
}




- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}



@end

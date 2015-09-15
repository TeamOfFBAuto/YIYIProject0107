//
//  AppDelegate.m
//  YiYiProject
//
//  Created by lichaowei on 14/12/10.
//  Copyright (c) 2014年 lcw. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"

#import "MailMessageViewController.h"

#import "UMSocial.h"
#import "MobClick.h"

#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"
#import "UMSocialSinaHandler.h"
//#import "UMSocialTencentWeiboHandler.h"
#import "BMapKit.h"

#import "RCIM.h"

#import "RCIMClient.h"

#import "LDataInstance.h"

//https://itunes.apple.com/us/app/id951259287?mt=8

//融云cloud

#define UmengAppkey @"548bae91fd98c50d0c000b8b"//正式 umeng后台：mobile@jiruijia.com mobile2014

#define SinaAppKey @"2208620241" //正式审核通过 微博开放平台账号szkyaojiayou@163.com 密码：mobile2014
#define SinaAppSecret @"fe596bc4ac8c92316ad5f255fbc49432"
#define QQAPPID @"1104065435" //十六进制:41CEB39B; 生成方法:echo 'ibase=10;obase=16;1104065435'|bc
#define QQAPPKEY @"UgVWGacRoeo9NtZy" //正式的账号

#define WXAPPID @"wx47f54e431de32846" //正式
#define WXAPPSECRET @"a71699732e3bef01aefdaf324e2f522c"


#define RedirectUrl @"http://sns.whalecloud.com/sina2/callback" //回调地址

//百度地图

//#define BAIDU_APPKEY @"iiUyYDDK4A6CnzmHL4SVUvuo" //企业 com.yijiayi.yjy
#define BAIDU_APPKEY @"xVfbtQq4cB5OLkTk8hmxlyLd" //appStore com.yijiayi.yijiayi

//测试
#define RONGCLOUD_IM_APPKEY    @"kj7swf8o7zaf2" //正式 融云账号 18600912932 cocos2d
#define RONGCLOUD_IM_APPSECRET @"2cCSWhaLcCm37"

//上线
//#define RONGCLOUD_IM_APPKEY    @"qf3d5gbj3a8gh" //正式 融云账号 18600912932 cocos2d
//#define RONGCLOUD_IM_APPSECRET @"rcUmYEhqkfs"

//sns.whalecloud.com

/**
 *  准备加支付了 2.0
 */
@interface AppDelegate ()<BMKGeneralDelegate,RCIMConnectionStatusDelegate,RCConnectDelegate,RCIMConnectionStatusDelegate,RCConnectDelegate,RCIMReceiveMessageDelegate,RCIMUserInfoFetcherDelegagte,GgetllocationDelegate>
{
    BMKMapManager* _mapManager;
    CLLocationManager *_locationManager;
    
    GMAPI *mapApi;
    LocationBlock _locationBlock;
    LocationBlock _addressDetailBlock;//根据坐标获取位置详细信息
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Override point for customization after application launch.
    
#pragma mark 融云
    
    [RCIM initWithAppKey:RONGCLOUD_IM_APPKEY deviceToken:nil];
    [[RCIM sharedRCIM]setConnectionStatusDelegate:self];//监控连接状态
    [[RCIM sharedRCIM] setReceiveMessageDelegate:self];//接受消息
    [RCIM setUserInfoFetcherWithDelegate:self isCacheUserInfo:YES];
    
    //系统登录成功通知 登录融云
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loginToRongCloud) name:NOTIFICATION_LOGIN object:nil];
    
    [self rongCloudDefaultLoginWithToken:[LTools cacheForKey:RONGCLOUD_TOKEN]];
    
    
#pragma mark 版本检测
    
    //版本更新
    
    [[LTools shareInstance]versionForAppid:@"951259287" Block:^(BOOL isNewVersion, NSString *updateUrl, NSString *updateContent) {
        
//        NSLog(@"updateContent %@ %@",updateUrl,updateContent);
        
    }];
    
#pragma mark 远程通知
    
    if (IOS7_OR_LATER) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    }
    
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] > 8.0)
    {
        if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge
                                                                                                 |UIRemoteNotificationTypeSound
                                                                                                 |UIRemoteNotificationTypeAlert) categories:nil];
            [application registerUserNotificationSettings:settings];
        }else{
            
            //注册推送, iOS 8
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert) categories:nil];
            [application registerUserNotificationSettings:settings];
        }
    }else
    {
        // 注册苹果推送，申请推送权限。
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
    }
    
    
    //UIApplicationLaunchOptionsRemoteNotificationKey,判断是通过推送消息启动的
    
    NSDictionary *infoDic = [launchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
    if (infoDic)
    {
        //test
//        NSLog(@"didFinishLaunch : infoDic %@",infoDic);
        
    }
#pragma mark 百度地图相关
    
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] > 8.0)
    {
        //设置定位权限 仅ios8有意义
        [_locationManager requestWhenInUseAuthorization];// 前台定位
        
        //  [locationManager requestAlwaysAuthorization];// 前后台同时定位
    }
    [_locationManager startUpdatingLocation];
    

    // 要使用百度地图，请先启动BaiduMapManager
    _mapManager = [[BMKMapManager alloc]init];
    // 如果要关注网络及授权验证事件，请设定   BMKGeneralDelegate协议
    
    BOOL ret = [_mapManager start:BAIDU_APPKEY  generalDelegate:self];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
    
#pragma mark 友盟
    
    [self umengShare];
    
#pragma mark 根视图
    
    RootViewController *root = [[RootViewController alloc]init];
    self.rootViewController = root;
    LNavigationController *unVc = [[LNavigationController alloc]initWithRootViewController:root];
    unVc.navigationBarHidden = YES;
    self.window.rootViewController = unVc;
    self.window.backgroundColor = [UIColor whiteColor];

    
    return YES;
}

#pragma mark - 获取坐标

//获取坐标
- (void)startDingweiWithBlock:(LocationBlock)location
{
    _locationBlock = location;
    
    //定位获取坐标
    mapApi = [GMAPI sharedManager];
    mapApi.delegate = self;
    [mapApi startDingwei];
    
//    [self startDingWeiTimer];//开始定位计时器
}

//根据坐标获取位置详细信息
- (void)getAddressDetailWithLontitud:(CGFloat)longtitude
                            latitude:(CGFloat)latitude
                        addressBlock:(LocationBlock)addressBlock
{
    _addressDetailBlock = addressBlock;
    //定位获取坐标
    mapApi = [GMAPI sharedManager];
    mapApi.delegate = self;
    [mapApi getAddressDetailWithLontitud:longtitude latitude:latitude];

}

/**
 *  开启定位定时器 lcw
 */
- (void)startDingWeiTimer
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (kCLAuthorizationStatusDenied == status || kCLAuthorizationStatusRestricted == status) {
        
        NSLog(@"请打开您的位置服务!");
        
    }else{
        //开启了地图定位 时间器
        [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(startDingweiWithBlock:) userInfo:nil repeats:YES];
    }
}

#pragma mark - 定位Delegate

- (void)theLocationDictionary:(NSDictionary *)dic{
    
    if (_locationBlock) {
        
        _locationBlock(dic);
        
        _locationBlock = nil;//撤销定位block
    }
    
    [GMAPI sharedManager].theLocationDic = [dic copy];
    
    [self updateLocationCache:dic];//更新当前位置信息
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_UPDATELOCATION_SUCCESS object:nil userInfo:dic];//更新当前位置成功通知
    
}

-(void)theLocationFaild:(NSDictionary *)dic{
    
    if (_locationBlock) {
        _locationBlock(dic);
    }
}

- (void)theLocationAddressDetailDictionary:(NSDictionary *)dic //定位返回详细地址信息
{
    if (dic) {
        
        if (_addressDetailBlock) {
            
            _addressDetailBlock(dic);
        }
    }
}


/**
 *  更新当前定位信息的本地保存
 *
 *  @param dic
 */
- (void)updateLocationCache:(NSDictionary *)dic
{
    [LTools cache:[dic stringValueForKey:@"long"] ForKey:USER_LOCATION_LONG];
    [LTools cache:[dic stringValueForKey:@"lat"] ForKey:USER_LOCATION_LAT];
    [LTools cache:[dic stringValueForKey:@"province"] ForKey:USER_LOCATION_PROVINCE];
    [LTools cache:[dic stringValueForKey:@"city"] ForKey:USER_LOCATION_CITY];
    [LTools cache:[dic stringValueForKey:@"addressDetail"] ForKey:USER_LOCATION_ADDRESS_DETAIL];
    [LTools cacheBool:[dic boolValueForKey:@"result"] ForKey:USER_LOCATION_STATE];
}

#pragma - mark

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    int rong_num = [[RCIM sharedRCIM] getTotalUnreadCount];
    
    rong_num = rong_num > 0 ? rong_num : 0;
    
    int other_num = [[LTools cacheForKey:USER_UNREADNUM]intValue];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = rong_num + other_num;//融云 + 其他
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    if ([LTools cacheBoolForKey:LOGIN_SERVER_STATE] == YES){
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_APPENTERFOREGROUND object:nil];
    }
    
    //通知获取抽奖状态
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_GETCHOUJIANGSTATE object:nil];

}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/**
 这里处理新浪微博SSO授权之后跳转回来，和微信分享完成之后跳转回来
 */
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    
    return  [UMSocialSnsService handleOpenURL:url wxApiDelegate:nil];
}

/**
 这里处理新浪微博SSO授权进入新浪微博客户端后进入后台，再返回原来应用
 */
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [UMSocialSnsService  applicationDidBecomeActive];
}

#pragma mark - 友盟分享

- (void)umengShare
{
    [UMSocialData setAppKey:UmengAppkey];
    
    //使用友盟统计
    [MobClick startWithAppkey:UmengAppkey];
        
    //打开调试log的开关
    [UMSocialData openLog:NO];
    
    //打开新浪微博的SSO开关
    [UMSocialSinaHandler openSSOWithRedirectURL:RedirectUrl];
    
    //设置分享到QQ空间的应用Id，和分享url 链接
    [UMSocialQQHandler setQQWithAppId:QQAPPID appKey:QQAPPKEY url:@"http://www.umeng.com/social"];
    
    //设置支持没有客户端情况下使用SSO授权
    [UMSocialQQHandler setSupportWebView:YES];
    
    //设置微信AppId，设置分享url，默认使用友盟的网址
    [UMSocialWechatHandler setWXAppId:WXAPPID appSecret:WXAPPSECRET url:@"http://www.umeng.com/social"];
    
//    [UMSocialTencentWeiboHandler openSSOWithRedirectUrl:@"http://sns.whalecloud.com/tencent2/callback"];
    
}


#pragma mark 远程推送

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    // Register to receive notifications.
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    // Handle the actions.
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}

// 获取苹果推送权限成功。

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    
    NSLog(@"My token is: %@", deviceToken);
    
    [[RCIM sharedRCIM]setDeviceToken:deviceToken];//融云
    
    NSString *string_pushtoken=[NSString stringWithFormat:@"%@",deviceToken];
    
    while ([string_pushtoken rangeOfString:@"<"].length||[string_pushtoken rangeOfString:@">"].length||[string_pushtoken rangeOfString:@" "].length) {
        string_pushtoken=[string_pushtoken stringByReplacingOccurrencesOfString:@"<" withString:@""];
        string_pushtoken=[string_pushtoken stringByReplacingOccurrencesOfString:@">" withString:@""];
        string_pushtoken=[string_pushtoken stringByReplacingOccurrencesOfString:@" " withString:@""];
        
    }
//    NSLog(@"mytoken==%@",string_pushtoken);
    
    [self PostDevicetoken:string_pushtoken];
    
    
    [LTools cache:string_pushtoken ForKey:USER_DEVICE_TOKEN];
    
    //给服务器token
    
}

#pragma mark--把devicetoken给后台传过去

-(void)PostDevicetoken:(NSString*)thetoken{

    if (thetoken && thetoken.length > 10) {
        
        if ([thetoken isEqualToString:@"null"] || [thetoken isEqualToString:@"(null)"]) {
            thetoken = @"";
        }
        
        NSString *post = [NSString stringWithFormat:@"&devicetoken=%@&authcode=%@",thetoken,[GMAPI getAuthkey]];
        NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        NSString *url = [NSString stringWithFormat:POST_UPDATEMYINFO_URL];
        LTools *ccc = [[LTools alloc]initWithUrl:url isPost:YES postData:postData];
        [ccc requestCompletion:^(NSDictionary *result, NSError *erro) {
            
//            NSLog(@"devicetoken给后台传过去 thedic==%@",result);

            
        } failBlock:^(NSDictionary *failDic, NSError *erro) {
            
            NSLog(@"token发送失败 == %@",failDic);
            
        }];
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
//    NSString *str = [NSString stringWithFormat: @"Error: %@", error];
//    NSLog(@"远程注册 erro  %@",str);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
    NSLog(@"userinf==%@",userInfo);
    
//    userinf=={
//        aps =     {
//            alert = "\U56de\U590d GoodMor2012:eeee";
//            sound = default;
//            type = 6;
//        };
//    }
    
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateInactive){
        NSLog(@"UIApplicationStateInactive %@",userInfo);
        //点击消息进入走此处,做相应处理
        
        NSDictionary *aps = userInfo[@"aps"];
        
        [self dealMessageWithDictionary:aps];
        
    }
    if (state == UIApplicationStateActive) {
        NSLog(@"UIApplicationStateActive %@",userInfo);
        //程序就在前台
        
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_REMOTE_MESSAGE object:nil];
        
        NSDictionary *aps = userInfo[@"aps"];
//        NSString *alertMessage = aps[@"alert"];//消息内容
        
        self.remote_message = [NSDictionary dictionaryWithDictionary:aps];
        
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"消息提示" message:alertMessage delegate:self cancelButtonTitle:@"忽略" otherButtonTitles:@"查看", nil];
//        alert.tag = 300;
//        [alert show];
        
        int type = [aps[@"type"] intValue];
        
        if (type == 9 || type == 10){
            
            //店铺申请状态通知
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_SHENQINGDIANPU_STATE object:nil];
        }
        
    }
    if (state == UIApplicationStateBackground)
    {
        NSLog(@"UIApplicationStateBackground %@",userInfo);
    }
    
    

}

- (void)dealMessageWithDictionary:(NSDictionary *)aps
{
//    NSString *alert = aps[@"alert"];//消息内容
    int type = [aps[@"type"] intValue];
    //1 衣加衣通知消息 2 关注用户通知消息 3 回复主题消息 4 回复主题回复
    //5 回复T台通知消息 6 回复T台回复通知消息 7 品牌促销通知消息 8 商场促销通知
    // 9 申请店铺成功  10 申请店铺失败
    //11 修改活动
    //12关注商家通知消息
    
    
    if (type == 1) {
        
        [self pushToMessageDetail:Message_List_Yy];
        
    }else if (type == 2 || type == 3 || type == 4 || type == 5 || type == 6)
    {
        [self pushToMessageDetail:Message_List_Dynamic];
        
    }else if (type == 7 || type == 8){
        
        [self pushToMessageDetail:Message_List_Shop];
    }else if (type == 9 || type == 10){
        
        //店铺申请状态通知
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_SHENQINGDIANPU_STATE object:nil];
    }else if (type == 11){
        [self pushToMessageDetail:Message_List_Shop];
    }

}

/**
 *  推送消息跳转
 *
 *  @param aType 消息类型
 */

- (void)pushToMessageDetail:(Message_List_Type)aType
{
    self.rootViewController.selectedIndex = 2;
    
    MailMessageViewController *mail = [[MailMessageViewController alloc]init];
    mail.aType = aType;
    mail.hidesBottomBarWhenPushed = YES;
    
    UINavigationController *unVc = [self.rootViewController.viewControllers objectAtIndex:2];
    
    [unVc pushViewController:mail animated:YES];
}


#pragma mark 事件处理

#pragma - mark - 获取融云token -

- (void)loginToRongCloud
{
    [self loginToRoncloudUserId:[GMAPI getUid] userName:[GMAPI getUsername] userHeadImage:[GMAPI getUerHeadImageUrl]];
}

- (void)loginToRoncloudUserId:(NSString *)userId
                     userName:(NSString *)userName
                userHeadImage:(NSString *)headImage
{
    
    if (headImage.length == 0) {
        headImage = @"nnn";
    }
    
    NSString *url = [NSString stringWithFormat:RONCLOUD_GET_TOKEN,userId,userName,headImage];
    LTools *tool = [[LTools alloc]initWithUrl:url isPost:NO postData:nil];
    [tool requestCompletion:^(NSDictionary *result, NSError *erro) {
        
        NSLog(@"result %@",result);
        
        [LTools cache:result[@"token"] ForKey:RONGCLOUD_TOKEN];
        
        [self rongCloudDefaultLoginWithToken:result[@"token"]];
        
        
    } failBlock:^(NSDictionary *result, NSError *erro) {
        
        NSLog(@"获取融云token失败 %@",result);
        
        
    }];
}

/**
 *  聊天登录失败
 */
- (void)chatLoginFailInfo:(NSString *)errInfo
{
    UIAlertView *alert= [[UIAlertView alloc]initWithTitle:@"" message:errInfo delegate:self cancelButtonTitle:@"取消" otherButtonTitles: @"确定",nil];
    alert.tag = 2001;
    [alert show];
}

- (void)rongCloudDefaultLoginWithToken:(NSString *)loginToken
{
    //默认测试
    
    if (loginToken.length > 0) {
        
        [RCIM connectWithToken:loginToken completion:^(NSString *userId) {
            
            NSLog(@"------> rongCloud 登陆成功 %@",userId);
            
            [LTools cacheBool:YES ForKey:LOGIN_RONGCLOUD_STATE];
            
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_LOGIN object:nil];
            
        } error:^(RCConnectErrorCode status) {
           
            NSLog(@"------> rongCloud 登陆失败 %d",(int)status);
            
            [LTools cacheBool:NO ForKey:LOGIN_RONGCLOUD_STATE];
            
        }];
    }
}

/**
 *  监测融云连接状态
 */
-(void)rongCloudConnectionState{
    
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [[RCIM sharedRCIM] setConnectionStatusDelegate:nil];
}

#pragma mark - RCIMConnectionStatusDelegate <NSObject>

-(void)responseConnectionStatus:(RCConnectionStatus)status{
    if (ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT == status) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert= [[UIAlertView alloc]initWithTitle:@"" message:@"您已下线，重新连接？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles: @"确定",nil];
            alert.tag = 2000;
            [alert show];
        });
        
        [LTools cacheBool:NO ForKey:LOGIN_RONGCLOUD_STATE];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (2000 == alertView.tag) {
        
        if (0 == buttonIndex) {
            
        }
        
        if (1 == buttonIndex) {
            
            [RCIMClient reconnect:self];
        }
        
    }else if (300 == alertView.tag){ //推送消息
        
        if (0 == buttonIndex) {
            
        }
        
        if (1 == buttonIndex) {
            
            [self dealMessageWithDictionary:self.remote_message];
        }
    }
    
}

#pragma mark - ReConnectDelegate
/**
 *  回调成功。
 *
 *  @param userId 当前登录的用户 Id，既换取登录 Token 时，App 服务器传递给融云服务器的用户 Id。
 */
- (void)responseConnectSuccess:(NSString*)userId{
    
    NSLog(@"userId %@ rongCloud登录成功",userId);
    
    [LTools cacheBool:YES ForKey:LOGIN_RONGCLOUD_STATE];
}

/**
 *  回调出错。
 *
 *  @param errorCode 连接错误代码。
 */
- (void)responseConnectError:(RCConnectErrorCode)errorCode
{
    NSLog(@"rongCloud重新连接失败--- %d",(int)errorCode);
    
    [LTools cacheBool:NO ForKey:LOGIN_RONGCLOUD_STATE];

}



#pragma mark - RCIMReceiveMessageDelegate

-(void)didReceivedMessage:(RCMessage *)message left:(int)nLeft
{
    if (0 == nLeft) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber+1;
        });
    }
    
    [[RCIM sharedRCIM] invokeVoIPCall:self.window.rootViewController message:message];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_REMOTE_MESSAGE object:nil];

}



//融云回调 获取用户名 和 头像
#pragma mark - RCIMUserInfoFetcherDelegagte method

- (void)getUserInfoWithUserId:(NSString *)userId completion:(void(^)(RCUserInfo* userInfo))completion
{
    NSString *userName = [LTools rongCloudUserNameWithUid:userId];
    NSString *userIcon = [LTools rongCloudUserIconWithUid:userId];
    
    
    NSLog(@"userId %@",userId);
    NSLog(@"userIcon %@",userIcon);
    if ([userId isEqualToString:[GMAPI getUid]]) {
        
        userName = [GMAPI getUsername];
    }
    
    NSLog(@"----->|%@|",userName);
    
    //没有保存用户名 或者 更新时间超过一个小时
    if ([LTools isEmpty:userName] || [LTools isEmpty:userIcon]  || [LTools rongCloudNeedRefreshUserId:userId]) {
    
        NSString *url = [NSString stringWithFormat:GET_PERSONINFO_WITHID,userId];
        LTools *tool = [[LTools alloc]initWithUrl:url isPost:NO postData:nil];
        [tool requestCompletion:^(NSDictionary *result, NSError *erro) {
            
            NSString *name = @"";
            if ([[result objectForKey:@"mall_type"]intValue] == 1) {//商场店
                name = [NSString stringWithFormat:@"%@.%@",result[@"brand_name"],result[@"mall_name"]];
            }else if ([[result objectForKey:@"mall_type"]intValue] == 2){//精品店
                name = result[@"mall_name"];
            }else{
                name = result[@"user_name"];
            }
            
            NSString *icon = result[@"photo"];
            
            //不为空
            if (![LTools isEmpty:name]) {
                
                [LTools cacheRongCloudUserName:name forUserId:userId];
            }
            
            [LTools cacheRongCloudUserIcon:icon forUserId:userId];
            
            
            
            RCUserInfo *userInfo = [[RCUserInfo alloc]initWithUserId:userId name:name portrait:icon];
            
            return completion(userInfo);
            
        } failBlock:^(NSDictionary *failDic, NSError *erro) {
            
        }];
    }
    
    NSLog(@"userId %@ %@",userId,userName);
    
    RCUserInfo *userInfo = [[RCUserInfo alloc]initWithUserId:userId name:userName portrait:userIcon];
    
    return completion(userInfo);
}


@end

//
//  YIYIChatViewController.m
//  YiYiProject
//
//  Created by lichaowei on 14/12/26.
//  Copyright (c) 2014年 lcw. All rights reserved.
//

#import "YIYIChatViewController.h"
#import "RCIM.h"
#import "GchatSettingViewController.h"
#import "RCPreviewViewController.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"

#import "PreviewImageController.h" //浏览单张大图
#import "FBMapViewController.h"//地图显示位置

@implementation YIYIChatViewController
{
    BOOL _isPush;//是否要push
}


-(id)init{
    self = [super init];
    if (self) {
        self.GTitleLabel = [[UILabel alloc]init];
    }
    
    return self;
}



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    self.navigationController.navigationBarHidden = NO;
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:MY_MACRO_NAME?IOS7DAOHANGLANBEIJING_PUSH:IOS6DAOHANGLANBEIJING] forBarMetrics: UIBarMetricsDefault];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_isPush) {
        return;
    }
    
    [self.navigationController setNavigationBarHidden:self.lastPageNavigationHidden animated:animated];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _isPush = NO;
}


-(void)viewDidLoad
{
    [super viewDidLoad];

    [self addBackButtonWithTarget:self action:@selector(leftBarButtonItemPressed:)];
    
    UIView *titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH - 100, 44)];
    [self.GTitleLabel setFrame:titleView.bounds];
    self.GTitleLabel.textAlignment = NSTextAlignmentCenter;
    [titleView addSubview:self.GTitleLabel];
    self.GTitleLabel.textColor = [UIColor blackColor];
    self.navigationItem.titleView = titleView;
    
    
    
    //自定义导航左右按钮
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]initWithTitle:@"设置" style:UIBarButtonItemStyleBordered target:self action:@selector(rightBarButtonItemPressed:)];
    [rightButton setTintColor:RGBCOLOR(255, 78, 139)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    
    if (self.isProductDetailVcPush) {
        //发送产品图文链接
        [self sendProductDetailMessage];
    }else
    {
        self.GTitleLabel.text = self.currentTargetName;
    }
    
    //设置点击跳转
    [self setDetailMessageViewClickedBlock];
}


-(void)rightBarButtonItemPressed:(id)sender{
    GchatSettingViewController *temp = [[GchatSettingViewController alloc]init];
    temp.HeadsPadView.hidden = YES;
    temp.targetId = self.currentTarget;
    temp.conversationType = self.conversationType;
    temp.portraitStyle = RCUserAvatarCycle;
    [self.navigationController pushViewController:temp animated:YES];
}


//发送产品图文链接
-(void)sendProductDetailMessage{
    
    if (self.orderInfo) {
        
        
    }
    
    if (!self.theModel) {
        return;
    }
    RCRichContentMessage *message = [[RCRichContentMessage alloc] init];
    message.title = self.theModel.product_name;
    NSString *zhekou = [NSString stringWithFormat:@"%.1f折",self.theModel.discount_num * 10];
    message.digest = [NSString stringWithFormat:@"  现价：%@元\n  折扣：%@\n  标签：%@",self.theModel.product_price,zhekou,self.theModel.product_tag];
    message.imageURL = self.theModel.product_tag;
    NSArray *imageArray = self.theModel.images;
    if (imageArray.count>0) {
        NSDictionary *dic = imageArray[0];
        message.imageURL = dic[@"540Middle"][@"src"];
    }
    
    message.extra = self.theModel.product_id;
    
//    [[RCIM sharedRCIM]sendRichContentMessage:self.conversationType
//                                    targetId:self.currentTarget
//                          richContentMessage:message
//                                    delegate:self
//                                      object:self];
    
    
    
    [self sendRichContentMessage:message];
    
}




//设置消息框点击跳转
-(void)setDetailMessageViewClickedBlock{
    
    __weak typeof (self)bself = self;
    
    [self setMessageTapHandler:^(RCMessage *message){
        
        [bself pushToProductDetailVcWithMessage:message];
    }];
    
    
}

-(void)pushToProductDetailVcWithMessage:(RCMessage*)message{
    
    RCRichContentMessage *ccc = (RCRichContentMessage*)message.content;
    NSDictionary *params = @{@"isYYChat":[NSNumber numberWithBool:YES]};
    [MiddleTools pushToProductDetailWithId:ccc.extra fromViewController:self lastNavigationHidden:NO hiddenBottom:YES extraParams:params updateBlock:nil];
}

/**
 *  点击聊天小图看大图
 *
 *  @param rcMessage 图片消息
 */
-(void)showPreviewPictureController:(RCMessage*)rcMessage{
    
    
    RCMessageContent *content = rcMessage.content;
    
    if ([content isKindOfClass:[RCImageMessage class]]) {
        
        RCImageMessage *imageMessage = (RCImageMessage *)content;
        
//        [self tapImageUrl:imageMessage.imageUrl];
        
//        FBPhotoBrowserController *browser = [[FBPhotoBrowserController alloc]init];
//        browser.showIndex = 0;
//        browser.imagesArray = @[imageMessage.imageUrl];
        
        
        PreviewImageController *browser = [[PreviewImageController alloc]init];
        browser.imageUrl = imageMessage.imageUrl;
        browser.thumImage = imageMessage.thumbnailImage;
        
        LNavigationController *ll = [[LNavigationController alloc]initWithRootViewController:browser];
        
        [self presentViewController:ll animated:YES completion:nil];
    }
}

/**
 *  进入地图位置
 *
 *  @param location
 *  @param locationName 地点名
 */
- (void)openLocation:(CLLocationCoordinate2D)location locationName:(NSString *)locationName {
    
    FBMapViewController * mapViewController = [[FBMapViewController alloc] init];
    mapViewController.address_title = locationName;
    mapViewController.address_latitude = location.latitude;
    mapViewController.address_longitude = location.longitude;
    
    [self.navigationController pushViewController:mapViewController animated:YES];
}

- (void)openLocationPicker:(id)sender
{
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"black"] forBarMetrics: UIBarMetricsDefault];
    
//    self.navigationController.delegate = self;
    
    _isPush = YES;
    [super openLocationPicker:sender];
 
    
}

@end

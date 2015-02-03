//
//  MessageListController.m
//  YiYiProject
//
//  Created by lichaowei on 15/1/25.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "MessageListController.h"
#import "RCIM.h"
#import "RCIMClient.h"

#import "MessageViewCell.h"
#import "MailMessageViewController.h"

#import "MessageModel.h"

#import "MessageViewController.h"


@interface MessageListController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_table;
    NSArray *arr_images;
    NSArray *arr_titles;
    
    MessageModel *yiyi_model;//衣+衣 消息
    MessageModel *shop_model;//商家消息
    MessageModel *other_model;//动态消息
    MessageModel *mes_model;//即时消息
}

@end

@implementation MessageListController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    int rong_num = [[RCIM sharedRCIM] getTotalUnreadCount];
    
    if (rong_num > 0 ) {
        
        [self setMesModelWithInfo:@"您有未读消息" num:rong_num];
    }else
    {
        [self setMesModelWithInfo:nil num:0];
    }
    
    [_table reloadData];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.myTitleLabel.text = @"消息";
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateHotpoint:) name:NOTIFICATION_CANCEL_HOTPOINT object:Nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateRemoteMessage:) name:NOTIFICATION_REMOTE_MESSAGE object:nil];
    
    arr_images = @[@"yixx150_150",@"sjxx150_150",@"my_shoucang",@"my_shenqing"];
    arr_titles = @[@"衣+衣团队",@"商家消息",@"动态消息",@"聊天消息"];
    
    _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64) style:UITableViewStylePlain];
    _table.delegate = self;
    _table.dataSource = self;
    _table.scrollEnabled = NO;
    [self.view addSubview:_table];
    
    [self getMyMessage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 推送消息

- (void)updateRemoteMessage:(NSNotification *)notification
{
    //获取消息
    [self getMyMessage];
}

- (void)setMesModelWithInfo:(NSString *)info num:(int)unreadNum
{
    if (mes_model == nil) {
        
        mes_model = [[MessageModel alloc]init];
    }
    mes_model.latest_msg_content = info;
    mes_model.unread_msg_num = unreadNum;
    mes_model.latest_msg_time = [LTools timechangeToDateline];
}

#pragma mark - 网络请求

- (void)getMyMessage
{
    __weak typeof(self)weakSelf = self;
    
    NSString *key = [GMAPI getAuthkey];
    
    NSString *url = [NSString stringWithFormat:MESSAGE_GET_MINE,key];
    LTools *tool = [[LTools alloc]initWithUrl:url isPost:NO postData:nil];
    [tool requestCompletion:^(NSDictionary *result, NSError *erro) {
        NSLog(@"result %@",result);
        
        if ([LTools isDictinary:result]) {
            
            yiyi_model = [[MessageModel alloc]initWithDictionary:[result objectForKey:@"yy_msg"]];
            shop_model = [[MessageModel alloc]initWithDictionary:[result objectForKey:@"shop_msg"]];
            other_model = [[MessageModel alloc]initWithDictionary:[result objectForKey:@"dynamic_msg"]];
            
            [weakSelf updateTabbarNumber:[self unreadMessgeNum]];
            
            [_table reloadData];
        }
        
        
    } failBlock:^(NSDictionary *failDic, NSError *erro) {
        
        
    }];
}

#pragma mark - 事件处理

//更新红点
- (void)updateHotpoint:(NSNotification *)notification
{
    NSLog(@"updateHotpoint %@ %@",notification.userInfo,notification.object);
    
    NSString *type = notification.object;
    if ([type isEqualToString:@"yy"]) {
        
        yiyi_model.unread_msg_num = 0;
        
    }else if ([type isEqualToString:@"shop"]){

        shop_model.unread_msg_num = 0;
        
    }else if ([type isEqualToString:@"dynamic"]){
        
        other_model.unread_msg_num = 0;
    }
    
    [self updateTabbarNumber:[self unreadMessgeNum]];
    
    [_table reloadData];
}

/**
 *  获取未读消息条数
 */
- (int)unreadMessgeNum
{
    int sum = 0;
    
    int rong_num = [[RCIM sharedRCIM] getTotalUnreadCount];
    
    if (rong_num <= 0) {
        rong_num = 0;
    }
    
    sum = yiyi_model.unread_msg_num + shop_model.unread_msg_num + other_model.unread_msg_num + rong_num;
    
    return sum;
}

/**
 *  更新未读消息显示
 *
 *  @param number 未读数
 */
- (void)updateTabbarNumber:(int)number
{
    NSString *number_str = nil;
    if (number > 0) {
        number_str = [NSString stringWithFormat:@"%d",number];
    }
    
    self.navigationController.tabBarItem.badgeValue = number_str;
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = [number_str intValue];
}

#pragma - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

/**
 *  衣加衣团队
 */
- (void)tapToYIJiaYi:(UITapGestureRecognizer *)tap
{
    NSLog(@"衣加衣团队");
    MailMessageViewController *mail = [[MailMessageViewController alloc]init];
    mail.aType = Message_Yy;
    mail.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:mail animated:YES];
}

/**
 *  商家消息
 */
- (void)tapToMail:(UITapGestureRecognizer *)tap
{
    NSLog(@"商家消息");
    MailMessageViewController *mail = [[MailMessageViewController alloc]init];
    mail.aType = Message_Shop;
    mail.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:mail animated:YES];
}

/**
 *  衣加衣团队
 */
- (void)tapToDynamic:(UITapGestureRecognizer *)tap
{
    NSLog(@"动态消息");
    MailMessageViewController *mail = [[MailMessageViewController alloc]init];
    mail.aType = Message_Dynamic;
    mail.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:mail animated:YES];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 3) {
        
        MessageViewController *message = [[MessageViewController alloc]init];
        message.only_rongcloud = YES;
        message.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:message animated:YES];
        
        return;
    }
    
    Message_Type aType;
    if (indexPath.row == 0) {
        aType = Message_Yy;

    }else if (indexPath.row == 1){

        aType = Message_Shop;
        
    }else if (indexPath.row == 2){
        
        aType = Message_Dynamic;
    }
    
    MailMessageViewController *mail = [[MailMessageViewController alloc]init];
    mail.aType = aType;
    mail.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:mail animated:YES];
}

#pragma - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *identify = @"MessageViewCell";
    MessageViewCell *cell = (MessageViewCell *)[LTools cellForIdentify:identify cellName:identify forTable:tableView];
    cell.iconImageView.image = [UIImage imageNamed:arr_images[indexPath.row]];
    cell.nameLabel.text = arr_titles[indexPath.row];
    cell.clickButton.userInteractionEnabled = NO;
    if (indexPath.row == 0) {
        
        [cell setCellWithModel:yiyi_model placeHolder:@"欢迎使用!"];
    }else if (indexPath.row == 1){
        [cell setCellWithModel:shop_model placeHolder:@"您关注的商家没有最新消息!"];
    }else if (indexPath.row == 2){
        
        [cell setCellWithModel:other_model placeHolder:@"暂时没有动态消息!"];

    }else if (indexPath.row == 3){
        [cell setCellWithModel:mes_model placeHolder:@"暂时没有消息!"];
    }
    
    return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.5;
}

@end

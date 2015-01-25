//
//  MailMessageViewController.m
//  YiYiProject
//
//  Created by lichaowei on 15/1/14.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "MailMessageViewController.h"
#import "RefreshTableView.h"

#import "MailMessageCell.h"

#import "MessageDetailController.h"

@interface MailMessageViewController ()<RefreshDelegate,UITableViewDataSource>
{
    RefreshTableView *_table;
}
@end

@implementation MailMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (self.aType == Message_Yy) {
        
        self.myTitleLabel.text = @"衣+衣团队消息";
        
    }else if (self.aType == Message_Shop){
        
        self.myTitleLabel.text = @"商家消息";

        
    }else if (self.aType == Message_Dynamic){
        
        self.myTitleLabel.text = @"动态消息";
    }
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    _table = [[RefreshTableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH,DEVICE_HEIGHT - 64)];
    _table.refreshDelegate = self;
    _table.dataSource = self;
    [self.view addSubview:_table];
    _table.backgroundColor = [UIColor colorWithHexString:@"f2f2f2"];
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [_table showRefreshHeader:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 网络请求

//action= yy(衣加衣) shop（商家） dynamic（动态）
- (void)getMailInfo
{
    NSString *key = [GMAPI getAuthkey];
    
    NSString *type;
    if (self.aType == Message_Yy) {
        type = @"yy";
    }else if (self.aType == Message_Shop){
        type = @"shop";
    }else if (self.aType == Message_Dynamic){
        type = @"dynamic";
    }
    
    NSString *url = [NSString stringWithFormat:MESSAGE_GET_LIST,type,key];
    LTools *tool = [[LTools alloc]initWithUrl:url isPost:NO postData:nil];
    [tool requestCompletion:^(NSDictionary *result, NSError *erro) {
        NSLog(@"");
        
        NSArray *data = result[@"data"];
        
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:data.count];
        for (NSDictionary *aDic in data) {
            MessageModel *aModel = [[MessageModel alloc]initWithDictionary:aDic];
            [arr addObject:aModel];
        }
        [_table reloadData:arr isHaveMore:NO];
        
        
    } failBlock:^(NSDictionary *failDic, NSError *erro) {
        
        
    }];
}

#pragma mark - RefreshDelegate

- (void)loadNewData
{
    [self getMailInfo];
}
- (void)loadMoreData
{
    
}

//新加
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    NSLog(@"详情");
    MessageModel *aModel = _table.dataArray[indexPath.row];
    MessageDetailController *detail = [[MessageDetailController alloc]init];
    detail.msg_id = aModel.msg_id;
    [self.navigationController pushViewController:detail animated:YES];
    
}
- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    MessageModel *aModel = _table.dataArray[indexPath.row];
    return [MailMessageCell heightForModel:aModel cellType:icon_Yes seeAll:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _table.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"MailMessageCell";
    MailMessageCell *cell = (MailMessageCell *)[LTools cellForIdentify:identify cellName:identify forTable:tableView];
    
    MessageModel *aModel = _table.dataArray[indexPath.row];
    [cell setCellWithModel:aModel cellType:icon_Yes seeAll:YES];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}


@end

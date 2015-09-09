//
//  GChooseAdrOfBjViewController.m
//  YiYiProject
//
//  Created by gaomeng on 15/9/8.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "GChooseAdrOfBjViewController.h"

@interface GChooseAdrOfBjViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tab;
    NSArray *_p_c_list;
    
}
@end

@implementation GChooseAdrOfBjViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    self.myTitle = @"选择地址";
    
    [self creatTab];
    [self prepareNetData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}


#pragma mark - MyMethod

-(void)prepareNetData{
    
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    LTools *tt = [[LTools alloc]initWithUrl:GET_ADRESS_BJ isPost:NO postData:nil];
    [tt requestCompletion:^(NSDictionary *result, NSError *erro) {
        
        _p_c_list = [result arrayValueForKey:@"p_c_list"];
        [_tab reloadData];
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    } failBlock:^(NSDictionary *result, NSError *erro) {
        
    }];
}

-(void)creatTab{
    _tab = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT-64) style:UITableViewStylePlain];
    _tab.delegate = self;
    _tab.dataSource = self;
    [self.view addSubview:_tab];
}

#pragma mark - UITableViewDataSource && UITableViewDelegate

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
    }
    
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    
    NSArray *children = [_p_c_list[indexPath.section] arrayValueForKey:@"children"];
    NSDictionary *dic = children[indexPath.row];
    NSString *name = [dic stringValueForKey:@"name"];
    cell.textLabel.text = name;
    [cell.textLabel setFont:[UIFont systemFontOfSize:14]];
    
    return cell;
    
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *children = [_p_c_list[section] arrayValueForKey:@"children"];
    return children.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _p_c_list.count;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 40)];
    view.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.2];
    UILabel *tLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, DEVICE_WIDTH-12, 40)];
    NSDictionary *dic = _p_c_list[section];
    NSString *name = [dic stringValueForKey:@"name"];
    tLabel.text = name;
    tLabel.font = [UIFont systemFontOfSize:15];
    [view addSubview:tLabel];
    return view;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //省份
    NSDictionary *provinceDic = _p_c_list[indexPath.section];
    NSString *provinceName = [provinceDic stringValueForKey:@"name"];
    NSString *provinceId = [provinceDic stringValueForKey:@"id"];
    NSArray *children = [provinceDic arrayValueForKey:@"children"];
    
    //城市
    NSDictionary *cityDic = children[indexPath.row];
    NSString *cityName = [cityDic stringValueForKey:@"name"];
    NSString *cityId = [cityDic stringValueForKey:@"id"];
    
    NSDictionary *params = @{@"provinceId":provinceId,
                             @"provinceName":provinceName,
                             @"cityId":cityId,
                             @"cityName":cityName};
    if (self.updateParamsBlock) {
        self.updateParamsBlock(params);
    }
    
    [self performSelector:@selector(leftButtonTap:) withObject:nil afterDelay:0.3];
}


@end

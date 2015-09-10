//
//  GChooseColorAndSizeViewController.m
//  YiYiProject
//
//  Created by gaomeng on 15/9/8.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "GChooseColorAndSizeViewController.h"
#import "GChooseColorSizeTableViewCell.h"

@interface GChooseColorAndSizeViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tab;
    NSArray *_dataArray;
}
@end

@implementation GChooseColorAndSizeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    self.myTitle = @"颜色尺码选择";
    
    [self creatTab];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - MyMethod

-(void)creatTab{
    _tab = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT) style:UITableViewStylePlain];
    _tab.delegate = self;
    _tab.dataSource = self;
    [self.view addSubview:_tab];
}

-(void)prepareNetData{
    if (self.productModelArray.count>0) {
        NSMutableArray *idsArray = [NSMutableArray arrayWithCapacity:1];
        for (ProductModel *model in self.productModelArray) {
            [idsArray addObject:model.product_id];
        }
        NSString *theIds =[idsArray componentsJoinedByString:@","];
        
        NSString *url = [NSString stringWithFormat:@"%@&product_ids=%@",CHOOSE_COLORANDSIZE,theIds];
        
        LTools *cc = [[LTools alloc]initWithUrl:url isPost:NO postData:nil];
        [cc requestCompletion:^(NSDictionary *result, NSError *erro) {
            _dataArray = [result arrayValueForKey:@"attr"];
            [_tab reloadData];
        } failBlock:^(NSDictionary *result, NSError *erro) {
            
        }];
        
        
    }else{
        
    }
}



#pragma mark - UITableViewDelegate && UITableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"identifier";
    GChooseColorSizeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[GChooseColorSizeTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    NSDictionary *dic = _dataArray[indexPath.row];
    ProductModel *model = self.productModelArray[indexPath.row];
    [cell loadCustomViewWithIndexPath:indexPath netDatamodel:dic productModel:model];
    
    
    
    return cell;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 250;
}








@end

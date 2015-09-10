//
//  HomeClothViewController.m
//  YiYiProject
//
//  Created by lichaowei on 14/12/12.
//  Copyright (c) 2014年 lcw. All rights reserved.
//

#import "HomeClothController.h"
#import "GCycleScrollView.h"
#import "GnearbyStoreViewController.h"
#import "NSDictionary+GJson.h"
#import "GScrollView.h"
#import "GpinpaiDetailViewController.h"
#import "GnearbyStoreViewController.h"
#import "GClothWaveCustomView.h"
#import "LoginViewController.h"

#import "LRefreshTableHeaderView.h"

#import "GStorePinpaiViewController.h"
#import "GwebViewController.h"
#import "MessageDetailController.h"
#import "GsearchViewController.h"

#import "RefreshTableView.h"
#import "GnearbyStoreTableViewCell.h"

//测试
#import "GChooseColorAndSizeViewController.h"//颜色尺码选择
#import "GChooseAdrOfBjViewController.h"//选择地区

@interface HomeClothController ()<RefreshDelegate,UITableViewDataSource,GgetllocationDelegate,UISearchBarDelegate>
{
    
    
    RefreshTableView *_tableView;//主tableview
    
    //定位相关
    NSDictionary *_locationDic;
    
    
    NSMutableArray *_nearByStoreDataArray;//缓存数据
    
    
    //网络请求类
    LTools *_dd;

}
@end

@implementation HomeClothController


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:YES];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0))
    {
        self.navigationController.navigationBar.translucent = NO;
    }
}

- (void)dealloc
{
    _tableView.refreshDelegate = nil;
    _tableView.dataSource = nil;
    _tableView = nil;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //精选
    
    self.view.backgroundColor = RGBCOLOR(235, 235, 235);
    
    _tableView = [[RefreshTableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT-64)];
    _tableView.refreshDelegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_tableView];
    
    //添加滑动到顶部按钮
    [self addScroll:_tableView topButtonPoint:CGPointMake(DEVICE_WIDTH - 40 - 10, DEVICE_HEIGHT - 10 - 40 - 49 - 64)];
    
    //先走缓存
    NSDictionary *dic = [GMAPI getHomeClothCacheOfNearStore];
    NSArray *arr = [dic arrayValueForKey:@"list"];
    if (arr.count) {
        
        [_tableView reloadData:arr pageSize:L_PAGE_SIZE];

    }
    //网络请求,先定位
    [self performSelector:@selector(prepareNetData) withObject:[NSNumber numberWithBool:YES] afterDelay:0.1];
    
}

#pragma mark - 请求网络数据
-(void)prepareNetData{
    
    [_tableView showRefreshHeader:YES];
}

#pragma mark - 获取经纬度
-(void)getjingweidu{
//    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
//    if (kCLAuthorizationStatusRestricted == status) {
//        NSLog(@"kCLAuthorizationStatusRestricted 开启定位失败");
//        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提示" message:@"开启定位失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [al show];
//        return;
//    }else if (kCLAuthorizationStatusDenied == status){
//        NSLog(@"请允许衣加衣使用定位服务");
//        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请允许衣加衣使用定位服务" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [al show];
//        return;
//    }
    
    __weak typeof(self)weakSelf = self;
    
    [[GMAPI appDeledate]startDingweiWithBlock:^(NSDictionary *dic) {
        
        [weakSelf theDelegateLocationDictionary:dic];
    }];
}

- (void)theDelegateLocationDictionary:(NSDictionary *)dic{
    
    NSLog(@"%@",dic);
    _locationDic = dic;
    [LTools cache:dic ForKey:CACHE_THELOCATION];
    
    [self prepareNearbyStore];
}


#pragma mark - RefreshDelegate

- (void)loadNewData
{
    [self getjingweidu];
}
- (void)loadMoreData
{
    
    [self getjingweidu];
}

//点击
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
//    NSLog(@"%s",__FUNCTION__);
//    NSLog(@"%ld",(long)indexPath.row);
//    
//    NSDictionary *dic = _tableView.dataArray [indexPath.row];
//    NSString *storeId = [dic stringValueForKey:@"mall_id"];
//    NSString *mallType = [dic stringValueForKey:@"mall_type"];
//    NSString *storeName = [dic stringValueForKey:@"mall_name"];
//    [self pushToNearbyStoreVCWithIdStr:storeId theStoreName:storeName theType:mallType];
    
    GChooseColorAndSizeViewController *aa = [[GChooseColorAndSizeViewController alloc]init];
    aa.hidesBottomBarWhenPushed = YES;
    
//    GChooseAdrOfBjViewController *aa = [[GChooseAdrOfBjViewController alloc]init];
//    aa.hidesBottomBarWhenPushed = YES;
    
    [self.rootViewController.navigationController pushViewController: aa animated:YES];
    
    
    
}
- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    return DEVICE_WIDTH*375.0/621;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _tableView.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"identifier";
    GnearbyStoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[GnearbyStoreTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    NSDictionary *dic = _tableView.dataArray[indexPath.row];
    [cell loadCustomViewWithModel:dic];
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.backgroundColor = RGBCOLOR(235, 235, 235);
    
    
    return cell;
    
}



//请求附近的商店
-(void)prepareNearbyStore{
    
    if (!_locationDic) {
        NSLog(@"默认经纬度");
        _locationDic = @{
                         @"lat":[NSString stringWithFormat:@"%f",40.041951],
                         @"long":[NSString stringWithFormat:@"%f",116.33934]
                        };
    }
    
    NSString *lon = [_locationDic stringValueForKey:@"long"];
    NSString *lat = [_locationDic stringValueForKey:@"lat"];
    
    NSString *api = [NSString stringWithFormat:@"%@&long=%@&lat=%@&page=%d&count=%d",HOME_CLOTH_NEARBYSTORE,lon,lat,_tableView.pageNum,L_PAGE_SIZE];
    
    if (_dd) {
        [_dd cancelRequest];
    }
    _dd = [[LTools alloc]initWithUrl:api isPost:YES postData:nil];
    [_dd requestCompletion:^(NSDictionary *result, NSError *erro) {

        if ([[result stringValueForKey:@"errorcode"]intValue] == 0) {
            NSArray *arr = [result objectForKey:@"list"];
            if (_tableView.pageNum == 1) {
                [GMAPI cleanHomeClothCacheOfNearStore];
                [GMAPI setHomeClothCacheOfNearStoreWithDic:result];
            }
            [_tableView reloadData:arr pageSize:L_PAGE_SIZE];
            
        }else{
            [_tableView loadFail];
        }
        
    } failBlock:^(NSDictionary *failDic, NSError *erro) {
        
        [_tableView loadFail];
    }];
    
}


-(void)pushToNearbyStoreVCWithIdStr:(NSString *)theID theStoreName:(NSString *)nameStr theType:(NSString *)mallType{
    if ([mallType intValue]==2) {//精品店
        
        GStorePinpaiViewController *cc = [[GStorePinpaiViewController alloc]init];
        cc.storeIdStr = theID;
        cc.storeNameStr = nameStr;
        cc.guanzhuleixing = @"精品店";
        cc.hidesBottomBarWhenPushed = YES;
        [self.rootViewController.navigationController pushViewController:cc animated:YES];
        
        
    }else if ([mallType intValue] ==3){//品牌店
        GStorePinpaiViewController *cc = [[GStorePinpaiViewController alloc]init];
        cc.storeIdStr = theID;
        cc.storeNameStr = nameStr;
        cc.guanzhuleixing = @"品牌店";
        cc.hidesBottomBarWhenPushed = YES;
        [self.rootViewController.navigationController pushViewController:cc animated:YES];
    }else if ([mallType intValue] == 1){//商场
        GnearbyStoreViewController *dd = [[GnearbyStoreViewController alloc]init];
        dd.storeIdStr = theID;
        dd.storeNameStr = nameStr;
        NSLog(@"%@",mallType);
        dd.hidesBottomBarWhenPushed = YES;
        [self.rootViewController.navigationController pushViewController:dd animated:YES];
    }
    
}





@end

//
//  ChooseImageViewController.m
//  YiYiProject
//
//  Created by unisedu on 15/1/8.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "ChooseImageViewController.h"

@interface ChooseImageViewController ()
{
    NSMutableArray *_dataSourceArray;
}
@end

@implementation ChooseImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden=NO;
    NSArray *clothesArray = (NSArray *)[sourceDic objectForKey:@"clothes"];
    long count = clothesArray.count;
    self.myTitle = [NSString stringWithFormat:@"%@(%ld)",[sourceDic objectForKey:@"sort_name"],count];
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    self.view.backgroundColor = [UIColor whiteColor];
    
    waterFlow = [[LWaterflowView alloc]initWithFrame:CGRectMake(0, 0, ALL_FRAME_WIDTH, ALL_FRAME_HEIGHT - 44) waterDelegate:self waterDataSource:self];
    waterFlow.backgroundColor = RGBCOLOR(235, 235, 235);
    [self.view addSubview:waterFlow];
    [self getNetData];
}
-(void)getNetData
{
    NSString *api = [NSString stringWithFormat:GET_CLASSICATIONCLOTHES_URL,[sourceDic objectForKey:@"sort_id"],[GMAPI getAuthkey]];
    
    NSLog(@"api===%@",api);
    LTools *gg = [[LTools alloc]initWithUrl:api isPost:NO postData:nil];
    [gg requestCompletion:^(NSDictionary *result, NSError *erro) {
        
        if(result && [[result objectForKey:@"errorcode"] integerValue] == 0)
        {
            _dataSourceArray = [result objectForKey:@"list"];
        }
       [waterFlow reloadData:_dataSourceArray total:100];
        NSLog(@"%@",result);
        
    } failBlock:^(NSDictionary *failDic, NSError *erro) {
        NSLog(@"%@",failDic);
        
    }];
}
#pragma mark - WaterFlowDelegate

- (void)waterLoadNewData
{
    
}
- (void)waterLoadMoreData
{
    
}

- (void)waterDidSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *currentDic = waterFlow.dataArray[indexPath.row];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addImag" object:currentDic];
}

- (CGFloat)waterHeightForCellIndexPath:(NSIndexPath *)indexPath
{
    return (DEVICE_WIDTH-5*10)/4;
}
- (CGFloat)waterViewNumberOfColumns
{
    return 4;
}

#pragma mark - TMQuiltViewDataSource

- (NSInteger)quiltViewNumberOfCells:(TMQuiltView *)TMQuiltView {
    
    return [waterFlow.dataArray count];
}

- (TMQuiltViewCell *)quiltView:(TMQuiltView *)quiltView cellAtIndexPath:(NSIndexPath *)indexPath
{
    TMQuiltViewCell *cell = (TMQuiltViewCell *)[quiltView dequeueReusableCellWithReuseIdentifier:@"PhotoCell"];
    if (!cell) {
        cell = [[TMQuiltViewCell alloc] initWithReuseIdentifier:@"PhotoCell"];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,  (DEVICE_WIDTH-5*10)/4,  (DEVICE_WIDTH-5*10)/4)];
        imageView.tag = 1001;
        imageView.backgroundColor = RGBCOLOR(180, 180, 180);
        [cell addSubview:imageView];
        
    }
    cell.layer.cornerRadius = 3.f;
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:1001];
    [imageView sd_setImageWithURL:[NSURL URLWithString:[[_dataSourceArray objectAtIndex:indexPath.row] objectForKey:@"image_url"]] placeholderImage:nil];
    NSLog(@".......%@",[[_dataSourceArray objectAtIndex:indexPath.row] objectForKey:@"image_url"]);
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

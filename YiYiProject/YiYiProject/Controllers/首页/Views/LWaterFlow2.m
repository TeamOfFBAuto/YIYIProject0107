//
//  LWaterFlow2.m
//  YiYiProject
//
//  Created by lichaowei on 15/8/19.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "LWaterFlow2.h"

#define NORMAL_TEXT @"上拉加载更多"
#define NOMORE_TEXT @"没有更多数据"

#define TABLEFOOTER_HEIGHT 50.f

@implementation LWaterFlow2

- (void)dealloc
{
    qtmquitView.collectionViewDataSource = nil;
    qtmquitView.collectionViewDelegate = nil;
    _refreshFooterView = nil;
    _refreshHeaderView = nil;
}

- (void)reloadData
{
    [qtmquitView reloadData];
}

/**
 *  滑动到顶部
 */
- (void)scrollToTop
{
    [qtmquitView setContentOffset:CGPointZero animated:YES];
}

-(instancetype)initWithFrame:(CGRect)frame
               waterDelegate:(id<PSWaterFlowDelegate>)waterDelegate
             waterDataSource:(id<PSCollectionViewDataSource>)waterDatasource
              noHeadeRefresh:(BOOL)noHeaderRefresh
             noFooterRefresh:(BOOL)noFooterRefresh

{
    self = [super initWithFrame:frame];
    if (self) {
        self.pageNum = 1;
        self.dataArray = [NSMutableArray array];
        
        qtmquitView = [[PSCollectionView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        qtmquitView.collectionViewDelegate = self;
        qtmquitView.collectionViewDataSource = waterDatasource;
        qtmquitView.delegate = self;
        self.waterDelegate = waterDelegate;
        
//        qtmquitView.backgroundColor = [UIColor orangeColor];
        
        qtmquitView.numColsLandscape = 3;
        qtmquitView.numColsPortrait = 2;
        
        self.quitView = qtmquitView;
        
        [self addSubview:qtmquitView];
        
        if (noHeaderRefresh == NO) {
            
            [self createHeaderView];
        }
        
        _noloadView = noFooterRefresh;
        
    }
    return self;
}


//成功加载
- (void)reloadData:(NSArray *)data pageSize:(int)pageSize
{
    self.isHaveMoreData = (data.count >= pageSize ? YES : NO);
    
    if (self.isReloadData) {
        
        [self.dataArray removeAllObjects];
        
    }
    [self.dataArray addObjectsFromArray:data];
    
    [self performSelector:@selector(testFinishedLoadData) withObject:nil afterDelay:0];
}


//成功加载
- (void)reloadData:(NSArray *)data isHaveMore:(BOOL)isHaveMore
{
    self.isHaveMoreData = isHaveMore;
    
    if (self.isReloadData) {
        
        [self.dataArray removeAllObjects];
        
    }
    [self.dataArray addObjectsFromArray:data];
    
    [self performSelector:@selector(testFinishedLoadData) withObject:nil afterDelay:0];
}

//成功加载
- (void)reloadData:(NSArray *)data total:(int)totalPage
{
    if (self.pageNum < totalPage) {
        
        self.isHaveMoreData = YES;
    }else
    {
        self.isHaveMoreData = NO;
    }
    
    if (self.isReloadData) {
        
        [self.dataArray removeAllObjects];
        
    }
    [self.dataArray addObjectsFromArray:data];
    
    [self performSelector:@selector(testFinishedLoadData) withObject:nil afterDelay:0];
}

//请求数据失败

- (void)loadFail
{
    if (self.isLoadMoreData) {
        self.pageNum --;
    }
    [self performSelector:@selector(testFinishedLoadData) withObject:nil afterDelay:0];
    
}

//＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
#pragma - mark 初始化刷新视图
//＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝

#pragma mark
#pragma methods for creating and removing the header view

-(void)setHeaderView:(UIView *)headerView
{
    _headerView = headerView;
    
    _quitView.headerView = headerView;
    
    [_quitView reloadData];
}

-(void)createHeaderView{
    if (_refreshHeaderView && [_refreshHeaderView superview]) {
        [_refreshHeaderView removeFromSuperview];
    }
    _refreshHeaderView = [[LRefreshTableHeaderView alloc] initWithFrame:
                          CGRectMake(0.0f, 0.0f - self.bounds.size.height,
                                     self.frame.size.width, self.bounds.size.height)];
    _refreshHeaderView.delegate = self;
    
    [qtmquitView addSubview:_refreshHeaderView];
    
    _refreshHeaderView.backgroundColor = [UIColor clearColor];
    
    [_refreshHeaderView refreshLastUpdatedDate];
}

-(void)removeHeaderView
{
    if (_refreshHeaderView && [_refreshHeaderView superview]) {
        [_refreshHeaderView removeFromSuperview];
    }
    _refreshHeaderView = Nil;
}

-(void)testFinishedLoadData{
    
    [self removeFooterView];
    [self finishReloadingData];
    
    //如果有更多数据，重新设置footerview  frame
    
    if (_noloadView == NO) {
        
        [self createFooterView];
        
    }
    
    if (self.isHaveMoreData)
    {
        [self stopLoading:1];
        
    }else {
        
        [self stopLoading:2];
    }
}

- (void)finishReloadingData{
    
    //  model should call this when its done loading
    _reloading = NO;
    
    if (_refreshHeaderView) {
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:qtmquitView];
        
        self.isReloadData = NO;
    }
    
    if (_refreshFooterView) {
        [_refreshFooterView egoRefreshScrollViewDataSourceDidFinishedLoading:qtmquitView];
        [self setFooterView];
    }
    
    // overide, the actula reloading tableView operation and reseting position operation is done in the subclass
    [qtmquitView reloadData];
}


-(void)setFooterView{
    //    UIEdgeInsets test = self.aoView.contentInset;
    // if the footerView is nil, then create it, reset the position of the footer
    CGFloat height = MAX(qtmquitView.contentSize.height, qtmquitView.frame.size.height + self.headerView.height);
    if (_refreshFooterView && [_refreshFooterView superview])
    {
        // reset position
        _refreshFooterView.frame = CGRectMake(0.0f,
                                              height,
                                              qtmquitView.frame.size.width,
                                              self.bounds.size.height);
    }else
    {
        // create the footerView
        _refreshFooterView = [[EGORefreshTableFooterView alloc] initWithFrame:
                              CGRectMake(0.0f, height,
                                         qtmquitView.frame.size.width, self.bounds.size.height)];
        //        _refreshFooterView.delegate = self;
        [qtmquitView addSubview:_refreshFooterView];
    }
    
    _refreshFooterView.backgroundColor = [UIColor clearColor];
    
    if (_refreshFooterView)
    {
        [_refreshFooterView refreshLastUpdatedDate];
    }
}


-(void)removeFooterView
{
    if (_refreshFooterView && [_refreshFooterView superview])
    {
        [_refreshFooterView removeFromSuperview];
    }
    _refreshFooterView = nil;
    
    
    if (tableFooterView && [tableFooterView superview]) {
        
        [tableFooterView removeFromSuperview];
    }
    
    tableFooterView = nil;
}

//代码触发刷新
-(void)showRefreshHeader:(BOOL)animated
{
    if (animated)
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        qtmquitView.contentInset = UIEdgeInsetsMake(65.0f, 0.0f, 0.0f, 0.0f);
        [qtmquitView scrollRectToVisible:CGRectMake(0, 0.0f, 1, 1) animated:NO];
        [UIView commitAnimations];
    }
    else
    {
        qtmquitView.contentInset = UIEdgeInsetsMake(65.0f, 0.0f, 0.0f, 0.0f);
        [qtmquitView scrollRectToVisible:CGRectMake(0, 0.0f, 1, 1) animated:NO];
    }
    
    [_refreshHeaderView setState:L_EGOOPullRefreshLoading];
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:qtmquitView];
}

-(void)beginToReloadData:(EGORefreshPos)aRefreshPos{
    
    //  should be calling your tableviews data source model to reload
    _reloading = YES;
    
    if (aRefreshPos == EGORefreshHeader)
    {
        _isReloadData = YES;
        self.pageNum = 1;
        // pull down to refresh data
        [self performSelector:@selector(refreshView) withObject:nil afterDelay:0.0];
        
    }else if(aRefreshPos == EGORefreshFooter)
    {
        self.pageNum ++;
        
        // pull up to load more data
        [self performSelector:@selector(getNextPageView) withObject:nil afterDelay:0.0];
    }
    
    // overide, the actual loading data operation is done in the subclass
}

//刷新调用的方法
-(void)refreshView
{
    if (_waterDelegate && [_waterDelegate respondsToSelector:@selector(waterLoadNewDataForWaterView:)]) {
        
        [_waterDelegate waterLoadNewDataForWaterView:qtmquitView];
    }
}
//加载调用的方法
-(void)getNextPageView
{
    if (_waterDelegate && [_waterDelegate respondsToSelector:@selector(waterLoadMoreDataForWaterView:)]) {
        
        [_waterDelegate waterLoadMoreDataForWaterView:qtmquitView];
    }
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (_refreshHeaderView)
    {
        [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    }
    
    if (_refreshFooterView)
    {
        [_refreshFooterView egoRefreshScrollViewDidScroll:scrollView];
    }
    
    if (_waterDelegate && [_waterDelegate respondsToSelector:@selector(waterScrollViewDidScroll:)]) {
        
        [_waterDelegate waterScrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    if (_waterDelegate && [_waterDelegate respondsToSelector:@selector(waterScrollViewDidEndDragging:)]) {
        
        [_waterDelegate waterScrollViewDidEndDragging:scrollView];
    }
    
    if (_refreshHeaderView)
    {
        [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    }
    
    if (_refreshFooterView)
    {
        [_refreshFooterView egoRefreshScrollViewDidEndDragging:scrollView];
    }
    
    // 下拉到最底部时显示更多数据
    
    if(_isHaveMoreData && scrollView.contentOffset.y > ((scrollView.contentSize.height - scrollView.frame.size.height-40)))
    {
        if (_waterDelegate && [_waterDelegate respondsToSelector:@selector(waterLoadMoreDataForWaterView:)]) {
            
            [self startLoading];
            
            _isLoadMoreData = YES;
            
            self.pageNum ++;
            [_waterDelegate waterLoadMoreDataForWaterView:qtmquitView];
        }
    }
}


#pragma mark -
#pragma mark EGORefreshTableDelegate Methods

- (void)egoRefreshTableDidTriggerRefresh:(EGORefreshPos)aRefreshPos
{
    
    [self beginToReloadData:aRefreshPos];
    
}

- (BOOL)egoRefreshTableDataSourceIsLoading:(UIView*)view{
    
    return _reloading; // should return if data source model is reloading
}


// if we don't realize this method, it won't display the refresh timestamp
- (NSDate*)egoRefreshTableDataSourceLastUpdated:(UIView*)view
{
    
    return [NSDate date]; // should return date data source was last changed
    
}

- (void)didReceiveMemoryWarning
{
    // Dispose of any resources that can be recreated.
}


#pragma mark - PSCollectionViewDelegate <NSObject>


- (void)collectionView:(PSCollectionView *)collectionView didSelectCell:(PSCollectionViewCell *)cell atIndex:(NSInteger)index
{
    NSLog(@"didSelectCell");
    
    
    
    
    if (_waterDelegate && [_waterDelegate respondsToSelector:@selector(waterDidSelectRowAtIndexPath:)]) {
        
        [_waterDelegate waterDidSelectRowAtIndexPath:index];
        
    }
//    else if (_waterDelegate && [_waterDelegate respondsToSelector:@selector(waterDidSelectRowAtIndexPath:water:)]){
//        [_waterDelegate waterDidSelectRowAtIndexPath:index water:collectionView];
//    }
    
}
//- (Class)collectionView:(PSCollectionView *)collectionView cellClassForRowAtIndex:(NSInteger)index
//{
//
//}

#pragma mark - PSCollectionViewDataSource <NSObject>

- (NSInteger)numberOfRowsInCollectionView:(PSCollectionView *)collectionView
{
    return [self.dataArray count];
}
- (PSCollectionViewCell *)collectionView:(PSCollectionView *)collectionView cellForRowAtIndex:(NSInteger)index
{
    PSCollectionViewCell *cell = (PSCollectionViewCell *)[collectionView dequeueReusableViewForClass:[PSCollectionViewCell class]];
    
    if(cell == nil) {
        
        cell = [[PSCollectionViewCell alloc]init];
    }
    return cell;
}
- (CGFloat)collectionView:(PSCollectionView *)collectionView heightForRowAtIndex:(NSInteger)index
{
    CGFloat aHeight = 0.f;
    
    if (_waterDelegate && [_waterDelegate respondsToSelector:@selector(waterHeightForCellIndexPath:waterView:)]) {
        
        aHeight = [_waterDelegate waterHeightForCellIndexPath:index waterView:collectionView];
    }
    return aHeight;
}


#pragma mark - 修改上拉部分

#pragma - mark 创建所需label 和 UIActivityIndicatorView

- (void)createFooterView
{
    CGFloat height = MAX(qtmquitView.contentSize.height, qtmquitView.frame.size.height);
    
    //没有数据的时候 需要显示没有更多数据
    if (self.dataArray.count == 0 && self.isHaveMoreData == NO) {
        
        height = 0.f + self.headerView.height;
    }
    
    if (tableFooterView && [tableFooterView superview]) {
        
        _refreshFooterView.frame = CGRectMake(0.0f,height,qtmquitView.frame.size.width,self.bounds.size.height);
    }else
    {
        tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, height, qtmquitView.width, TABLEFOOTER_HEIGHT)];
        
        [tableFooterView addSubview:self.loadingIndicator];
        [tableFooterView addSubview:self.loadingLabel];
        [tableFooterView addSubview:self.normalLabel];
        
        tableFooterView.backgroundColor = [UIColor clearColor];
        
        [qtmquitView addSubview:tableFooterView];
    }
}

- (UIActivityIndicatorView*)loadingIndicator
{
    if (!_loadingIndicator) {
        _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _loadingIndicator.hidden = YES;
        _loadingIndicator.backgroundColor = [UIColor clearColor];
        _loadingIndicator.hidesWhenStopped = YES;
        _loadingIndicator.frame = CGRectMake(self.frame.size.width/2 - 70 ,6+2 + (TABLEFOOTER_HEIGHT - 40)/2.0, 24, 24);
    }
    return _loadingIndicator;
}

- (UILabel*)normalLabel
{
    if (!_normalLabel) {
        _normalLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 8 + (TABLEFOOTER_HEIGHT - 40)/2.0, self.frame.size.width, 20)];
        _normalLabel.text = NSLocalizedString(NORMAL_TEXT, nil);
        _normalLabel.backgroundColor = [UIColor clearColor];
        [_normalLabel setFont:[UIFont systemFontOfSize:14]];
        _normalLabel.textAlignment = NSTextAlignmentCenter;
        [_normalLabel setTextColor:[UIColor darkGrayColor]];
    }
    
    return _normalLabel;
    
}

- (UILabel*)loadingLabel
{
    if (!_loadingLabel) {
        _loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(320.f/2-80,8 + (TABLEFOOTER_HEIGHT - 40)/2.0, self.frame.size.width/2+30, 20)];
        _loadingLabel.text = NSLocalizedString(@"加载中...", nil);
        _loadingLabel.backgroundColor = [UIColor clearColor];
        [_loadingLabel setFont:[UIFont systemFontOfSize:14]];
        _loadingLabel.textAlignment = NSTextAlignmentCenter;
        [_loadingLabel setTextColor:[UIColor darkGrayColor]];
        [_loadingLabel setHidden:YES];
    }
    
    return _loadingLabel;
}


- (void)startLoading
{
    [self.loadingIndicator startAnimating];
    [self.loadingLabel setHidden:NO];
    [self.normalLabel setHidden:YES];
}

- (void)stopLoading:(int)loadingType
{
    _isLoadMoreData = NO;
    
    [self.loadingIndicator stopAnimating];
    switch (loadingType) {
        case 1:
            [self.normalLabel setHidden:NO];
            [self.normalLabel setText:NSLocalizedString(NORMAL_TEXT, nil)];
            [self.loadingLabel setHidden:YES];
            break;
        case 2:
            [self.normalLabel setHidden:NO];
            [self.normalLabel setText:NSLocalizedString(NOMORE_TEXT, nil)];
            [self.loadingLabel setHidden:YES];
            break;
        default:
            break;
    }
}

@end

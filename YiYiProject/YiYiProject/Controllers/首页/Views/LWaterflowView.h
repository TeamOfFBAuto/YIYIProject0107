//
//  LWaterflowView.h
//  Waterflow
//
//  Created by lichaowei on 14/12/13.
//  Copyright (c) 2014年 yangjw . All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LRefreshTableHeaderView.h"
#import "EGORefreshTableFooterView.h"
#import "TMQuiltView.h"
#import "TMPhotoQuiltViewCell.h"

@class LWaterflowView;

@protocol WaterFlowDelegate <NSObject>

@optional
- (void)waterLoadNewData;
- (void)waterLoadMoreData;

- (void)waterLoadNewDataForWaterView:(TMQuiltView *)waterView;
- (void)waterLoadMoreDataForWaterView:(TMQuiltView *)waterView;

- (void)waterDidSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)waterHeightForCellIndexPath:(NSIndexPath *)indexPath;

- (CGFloat)waterHeightForCellIndexPath:(NSIndexPath *)indexPath waterView:(TMQuiltView *)waterView;


- (CGFloat)waterViewNumberOfColumns;

- (void)waterScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)waterScrollViewDidEndDragging:(UIScrollView *)scrollView;



@end

@interface LWaterflowView : UIView<L_EGORefreshTableDelegate,TMQuiltViewDataSource,TMQuiltViewDelegate>
{
    //EGOHeader
    LRefreshTableHeaderView *_refreshHeaderView;
    //EGOFoot
    EGORefreshTableFooterView *_refreshFooterView;
    //
    BOOL _reloading;
    
    TMQuiltView *qtmquitView;
    
    UIView *tableFooterView;
    
    BOOL _noloadView;
}

@property (nonatomic,assign)id<WaterFlowDelegate>waterDelegate;
@property (nonatomic,assign)BOOL                        isReloadData;      //是否是下拉刷新数据
@property (nonatomic,assign)BOOL                        reloading;         //是否正在loading
@property (nonatomic,assign)BOOL                        isLoadMoreData;    //是否是载入更多
@property (nonatomic,assign)BOOL                        isHaveMoreData;    //是否还有更多数据,决定是否有更多view

@property (nonatomic,assign)int pageNum;//页数
@property (nonatomic,retain)NSMutableArray *dataArray;//数据源

@property(nonatomic,retain)UIActivityIndicatorView *loadingIndicator;
@property(nonatomic,retain)UILabel *normalLabel;
@property(nonatomic,retain)UILabel *loadingLabel;
@property(nonatomic,assign)BOOL hiddenLoadMore;//隐藏加载更多,默认隐藏

@property(nonatomic,assign)TMQuiltView *quitView;

@property(nonatomic,retain)UIView *headerView;//头view

-(instancetype)initWithFrame:(CGRect)frame
               waterDelegate:(id<WaterFlowDelegate>)waterDelegate
             waterDataSource:(id<TMQuiltViewDataSource>)waterDatasource;

-(instancetype)initWithFrame:(CGRect)frame
               waterDelegate:(id<WaterFlowDelegate>)waterDelegate
             waterDataSource:(id<TMQuiltViewDataSource>)waterDatasource noloadView:(BOOL)noloadView;

/**
 *  灵活控制 刷新 header 和 footer的显示
 *  @param noHeaderRefresh 头部刷新
 *  @param noFooterRefresh 底部刷新
 */
-(instancetype)initWithFrame:(CGRect)frame
               waterDelegate:(id<WaterFlowDelegate>)waterDelegate
             waterDataSource:(id<TMQuiltViewDataSource>)waterDatasource
              noHeadeRefresh:(BOOL)noHeaderRefresh
             noFooterRefresh:(BOOL)noFooterRefresh;

/**
 *  滑动到顶部
 */
- (void)scrollToTop;

- (void)reloadData;
-(void)showRefreshHeader:(BOOL)animated;

- (void)reloadData:(NSArray *)data pageSize:(int)pageSize;
//成功加载
- (void)reloadData:(NSArray *)data isHaveMore:(BOOL)isHaveMore;
- (void)reloadData:(NSArray *)data total:(int)totalPage;//更新数据 //根据总页数获取是否有更多
- (void)loadFail;//请求数据失败

-(void)removeHeaderView;

- (void)finishReloadingData;


@end

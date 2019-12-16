//
//  MyFeedbackViewController.m
//  HWForTeacher
//
//  Created by vision on 2019/9/25.
//  Copyright © 2019 vision. All rights reserved.
//

#import "MyFeedbackViewController.h"
#import "FeedbackContentViewController.h"
#import "FeedbackChatViewController.h"
#import "FeedbackTableView.h"
#import "FilterView.h"
#import "BRPickerView.h"
#import "BlankView.h"
#import "NSDate+Extend.h"
#import <MJRefresh/MJRefresh.h>

@interface MyFeedbackViewController ()<FeedbackTableViewDelegate,FilterViewDelegate>

@property (nonatomic,strong) FilterView        *filterView;
@property (nonatomic,strong) FeedbackTableView *myTableView;

@property (nonatomic,strong) NSArray           *typesArr;

@property (nonatomic,assign) NSInteger         page;
@property (nonatomic,strong) NSMutableArray    *guideFeedbacksArray;

@property (nonatomic, copy ) NSString  *selDateStr;
@property (nonatomic,assign) NSInteger selType;

@end

@implementation MyFeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"辅导反馈";
    
    self.selDateStr = [NSDate currentDateTimeWithFormat:@"yyyy年MM月dd日"];
    self.selType = 0;
    self.page = 1;
    self.typesArr  = @[@"全部",@"免费体验学生",@"月辅导学生",@"季辅导学生",@"年辅导学生"];
    
    [self.view addSubview:self.filterView];
    [self.view addSubview:self.myTableView];
    
    [self loadFeedbackData];
}

#pragma mark FeedbackTableViewDelegate
#pragma mark 查看辅导内容
-(void)feedbackTableView:(FeedbackTableView *)tableView didCheckFeedbackContent:(FeedbackModel *)model{
    FeedbackChatViewController *feedbackChatVC = [[FeedbackChatViewController alloc] init];
    feedbackChatVC.conversationType = ConversationType_PRIVATE;
    feedbackChatVC.feedbackModel = model;
    feedbackChatVC.targetId = model.third_id;
    [self.navigationController pushViewController:feedbackChatVC animated:YES];
}

#pragma mark 填写辅导反馈
-(void)feedbackTableView:(FeedbackTableView *)tableView didEditCoachFeedback:(FeedbackModel *)model{
    FeedbackContentViewController *contentVC = [[FeedbackContentViewController alloc] init];
    contentVC.id = model.id;
    [self.navigationController pushViewController:contentVC animated:YES];
}

#pragma mark FilterViewDelegate
-(void)filerViewDidClickWithIndex:(NSInteger)index{
    if (index==0) { //选择日期
        [BRDatePickerView showDatePickerWithTitle:@"日期" dateType:UIDatePickerModeDate defaultSelValue:self.selDateStr minDateStr:@"" maxDateStr:self.selDateStr isAutoSelect:NO resultBlock:^(NSString *selectValue) {
            MyLog(@"selectValue:%@",selectValue);
            self.selDateStr = selectValue;
            self.filterView.dateStr = selectValue;
            [self loadFeedbackData];
        }];
    }else{ //选择科目
        NSString *defaultType = self.typesArr[self.selType];
        [BRStringPickerView showStringPickerWithTitle:@"" dataSource:self.typesArr defaultSelValue:defaultType isAutoSelect:NO resultBlock:^(id selectValue) {
            MyLog(@"selectValue:%@",selectValue);
            self.selType = [self.typesArr indexOfObject:selectValue];
            self.filterView.typeStr = selectValue;
            [self loadFeedbackData];
        }];
    }
}

#pragma mark -- Priavte Methods
#pragma mark 加载反馈数据
-(void)loadFeedbackData{
    NSNumber *timesp = [[ZYHelper sharedZYHelper] timeSwitchTimestamp:self.selDateStr format:@"yyyy-MM-dd"];
    NSDictionary *dict = @{@"token":kUserTokenValue,@"search_time":timesp,@"page":[NSNumber numberWithInteger:self.page],@"pagesize":@20,@"state":[NSNumber numberWithInteger:self.selType]};
    [[HttpRequest sharedInstance] postWithURLString:kGuideFeedbackAPI parameters:dict success:^(id responseObject) {
        NSArray *data = [responseObject objectForKey:@"data"];
        NSMutableArray *tempArr = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in data) {
            FeedbackModel *model = [[FeedbackModel alloc] init];
            [model setValues:dict];
            [tempArr addObject:model];
        }
        
        if (self.page==1) {
            self.guideFeedbacksArray = tempArr;
        }else{
            [self.guideFeedbacksArray addObjectsFromArray:tempArr];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.myTableView.mj_footer.hidden = tempArr.count<20;
            [self.myTableView.mj_header endRefreshing];
            [self.myTableView.mj_footer endRefreshing];
            self.myTableView.feedbacksArray = self.guideFeedbacksArray;
            [self.myTableView reloadData];
        });
    } failure:^(NSString *errorStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.myTableView.mj_header endRefreshing];
            [self.myTableView.mj_footer endRefreshing];
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        });
    }];
}

#pragma mark 加载最新辅导反馈
-(void)loadNewMyFeedbackListData{
    self.page = 1;
    [self loadFeedbackData];
}

#pragma mark 加载更多辅导反馈
-(void)loadMoreMyFeedbackListData{
    self.page++;
    [self loadFeedbackData];
}

#pragma mark -- Getters
#pragma mark 筛选
-(FilterView *)filterView{
    if (!_filterView) {
        _filterView = [[FilterView alloc] initWithFrame:CGRectMake(0, kNavHeight, kScreenWidth,IS_IPAD?60:45)];
        _filterView.viewDelegate = self;
        _filterView.dateStr = self.selDateStr;
        _filterView.typeStr = self.typesArr[self.selType];
    }
    return _filterView;
}

#pragma mark 辅导反馈
-(FeedbackTableView *)myTableView{
    if (!_myTableView) {
        _myTableView = [[FeedbackTableView alloc] initWithFrame:CGRectMake(0, self.filterView.bottom, kScreenWidth, kScreenHeight-self.filterView.bottom) style:UITableViewStylePlain];
        _myTableView.viewDelegate = self;
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewMyFeedbackListData)];
        header.automaticallyChangeAlpha=YES;
        header.lastUpdatedTimeLabel.hidden=YES;
        _myTableView.mj_header=header;
        
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreMyFeedbackListData)];
        footer.automaticallyRefresh = NO;
        _myTableView.mj_footer = footer;
        footer.hidden=YES;
    }
    return _myTableView;
}

-(NSMutableArray *)guideFeedbacksArray{
    if (!_guideFeedbacksArray) {
        _guideFeedbacksArray = [[NSMutableArray alloc] init];
    }
    return _guideFeedbacksArray;
}

@end

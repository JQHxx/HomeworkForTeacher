//
//  StudentViewController.m
//  HWForTeacher
//
//  Created by vision on 2019/9/19.
//  Copyright © 2019 vision. All rights reserved.
//

#import "StudentViewController.h"
#import "MyConversationViewController.h"
#import "StudentDetailsViewController.h"
#import "FeedbackContentViewController.h"
#import "FeedbackChatViewController.h"
#import "MyTabBarController.h"
#import "ChatViewController.h"
#import "SlideMenuView.h"
#import "StudentTableView.h"
#import "FeedbackTableView.h"
#import "EBDropdownListView.h"
#import "NSDate+Extend.h"
#import "StudentModel.h"
#import "FeedbackModel.h"
#import <MJRefresh/MJRefresh.h>
#import "PPBadgeView.h"

@interface StudentViewController ()<SlideMenuViewDelegate,StudentTableViewDelegate,FeedbackTableViewDelegate,EBDropdownListViewDelegate,MyConversationViewControllerDelegate>{
    UIButton             *allBtn;     //全部
    EBDropdownListView   *paidListView;      //已付费
    EBDropdownListView   *unpaidListView;    //未付费
}

@property (nonatomic,strong) SlideMenuView      *menuView;
@property (nonatomic,strong) UIView             *menuRedBadge;
@property (nonatomic,strong) UIButton           *serviceBtn;
@property (nonatomic,strong) MyConversationViewController  *conversationVC;
@property (nonatomic,strong) StudentTableView   *studentTableView;
@property (nonatomic,strong) UIView             *studentMenuView;
@property (nonatomic,strong) FeedbackTableView  *feedbackTableView;

@property (nonatomic,assign) NSInteger type;
@property (nonatomic,assign) NSInteger page;
@property (nonatomic,strong) NSMutableArray  *dailyFeedbacksArray;



@end

@implementation StudentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isHiddenNavBar = YES;
    
    self.type = 0;
    self.page = 1;
    
    [self initStudentView];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"学生"];
    
    //刷新会话列表
    if (self.conversationVC) {
        [self.conversationVC notifyUpdateUnreadMessageCount];
    }
    
    if ([ZYHelper sharedZYHelper].isUpdateStudent) {
        [self loadMyStudentsData];
        [ZYHelper sharedZYHelper].isUpdateStudent = NO;
    }
    
    if ([ZYHelper sharedZYHelper].isUpdateFeedback) {
        [self loadDailyFeedbackData];
        [ZYHelper sharedZYHelper].isUpdateFeedback = NO;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMessageNotification:) name:RCKitDispatchMessageNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"学生"];
}

#pragma mark -- Delegate
#pragma mark SlideMenuViewDelegate
-(void)slideMenuView:(SlideMenuView *)menuView didSelectedWithIndex:(NSInteger)index{
    if (index==0) {
        self.studentMenuView.hidden = self.studentTableView.hidden = self.feedbackTableView.hidden = YES;
        self.conversationVC.view.hidden = NO;
        [self.conversationVC refreshConversationTableViewIfNeeded];
    }else if (index==1){
        self.conversationVC.view.hidden = self.feedbackTableView.hidden = YES;
        self.studentMenuView.hidden = self.studentTableView.hidden =  NO;
        [self loadMyStudentsData];
    }else{
        self.conversationVC.view.hidden = self.studentMenuView.hidden = self.studentTableView.hidden = YES;
        self.feedbackTableView.hidden = NO;
        [self loadDailyFeedbackData];
    }
}

#pragma mark StudentTableViewDelegate
#pragma mark 去辅导
-(void)studentTableViewDidSelectStudent:(StudentModel *)model{
    if (!kIsEmptyString(model.third_id)) {
        ChatViewController *chatVC = [[ChatViewController alloc]init];
        chatVC.conversationType = ConversationType_PRIVATE;
        chatVC.targetId = model.third_id;
        [self.navigationController pushViewController:chatVC animated:YES];
    }
}

#pragma mark 查看学生详情
-(void)studentTableViewDidShowStudentDetailsWithStudent:(StudentModel *)model{
    StudentDetailsViewController *detailsVC = [[StudentDetailsViewController alloc] init];
    detailsVC.s_id = model.s_id;
    [self.navigationController pushViewController:detailsVC animated:YES];
}

#pragma mark EBDropdownListViewDelegate
-(void)dropdownListView:(EBDropdownListView *)listView didSelectedItem:(EBDropdownListItem *)item{
    allBtn.selected = NO;
    if (listView == paidListView) {
        paidListView.textColor = [UIColor colorWithHexString:@"#FF5353"];
        unpaidListView.textColor =  [UIColor colorWithHexString:@"#9495A0"];
        unpaidListView.selectedIndex = 0;
        self.type = [item.itemId integerValue]+1;
    }else{
        unpaidListView.textColor = [UIColor colorWithHexString:@"#FF5353"];
        paidListView.textColor =  [UIColor colorWithHexString:@"#9495A0"];
        paidListView.selectedIndex = 0;
        self.type = [item.itemId integerValue]+5;
    }
    MyLog(@"didSelectedItem,id:%@,name:%@",item.itemId,item.itemName);
    [self loadMyStudentsData];
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


#pragma mark MyConversationViewControllerDelegate
#pragma mark 跳转到聊天页
-(void)myConversationViewControllerDidPushToChatWithTargetID:(NSString *)targetId{
    // 会话页面:直接使用或者继承RCConversationViewController
    ChatViewController *chatVC = [[ChatViewController alloc]init];
    chatVC.conversationType = ConversationType_PRIVATE;
    chatVC.targetId = targetId;
    [self.navigationController pushViewController:chatVC animated:YES];
}

#pragma mark 查看未读消息
-(void)myConversationViewControllerShowMessageUnreadCount:(NSInteger)count{
    dispatch_async(dispatch_get_main_queue(),^{
        self.menuRedBadge.hidden = count==0;
        MyTabBarController *tabbarController = (MyTabBarController *)self.tabBarController;
        if (count>0) {
            [tabbarController.teacherItem pp_addDotWithColor:[UIColor commonColor_red]];
        }else{
            [tabbarController.teacherItem pp_hiddenBadge];
        }
    });
}


#pragma mark 收到聊天消息回调
-(void)didReceiveMessageNotification:(NSNotification *)notification{
    int unreadMsgCount = [[RCIMClient sharedRCIMClient] getUnreadCount:@[ @(ConversationType_PRIVATE)]];
    MyLog(@"didReceiveMessageNotification ,收到消息：%d",unreadMsgCount);
    dispatch_async(dispatch_get_main_queue(),^{
        self.menuRedBadge.hidden = unreadMsgCount==0;
        MyTabBarController *tabbarController = (MyTabBarController *)self.tabBarController;
        if (unreadMsgCount>0) {
            [tabbarController.teacherItem pp_addDotWithColor:[UIColor commonColor_red]];
        }else{
            [tabbarController.teacherItem pp_hiddenBadge];
        }
    });
}

#pragma mark -- Event response
#pragma mark 全部
-(void)chooseAllTypeAction:(UIButton *)sender{
    if (!sender.selected) {
        sender.selected = YES;
        paidListView.textColor = unpaidListView.textColor = [UIColor colorWithHexString:@"#9495A0"];
        paidListView.selectedIndex = unpaidListView.selectedIndex = 0;
    }
    self.type = 0;
    [self loadMyStudentsData];
}

#pragma mark -- Private methods
#pragma mark 初始化
-(void)initStudentView{
    [self.view addSubview:self.menuView];
    [self.view addSubview:self.menuRedBadge];
    self.menuRedBadge.hidden = YES;
    [self.view addSubview:self.serviceBtn];
    [self.view addSubview:self.conversationVC.view];
    [self.view addSubview:self.studentMenuView];
    self.studentMenuView.hidden = YES;
    [self.view addSubview:self.studentTableView];
    self.studentTableView.hidden = YES;
    [self.view addSubview:self.feedbackTableView];
    self.feedbackTableView.hidden = YES;
}

#pragma mark 加载我的学生数据
-(void)loadMyStudentsData{
    [[HttpRequest sharedInstance] postWithURLString:kMyStudentsAPI parameters:@{@"token":kUserTokenValue,@"label":[NSNumber numberWithInteger:self.type]} success:^(id responseObject) {
        NSArray *data = [responseObject objectForKey:@"data"];
        NSMutableArray *tempArr = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in data) {
            StudentModel *model = [[StudentModel alloc] init];
            [model setValues:dict];
            [tempArr addObject:model];
        }
       
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.studentTableView.studentsArray = tempArr;
            [self.studentTableView reloadData];
        });
    } failure:^(NSString *errorStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        });
    }];
}

#pragma mark 加载最新今日反馈
-(void)loadNewFeedbackListData{
    self.page=1;
    [self loadDailyFeedbackData];
}

#pragma mark 加载更多今日反馈
-(void)loadMoreFeedbackListData{
    self.page++;
    [self loadDailyFeedbackData];
}

#pragma mark 加载今日反馈数据
-(void)loadDailyFeedbackData{
    NSString *currentDate = [NSDate currentDateTimeWithFormat:@"yyyy-MM-dd"];
    NSNumber *timesp = [[ZYHelper sharedZYHelper] timeSwitchTimestamp:currentDate format:@"yyyy-MM-dd"];
    NSDictionary *dict = @{@"token":kUserTokenValue,@"search_time":timesp,@"state":@0,@"page":[NSNumber numberWithInteger:self.page],@"pagesize":@20};
    [[HttpRequest sharedInstance] postWithURLString:kGuideFeedbackAPI parameters:dict success:^(id responseObject) {
        NSArray *data = [responseObject objectForKey:@"data"];
        NSMutableArray *tempArr = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in data) {
            FeedbackModel *model = [[FeedbackModel alloc] init];
            [model setValues:dict];
            [tempArr addObject:model];
        }
        
        if (self.page==1) {
            self.dailyFeedbacksArray = tempArr;
        }else{
            [self.dailyFeedbacksArray addObjectsFromArray:tempArr];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.feedbackTableView.mj_footer.hidden = tempArr.count<20;
            [self.feedbackTableView.mj_header endRefreshing];
            [self.feedbackTableView.mj_footer endRefreshing];
            self.feedbackTableView.feedbacksArray = self.dailyFeedbacksArray;
            [self.feedbackTableView reloadData];
        });
    } failure:^(NSString *errorStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.feedbackTableView.mj_header endRefreshing];
            [self.feedbackTableView.mj_footer endRefreshing];
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        });
    }];
}

#pragma mark --Getters
#pragma mark 菜单
-(SlideMenuView *)menuView{
    if (!_menuView) {
        _menuView = [[SlideMenuView alloc] initWithFrame:CGRectMake(18, KStatusHeight,IS_IPAD?360:240, kNavHeight-KStatusHeight+(IS_IPAD?15:0)) btnTitleFont:[UIFont regularFontWithSize:15.0f] color:[UIColor colorWithHexString:@"#9495A0"] selColor:[UIColor colorWithHexString:@"#303030"]];
        _menuView.btnCapWidth = 10;
        _menuView.lineWidth = 16.0;
        _menuView.selectTitleFont = [UIFont mediumFontWithSize:20.0f];
        _menuView.myTitleArray = [NSMutableArray arrayWithArray:@[@"辅导",@"我的学生",@"今日反馈"]];
        _menuView.currentIndex = 0;
        _menuView.delegate = self;
    }
    return _menuView;
}

#pragma mark 未读消息
-(UIView *)menuRedBadge{
    if (!_menuRedBadge) {
        _menuRedBadge = [[UIView alloc] initWithFrame:CGRectMake(self.menuView.width/3.0, self.menuView.top+8, 10, 10)];
        _menuRedBadge.backgroundColor = [UIColor redColor];
        [_menuRedBadge setBorderWithCornerRadius:5 type:UIViewCornerTypeAll];
    }
    return _menuRedBadge;
}

#pragma mark 客服
-(UIButton *)serviceBtn{
    if (!_serviceBtn) {
        _serviceBtn = [[UIButton alloc] initWithFrame:IS_IPAD?CGRectMake(kScreenWidth-60, KStatusHeight+9,50,50):CGRectMake(kScreenWidth-40, KStatusHeight+7, 30, 30)];
        [_serviceBtn setImage:[UIImage imageNamed:@"tutor_service"] forState:UIControlStateNormal];
        [_serviceBtn addTarget:self action:@selector(pushToCustomerServiceVC) forControlEvents:UIControlEventTouchUpInside];
    }
    return _serviceBtn;
}

#pragma mark 会话
-(MyConversationViewController *)conversationVC{
    if (!_conversationVC) {
        _conversationVC = [[MyConversationViewController alloc] init];
        _conversationVC.view.frame = CGRectMake(0, self.menuView.bottom, kScreenWidth, kScreenHeight-self.menuView.bottom-kTabHeight);
        _conversationVC.controlerDelegate = self;
    }
    return _conversationVC;
}

#pragma mark 学生菜单栏
-(UIView *)studentMenuView{
    if (!_studentMenuView) {
        _studentMenuView = [[UIView alloc] initWithFrame:CGRectMake(0, self.menuView.bottom, kScreenWidth, 40)];
        _studentMenuView.backgroundColor = [UIColor colorWithHexString:@"#F6F6FA"];
        
        CGFloat btnWidth = (kScreenWidth-100)/3.0;
        allBtn = [[UIButton alloc] initWithFrame:CGRectMake(30, 5, btnWidth, 30)];
        [allBtn setTitle:@"全部" forState:UIControlStateNormal];
        [allBtn setTitleColor:[UIColor colorWithHexString:@"#9495A0"] forState:UIControlStateNormal];
        [allBtn setTitleColor:[UIColor colorWithHexString:@"#FF5353"] forState:UIControlStateSelected];
        allBtn.titleLabel.font = [UIFont regularFontWithSize:13];
        allBtn.selected = YES;
        [allBtn addTarget:self action:@selector(chooseAllTypeAction:) forControlEvents:UIControlEventTouchUpInside];
        [_studentMenuView addSubview:allBtn];
        
        NSArray *values = @[@[@"已付费",@"月辅导",@"季辅导",@"年辅导"],@[@"未付费",@"今日新增",@"三日新增",@"七日新增"]];
        for (NSInteger i=0; i<values.count; i++) {
            NSArray *titles = values[i];
            NSMutableArray *tempArr = [[NSMutableArray alloc] init];
            for (NSInteger i=0; i<titles.count; i++) {
                EBDropdownListItem *item = [[EBDropdownListItem alloc] initWithItem:[NSString stringWithFormat:@"%ld",i] itemName:titles[i]];
                [tempArr addObject:item];
            }
            EBDropdownListView *listView = [[EBDropdownListView alloc] initWithDataSource:tempArr];
            listView.frame = CGRectMake(allBtn.right+20+(btnWidth+20)*i, 5, btnWidth, 30);
            listView.selectedIndex = 0;
            listView.textColor = [UIColor colorWithHexString:@"#9495A0"];
            listView.font = [UIFont regularFontWithSize:13];
            [listView setViewBorder:0.0 borderColor:[UIColor colorWithHexString:@"#FFAE7C"] cornerRadius:4];
            listView.delegate = self;
            [_studentMenuView addSubview:listView];
            
            if (i==0) {
                paidListView = listView;
            }else{
                unpaidListView = listView;
            }
        }
        
    }
    return _studentMenuView;
}

#pragma mark  我的学生
-(StudentTableView *)studentTableView{
    if (!_studentTableView) {
        _studentTableView = [[StudentTableView alloc] initWithFrame:CGRectMake(0, self.studentMenuView.bottom, kScreenWidth, kScreenHeight-self.studentMenuView.bottom-kTabHeight) style:UITableViewStylePlain];
        _studentTableView.viewDelegate = self;
    }
    return _studentTableView;
}

#pragma mark 今日反馈
-(FeedbackTableView *)feedbackTableView{
    if (!_feedbackTableView) {
        _feedbackTableView = [[FeedbackTableView alloc] initWithFrame:CGRectMake(0, self.menuView.bottom, kScreenWidth, kScreenHeight-self.menuView.bottom-kTabHeight) style:UITableViewStylePlain];
        _feedbackTableView.viewDelegate = self;
        
        //  下拉加载最新
       MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewFeedbackListData)];
       header.automaticallyChangeAlpha=YES;
       header.lastUpdatedTimeLabel.hidden=YES;
       _feedbackTableView.mj_header=header;
       
       MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreFeedbackListData)];
       footer.automaticallyRefresh = NO;
       _feedbackTableView.mj_footer = footer;
       footer.hidden=YES;
        
    }
    return _feedbackTableView;
}


-(NSMutableArray *)dailyFeedbacksArray{
    if (!_dailyFeedbacksArray) {
        _dailyFeedbacksArray = [[NSMutableArray alloc] init];
    }
    return _dailyFeedbacksArray;
}

@end

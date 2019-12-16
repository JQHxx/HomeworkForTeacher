//
//  MineViewController.m
//  HWForTeacher
//
//  Created by vision on 2019/9/19.
//  Copyright © 2019 vision. All rights reserved.
//

#import "MineViewController.h"
#import "SetupViewController.h"
#import "UserInfoViewController.h"
#import "LeaveViewController.h"
#import "MyWalletViewController.h"
#import "BaseWebViewController.h"
#import "MineHeaderView.h"
#import "NoneUserView.h"
#import "MyWalletTableViewCell.h"
#import "UserModel.h"
#import <MJRefresh/MJRefresh.h>

@interface MineViewController ()<UITableViewDelegate,UITableViewDataSource,MineHeaderViewDelegate>{
    NSArray *titlesArr;
    NSArray *imagesArr;
    NSArray *classesArray;
}

@property (nonatomic,strong) UITableView    *mineTableView;
@property (nonatomic,strong) MineHeaderView *headerView;
@property (nonatomic,strong) NoneUserView   *tempHeaderView;
@property (nonatomic,strong) UIButton        *setupBtn;   //设置

@property (nonatomic,strong) UserModel       *userInfo;
@property (nonatomic,strong) EarningsModel   *earningsModel;

@end

@implementation MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isHiddenBackBtn = YES;
    
    titlesArr = @[@"辅导反馈",@"我的学生变动",@"客服中心",@"规章制度",@"操作介绍"];
    imagesArr = @[@"my_tutor_feedback",@"my_student_changes",@"my_service_center",@"my_rules",@"my_operation"];
    classesArray = @[@"MyFeedback",@"StudentChange",@"ContactCenter",@"Rules",@"UserHelp"];
    
    [self.view addSubview:self.mineTableView];
    [self.view addSubview:self.setupBtn];
    
    [self loadUserInfoData];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [MobClick beginLogPageView:@"我的"];
    
    if ([ZYHelper sharedZYHelper].isUpdateMine) {
        [self loadUserInfoData];
        [ZYHelper sharedZYHelper].isUpdateMine = NO;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadUserInfoData) name:kReloadMsgNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"我的"];
}


#pragma mark -- UITableViewDataSource and UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==0) {
        return 1;
    }else{
        return titlesArr.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        MyWalletTableViewCell *cell = [[MyWalletTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.amount = [self.earningsModel.already_money doubleValue];
        cell.monthIncome = [self.earningsModel.predict_money doubleValue];
        
        return cell;
    }else{
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor colorWithHexString:@"#F7F7FB"];
        cell.textLabel.text = titlesArr[indexPath.row];
        cell.imageView.image = [UIImage imageNamed:imagesArr[indexPath.row]];
        cell.textLabel.font = [UIFont regularFontWithSize:16.0];
        cell.textLabel.textColor = [UIColor colorWithHexString:@"#303030"];
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return IS_IPAD?140:100;
    }else{
        return IS_IPAD?62:50;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        MyWalletViewController *walletVC = [[MyWalletViewController alloc] init];
        [self.navigationController pushViewController:walletVC animated:YES];
    }else{
        if (indexPath.row==3) {
            BaseWebViewController *webVC = [[BaseWebViewController alloc] init];
            webVC.urlStr = kRulesUrl;
            webVC.webTitle = @"规章制度";
            [self.navigationController pushViewController:webVC animated:YES];
        }else{
            NSString *classStr = [NSString stringWithFormat:@"%@ViewController",classesArray[indexPath.row]];
            Class aClass = NSClassFromString(classStr);
            BaseViewController *vc = (BaseViewController *)[[aClass alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

#pragma mark -- Delegate
#pragma mark MineHeaderViewDelegate
#pragma mark 个人资料
-(void)mineHeaderViewDidEditUserInfo{
    UserInfoViewController *userInfoVC = [[UserInfoViewController alloc] init];
    userInfoVC.userDetails = self.userInfo;
    [self.navigationController pushViewController:userInfoVC animated:YES];
}

#pragma mark 请假
-(void)mineHeaderViewLeave{
    LeaveViewController *leaveVC = [[LeaveViewController alloc] init];
    [self.navigationController pushViewController:leaveVC animated:YES];
}

#pragma mark -- Event response
#pragma mark 设置
-(void)rightNavigationItemAction{
    SetupViewController *setupVC = [[SetupViewController alloc] init];
    [self.navigationController pushViewController:setupVC animated:YES];
}

#pragma mark -- Private Methods
#pragma mark 加载用户信息
-(void)loadUserInfoData{
    [[HttpRequest sharedInstance] postWithURLString:kHomeAPI parameters:@{@"token":kUserTokenValue} success:^(id responseObject) {
        NSDictionary *data = [responseObject objectForKey:@"data"];
        NSDictionary *userDict = [data valueForKey:@"user"];
        [self.userInfo setValues:userDict];
        
        NSDictionary *earningDict = [data valueForKey:@"earnings"];
        [self.earningsModel setValues:earningDict];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mineTableView.mj_header endRefreshing];
            if ([self.userInfo.card_state integerValue]==2&&[self.userInfo.video_state integerValue]==2&&[self.userInfo.train_state integerValue]==2&&[self.userInfo.state integerValue]==1&&[self.userInfo.guide_state integerValue]==1) { //全部通过审核
                self.headerView.userModel = self.userInfo;
                self.mineTableView.tableHeaderView = self.headerView;
            }else{
                self.mineTableView.tableHeaderView = self.tempHeaderView;
            }
            [self.mineTableView reloadData];
        });
    } failure:^(NSString *errorStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mineTableView.mj_header endRefreshing];
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        });
    }];
}

#pragma mark -- Getters
#pragma mark 头部
-(MineHeaderView *)headerView{
    if (!_headerView) {
        _headerView = [[MineHeaderView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth,KStatusHeight +(IS_IPAD?180:155))];
        _headerView.delegate = self;
    }
    return _headerView;
}

#pragma mark
-(NoneUserView *)tempHeaderView{
    if (!_tempHeaderView) {
        _tempHeaderView = [[NoneUserView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, KStatusHeight+100)];
    }
    return _tempHeaderView;
}

#pragma mark 设置
-(UIButton *)setupBtn{
    if (!_setupBtn) {
        _setupBtn = [[UIButton alloc] initWithFrame:IS_IPAD?CGRectMake(kScreenWidth-60, KStatusHeight+9,50,50):CGRectMake(kScreenWidth-45, KStatusHeight+2, 40, 40)];
        [_setupBtn setImage:[UIImage drawImageWithName:@"my_install" size:IS_IPAD?CGSizeMake(32, 32):CGSizeMake(24, 24)] forState:UIControlStateNormal];
        [_setupBtn addTarget:self action:@selector(rightNavigationItemAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _setupBtn;
}

#pragma mark 我的
-(UITableView *)mineTableView{
    if (!_mineTableView) {
        _mineTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0, kScreenWidth, kScreenHeight-kTabHeight) style:UITableViewStyleGrouped];
        _mineTableView.dataSource = self;
        _mineTableView.delegate = self;
        _mineTableView.tableFooterView = [[UIView alloc] init];
        _mineTableView.backgroundColor = [UIColor colorWithHexString:@"#F7F7FB"];
        _mineTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        if (@available(iOS 11.0, *)) {
            _mineTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadUserInfoData)];
        header.automaticallyChangeAlpha=YES;
        header.lastUpdatedTimeLabel.hidden=YES;
        _mineTableView.mj_header=header;
    }
    return _mineTableView;
}

-(UserModel *)userInfo{
    if (!_userInfo) {
        _userInfo = [[UserModel alloc] init];
    }
    return _userInfo;
}

-(EarningsModel *)earningsModel{
    if (!_earningsModel) {
        _earningsModel = [[EarningsModel alloc] init];
    }
    return _earningsModel;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReloadMsgNotification object:nil];
}

@end

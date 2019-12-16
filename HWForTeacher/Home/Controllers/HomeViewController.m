//
//  HomeViewController.m
//  HWForTeacher
//
//  Created by vision on 2019/9/19.
//  Copyright © 2019 vision. All rights reserved.
//

#import "HomeViewController.h"
#import "UploadPaperworkViewController.h"
#import "UploadVideoViewController.h"
#import "SetProfileViewController.h"
#import "SetCoachTimeViewController.h"
#import "MessagesViewController.h"
#import "ChatViewController.h"
#import "AuthenticateView.h"
#import "TeacherInfoView.h"
#import "MyDataView.h"
#import "HomeTableView.h"
#import "UserModel.h"
#import "StudentModel.h"
#import <MJRefresh/MJRefresh.h>
#import <UMPush/UMessage.h>

@interface HomeViewController ()<AuthenticateViewDelegate,HomeTableViewDelegate>

@property (nonatomic,strong) UIView           *navbarView;
@property (nonatomic,strong) UIView           *redBadge;
@property (nonatomic,strong) UIScrollView     *rootScrollView;
@property (nonatomic,strong) AuthenticateView *authenView;
@property (nonatomic,strong) TeacherInfoView  *userView;
@property (nonatomic,strong) MyDataView       *dataView;
@property (nonatomic,strong) HomeTableView    *homeTableView;

@property (nonatomic,strong) UserModel        *userInfo;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isHiddenNavBar = YES;
    
    [self initHomeView];
    [self loadTeacherInfoData];
    [self loadUnreadMessageData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"首页"];
    
    if ([ZYHelper sharedZYHelper].isUpdateHome) {
        [self loadTeacherInfoData];
        [ZYHelper sharedZYHelper].isUpdateHome = NO;
    }
    
    if ([ZYHelper sharedZYHelper].isUpdateMessage) {
        [self loadUnreadMessageData];
        [ZYHelper sharedZYHelper].isUpdateMessage = NO;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadHomeData) name:kReloadMsgNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"首页"];
}



#pragma mark -- Delegate
#pragma mark AuthenticateViewDelegate
-(void)authenticateViewDidClickBtn:(NSInteger)btnTag step:(NSInteger)step{
    if (step==0) {
        if (btnTag==100) {
            UploadPaperworkViewController *uploadPaperworkVC = [[UploadPaperworkViewController alloc] init];
            [self.navigationController pushViewController:uploadPaperworkVC animated:YES];
        }else{
            UploadVideoViewController *uploadVideoVC = [[UploadVideoViewController alloc] init];
            uploadVideoVC.grades = self.userInfo.grade;
            [self.navigationController pushViewController:uploadVideoVC animated:YES];
        }
    }else if (step==1){
        if (btnTag==100) {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = WX_NUMBER;
            [self.view makeToast:@"微信号已复制" duration:1.0 position:CSToastPositionCenter];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                UIApplication *application = [UIApplication sharedApplication];
                NSURL *URL = [NSURL URLWithString:@"weixin://"];
                if (@available(iOS 10.0, *)) {
                    [application openURL:URL options:@{} completionHandler:^(BOOL success) {
                        MyLog(@"iOS10 Open %@: %d",URL,success);
                    }];
                } else {
                    // Fallback on earlier versions
                    BOOL success = [application openURL:URL];
                    MyLog(@"Open %@: %d",URL,success);
                }
            });
        }
    }else if (step==2){
        if (btnTag==100) {
            SetProfileViewController *setProfileVC = [[SetProfileViewController alloc] init];
            [self.navigationController pushViewController:setProfileVC animated:YES];
        }else{
            SetCoachTimeViewController *setTimeVC = [[SetCoachTimeViewController alloc] init];
            [self.navigationController pushViewController:setTimeVC animated:YES];
        }
    }
}

#pragma mark HomeTableViewDelegate
-(void)homeTableViewDidSelectStudent:(StudentModel *)student{
    if (!kIsEmptyString(student.third_id)) {
        ChatViewController *chatVC = [[ChatViewController alloc]init];
        chatVC.conversationType = ConversationType_PRIVATE;
        chatVC.targetId = student.third_id;
        [self.navigationController pushViewController:chatVC animated:YES];
    }
}

#pragma mark -- Event response
#pragma mark 客服
-(void)contactServiceAction:(UIButton *)sender{
    [self pushToCustomerServiceVC];
}

#pragma mark 消息
-(void)checkMessagesAction:(UIButton *)sender{
    MessagesViewController *messagesVC = [[MessagesViewController alloc] init];
    [self.navigationController pushViewController:messagesVC animated:YES];
}

#pragma mark -- Private Methods
#pragma mark 初始化
-(void)initHomeView{
    [self.view addSubview:self.navbarView];
    [self.view addSubview:self.rootScrollView];
    [self.rootScrollView addSubview:self.authenView];
    self.authenView.hidden = YES;
    [self.rootScrollView addSubview:self.userView];
    self.userView.hidden = YES;
    [self.rootScrollView addSubview:self.dataView];
    [self.rootScrollView addSubview:self.homeTableView];
}

#pragma mark 加载用户信息
-(void)loadTeacherInfoData{
//    NSString *body = [NSString stringWithFormat:@"token=%@",kUserTokenValue];
    [[HttpRequest sharedInstance] postWithURLString:kHomeAPI parameters:@{@"token":kUserTokenValue} success:^(id responseObject) {
        NSDictionary *data = [responseObject objectForKey:@"data"];
        //用户信息 （包括我的收益、我的学生）
        NSDictionary *userDict = [data valueForKey:@"user"];
        [self.userInfo setValues:userDict];
        
        NSDictionary *studentDict = [data valueForKey:@"student"];
        StudentDataModel *studentDataModel = [[StudentDataModel alloc] init];
        [studentDataModel setValues:studentDict];
        
        NSDictionary *incomeDict = [data valueForKey:@"income"];
        IncomeModel *incomeModel = [[IncomeModel alloc] init];
        [incomeModel setValues:incomeDict];
        
        [NSUserDefaultsInfos putKey:kUserId andValue:self.userInfo.tid];
        [NSUserDefaultsInfos putKey:kUserNickname andValue:self.userInfo.name];
        [NSUserDefaultsInfos putKey:kUserHeadPic andValue:self.userInfo.cover];
        [NSUserDefaultsInfos putKey:kRongCloudID andValue:self.userInfo.third_id];
        [NSUserDefaultsInfos putKey:kRongCloudToken andValue:self.userInfo.third_token];
        
        
        //绑定友盟推送别名
       NSNumber *userId = self.userInfo.tid;
       if (userId.integerValue>0) {
           NSString *tempStr = isTrueEnvironment?@"zs_new":@"cs_new";
           NSString *aliasStr=[NSString stringWithFormat:@"%@%@",tempStr,userId];
           [UMessage setAlias:aliasStr type:kUMAlaisType response:^(id  _Nullable responseObject, NSError * _Nullable error) {
              if (error) {
                  MyLog(@"绑定别名失败，error:%@",error.localizedDescription);
              }else{
                  MyLog(@"绑定别名成功,result:%@",responseObject);
              }
           }];
       }
        
        //未成单学生
        NSArray *studentsArr = [data valueForKey:@"order"];
        NSMutableArray *tempArr = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in studentsArr) {
            StudentModel *model = [[StudentModel alloc] init];
            [model setValues:dict];
            [tempArr addObject:model];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.rootScrollView.mj_header endRefreshing];
            if ([self.userInfo.card_state integerValue]==2&&[self.userInfo.video_state integerValue]==2&&[self.userInfo.train_state integerValue]==2&&[self.userInfo.state integerValue]==1&&[self.userInfo.guide_state integerValue]==1) { //全部通过审核
                self.authenView.hidden = YES;
                self.userView.hidden = NO;
                self.userView.user = self.userInfo;
                self.dataView.frame = CGRectMake(0, self.userView.bottom, kScreenWidth,IS_IPAD?320:280);
            }else{
                self.authenView.hidden = NO;
                self.userView.hidden = YES;
                self.dataView.frame = CGRectMake(0, self.authenView.bottom, kScreenWidth,IS_IPAD?320:280);
                
                self.authenView.userModel = self.userInfo;
                if ([self.userInfo.card_state integerValue]==2&&[self.userInfo.video_state integerValue]==2) {
                    if ([self.userInfo.train_state integerValue]==2) {
                        self.authenView.selectStep = 2;
                    }else{
                        self.authenView.selectStep=1;
                    }
                }else{
                    self.authenView.selectStep=0;
                }
            }
            
            self.dataView.incomeModel = incomeModel;
            self.dataView.studentData = studentDataModel;
            
            self.homeTableView.studentsArray = tempArr;
            [self.homeTableView reloadData];
            self.homeTableView.frame = CGRectMake(0, self.dataView.bottom, kScreenWidth,tempArr.count>0?(IS_IPAD?108:78)*tempArr.count+54:204);
            self.rootScrollView.contentSize = CGSizeMake(kScreenWidth, self.homeTableView.top+self.homeTableView.height);
        });
    } failure:^(NSString *errorStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.rootScrollView.mj_header endRefreshing];
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        });
    }];
}

#pragma mark 获取未读消息
-(void)loadUnreadMessageData{
    [[HttpRequest sharedInstance] postNotShowLoadingWithURLString:kUnreadMessageAPI parameters:@{@"token":kUserTokenValue} success:^(id responseObject) {
        NSDictionary *data = [responseObject objectForKey:@"data"];
        NSNumber *state = [data valueForKey:@"state"];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.redBadge.hidden = ![state boolValue];
        });
    }];
}

#pragma mark NSNotification
#pragma mark 刷新数据
-(void)loadHomeData{
    [self loadTeacherInfoData];
    [self loadUnreadMessageData];
}

#pragma mark -- Getters
#pragma mark 导航栏
-(UIView *)navbarView{
    if (!_navbarView) {
        _navbarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kNavHeight)];
        
        UILabel *titleLab =[[UILabel alloc] initWithFrame:CGRectMake(10,IS_IPAD?KStatusHeight+16:KStatusHeight+12, 180,IS_IPAD?34:22)];
        titleLab.textColor=[UIColor commonColor_black];
        titleLab.font=[UIFont mediumFontWithSize:18];
        titleLab.text = @"作业101教师端";
        [_navbarView addSubview:titleLab];
        
        UIButton  *serviceBtn = [[UIButton alloc] initWithFrame:IS_IPAD?CGRectMake(kScreenWidth-130, KStatusHeight+12, 40, 40):CGRectMake(kScreenWidth-77, KStatusHeight+7, 30, 30)];
        [serviceBtn setImage:[UIImage drawImageWithName:@"tutor_service" size:IS_IPAD?CGSizeMake(30, 30):CGSizeMake(20, 20)] forState:UIControlStateNormal];
        [serviceBtn addTarget:self action:@selector(contactServiceAction:) forControlEvents:UIControlEventTouchUpInside];
        [_navbarView addSubview:serviceBtn];
        
        UIButton *messageBtn = [[UIButton alloc] initWithFrame:IS_IPAD?CGRectMake(serviceBtn.right+15, KStatusHeight+12, 40, 40): CGRectMake(serviceBtn.right+5, KStatusHeight+7, 30, 30)];
        [messageBtn setImage:[UIImage drawImageWithName:@"tutor_message" size:IS_IPAD?CGSizeMake(30, 30):CGSizeMake(20, 20)] forState:UIControlStateNormal];
        [messageBtn addTarget:self action:@selector(checkMessagesAction:) forControlEvents:UIControlEventTouchUpInside];
        [_navbarView addSubview:messageBtn];
        
        _redBadge = [[UIView alloc] initWithFrame:CGRectMake(messageBtn.right-10, messageBtn.top+2, 10, 10)];
        _redBadge.backgroundColor = [UIColor redColor];
        [_redBadge setBorderWithCornerRadius:5 type:UIViewCornerTypeAll];
        [_navbarView addSubview:_redBadge];
        _redBadge.hidden = YES;
    }
    return _navbarView;
}

#pragma mark
-(UIScrollView *)rootScrollView{
    if (!_rootScrollView) {
        _rootScrollView  = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kNavHeight, kScreenWidth, kScreenHeight-kTabHeight-kNavHeight)];
        _rootScrollView.showsVerticalScrollIndicator=NO;
        
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadHomeData)];
        header.automaticallyChangeAlpha=YES;
        header.lastUpdatedTimeLabel.hidden=YES;
        _rootScrollView.mj_header=header;
    }
    return _rootScrollView;
}

#pragma mark 认证
-(AuthenticateView *)authenView{
    if (!_authenView) {
        _authenView = [[AuthenticateView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth,IS_IPAD?266:200)];
        _authenView.delegate = self;
    }
    return _authenView;
}

#pragma mark 老师信息
-(TeacherInfoView *)userView{
    if (!_userView) {
        _userView = [[TeacherInfoView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth,IS_IPAD?200:172)];
    }
    return _userView;
}

#pragma mark 数据
-(MyDataView *)dataView{
    if (!_dataView) {
        _dataView = [[MyDataView alloc] initWithFrame:CGRectMake(0, self.userView.bottom, kScreenWidth,IS_IPAD?320: 280)];
    }
    return _dataView;
}

#pragma mark 未成单学生
-(HomeTableView *)homeTableView{
    if (!_homeTableView) {
        _homeTableView = [[HomeTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _homeTableView.viewDelegate = self;
    }
    return _homeTableView;
}

-(UserModel *)userInfo{
    if (!_userInfo) {
        _userInfo = [[UserModel alloc] init];
    }
    return _userInfo;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReloadMsgNotification object:nil];
}

@end

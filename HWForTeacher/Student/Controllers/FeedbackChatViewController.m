//
//  FeedbackChatViewController.m
//  HWForTeacher
//
//  Created by vision on 2019/10/16.
//  Copyright © 2019 vision. All rights reserved.
//

#import "FeedbackChatViewController.h"
#import "StudentModel.h"
#import <UMAnalytics/MobClick.h>

@interface FeedbackChatViewController ()

@property (nonatomic,strong) UIView     *navView;

@end

@implementation FeedbackChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES];
    [self.view addSubview:self.navView];
    
    [self setChatConfig];
    [self loadCoachHistoryMessages];
    
    [self loadUserInfo];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"选择聊天内容"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"选择聊天内容"];
}

#pragma mark -- Event response
#pragma mark 返回
-(void)serviceBackAction:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -- Private methods
#pragma mark 获取辅导内容
-(void)loadCoachHistoryMessages{
    [[RCIMClient sharedRCIMClient] getRemoteHistoryMessages:ConversationType_PRIVATE targetId:self.targetId recordTime: [self.feedbackModel.start_time longLongValue] count:20 success:^(NSArray *messages, BOOL isRemaining) {
        MyLog(@"messages:%@",messages);
        
        [self.conversationDataRepository addObjectsFromArray:messages];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.conversationMessageCollectionView reloadData];
        });
    } error:^(RCErrorCode status) {
        MyLog(@"error---------code:%ld",status);
    }];
}

#pragma mark 设置聊天相关属性
-(void)setChatConfig{
    
    //设置头像样式和大小
    [[RCIM sharedRCIM] setGlobalMessageAvatarStyle:RC_USER_AVATAR_CYCLE];
    [[RCIM sharedRCIM] setGlobalMessagePortraitSize:CGSizeMake(40, 40)];
    
    self.chatSessionInputBarControl.hidden = YES;
    self.conversationMessageCollectionView.frame = CGRectMake(0, kNavHeight, kScreenWidth, kScreenHeight-kNavHeight);
}

#pragma mark 刷新用户信息
- (void)loadUserInfo{
    if (self.conversationType == ConversationType_PRIVATE) {
        if (![self.targetId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
            NSDictionary *params = @{@"token":kUserTokenValue,@"third_id":self.targetId};
            [[HttpRequest sharedInstance] postWithURLString:kRCUserInfoAPI parameters:params success:^(id responseObject) {
                NSDictionary *data = [responseObject objectForKey:@"data"];
                StudentModel *model = [[StudentModel alloc] init];
                [model setValues:data];
                
                RCUserInfo *userInfo = [[RCUserInfo alloc] init];
                userInfo.name = model.name;
                userInfo.portraitUri = model.cover;
                userInfo.userId = self.targetId;
                [[RCIM sharedRCIM] refreshUserInfoCache:userInfo withUserId:userInfo.userId];
                
            } failure:^(NSString *errorStr) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
                });
            }];
        }
    }
    
    //刷新自己头像昵称
    RCUserInfo *user = [RCIM sharedRCIM].currentUserInfo;
    user.name = [NSUserDefaultsInfos getValueforKey:kUserNickname];
    user.portraitUri = [NSUserDefaultsInfos getValueforKey:kUserHeadPic];
    MyLog(@"自己的用户信息，userId:%@,trait:%@,name:%@",user.userId,user.portraitUri,user.name);
    [[RCIM sharedRCIM] refreshUserInfoCache:user withUserId:user.userId];
}

#pragma mark -- getters
#pragma mark 导航栏背景
-(UIView *)navView{
    if (!_navView) {
         _navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kNavHeight)];
               
         UIButton *leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(5,KStatusHeight + 2, 40, 40)];
         [leftBtn setImage:[UIImage imageNamed:@"return_black"] forState:UIControlStateNormal];
         [leftBtn addTarget:self action:@selector(serviceBackAction:) forControlEvents:UIControlEventTouchUpInside];
         [_navView addSubview:leftBtn];
       
         UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth-240)/2, KStatusHeight+12, 240, 22)];
         titleLab.textColor=[UIColor commonColor_black];
         titleLab.font=[UIFont mediumFontWithSize:18.0f];
         titleLab.textAlignment=NSTextAlignmentCenter;
         titleLab.text = self.feedbackModel.name;
         [_navView addSubview:titleLab];
    }
    return _navView;
}

@end

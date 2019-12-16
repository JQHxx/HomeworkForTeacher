//
//  ChatViewController.m
//  Homework
//
//  Created by vision on 2019/9/29.
//  Copyright © 2019 vision. All rights reserved.
//

#import "ChatViewController.h"
#import "StudentDetailsViewController.h"
#import "CustomMessageCell.h"
#import "CustomMessage.h"
#import "StudentModel.h"
#import "MXActionSheet.h"
#import <UMAnalytics/MobClick.h>

@interface ChatViewController ()<RCIMReceiveMessageDelegate>

@property (nonatomic,strong) UIView         *navView;
@property (nonatomic,strong) UILabel        *titleLab;

@property (nonatomic,strong) UIView         *footerView;
@property (nonatomic,strong) UILabel        *tipsLab;
@property (nonatomic,strong) UIButton       *coachBtn;

@property (nonatomic,strong) StudentModel   *student;
@property (nonatomic, copy ) NSString       *guideId;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    [self initChatView];
    [self setChatConfig];
    [self refreshUserInfo];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"聊天"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"聊天"];
}

#pragma mark 输入工具栏尺寸（高度）发生变化的回调
-(void)chatInputBar:(RCChatSessionInputBarControl *)chatInputBar shouldChangeFrame:(CGRect)frame{
    [super chatInputBar:self.chatSessionInputBarControl shouldChangeFrame:frame];
    
    MyLog(@"chatInputBar-----shouldChangeFrame----y:%.f,height:%.f",frame.origin.y,frame.size.height);
    
    if ([self.student.guide_status boolValue]) {
        CGRect aFrame = self.conversationMessageCollectionView.frame;
        aFrame.size.height -= 62;
        self.conversationMessageCollectionView.frame = aFrame;
        self.footerView.frame = CGRectMake(0,frame.origin.y-62, kScreenWidth, 62);
    }else{
//        self.conversationMessageCollectionView.frame = CGRectMake(0, kNavHeight, kScreenWidth, kScreenHeight-50-kNavHeight);
        if (self.footerView) {
            [self.footerView removeFromSuperview];
            self.footerView = nil;
        }
    }
    
    NSInteger num = [self.conversationMessageCollectionView numberOfItemsInSection:0];
    if (num>0) {
        NSUInteger finalRow = MAX(0, [self.conversationMessageCollectionView numberOfItemsInSection:0] - 1);
        NSIndexPath *finalIndexPath = [NSIndexPath indexPathForItem:finalRow inSection:0];
        [self.conversationMessageCollectionView scrollToItemAtIndexPath:finalIndexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    }
}

#pragma mark RCIMReceiveMessageDelegate
#pragma mark  接收消息的回调方法
-(void)onRCIMReceiveMessage:(RCMessage *)message left:(int)left{
    if ([message.content isMemberOfClass:[RCInformationNotificationMessage class]]) {
        RCInformationNotificationMessage *msg = (RCInformationNotificationMessage *)message.content;
        if ([msg.extra isEqualToString:@"start_coach"]) { //开始辅导
            MyLog(@"对方开始辅导");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.conversationMessageCollectionView setFrame:CGRectMake(0, kNavHeight, kScreenWidth, kScreenHeight-50-62-kNavHeight)];
                [self.view addSubview:self.footerView];
                
                NSInteger num = [self.conversationMessageCollectionView numberOfItemsInSection:0];
                if (num>0) {
                    NSUInteger finalRow = MAX(0, [self.conversationMessageCollectionView numberOfItemsInSection:0] - 1);
                    NSIndexPath *finalIndexPath = [NSIndexPath indexPathForItem:finalRow inSection:0];
                    [self.conversationMessageCollectionView scrollToItemAtIndexPath:finalIndexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
                }
            });
            self.student.guide_status = [NSNumber numberWithBool:YES];
        }else if ([msg.extra isEqualToString:@"end_coach"]){
            [self loadLastestGuideId];
            MyLog(@"对方已结束辅导");
        }
    }
    
}

#pragma mark -- Event Response
#pragma mark 返回
-(void)leftNavigationItemAction{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 更多
-(void)chatMoreAction:(UIButton *)sender{
    NSArray *buttonTitles = @[@"发送付款邀请",@"添加备注",@"设置版本",@"学生详情"];
    [MXActionSheet showWithTitle:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:buttonTitles selectedBlock:^(NSInteger index) {
        if (index==1) { //发送付款邀请
            CustomMessage *msg = [CustomMessage messageWithContent:@"老师正在邀请你去购买" extra:@"msg_invite_buy"];
            [self sendMessage:msg pushContent:nil];
        }else if (index==2||index==3||index==4){ //添加备注、设置版本、学生详情
            StudentDetailsViewController *detailsVC = [[StudentDetailsViewController alloc] init];
            detailsVC.s_id = self.student.s_id;
            [self.navigationController pushViewController:detailsVC animated:YES];
        }
    }];
}

#pragma mark 结束辅导
-(void)coachBtnAction:(UIButton *)sender{
    RCInformationNotificationMessage *warningMsg =[RCInformationNotificationMessage notificationWithMessage:@"本次辅导结束" extra:@"end_coach"];
    [self sendMessage:warningMsg pushContent:@"结束辅导"];
    [self loadLastestGuideId];
}

#pragma mark -- Priavte Methods
#pragma mark 初始化界面
-(void)initChatView{
    [self.view addSubview:self.navView];
}

#pragma mark 设置聊天相关属性
-(void)setChatConfig{
    //发送新拍照的图片完成之后，是否将图片在本地另行存储
    self.enableSaveNewPhotoToLocalSystem = YES;
    
    //设置头像样式和大小
    [[RCIM sharedRCIM] setGlobalMessageAvatarStyle:RC_USER_AVATAR_CYCLE];
    [[RCIM sharedRCIM] setGlobalMessagePortraitSize:CGSizeMake(40, 40)];
    
    //设置接收消息代理
    [RCIM sharedRCIM].receiveMessageDelegate = self;
    
     //更新面板图片
    [self.chatSessionInputBarControl.pluginBoardView removeItemAtIndex:2];
    
    [self.chatSessionInputBarControl.pluginBoardView updateItemAtIndex:0 image:[UIImage imageNamed:@"tutor_chat_add_picture"] title:@"相册"];
    [self.chatSessionInputBarControl.pluginBoardView updateItemAtIndex:1 image:[UIImage imageNamed:@"tutor_chat_add_photograph"] title:@"拍摄"];
    [self.chatSessionInputBarControl.pluginBoardView updateItemAtIndex:2 image:[UIImage imageNamed:@"tutor_chat_add_voice"] title:@"语音通话"];
    [self.chatSessionInputBarControl.pluginBoardView updateItemAtIndex:3 image:[UIImage imageNamed:@"tutor_chat_add_video"] title:@"视频通话"];
    
    //自定义消息
    [self registerClass:[CustomMessageCell class] forMessageClass:[CustomMessage class]];
    
    self.enableNewComingMessageIcon = YES; //开启消息提醒
    self.enableUnreadMessageIcon = YES; //是否在右上角提示上方存在的未读消息数
}

#pragma mark 刷新用户信息
- (void)refreshUserInfo{
    if (self.conversationType == ConversationType_PRIVATE) {
        if (![self.targetId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
            NSDictionary *params = @{@"token":kUserTokenValue,@"third_id":self.targetId};
            [[HttpRequest sharedInstance] postWithURLString:kRCUserInfoAPI parameters:params success:^(id responseObject) {
                NSDictionary *data = [responseObject objectForKey:@"data"];
                [self.student setValues:data];
                self.student.third_id = self.targetId;
                
                RCUserInfo *userInfo = [[RCUserInfo alloc] init];
                userInfo.name = self.student.name;
                userInfo.portraitUri = self.student.cover;
                userInfo.userId = self.targetId;
                [[RCIM sharedRCIM] refreshUserInfoCache:userInfo withUserId:userInfo.userId];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.titleLab.text = self.student.name;
                    if ([self.student.guide_status boolValue]) {
                        [self.conversationMessageCollectionView setFrame:CGRectMake(0, kNavHeight, kScreenWidth, kScreenHeight-self.chatSessionInputBarControl.height-62-kNavHeight)];
                        [self.view addSubview:self.footerView];
                        
                        NSInteger num = [self.conversationMessageCollectionView numberOfItemsInSection:0];
                        if (num>0) {
                            NSUInteger finalRow = MAX(0, [self.conversationMessageCollectionView numberOfItemsInSection:0] - 1);
                            NSIndexPath *finalIndexPath = [NSIndexPath indexPathForItem:finalRow inSection:0];
                            [self.conversationMessageCollectionView scrollToItemAtIndexPath:finalIndexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
                        }
                    }else{
                        self.conversationMessageCollectionView.frame = CGRectMake(0, kNavHeight, kScreenWidth, kScreenHeight-self.chatSessionInputBarControl.height-kNavHeight);
                        if (self.footerView) {
                            [self.footerView removeFromSuperview];
                            self.footerView = nil;
                        }
                    }
                    [self.conversationMessageCollectionView reloadData];
                });
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
 
#pragma mark 获取辅导id
-(void)loadLastestGuideId{
    NSDictionary *params = @{@"token":kUserTokenValue,@"s_id":self.student.s_id};
    [[HttpRequest sharedInstance] postWithURLString:kGetGuideIdAPI parameters:params success:^(id responseObject) {
        self.student.guide_status = [NSNumber numberWithBool:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.tipsLab.text = @"辅导已完成";
            [self.coachBtn setTitle:@"去辅导" forState:UIControlStateNormal];
        });
    } failure:^(NSString *errorStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        });
    }];
}

#pragma mark -- Getters
#pragma mark 导航栏背景
-(UIView *)navView{
    if (!_navView) {
        _navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kNavHeight)];
        
        UIButton *leftBtn = [[UIButton alloc] initWithFrame:IS_IPAD?CGRectMake(10, KStatusHeight+9, 50, 50):CGRectMake(5,KStatusHeight + 2, 40, 40)];
        [leftBtn setImage:[UIImage drawImageWithName:@"return_black"size:IS_IPAD?CGSizeMake(13, 23):CGSizeMake(12, 18)] forState:UIControlStateNormal];
        [leftBtn addTarget:self action:@selector(leftNavigationItemAction) forControlEvents:UIControlEventTouchUpInside];
        [_navView addSubview:leftBtn];
        
        self.titleLab = [[UILabel alloc] initWithFrame:IS_IPAD?CGRectMake((kScreenWidth-280)/2.0, KStatusHeight+16, 280, 36):CGRectMake((kScreenWidth-240)/2, KStatusHeight+12, 240, 22)];
        self.titleLab.textColor=[UIColor commonColor_black];
        self.titleLab.font=[UIFont mediumFontWithSize:18.0f];
        self.titleLab.textAlignment=NSTextAlignmentCenter;
        [_navView addSubview:self.titleLab];
        
        UIButton *moreBtn=[[UIButton alloc] initWithFrame:IS_IPAD?CGRectMake(kScreenWidth-60, KStatusHeight+9,50,50):CGRectMake(kScreenWidth-45, KStatusHeight+2, 40, 40)];
        [moreBtn setImage:[UIImage drawImageWithName:@"tutor_chat_more" size:IS_IPAD?CGSizeMake(27, 33):CGSizeMake(18, 22)] forState:UIControlStateNormal];
        [moreBtn addTarget:self action:@selector(chatMoreAction:) forControlEvents:UIControlEventTouchUpInside];
        [_navView addSubview:moreBtn];
        
    }
    return _navView;
}

#pragma mark 底部视图
-(UIView *)footerView{
    if (!_footerView) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0,kScreenHeight-self.chatSessionInputBarControl.height-62, kScreenWidth, 62)];
        _footerView.backgroundColor = [UIColor colorWithHexString:@"#EAECF9"];
        
        _tipsLab = [[UILabel alloc] initWithFrame:CGRectMake(15, 10,kScreenWidth-100, 40)];
        _tipsLab.textColor=[UIColor colorWithHexString:@"#9495A0"];
        _tipsLab.font=[UIFont mediumFontWithSize:13.0f];
        _tipsLab.numberOfLines = 0;
        _tipsLab.text = @"辅导结束后，请主动点击结束辅导。\n结束辅导后，将上传辅导记录。";
        [_footerView addSubview:_tipsLab];
        
        _coachBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-75, 10, 65, 24)];
        _coachBtn.backgroundColor = [UIColor bm_colorGradientChangeWithSize:_coachBtn.size direction:IHGradientChangeDirectionVertical startColor:[UIColor colorWithHexString:@"#FF8C00"] endColor:[UIColor colorWithHexString:@"#FFA941"]];
        _coachBtn.layer.cornerRadius = 4.0;
        [_coachBtn setTitle:@"结束辅导" forState:UIControlStateNormal];
        [_coachBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _coachBtn.titleLabel.font = [UIFont mediumFontWithSize:12];
        [_coachBtn addTarget:self action:@selector(coachBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [_footerView addSubview:_coachBtn];
    }
    return _footerView;
}

-(StudentModel *)student{
    if (!_student) {
        _student = [[StudentModel alloc] init];
    }
    return _student;
}

@end

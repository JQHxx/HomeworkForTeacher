//
//  UploadVideoViewController.m
//  HWForTeacher
//
//  Created by vision on 2019/9/24.
//  Copyright © 2019 vision. All rights reserved.
//

#import "UploadVideoViewController.h"
#import "PlayVideoViewController.h"
#import "MXActionSheet.h"
#import "UploadParam.h"
#import <AVFoundation/AVFoundation.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface UploadVideoViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    NSString  * _qualityPreset;
}

@property (nonatomic,strong) UIScrollView *rootScrollView;
@property (nonatomic,strong) UILabel      *tipsLabel;
@property (nonatomic,strong) UILabel      *testTitleLab; //要求
@property (nonatomic,strong) UILabel      *testDescLab; //讲解要求
@property (nonatomic,strong) UILabel      *topicTitleLab; //题目标题
@property (nonatomic,strong) UIImageView  *topicImgView; //题目
@property (nonatomic,strong) UIButton     *uploadBtn;
@property (nonatomic,strong) UIButton     *playBtn;   //视频播放
@property (nonatomic,strong) UIButton     *reloadBtn; //重新上传
@property (nonatomic,strong) UIButton     *confirmBtn;

@property (nonatomic,strong) NSString     *videoUrl;

@end

@implementation UploadVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"上传试讲视频";
    self.rightImageName = @"tutor_service";
    
    [self initUploadVideoVIew];
    [self loadTestInfo];
}

#pragma mark -- UIImagePickerControllerDelegate
#pragma mark 确定选择
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info{
    MyLog(@"didFinishPickingMediaWithInfo:%@",info);
    [self.imgPicker dismissViewControllerAnimated:YES completion:nil];
    NSURL* mediaURL = [info objectForKey:UIImagePickerControllerMediaURL];
    //获取视频大小
    CGFloat videoSize = [[ZYHelper sharedZYHelper] getFileSize:[mediaURL path]];
    MyLog(@"压缩处理之前的视频大小：%@", [NSString stringWithFormat:@"%.2f MB", videoSize]);
    
    // 预设压缩质量（最高画质）
    _qualityPreset = AVAssetExportPresetHighestQuality;
    // 如果视频大于 1000MB 则最低画质压缩
    if (videoSize > 1000) {
        _qualityPreset = AVAssetExportPresetLowQuality;
    } else if (videoSize > 20) {
        // 中等画质压缩
        _qualityPreset = AVAssetExportPresetMediumQuality;
    }
    MyLog(@"压缩质量:%@",_qualityPreset);
    
    // 配置输出的视频文件,保存在app自己的沙盒路径里，在上传后删除掉。
   NSURL *newVideoUrl;
   NSDateFormatter *formater = [[NSDateFormatter alloc] init];
   //用时间给文件全名，以免重复，在测试的时候其实可以判断文件是否存在若存在，则删除，重新生成文件即可
   [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
   newVideoUrl = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/output-%@.mp4", [formater stringFromDate:[NSDate date]]]] ;
   [picker dismissViewControllerAnimated:YES completion:nil];
   [self convertVideoQuailtyWithInputURL:mediaURL outputURL:newVideoUrl completeHandler:nil];
}

#pragma mark -- Event response
#pragma mark 上传视频
-(void)uploadVideoAction:(UIButton *)sender{
    NSArray *buttonTitles = @[@"拍摄",@"相册",];
    [MXActionSheet showWithTitle:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:buttonTitles selectedBlock:^(NSInteger index) {
        self.imgPicker=[[UIImagePickerController alloc]init];
        self.imgPicker.delegate=self;
        self.modalPresentationStyle=UIModalPresentationOverCurrentContext;
        NSArray *availableMedia = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        self.imgPicker.mediaTypes = [NSArray arrayWithObject:availableMedia[1]];//设置媒体类型为public.movie
        if (index==1) {
           if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) //判断设备相机是否可用
           {
               self.imgPicker.sourceType=UIImagePickerControllerSourceTypeCamera;
               self.imgPicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
                [self presentViewController:self.imgPicker animated:YES completion:nil];
           }else{
               [self.view makeToast:@"您的相机不可用" duration:1.0 position:CSToastPositionCenter];
               return ;
           }
        }else if (index==2){
           self.imgPicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
           [self presentViewController:self.imgPicker animated:YES completion:nil];
        }
    }];
}

#pragma mark 完成
-(void)completeUploadVideoAction:(UIButton *)sender{
    if (kIsEmptyString(self.videoUrl)) {
        [self.view makeToast:@"请先上传视频" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    self.confirmBtn.userInteractionEnabled = NO;
    [[HttpRequest sharedInstance] postWithURLString:kSetTrialVideoAPI parameters:@{@"token":kUserTokenValue,@"video":self.videoUrl} success:^(id responseObject) {
        [ZYHelper sharedZYHelper].isUpdateHome = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view makeToast:@"试讲视频上传成功，请等待审核" duration:1.0 position:CSToastPositionCenter];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
            self.confirmBtn.userInteractionEnabled = YES;
        });
    } failure:^(NSString *errorStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.confirmBtn.userInteractionEnabled = YES;
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        });
    }];
}

#pragma mark 播放视频
-(void)playVideoAction:(UIButton *)sender{
    MyLog(@"playVideoAction");
    PlayVideoViewController *playVC = [[PlayVideoViewController alloc] init];
    playVC.videoUrl = self.videoUrl;
    [self presentViewController:playVC animated:YES completion:nil];
    
}

#pragma mark 联系客服
-(void)rightNavigationItemAction{
    [self pushToCustomerServiceVC];
}

#pragma mark -- Private methods
#pragma mark 初始化
-(void)initUploadVideoVIew{
    [self.view addSubview:self.rootScrollView];
    [self.rootScrollView addSubview:self.tipsLabel];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, self.tipsLabel.bottom+20, kScreenWidth, 1)];
    line.backgroundColor = [UIColor colorWithHexString:@"#D8D8D8"];
    [self.rootScrollView addSubview:line];
    
    [self.rootScrollView addSubview:self.testTitleLab];
    [self.rootScrollView addSubview:self.testDescLab];
    [self.rootScrollView addSubview:self.topicTitleLab];
    [self.rootScrollView addSubview:self.topicImgView];
    [self.rootScrollView addSubview:self.uploadBtn];
    [self.rootScrollView addSubview:self.reloadBtn];
    self.reloadBtn.hidden = YES;
    [self.rootScrollView addSubview:self.playBtn];
    self.playBtn.hidden = YES;
    [self.rootScrollView addSubview:self.confirmBtn];
    
    self.rootScrollView.contentSize = CGSizeMake(kScreenWidth, self.confirmBtn.bottom+30);
}

#pragma mark 加载试题数据
-(void)loadTestInfo{
    [[HttpRequest sharedInstance] postWithURLString:kGetTrialAPI parameters:@{@"token":kUserTokenValue} success:^(id responseObject) {
        NSDictionary *dict = [responseObject objectForKey:@"data"];
        if (kIsDictionary(dict)&&dict.count>0) {
            CGFloat width = [dict[@"width"] doubleValue];
            CGFloat height = [dict[@"height"] doubleValue];
            NSString *imgUrl = [dict valueForKey:@"question"];
            dispatch_async(dispatch_get_main_queue(), ^{

                [self.topicImgView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@""]];
                self.topicImgView.frame = CGRectMake(25, self.topicTitleLab.bottom+10, kScreenWidth-50, (kScreenWidth-50)*(height/width));
                
                self.uploadBtn.frame = CGRectMake(28, self.topicImgView.bottom+20,kScreenWidth-55,IS_IPAD?280:180);
                self.playBtn.center = self.uploadBtn.center;
                self.reloadBtn.frame =IS_IPAD?CGRectMake((kScreenWidth-240)/2.0,self.uploadBtn.bottom+10, 240, 60):CGRectMake((kScreenWidth-160)/2.0,self.uploadBtn.bottom+10, 160, 44);
                self.confirmBtn.frame = CGRectMake((kScreenWidth-300)/2.0,self.reloadBtn.bottom+30, 300, 62);
                self.rootScrollView.contentSize = CGSizeMake(kScreenWidth, self.confirmBtn.bottom+30);
            });
        }
    } failure:^(NSString *errorStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        });
    }];
}

#pragma mark 视频压缩转码处理
- (void)convertVideoQuailtyWithInputURL:(NSURL*)inputURL outputURL:(NSURL*)outputURL completeHandler:(void (^)(AVAssetExportSession*))handler{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD show];
    });
    
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    if (!_qualityPreset) {
        _qualityPreset = AVAssetExportPresetMediumQuality;
    }
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:_qualityPreset];
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.shouldOptimizeForNetworkUse= YES;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void) {
         switch (exportSession.status) {
             case AVAssetExportSessionStatusCancelled:
                 MyLog(@"AVAssetExportSessionStatusCancelled");
                 break;
             case AVAssetExportSessionStatusUnknown:
                 MyLog(@"AVAssetExportSessionStatusUnknown");
                 break;
             case AVAssetExportSessionStatusWaiting:
                 MyLog(@"AVAssetExportSessionStatusWaiting");
                 break;
             case AVAssetExportSessionStatusExporting:
                 MyLog(@"AVAssetExportSessionStatusExporting");
                 break;
             case AVAssetExportSessionStatusCompleted:
                 MyLog(@"AVAssetExportSessionStatusCompleted");
                 CGFloat videoSize = [[ZYHelper sharedZYHelper] getFileSize:[outputURL path]];
                 MyLog(@"压缩处理后的视频大小：%@", [NSString stringWithFormat:@"%.2f MB", videoSize]);
                 [self uploadVideoUrl:outputURL];
                 break;
             case AVAssetExportSessionStatusFailed:
                 NSLog(@"AVAssetExportSessionStatusFailed");
                 break;
         }
     }];
}

#pragma mark
-(void)uploadVideoUrl:(NSURL *)url{
    UploadParam *param = [[UploadParam alloc] init];
    NSData *data = [NSData dataWithContentsOfURL:url];
    param.data = data;
    param.name = @"video";
    
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
    param.filename = [NSString stringWithFormat:@"upload-%@.mp4", [formater stringFromDate:[NSDate date]]];
    param.mimeType = @"video/mpeg";
    [[HttpRequest sharedInstance] uploadWithURLString:kUploadVideoAPI parameters:nil uploadParam:@[param] success:^(id responseObject) {
        self.videoUrl = [responseObject objectForKey:@"data"];
        
        //获取视频首帧
        UIImage *videoCover = [UIImage getVideoPreViewImage:[NSURL URLWithString:self.videoUrl]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.uploadBtn setBackgroundImage:videoCover forState:UIControlStateNormal];
            [self.uploadBtn setImage:nil forState:UIControlStateNormal];
            [self.uploadBtn setTitle:nil forState:UIControlStateNormal];
            self.playBtn.hidden = self.reloadBtn.hidden = NO;
        });
    } failure:^(NSString *errorStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        });
    }];
}

#pragma mark -- Getters
#pragma mark 滚动视图
-(UIScrollView *)rootScrollView{
    if (!_rootScrollView) {
        _rootScrollView  = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kNavHeight, kScreenWidth, kScreenHeight-kNavHeight)];
        _rootScrollView.showsVerticalScrollIndicator=NO;
        _rootScrollView.backgroundColor = [UIColor whiteColor];
    }
    return _rootScrollView;
}

#pragma mark 说明
-(UILabel *)tipsLabel{
    if (!_tipsLabel) {
        _tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 20, kScreenWidth-50,IS_IPAD?70:65)];
        NSString *gradeStr = [self.grades componentsJoinedByString:@"、"];
        _tipsLabel.text = [NSString stringWithFormat:@"您选择了教授%@，请按要求讲解一下试题，请抄题后，把视频对着纸上进行讲解录制。",gradeStr];
        _tipsLabel.font = [UIFont regularFontWithSize:14];
        _tipsLabel.textColor = [UIColor commonColor_black];
        _tipsLabel.numberOfLines = 0;
    }
    return _tipsLabel;
}

#pragma mark 试题要求
-(UILabel *)testTitleLab{
    if (!_testTitleLab) {
        _testTitleLab = [[UILabel alloc] initWithFrame:CGRectMake(25, self.tipsLabel.bottom+(IS_IPAD?36:20), kScreenWidth-50,IS_IPAD?36:25)];
        _testTitleLab.font = [UIFont mediumFontWithSize:18];
        _testTitleLab.textColor = [UIColor colorWithHexString:@"#303030"];
        _testTitleLab.text = @"试讲要求";
    }
    return _testTitleLab;
}

#pragma mark 讲解要求
-(UILabel *)testDescLab{
    if (!_testDescLab) {
        _testDescLab = [[UILabel alloc] initWithFrame:CGRectZero];
        _testDescLab.font = [UIFont regularFontWithSize:13];
        _testDescLab.textColor = [UIColor commonColor_black];
        _testDescLab.numberOfLines=0;
        _testDescLab.text = @"1、教师试讲以下一题，按讲解流程要求录制3-5分钟的题目讲解视频。（2次机会）\n2、讲解流程要求：\n1）、引导学生审题，分析题意（问题、条件、关键信息等。）\n2）、帮助学生回顾相关知识点，建立解题思路，完成解题。\n3）、解题方法、知识点总结。\n注 ：教师普通话标准，语速适中，表达清晰自然，态度和蔼，语音环境安静无杂音，所讲解的思路和方法适合该学段的学生。";
        CGFloat labH = [_testDescLab.text boundingRectWithSize:CGSizeMake(kScreenWidth-50, CGFLOAT_MAX) withTextFont:_testDescLab.font].height;
        _testDescLab.frame = CGRectMake(25, self.testTitleLab.bottom+10, kScreenWidth-50, labH);
    }
    return _testDescLab;
}

#pragma mark 试题标题
-(UILabel *)topicTitleLab{
    if (!_topicTitleLab) {
        _topicTitleLab = [[UILabel alloc] initWithFrame:CGRectMake(25, self.testDescLab.bottom+10, kScreenWidth-50,IS_IPAD?36:25)];
        _topicTitleLab.font = [UIFont mediumFontWithSize:18];
        _topicTitleLab.textColor = [UIColor colorWithHexString:@"#303030"];
        _topicTitleLab.text = @"试讲题";
    }
    return _topicTitleLab;
}

#pragma mark 题目
-(UIImageView *)topicImgView{
    if (!_topicImgView) {
        _topicImgView = [[UIImageView alloc] initWithFrame:CGRectMake(25, self.topicTitleLab.bottom+10, kScreenWidth-50, 0)];
    }
    return _topicImgView;
}


#pragma mark 上传视频
-(UIButton *)uploadBtn{
    if (!_uploadBtn) {
        _uploadBtn = [[UIButton alloc] initWithFrame:CGRectMake(28, self.topicImgView.bottom+20,kScreenWidth-55,IS_IPAD?280:180)];
        [_uploadBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"#F1F1F5"] size:_uploadBtn.size] forState:UIControlStateNormal];
        [_uploadBtn setImage:[UIImage drawImageWithName:@"add_video" size:IS_IPAD?CGSizeMake(75, 69):CGSizeMake(50, 46)] forState:UIControlStateNormal];
        [_uploadBtn setTitle:@"（点击上传试讲视频）" forState:UIControlStateNormal];
        [_uploadBtn setTitleColor:[UIColor colorWithHexString:@"#9495A0"] forState:UIControlStateNormal];
        _uploadBtn.titleLabel.font = [UIFont regularFontWithSize:12];
        _uploadBtn.imageEdgeInsets = UIEdgeInsetsMake(-(_uploadBtn.height - _uploadBtn.titleLabel.height- _uploadBtn.titleLabel.y-54),(_uploadBtn.width-_uploadBtn.imageView.width)/2.0, 0, 0);
        _uploadBtn.titleEdgeInsets = UIEdgeInsetsMake(_uploadBtn.imageView.height+_uploadBtn.imageView.y-15, -_uploadBtn.imageView.width, 0, 0);
        [_uploadBtn addTarget:self action:@selector(uploadVideoAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _uploadBtn;
}

#pragma mark - 重新上传
-(UIButton *)reloadBtn{
    if (!_reloadBtn) {
        _reloadBtn = [[UIButton alloc] initWithFrame:IS_IPAD?CGRectMake((kScreenWidth-240)/2.0,self.uploadBtn.bottom+10, 240, 60): CGRectMake((kScreenWidth-160)/2.0,self.uploadBtn.bottom+10, 160, 44)];
        [_reloadBtn setTitle:@"重新上传视频" forState:UIControlStateNormal];
        [_reloadBtn setTitleColor:[UIColor colorWithHexString:@"#6D6D6D"] forState:UIControlStateNormal];
        _reloadBtn.titleLabel.font = [UIFont regularFontWithSize:14];
        _reloadBtn.layer.cornerRadius = 4.0;
        _reloadBtn.layer.borderColor = [UIColor colorWithHexString:@"#D8D8D8"].CGColor;
        _reloadBtn.layer.borderWidth = 1.0;
        [_reloadBtn addTarget:self action:@selector(uploadVideoAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _reloadBtn;
}

#pragma mark - play
-(UIButton *)playBtn{
    if (!_playBtn) {
        _playBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 34, 44)];
        _playBtn.center = self.uploadBtn.center;
        [_playBtn setImage:[UIImage imageNamed:@"user_play_video"] forState:UIControlStateNormal];
        [_playBtn addTarget:self action:@selector(playVideoAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playBtn;
}


#pragma mark 完成
-(UIButton *)confirmBtn{
    if (!_confirmBtn) {
        _confirmBtn =  [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-300)/2.0,self.reloadBtn.bottom+30, 300, 62)];
        [_confirmBtn setBackgroundImage:[UIImage imageNamed:@"button_background"] forState:UIControlStateNormal];
        [_confirmBtn setTitle:@"完成" forState:UIControlStateNormal];
        [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _confirmBtn.titleLabel.font = [UIFont mediumFontWithSize:16.0f];
        [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _confirmBtn.titleEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, 0);
        [_confirmBtn addTarget:self action:@selector(completeUploadVideoAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmBtn;
}

@end

//
//  UploadPaperworkViewController.m
//  HWForTeacher
//
//  Created by vision on 2019/9/24.
//  Copyright © 2019 vision. All rights reserved.
//

#import "UploadPaperworkViewController.h"

#define kPhotoWidth  kScreenWidth-55
#define kPhotoHeight (kScreenWidth-55)*(18.0/32.0)

@interface UploadPaperworkViewController ()

@property (nonatomic,strong) UIScrollView   *rootScrollView;
@property (nonatomic,strong) UILabel        *tipsLab;
@property (nonatomic,strong) UIView         *contentView;
@property (nonatomic,strong) UIButton       *confirmBtn;

@property (nonatomic,strong) UIButton      *addFrontBtn;   
@property (nonatomic,strong) UIButton      *addBackBtn;
@property (nonatomic,strong) UIButton      *addTeachBtn;
@property (nonatomic,strong) UIButton      *addProfessionBtn;

@property (nonatomic,assign) NSInteger     selectedIndex;

@property (nonatomic, copy ) NSString      *certFrontPic;  //身份证正面
@property (nonatomic, copy ) NSString      *certBackPic;   //身份证反面
@property (nonatomic, copy ) NSString      *teachPic;      //教师资格证
@property (nonatomic, copy ) NSString      *skillPic;      //职称


@end

@implementation UploadPaperworkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"上传证件";
    self.rightImageName = @"tutor_service";
    
    [self initUploadPaperworkView];
}

#pragma makr -- Delegate
#pragma mark  UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    [self.imgPicker dismissViewControllerAnimated:YES completion:nil];
    UIImage* curImage=[info objectForKey:UIImagePickerControllerOriginalImage];
    NSData *imageData = [UIImage zipNSDataWithImage:curImage];
    NSString *encodeResult = [imageData base64EncodedStringWithOptions:0]; //base64
    [[HttpRequest sharedInstance] postWithURLString:kUploadPicAPI parameters:@{@"pic":encodeResult,@"label":@1} success:^(id responseObject) {
        NSString *imgUrl = [responseObject objectForKey:@"data"];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(self.selectedIndex==0){
                self.certFrontPic = imgUrl;
                [self.addFrontBtn setImage:curImage forState:UIControlStateNormal];
            }else if (self.selectedIndex==1){
                self.certBackPic = imgUrl;
                [self.addBackBtn setImage:curImage forState:UIControlStateNormal];
            }else if (self.selectedIndex==2){
                self.teachPic = imgUrl;
                [self.addTeachBtn setImage:curImage forState:UIControlStateNormal];
            }else{
                self.skillPic = imgUrl;
                [self.addProfessionBtn setImage:curImage forState:UIControlStateNormal];
            }
        });
    } failure:^(NSString *errorStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        });
    }];
}

#pragma mark -- Event reponse
#pragma mark 客服
-(void)rightNavigationItemAction{
    [self pushToCustomerServiceVC];
}

#pragma mark 上传图片
-(void)addVerifiedPhotoAction:(UIButton *)sender{
    self.selectedIndex = sender.tag;
    [self addPhoto];
}

#pragma mark  完成
-(void)completeUploadPaperworkAction:(UIButton *)sender{
    if (kIsEmptyString(self.certFrontPic)) {
        [self.view makeToast:@"请上传身份证正面照片" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    if (kIsEmptyString(self.certBackPic)) {
        [self.view makeToast:@"请上传身份证反面照片" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    if (kIsEmptyString(self.teachPic)) {
        [self.view makeToast:@"请上传教师资格证照片" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    
    self.confirmBtn.userInteractionEnabled = NO;
    NSDictionary *params = @{@"token":kUserTokenValue,@"card_front":self.certFrontPic,@"card_reverse":self.certBackPic,@"license":self.teachPic,@"evaluation":kIsEmptyString(self.skillPic)?@"":self.skillPic};
    [[HttpRequest sharedInstance] postWithURLString:kUploadCertAPI parameters:params success:^(id responseObject) {
        [ZYHelper sharedZYHelper].isUpdateHome = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view makeToast:@"证件上传成功，请等待审核" duration:1.0 position:CSToastPositionCenter];
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

#pragma mark -- Private Methods
#pragma mark 初始化
-(void)initUploadPaperworkView{
    [self.view addSubview:self.rootScrollView];
    [self.rootScrollView addSubview:self.tipsLab];
    [self.rootScrollView addSubview:self.contentView];
    [self.rootScrollView addSubview:self.confirmBtn];
    self.rootScrollView.contentSize = CGSizeMake(kScreenWidth,self.confirmBtn.bottom+20);
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
-(UILabel *)tipsLab{
    if (!_tipsLab) {
        _tipsLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 15,kScreenWidth-40, 46)];
        _tipsLab.font = [UIFont regularFontWithSize:14];
        _tipsLab.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        _tipsLab.text = @"身份证和教师资格我们只做内部审核用，会严格遵循保密制度。";
        _tipsLab.numberOfLines = 0;
    }
    return _tipsLab;
}

#pragma mark 主界面
-(UIView *)contentView{
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectZero];
        NSArray *titlesArr = @[@"身份证正面",@"身份证反面",@"教师资格证",@"教师职称证书（可选）"];
        NSArray *tipsArr = @[@"（请上传身份证正面照片）",@"（请上传身份证反面照片）",@"（请上传教师资格证照片）",@"（请上传教师职称证书照片）"];
        NSArray *bgImages = @[@"identity_card_facade",@"identity_card_back",@"teacher_certification",@"grade_title"];
        for (NSInteger i=0; i<titlesArr.count; i++) {
            UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(25, 10+i*((IS_IPAD?100:80)+kPhotoHeight),kScreenWidth-50,IS_IPAD?32:20)];
            titleLab.font = [UIFont mediumFontWithSize:16];
            titleLab.textColor = [UIColor colorWithHexString:@"#303030"];
            titleLab.text = titlesArr[i];
            [_contentView addSubview:titleLab];
            
            UIButton *addPhotoBtn =[[UIButton alloc] initWithFrame:CGRectMake(28,titleLab.bottom+16,kPhotoWidth,kPhotoHeight)];
            addPhotoBtn.backgroundColor = [UIColor colorWithHexString:@"#F1F1F5"];
            [addPhotoBtn setBackgroundImage:[UIImage imageNamed:bgImages[i]] forState:UIControlStateNormal];
            [addPhotoBtn setImage:[UIImage drawImageWithName:@"certificate_add" size:CGSizeMake(74, 70)] forState:UIControlStateNormal];
            addPhotoBtn.adjustsImageWhenDisabled = NO;
            addPhotoBtn.adjustsImageWhenHighlighted = NO;
            addPhotoBtn.layer.cornerRadius = 5.0;
            addPhotoBtn.tag = i;
            [addPhotoBtn addTarget:self action:@selector(addVerifiedPhotoAction:) forControlEvents:UIControlEventTouchUpInside];
            [_contentView addSubview:addPhotoBtn];
            
            if (i==0) {
                self.addFrontBtn = addPhotoBtn;
            }else if (i==1){
                self.addBackBtn = addPhotoBtn;
            }else if (i==2){
                self.addTeachBtn = addPhotoBtn;
            }else{
                self.addProfessionBtn = addPhotoBtn;
            }
            
            UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(25,addPhotoBtn.bottom+10,kScreenWidth-50,IS_IPAD?32:20)];
            lab.font = [UIFont regularFontWithSize:14];
            lab.textColor = [UIColor colorWithHexString:@"#9B9B9B"];
            lab.textAlignment = NSTextAlignmentCenter;
            lab.text = tipsArr[i];
            [_contentView addSubview:lab];
        }
        
        _contentView.frame = CGRectMake(0, self.tipsLab.bottom, kScreenWidth, titlesArr.count*(kPhotoHeight+80)+10);
    }
    return _contentView;
}

#pragma mark 完成
-(UIButton *)confirmBtn{
    if (!_confirmBtn) {
        _confirmBtn =  [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-300)/2.0,self.contentView.bottom+20, 300, 62)];
        [_confirmBtn setBackgroundImage:[UIImage imageNamed:@"button_background"] forState:UIControlStateNormal];
        [_confirmBtn setTitle:@"完成" forState:UIControlStateNormal];
        [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _confirmBtn.titleLabel.font = [UIFont mediumFontWithSize:16.0f];
        _confirmBtn.titleEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, 0);
        [_confirmBtn addTarget:self action:@selector(completeUploadPaperworkAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmBtn;
}
                                 
@end

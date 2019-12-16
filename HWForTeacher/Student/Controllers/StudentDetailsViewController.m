//
//  StudentDetailsViewController.m
//  HWForTeacher
//
//  Created by vision on 2019/9/25.
//  Copyright © 2019 vision. All rights reserved.
//

#import "StudentDetailsViewController.h"
#import "StudentInfoView.h"
#import "UITextView+ZWPlaceHolder.h"
#import "UITextView+ZWLimitCounter.h"
#import "BRPickerView.h"
#import "StudentModel.h"

@interface StudentDetailsViewController ()<UITextFieldDelegate>

@property (nonatomic,strong) UIImageView     *bgImgView;
@property (nonatomic,strong) UIButton        *backBtn;
@property (nonatomic,strong) UILabel         *titleLab;
@property (nonatomic,strong) StudentInfoView *infoView;
@property (nonatomic,strong) UIView          *versionView;
@property (nonatomic,strong) UITextField     *versionTextField;
@property (nonatomic,strong) UILabel         *remarkTitleLab;
@property (nonatomic,strong) UITextView      *remarkTextView;
@property (nonatomic,strong) UIButton        *confirmBtn;

@property (nonatomic,strong) StudentModel    *studentModel;

@end

@implementation StudentDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isHiddenNavBar = YES;
    
    [self initStudentDetailView];
    [self loadStudentDetailsData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"学生详情"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"学生详情"];
}

#pragma mark UITextFieldDelegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (1 == range.length) {//按下回格键
        return YES;
    }
    if (self.versionTextField == textField) {
        if ([textField.text length] < 10) {
            return YES;
        }
    }
    return NO;
}

#pragma mark -- Event response
#pragma mark 保存
-(void)saveStudentRemarkAction:(UIButton *)sender{
    NSDictionary *params = @{@"token":kUserTokenValue,@"version":kIsEmptyString(self.versionTextField.text)?@"":self.versionTextField.text ,@"id":self.studentModel.id,@"remark":kIsEmptyString(self.remarkTextView.text)?@"":self.remarkTextView.text};
    [[HttpRequest sharedInstance] postWithURLString:kSubmitStudentAPI parameters:params success:^(id responseObject) {
        [ZYHelper sharedZYHelper].isUpdateStudent = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
           [self.view makeToast:@"学生备注信息提交成功" duration:1.0 position:CSToastPositionCenter];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
           [self.navigationController popViewControllerAnimated:YES];
        });
    } failure:^(NSString *errorStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        });
    }];
}

#pragma mark -- Private methods
#pragma mark 初始化
-(void)initStudentDetailView{
    [self.view addSubview:self.bgImgView];
    [self.view addSubview:self.backBtn];
    [self.view addSubview:self.titleLab];
    [self.view addSubview:self.infoView];
    [self.view addSubview:self.versionView];
    [self.view addSubview:self.remarkTitleLab];
    [self.view addSubview:self.remarkTextView];
    [self.view addSubview:self.confirmBtn];
}

#pragma mark 获取学生详情
-(void)loadStudentDetailsData{
    NSDictionary *params = @{@"token":kUserTokenValue,@"s_id":self.s_id};
    [[HttpRequest sharedInstance] postWithURLString:kStudentDetailAPI parameters:params success:^(id responseObject) {
        NSDictionary *data = [responseObject objectForKey:@"data"];
        [self.studentModel setValues:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.infoView.model = self.studentModel;
            self.versionTextField.text = kIsEmptyString(self.studentModel.version)?@"":self.studentModel.version;
            self.remarkTextView.text = self.studentModel.remark;
        });
    } failure:^(NSString *errorStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        });
    }];
}

#pragma mark -- Getters
#pragma mark 背景
-(UIImageView *)bgImgView{
    if (!_bgImgView) {
        _bgImgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _bgImgView.image = [UIImage imageNamed:@"student_details_background"];
    }
    return _bgImgView;
}

#pragma mark 返回
-(UIButton *)backBtn{
    if (!_backBtn) {
        _backBtn=[[UIButton alloc] initWithFrame:IS_IPAD?CGRectMake(10, KStatusHeight+9, 50, 50):CGRectMake(5,KStatusHeight + 2, 40, 40)];
        [_backBtn setImage:[UIImage drawImageWithName:@"return_black"size:IS_IPAD?CGSizeMake(13, 23):CGSizeMake(12, 18)] forState:UIControlStateNormal];
        [_backBtn setImageEdgeInsets:UIEdgeInsetsMake(0,-10.0, 0, 0)];
        [_backBtn addTarget:self action:@selector(leftNavigationItemAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

#pragma mark 标题
-(UILabel *)titleLab{
    if (!_titleLab) {
        _titleLab =[[UILabel alloc] initWithFrame:IS_IPAD?CGRectMake((kScreenWidth-280)/2.0, KStatusHeight+16, 280, 36):CGRectMake((kScreenWidth-180)/2, KStatusHeight+12, 180, 22)];
        _titleLab.textColor=[UIColor commonColor_black];
        _titleLab.font=[UIFont mediumFontWithSize:18];
        _titleLab.textAlignment=NSTextAlignmentCenter;
        _titleLab.text = @"学生详情";
    }
    return _titleLab;
}

#pragma mark 学生信息
-(StudentInfoView *)infoView{
    if (!_infoView) {
        _infoView = [[StudentInfoView alloc] initWithFrame:CGRectMake(0, kNavHeight, kScreenWidth,IS_IPAD?120:100)];
    }
    return _infoView;
}

#pragma mark 版本
-(UIView *)versionView{
    if (!_versionView) {
        _versionView = [[UIView alloc] initWithFrame:CGRectMake(20, self.infoView.bottom, kScreenWidth-40,IS_IPAD?62:50)];
        _versionView.backgroundColor = [UIColor whiteColor];
        [_versionView setBorderWithCornerRadius:8 type:UIViewCornerTypeAll];
        
       UILabel  *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15,15, 120,IS_IPAD?32:20)];
        titleLabel.textColor = [UIColor commonColor_black];
        titleLabel.font = [UIFont regularFontWithSize:15.0f];
        titleLabel.text = @"教材版本";
        [_versionView addSubview:titleLabel];
        
        self.versionTextField = [[UITextField alloc] initWithFrame:CGRectMake(kScreenWidth-240, 15, 160,IS_IPAD?32:20)];
        self.versionTextField.textColor = [UIColor colorWithHexString:@"#9495A0"];
        self.versionTextField.font = [UIFont regularFontWithSize:15.0f];
        self.versionTextField.placeholder = @"请输入教材版本";
        self.versionTextField.delegate = self;
        self.versionTextField.textAlignment = NSTextAlignmentRight;
        [_versionView addSubview:self.versionTextField];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(self.versionTextField.right+10,IS_IPAD?23:17, 9, 16)];
        imgView.image = [UIImage imageNamed:@"my_arrow_gray"];
        [_versionView addSubview:imgView];
        
    }
    return _versionView;
}

#pragma mark 备注标题
-(UILabel *)remarkTitleLab{
    if (!_remarkTitleLab) {
        _remarkTitleLab = [[UILabel alloc] initWithFrame:CGRectMake(20, self.versionView.bottom+29, 100,IS_IPAD?28:16)];
        _remarkTitleLab.text = @"备注";
        _remarkTitleLab.textColor = [UIColor colorWithHexString:@"#303030"];
        _remarkTitleLab.font = [UIFont mediumFontWithSize:16.0f];
    }
    return _remarkTitleLab;
}

#pragma mark 备注
-(UITextView *)remarkTextView{
    if (!_remarkTextView) {
        _remarkTextView = [[UITextView alloc] initWithFrame:CGRectMake(20, self.remarkTitleLab.bottom+14, kScreenWidth-40, 180)];
        _remarkTextView.backgroundColor = [UIColor colorWithHexString:@"#F0F0F7"];
        _remarkTextView.layer.cornerRadius = 8.0;
        _remarkTextView.font = [UIFont regularFontWithSize:14];
        _remarkTextView.zw_limitCount = 100;
        _remarkTextView.zw_labHeight  = 30;
        _remarkTextView.zw_placeHolder = @"请输入备注";
    }
    return _remarkTextView;
}

#pragma mark 完成
-(UIButton *)confirmBtn{
    if (!_confirmBtn) {
        _confirmBtn =  [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-300)/2.0,kScreenHeight-95, 300, 62)];
        [_confirmBtn setBackgroundImage:[UIImage imageNamed:@"button_background"] forState:UIControlStateNormal];
        [_confirmBtn setTitle:@"保存" forState:UIControlStateNormal];
        [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _confirmBtn.titleLabel.font = [UIFont mediumFontWithSize:16.0f];
        [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _confirmBtn.titleEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, 0);
        [_confirmBtn addTarget:self action:@selector(saveStudentRemarkAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmBtn;
}

-(StudentModel *)studentModel{
    if (!_studentModel) {
        _studentModel = [[StudentModel alloc] init];
    }
    return _studentModel;
}

@end

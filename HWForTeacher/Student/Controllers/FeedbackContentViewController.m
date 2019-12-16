//
//  FeedbackContentViewController.m
//  HWForTeacher
//
//  Created by vision on 2019/9/25.
//  Copyright © 2019 vision. All rights reserved.
//

#import "FeedbackContentViewController.h"
#import "UITextView+ZWLimitCounter.h"
#import "UITextView+ZWPlaceHolder.h"
#import "NSDate+Extend.h"

@interface FeedbackContentViewController ()

@property (nonatomic,strong) UIButton    *dateBtn;
@property (nonatomic,strong) UIButton    *advanTitleBtn;
@property (nonatomic,strong) UITextView  *advanTextView;
@property (nonatomic,strong) UIButton    *disavanTitleBtn;
@property (nonatomic,strong) UITextView  *disavanTextView;
@property (nonatomic,strong) UIButton    *submitBtn;

@end

@implementation FeedbackContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"辅导反馈";
    
    [self initFeedbackContentView];
    
}

#pragma mark -- Event response
#pragma mark 提交
-(void)submitFeedbackContentAction:(UIButton *)sender{
    if (kIsEmptyString(self.advanTextView.text)) {
        [self.view makeToast:@"请输入今天该生辅导时表现的优点" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    if (kIsEmptyString(self.disavanTextView.text)) {
        [self.view makeToast:@"请输入今天该生辅导时表现的欠缺点" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    NSDictionary *params = @{@"token":kUserTokenValue,@"id":self.id,@"merit":self.advanTextView.text,@"defect":self.disavanTextView.text};
    [[HttpRequest sharedInstance] postWithURLString:kFeedbackSubmitAPI parameters:params success:^(id responseObject) {
        [ZYHelper sharedZYHelper].isUpdateFeedback = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
           [self.view makeToast:@"您的辅导反馈已提交" duration:1.0 position:CSToastPositionCenter];
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

#pragma mark -- Private Methods
#pragma mark 初始化
-(void)initFeedbackContentView{
    [self.view addSubview:self.dateBtn];
    [self.view addSubview:self.advanTitleBtn];
    [self.view addSubview:self.advanTextView];
    [self.view addSubview:self.disavanTitleBtn];
    [self.view addSubview:self.disavanTextView];
    [self.view addSubview:self.submitBtn];
}

#pragma mark -- Getters
#pragma mark 日期
-(UIButton *)dateBtn{
    if (!_dateBtn) {
        _dateBtn = [[UIButton alloc] initWithFrame:CGRectMake(25,kNavHeight + 20,IS_IPAD?150:120,IS_IPAD?30:20)];
        [_dateBtn setImage:[UIImage drawImageWithName:@"my_teacher_time" size:IS_IPAD?CGSizeMake(24, 24):CGSizeMake(20, 20)] forState:UIControlStateNormal];
        [_dateBtn setTitle:[NSDate currentDateTimeWithFormat:@"yyyy-MM-dd"] forState:UIControlStateNormal];
        [_dateBtn setTitleColor:[UIColor colorWithHexString:@"#FF8B00"] forState:UIControlStateNormal];
        _dateBtn.titleLabel.font = [UIFont mediumFontWithSize:15.0f];
        _dateBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 0);
        _dateBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -4, 0, 0);
    }
    return _dateBtn;
}

#pragma mark 优点
-(UIButton *)advanTitleBtn{
    if (!_advanTitleBtn) {
        _advanTitleBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, self.dateBtn.bottom+20, 90,IS_IPAD?32:20)];
        [_advanTitleBtn setImage:[UIImage drawImageWithName:@"tutor_feedback_advantage" size:IS_IPAD?CGSizeMake(30, 30):CGSizeMake(20, 20)] forState:UIControlStateNormal];
        [_advanTitleBtn setTitle:@"优点" forState:UIControlStateNormal];
        [_advanTitleBtn setTitleColor:[UIColor commonColor_black] forState:UIControlStateNormal];
        _advanTitleBtn.titleLabel.font = [UIFont mediumFontWithSize:18.0f];
        _advanTitleBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 0);
        _advanTitleBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -4, 0, 0);
    }
    return _advanTitleBtn;
}

#pragma mark 优点
-(UITextView *)advanTextView{
    if (!_advanTextView) {
        _advanTextView = [[UITextView alloc] initWithFrame:CGRectMake(25, self.advanTitleBtn.bottom+20, kScreenWidth-50,IS_IPAD?200:150)];
        _advanTextView.layer.borderWidth = 1.0;
        _advanTextView.layer.borderColor = [UIColor colorWithHexString:@"#EEEFF2"].CGColor;
        _advanTextView.layer.cornerRadius = 6.0;
        _advanTextView.backgroundColor = [UIColor colorWithHexString:@"#FAFAFB"];
        _advanTextView.font = [UIFont regularFontWithSize:14];
        _advanTextView.zw_limitCount = 100;
        _advanTextView.zw_labHeight  = 30;
        _advanTextView.zw_placeHolder = @"请输入今天该生辅导时表现的优点。";
    }
    return _advanTextView;
}

#pragma mark 缺点标题
-(UIButton *)disavanTitleBtn{
    if (!_disavanTitleBtn) {
        _disavanTitleBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, self.advanTextView.bottom+20, 90,IS_IPAD?30:20)];
        [_disavanTitleBtn setImage:[UIImage drawImageWithName:@"tutor_feedback_shortcoming" size:IS_IPAD?CGSizeMake(30, 30):CGSizeMake(20, 20)] forState:UIControlStateNormal];
        [_disavanTitleBtn setTitle:@"欠缺" forState:UIControlStateNormal];
        [_disavanTitleBtn setTitleColor:[UIColor commonColor_black] forState:UIControlStateNormal];
        _disavanTitleBtn.titleLabel.font = [UIFont mediumFontWithSize:18.0f];
        _disavanTitleBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 0);
        _disavanTitleBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -4, 0, 0);
    }
    return _disavanTitleBtn;
}

#pragma mark 缺点
-(UITextView *)disavanTextView{
    if (!_disavanTextView) {
        _disavanTextView = [[UITextView alloc] initWithFrame:CGRectMake(25, self.disavanTitleBtn.bottom+20, kScreenWidth-50,IS_IPAD?200:150)];
        _disavanTextView.layer.borderWidth = 1.0;
        _disavanTextView.layer.borderColor = [UIColor colorWithHexString:@"#EEEFF2"].CGColor;
        _disavanTextView.layer.cornerRadius = 6.0;
        _disavanTextView.backgroundColor = [UIColor colorWithHexString:@"#FAFAFB"];
        _disavanTextView.font = [UIFont regularFontWithSize:14];
        _disavanTextView.zw_limitCount = 100;
        _disavanTextView.zw_labHeight  = 30;
        _disavanTextView.zw_placeHolder = @"请输入今天该生辅导时表现的欠缺点，或者描述知识点欠缺的地方。";
    }
    return _disavanTextView;
}

#pragma mark 完成
-(UIButton *)submitBtn{
    if (!_submitBtn) {
        _submitBtn =  [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-300)/2.0,kScreenHeight-95, 300, 62)];
        [_submitBtn setBackgroundImage:[UIImage imageNamed:@"button_background"] forState:UIControlStateNormal];
        [_submitBtn setTitle:@"提交" forState:UIControlStateNormal];
        [_submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _submitBtn.titleLabel.font = [UIFont mediumFontWithSize:16.0f];
        [_submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_submitBtn addTarget:self action:@selector(submitFeedbackContentAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _submitBtn;
}

@end

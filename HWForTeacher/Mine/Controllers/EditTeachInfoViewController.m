//
//  EditTeachInfoViewController.m
//  HWForTeacher
//
//  Created by vision on 2019/9/28.
//  Copyright © 2019 vision. All rights reserved.
//

#import "EditTeachInfoViewController.h"
#import "UITextView+ZWPlaceHolder.h"
#import "UITextView+ZWLimitCounter.h"

@interface EditTeachInfoViewController ()

@property (nonatomic,strong) UITextView   *teachTextView;
@property (nonatomic,strong) UIButton     *saveBtn;

@end

@implementation EditTeachInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.baseTitle = self.titleStr;
    
    [self.view addSubview:self.teachTextView];
    [self.view addSubview:self.saveBtn];
}

#pragma mark -- Event response
#pragma mark 保存
-(void)saveTeachInfoAction:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:YES];
    if ([self.delgate respondsToSelector:@selector(editTeachInfoViewControllerDidSaveTeachInfo:type:)]) {
        [self.delgate editTeachInfoViewControllerDidSaveTeachInfo:self.teachTextView.text type:self.titleStr];
    }
}

#pragma mark -- Getters
#pragma mark 教学信息
-(UITextView *)teachTextView{
    if (!_teachTextView) {
        _teachTextView = [[UITextView alloc] initWithFrame:CGRectMake(30, kNavHeight+18, kScreenWidth-60,IS_IPAD?320:260)];
        [_teachTextView setBorderWithCornerRadius:4.0 type:UIViewCornerTypeAll];
        _teachTextView.backgroundColor = [UIColor colorWithHexString:@"#FAFAFB"];
        _teachTextView.textColor = [UIColor colorWithHexString:@"#6D6D6D"];
        _teachTextView.font = [UIFont regularFontWithSize:14];
        _teachTextView.layer.borderColor = [UIColor colorWithHexString:@"#EEEFF2"].CGColor;
        _teachTextView.layer.cornerRadius = 6.0;
        _teachTextView.layer.borderWidth = 1.0;
        _teachTextView.zw_limitCount = 300;
        _teachTextView.zw_labHeight  = 30;
        _teachTextView.text = self.teachInfo;
        _teachTextView.zw_placeHolder = [NSString stringWithFormat:@"请输入您的%@",self.titleStr];
    }
    return _teachTextView;
}

#pragma mark 保存
-(UIButton *)saveBtn{
    if (!_saveBtn) {
        _saveBtn =  [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-300)/2.0,kScreenHeight-97, 300, 62)];
        [_saveBtn setBackgroundImage:[UIImage imageNamed:@"button_background"] forState:UIControlStateNormal];
        [_saveBtn setTitle:@"完成" forState:UIControlStateNormal];
        [_saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _saveBtn.titleLabel.font = [UIFont mediumFontWithSize:16.0f];
        [_saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _saveBtn.titleEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, 0);
        [_saveBtn addTarget:self action:@selector(saveTeachInfoAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveBtn;
}

@end

//
//  SubjectViewController.m
//  HWForTeacher
//
//  Created by vision on 2019/9/24.
//  Copyright © 2019 vision. All rights reserved.
//

#import "SubjectViewController.h"
#import "GradeViewController.h"

#define kBtnWidth (kScreenWidth-80-19*2)/3.0

@interface SubjectViewController (){
    UIButton  *selBtn;
}

@property (nonatomic,strong)NSArray  *subjectsArr;

@end

@implementation SubjectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.subjectsArr = [ZYHelper sharedZYHelper].subjects;
    
    [self initSubjectView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"选择科目"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"选择科目"];
}

#pragma mark -- Event response
#pragma mark 选择科目
-(void)chooseSubjectAction:(UIButton *)sender{
    if (selBtn) {
        selBtn.backgroundColor = [UIColor bm_colorGradientChangeWithSize:CGSizeMake(kBtnWidth, 38) direction:IHGradientChangeDirectionVertical startColor:[UIColor colorWithHexString:@"#F8F9FA"] endColor:[UIColor colorWithHexString:@"#EFF1F3"]];
        [selBtn setTitleColor:[UIColor colorWithHexString:@"#9C9DA8"] forState:UIControlStateNormal];
    }
    sender.backgroundColor = [UIColor bm_colorGradientChangeWithSize:CGSizeMake(kBtnWidth, 38) direction:IHGradientChangeDirectionVertical startColor:[UIColor colorWithHexString:@"#FF3737"] endColor:[UIColor colorWithHexString:@"#FF5777"]];
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    selBtn = sender;
}

#pragma mark 下一步
-(void)gradeForNextStepAction:(UIButton *)sender{
    GradeViewController *gradeVC = [[GradeViewController alloc] init];
    gradeVC.subject = self.subjectsArr[selBtn.tag];
    gradeVC.subjectInt = selBtn.tag+1;
    [self.navigationController pushViewController:gradeVC animated:YES];
}

#pragma mark -- Getters
#pragma mark 初始化界面
-(void)initSubjectView{
    UILabel  *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, kNavHeight+33, kScreenWidth-80,IS_IPAD?36:24)];
    titleLabel.font = [UIFont mediumFontWithSize:24.0f];
    titleLabel.textColor = [UIColor colorWithHexString:@"#303030"];
    titleLabel.text = @"请选择您辅导的科目";
    [self.view addSubview:titleLabel];
    
    for (NSInteger i=0; i<self.subjectsArr.count; i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(40+(i%3)*(kBtnWidth+19), titleLabel.bottom+(IS_IPAD?50:38)+(i/3)*((IS_IPAD?50:38)+18), kBtnWidth,IS_IPAD?50:38)];
        btn.backgroundColor = [UIColor bm_colorGradientChangeWithSize:btn.size direction:IHGradientChangeDirectionVertical startColor:[UIColor colorWithHexString:@"#F8F9FA"] endColor:[UIColor colorWithHexString:@"#EFF1F3"]];
        [btn setTitle:self.subjectsArr[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithHexString:@"#9C9DA8"] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont regularFontWithSize:16.0f];
        btn.layer.cornerRadius =IS_IPAD?25:19.0f;
        if (i==0) {
            btn.backgroundColor = [UIColor bm_colorGradientChangeWithSize:btn.size direction:IHGradientChangeDirectionVertical startColor:[UIColor colorWithHexString:@"#FF3737"] endColor:[UIColor colorWithHexString:@"#FF5777"]];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            selBtn = btn;
        }
        btn.tag = i;
        [btn addTarget:self action:@selector(chooseSubjectAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
    
    UIButton *nextBtn = [[UIButton alloc] initWithFrame:IS_IPAD?CGRectMake(kScreenWidth-130, kScreenHeight-220, 100, 100):CGRectMake(kScreenWidth-85, kScreenHeight-128, 60, 60)];
    [nextBtn setImage:[UIImage drawImageWithName:@"landing_nextstep_2" size:nextBtn.size] forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(gradeForNextStepAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextBtn];
}


@end

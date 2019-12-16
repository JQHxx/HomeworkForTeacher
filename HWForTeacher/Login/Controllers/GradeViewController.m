//
//  GradeViewController.m
//  HWForTeacher
//
//  Created by vision on 2019/9/19.
//  Copyright © 2019 vision. All rights reserved.
//

#import "GradeViewController.h"
#import "AppDelegate.h"
#import "MyTabBarController.h"

#define kBtnWidth (kScreenWidth-80-19*2)/3.0

@interface GradeViewController (){
    NSArray          *gradesArr;
    NSMutableArray   *selBtnsArray;
}

@end

@implementation GradeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    gradesArr = [[ZYHelper sharedZYHelper] getGradesWithSubject:self.subject];
    selBtnsArray = [[NSMutableArray alloc] init];
    
    [self initGradeView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"选择年级"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"选择年级"];
}

#pragma mark -- Event response
#pragma mark 选择年级
-(void)chooseGradeAction:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (sender.selected) {
        if (selBtnsArray.count>2) {
            sender.selected = NO;
            sender.backgroundColor = [UIColor bm_colorGradientChangeWithSize:CGSizeMake(kBtnWidth, 38) direction:IHGradientChangeDirectionVertical startColor:[UIColor colorWithHexString:@"#F8F9FA"] endColor:[UIColor colorWithHexString:@"#EFF1F3"]];
            [selBtnsArray removeObject:sender];
            [self.view makeToast:@"最多可以选择三个年级" duration:1.0 position:CSToastPositionCenter];
            return;
        }
        sender.backgroundColor = [UIColor bm_colorGradientChangeWithSize:CGSizeMake(kBtnWidth, 38) direction:IHGradientChangeDirectionVertical startColor:[UIColor colorWithHexString:@"#FF3737"] endColor:[UIColor colorWithHexString:@"#FF5777"]];
        [selBtnsArray addObject:sender];
    }else{
        sender.backgroundColor = [UIColor bm_colorGradientChangeWithSize:CGSizeMake(kBtnWidth, 38) direction:IHGradientChangeDirectionVertical startColor:[UIColor colorWithHexString:@"#F8F9FA"] endColor:[UIColor colorWithHexString:@"#EFF1F3"]];
        [selBtnsArray removeObject:sender];
    }
}

#pragma mark 下一步
-(void)confirmChooseAction:(UIButton *)sender{
    NSMutableArray *tempGradeTagsArr = [[NSMutableArray alloc] init];
    for (UIButton *btn in selBtnsArray) {
        [tempGradeTagsArr addObject:[NSNumber numberWithInteger:btn.tag+1]];
    }
    NSArray *grades = [tempGradeTagsArr sortedArrayUsingSelector:@selector(compare:)];
    MyLog(@"tags：%@",grades);
    NSString *gradeJsonStr = [[ZYHelper sharedZYHelper] getValueWithParams:grades];
    NSDictionary *params = @{@"token":kUserTokenValue,@"subject":[NSNumber numberWithInteger:self.subjectInt],@"grades":gradeJsonStr};
    [[HttpRequest sharedInstance] postWithURLString:kSetTeachInfoAPI parameters:params success:^(id responseObject) {
        [NSUserDefaultsInfos putKey:kIsLogin andValue:[NSNumber numberWithBool:YES]];
        dispatch_async(dispatch_get_main_queue(), ^{
           AppDelegate *appDelegate = kAppDelegate;
           MyTabBarController *myTabbarVC = [[MyTabBarController alloc] init];
           appDelegate.window.rootViewController = myTabbarVC;
        });
    } failure:^(NSString *errorStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        });
    }];
}

#pragma mark -- Private methods
#pragma mark 初始化
-(void)initGradeView{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, kNavHeight+33, kScreenWidth-80,IS_IPAD?36:24)];
    titleLabel.font = [UIFont mediumFontWithSize:24.0f];
    titleLabel.textColor = [UIColor colorWithHexString:@"#303030"];
    titleLabel.text = @"请选择您辅导的年级";
    [self.view addSubview:titleLabel];
    
    UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(40,titleLabel.bottom+10, kScreenWidth-80,IS_IPAD?36:24)];
    tipsLabel.font = [UIFont regularFontWithSize:14.0f];
    tipsLabel.textColor = [UIColor colorWithHexString:@"#303030"];
    tipsLabel.text = @"*最多可以选择三个年级";
    [self.view addSubview:tipsLabel];
    
    CGFloat tempViewheight = 0.0;
    for (NSInteger i=0; i<gradesArr.count; i++) {
        NSDictionary *dict = gradesArr[i];
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(40,tipsLabel.bottom+30+tempViewheight,IS_IPAD?8:3,IS_IPAD?23:13)];
        bgView.backgroundColor = [UIColor commonColor_red];
        [self.view addSubview:bgView];
        
        UILabel  *gradeTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(bgView.right+6, tipsLabel.bottom+28+tempViewheight,160,IS_IPAD?27:17)];
        gradeTitleLabel.font = [UIFont mediumFontWithSize:16.0f];
        gradeTitleLabel.textColor = [UIColor colorWithHexString:@"#303030"];
        gradeTitleLabel.text = dict[@"type"];
        [self.view addSubview:gradeTitleLabel];
        
        NSArray *tempGradesArr = dict[@"values"];
        for (NSInteger j=0; j<tempGradesArr.count; j++) {
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(40+(j%3)*(kBtnWidth+19), gradeTitleLabel.bottom+18+(j/3)*(IS_IPAD?78:56), kBtnWidth,(IS_IPAD?50:38))];
            btn.backgroundColor = [UIColor bm_colorGradientChangeWithSize:btn.size direction:IHGradientChangeDirectionVertical startColor:[UIColor colorWithHexString:@"#F8F9FA"] endColor:[UIColor colorWithHexString:@"#EFF1F3"]];
            [btn setTitle:tempGradesArr[j] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor colorWithHexString:@"#9C9DA8"] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            btn.titleLabel.font = [UIFont regularFontWithSize:16.0f];
            btn.layer.cornerRadius = IS_IPAD?25:19.0f;
            btn.tag = gradesArr.count==1?6+j:i*6+j;
            [btn addTarget:self action:@selector(chooseGradeAction:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:btn];
        }
        tempViewheight = (i+1)*((IS_IPAD?50:38)+18)*(tempGradesArr.count/3)+45;
    }
    
    UILabel *descLab = [[UILabel alloc] initWithFrame:IS_IPAD?CGRectMake(40, kScreenHeight-150, kScreenWidth-80, 36):CGRectMake(40,kScreenHeight-110, kScreenWidth-80, 24)];
    descLab.font = [UIFont regularFontWithSize:13.0f];
    descLab.textColor = [UIColor colorWithHexString:@"#9495A0"];
    descLab.text = @"*辅导年级确定后，将不能修改";
    descLab.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:descLab];
    
    UIButton *btn =  [[UIButton alloc] initWithFrame:IS_IPAD?CGRectMake((kScreenWidth-360)/2.0, descLab.bottom+10, 360, 80): CGRectMake((kScreenWidth-300)/2.0,kScreenHeight-85, 300, 62)];
    [btn setBackgroundImage:[UIImage imageNamed:@"button_background"] forState:UIControlStateNormal];
    [btn setTitle:@"确定" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont mediumFontWithSize:16.0f];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, 0);
    [btn addTarget:self action:@selector(confirmChooseAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
}


@end

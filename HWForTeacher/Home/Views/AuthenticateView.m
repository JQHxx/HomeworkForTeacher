//
//  AuthenticateView.m
//  HWForTeacher
//
//  Created by vision on 2019/9/24.
//  Copyright © 2019 vision. All rights reserved.
//

#import "AuthenticateView.h"

#define kBtnCap (kScreenWidth-80-(IS_IPAD?80:44)*3)/2.0

@interface AuthenticateView ()

@property (nonatomic,strong) UIImageView    *bgImgView;
@property (nonatomic,strong) UILabel        *titlelab;
@property (nonatomic,strong) UIView         *headView;
@property (nonatomic,strong) UIImageView    *arrowImgView;
@property (nonatomic,strong) UIImageView    *bgView;
@property (nonatomic,strong) UILabel        *tipsLab1;
@property (nonatomic,strong) UIButton       *btn1;
@property (nonatomic,strong) UILabel        *tipsLab2;
@property (nonatomic,strong) UIButton       *btn2;

@property (nonatomic,strong) NSMutableArray *imgViewsArr;

@end

@implementation AuthenticateView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.bgImgView];
        [self addSubview:self.titlelab];
        [self addSubview:self.headView];
        [self addSubview:self.arrowImgView];
        [self addSubview:self.bgView];
        [self addSubview:self.tipsLab1];
        [self addSubview:self.btn1];
        [self addSubview:self.tipsLab2];
        [self addSubview:self.btn2];
    }
    return self;
}

#pragma mark -- Event response
#pragma mark 按钮操作
-(void)btnHandlerAction:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(authenticateViewDidClickBtn:step:)]) {
        [self.delegate authenticateViewDidClickBtn:sender.tag step:self.selectStep];
    }
}

#pragma mark -- Setters
#pragma mark 用户信息
-(void)setUserModel:(UserModel *)userModel{
    _userModel = userModel;
}

#pragma mark 选择步骤
-(void)setSelectStep:(NSInteger)selectStep{
    _selectStep = selectStep;
    
    for (UIImageView *imgView in self.imgViewsArr) {
        if (imgView.tag==selectStep) {
            imgView.image = [UIImage imageNamed:@"oval_big"];
        }else{
            imgView.image = [UIImage imageNamed:@"oval_small"];
        }
    }
    CGRect aFrame = self.arrowImgView.frame;
    aFrame.origin.x = 40 + selectStep*((IS_IPAD?80:44)+kBtnCap)+(IS_IPAD?68:36)/2.0;
    self.arrowImgView.frame = aFrame;
    
    if (selectStep==1) {
        self.btn2.hidden = YES;
        self.tipsLab1.text = @"岗前培训";
        self.btn1.userInteractionEnabled = YES;
        [self.btn1 setTitle:@"去完成" forState:UIControlStateNormal];
        self.btn1.backgroundColor = [self getBtnBgColorWithState:@"去完成"];
        self.tipsLab2.text = @"请添加微信号：zuoye1001 获取资料";
    }else{
        self.btn2.hidden = NO;
        if (selectStep==0) {
            self.tipsLab1.text = @"上传身份证、教师资格证";
            NSArray *grades = self.userModel.grade;
            self.tipsLab2.text = [NSString stringWithFormat:@"上传%@试讲视频",[grades componentsJoinedByString:@"、"]];
            
            NSString *title1 = [self getBtnTitleWithState:[self.userModel.card_state integerValue]];
            [self.btn1 setTitle:title1 forState:UIControlStateNormal];
            self.btn1.backgroundColor = [self getBtnBgColorWithState:title1];
            self.btn1.userInteractionEnabled = [self setBtnEnabledWithState:title1];
            
            NSString *title2 = [self getBtnTitleWithState:[self.userModel.video_state integerValue]];
            [self.btn2 setTitle:title2 forState:UIControlStateNormal];
            self.btn2.backgroundColor = [self getBtnBgColorWithState:title2];
            self.btn2.userInteractionEnabled = [self setBtnEnabledWithState:title2];
        }else if (selectStep==2){
            self.tipsLab1.text = @"完善个人资料";
            NSString *title1 = [self getOtherBtnTitleWithState:[self.userModel.state integerValue]];
            [self.btn1 setTitle:title1 forState:UIControlStateNormal];
            self.btn1.backgroundColor = [self getBtnBgColorWithState:title1];
            self.btn1.userInteractionEnabled = [self setBtnEnabledWithState:title1];
            
            self.tipsLab2.text = @"设置辅导时间";
            NSString *title2 = [self getOtherBtnTitleWithState:[self.userModel.guide_state integerValue]];
            [self.btn2 setTitle:title2 forState:UIControlStateNormal];
            self.btn2.backgroundColor = [self getBtnBgColorWithState:title2];
            self.btn2.userInteractionEnabled = [self setBtnEnabledWithState:title2];
        }
    }
}


#pragma mark -- Private methods
#pragma mark 画虚线
-(void)drawDashLine:(UIView *)lineView lineLength:(int)lineLength lineSpacing:(int)lineSpacing lineColor:(UIColor *)lineColor{
  CAShapeLayer *shapeLayer = [CAShapeLayer layer];
  [shapeLayer setBounds:lineView.bounds];
  [shapeLayer setPosition:CGPointMake(CGRectGetWidth(lineView.frame) / 2, CGRectGetHeight(lineView.frame))];
  [shapeLayer setFillColor:[UIColor clearColor].CGColor];
  //  设置虚线颜色为blackColor
  [shapeLayer setStrokeColor:lineColor.CGColor];
  //  设置虚线宽度
  [shapeLayer setLineWidth:CGRectGetHeight(lineView.frame)];
  [shapeLayer setLineJoin:kCALineJoinRound];
  //  设置线宽，线间距
  [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:lineLength], [NSNumber numberWithInt:lineSpacing], nil]];
  //  设置路径
  CGMutablePathRef path = CGPathCreateMutable();
  CGPathMoveToPoint(path, NULL, 0, 0);
  CGPathAddLineToPoint(path, NULL, CGRectGetWidth(lineView.frame), 0);
  [shapeLayer setPath:path];
  CGPathRelease(path);
  //  把绘制好的虚线添加上来
  [lineView.layer addSublayer:shapeLayer];
}

#pragma mark 获取状态
-(NSString *)getBtnTitleWithState:(NSInteger)state{
    NSString *title;
    switch (state) {
        case 0:
            title = @"去完成";
            break;
        case 1:
            title = @"待审核";
            break;
        case 2:
            title = @"已通过";
            break;
        default:
            title = @"不通过";
            break;
    }
    return title;
}

#pragma mark 获取状态
-(NSString *)getOtherBtnTitleWithState:(NSInteger)state{
    NSString *title;
    switch (state) {
        case 0:
            title = @"去完成";
            break;
        case 1:
            title = @"已通过";
            break;
        case 2:
            title = @"待审核";
            break;
        default:
            title = @"不通过";
            break;
    }
    return title;
}

#pragma mark 按钮背景色
-(UIColor *)getBtnBgColorWithState:(NSString *)state{
    UIColor *color ;
    if ([state isEqualToString:@"待审核"]||[state isEqualToString:@"已通过"]) {
         color = [UIColor bm_colorGradientChangeWithSize:_btn1.size direction:IHGradientChangeDirectionVertical startColor:[UIColor colorWithHexString:@"#C7C7C7"] endColor:[UIColor colorWithHexString:@"#ADADAD"]];
    }else{
        color = [UIColor bm_colorGradientChangeWithSize:_btn1.size direction:IHGradientChangeDirectionVertical startColor:[UIColor colorWithHexString:@"#FF3737"] endColor:[UIColor colorWithHexString:@"#FF5777"]];
    }
    return color;
}

-(BOOL)setBtnEnabledWithState:(NSString *)state{
    BOOL enabled = YES;
    if ([state isEqualToString:@"待审核"]||[state isEqualToString:@"已通过"]) {
        enabled = NO;
    }else{
        enabled = YES;
    }
    return enabled;
}

#pragma mark -- getters
#pragma mark 背景
-(UIImageView *)bgImgView{
    if (!_bgImgView) {
        _bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, kScreenWidth-40,IS_IPAD?246:178)];
        _bgImgView.image = [UIImage drawImageWithName:@"home_authentication_process_background" size:_bgImgView.size];
    }
    return _bgImgView;
}

#pragma mark 标题
-(UILabel *)titlelab{
    if (!_titlelab) {
        _titlelab = [[UILabel alloc] initWithFrame:CGRectMake(30, 35, kScreenWidth-60,IS_IPAD?28:16)];
        _titlelab.textColor=[UIColor whiteColor];
        _titlelab.font=[UIFont mediumFontWithSize:15];
        _titlelab.textAlignment = NSTextAlignmentCenter;
        _titlelab.text = @"作业101家教老师注册认证流程";
    }
    return _titlelab;
}

#pragma mark 认证头部
-(UIView *)headView{
    if (!_headView) {
        _headView = [[UIView alloc] initWithFrame:CGRectMake(0, self.titlelab.bottom, kScreenWidth,IS_IPAD?72:60)];
        
        UIView *dotView = [[UIView alloc] initWithFrame:CGRectMake(60, 30, kScreenWidth-120, 1)];
        [self drawDashLine:dotView lineLength:1 lineSpacing:1 lineColor:[UIColor whiteColor]];
        [_headView addSubview:dotView];
        
        NSArray *titles = @[@"上传信息",@"岗前培训",@"完善资料"];
        for (NSInteger i=0; i<titles.count; i++) {
            UILabel *titleLab = [[UILabel alloc] initWithFrame:IS_IPAD?CGRectMake(40+i*(80+kBtnCap), 50, 80, 32):CGRectMake(40+i*(44+kBtnCap), 40,44, 20)];
            titleLab.text = titles[i];
            titleLab.textAlignment =NSTextAlignmentCenter;
            titleLab.font = [UIFont regularFontWithSize:11];
            titleLab.textColor = [UIColor whiteColor];
            [_headView addSubview:titleLab];
            
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:IS_IPAD?CGRectMake(titleLab.left+(80-30)/2.0, 15, 30, 30):CGRectMake(titleLab.left+11, 20, 20, 20)];
            imgView.image = [UIImage imageNamed:i==0?@"oval_big":@"oval_small"];
            imgView.tag = i;
            [_headView addSubview:imgView];
            [self.imgViewsArr addObject:imgView];
        }
    }
    return _headView;
}

#pragma mark 箭头
-(UIImageView *)arrowImgView{
    if (!_arrowImgView) {
        _arrowImgView = [[UIImageView alloc] initWithFrame:IS_IPAD?CGRectMake(40+(80-13.5)/2.0, self.headView.bottom+20, 13.5, 12):CGRectMake(40 +(44-8)/2.0, self.headView.bottom+5, 9, 8)];
        _arrowImgView.image = [UIImage imageNamed:@"home_authentication_process_arrow"];
    }
    return _arrowImgView;
}

#pragma mark 背景
-(UIImageView *)bgView{
    if (!_bgView) {
        _bgView = [[UIImageView alloc] initWithFrame:CGRectMake(35, self.arrowImgView.bottom, kScreenWidth-70,IS_IPAD?86:64)];
        _bgView.image = [UIImage imageNamed:@"home_authentication_process"];
    }
    return _bgView;
}

#pragma mark 介绍1
-(UILabel *)tipsLab1{
    if (!_tipsLab1) {
        _tipsLab1 = [[UILabel alloc] initWithFrame:CGRectMake(45, self.arrowImgView.bottom+10, kScreenWidth-140,IS_IPAD?32:20)];
        _tipsLab1.textColor=[UIColor colorWithHexString:@"#85513E"];
        _tipsLab1.font=[UIFont regularFontWithSize:12];
        _tipsLab1.text = @"上传身份证、教师资格证";
    }
    return _tipsLab1;
}

#pragma mark 按钮1
-(UIButton *)btn1{
    if (!_btn1) {
        _btn1 = [[UIButton alloc] initWithFrame:IS_IPAD?CGRectMake(kScreenWidth-125, self.arrowImgView.bottom+10, 80, 32):CGRectMake(kScreenWidth-95, self.arrowImgView.bottom+10, 50,20)];
        [_btn1 setTitle:@"待审核" forState:UIControlStateNormal];
        [_btn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _btn1.backgroundColor = [UIColor bm_colorGradientChangeWithSize:_btn1.size direction:IHGradientChangeDirectionVertical startColor:[UIColor colorWithHexString:@"#C7C7C7"] endColor:[UIColor colorWithHexString:@"#ADADAD"]];
        _btn1.layer.cornerRadius = 4.0;
        _btn1.titleLabel.font = [UIFont regularFontWithSize:12.0f];
        _btn1.tag = 100;
        [_btn1 addTarget:self action:@selector(btnHandlerAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btn1;
}

#pragma mark 介绍2
-(UILabel *)tipsLab2{
    if (!_tipsLab2) {
        _tipsLab2 = [[UILabel alloc] initWithFrame:CGRectMake(45, self.tipsLab1.bottom+5, kScreenWidth-140,IS_IPAD?32:20)];
        _tipsLab2.textColor=[UIColor colorWithHexString:@"#85513E"];
        _tipsLab2.font=[UIFont regularFontWithSize:12];
        _tipsLab2.text = @"上传三年级、四年级、五年级试讲视频";
    }
    return _tipsLab2;
}

#pragma mark 按钮2
-(UIButton *)btn2{
    if (!_btn2) {
        _btn2 = [[UIButton alloc] initWithFrame:IS_IPAD?CGRectMake(kScreenWidth-125, self.btn1.bottom+5, 80, 32):CGRectMake(kScreenWidth-95, self.btn1.bottom+5, 50, 20)];
        [_btn2 setTitle:@"去完成" forState:UIControlStateNormal];
        [_btn2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _btn2.backgroundColor = [UIColor bm_colorGradientChangeWithSize:_btn1.size direction:IHGradientChangeDirectionVertical startColor:[UIColor colorWithHexString:@"#FF3737"] endColor:[UIColor colorWithHexString:@"#FF5777"]];
        _btn2.layer.cornerRadius = 4.0;
        _btn2.titleLabel.font = [UIFont regularFontWithSize:12.0f];
        _btn2.tag = 101;
        [_btn2 addTarget:self action:@selector(btnHandlerAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btn2;
}


-(NSMutableArray *)imgViewsArr{
    if (!_imgViewsArr) {
        _imgViewsArr = [[NSMutableArray alloc] init];
    }
    return _imgViewsArr;
}

@end

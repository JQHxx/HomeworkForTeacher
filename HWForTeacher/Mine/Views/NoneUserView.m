//
//  NoneUserView.m
//  HWForTeacher
//
//  Created by vision on 2019/9/29.
//  Copyright © 2019 vision. All rights reserved.
//

#import "NoneUserView.h"

@interface NoneUserView ()

@property (nonatomic,strong) UIImageView  *headImgView;
@property (nonatomic,strong) UILabel      *nameLabel;
@property (nonatomic,strong) UILabel      *tipsLabel;

@end

@implementation NoneUserView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addSubview:self.headImgView];
        [self addSubview:self.nameLabel];
        [self addSubview:self.tipsLabel];
        
    }
    return self;
}

#pragma mark -- getters
#pragma mark 头像
-(UIImageView *)headImgView{
    if (!_headImgView) {
        _headImgView = [[UIImageView alloc] initWithFrame:CGRectMake(22,KStatusHeight+27, 58, 58)];
        _headImgView.image = [UIImage imageNamed:@"my_default_head"];
        [_headImgView setBorderWithCornerRadius:29 type:UIViewCornerTypeAll];
    }
    return _headImgView;
}

#pragma mark 姓名
-(UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headImgView.right+10,KStatusHeight+32,260,IS_IPAD?32:20)];
        _nameLabel.textColor = [UIColor colorWithHexString:@"#303030"];
        _nameLabel.font = [UIFont mediumFontWithSize:20.0f];
        _nameLabel.text = [NSUserDefaultsInfos getValueforKey:kLoginPhone];
    }
    return _nameLabel;
}

#pragma mark 说明
-(UILabel *)tipsLabel{
    if (!_tipsLabel) {
        _tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headImgView.right+10,self.nameLabel.bottom+10,kScreenWidth-self.headImgView.right-90,IS_IPAD?30:18)];
        _tipsLabel.textColor = [UIColor colorWithHexString:@"#9495A0"];
        _tipsLabel.font = [UIFont regularFontWithSize:12.0f];
        _tipsLabel.text = @"请先完成注册认证";
    }
    return _tipsLabel;
}

@end

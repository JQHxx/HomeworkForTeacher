//
//  FilterView.m
//  Homework
//
//  Created by vision on 2019/9/10.
//  Copyright © 2019 vision. All rights reserved.
//

#import "FilterView.h"

@interface FilterView ()

@property (nonatomic,strong) UILabel            *dateLabel;
@property (nonatomic,strong) UIButton           *dateSelButton;
@property (nonatomic,strong) UIButton           *typeSelBtn;

@end

@implementation FilterView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.dateLabel];
        [self addSubview:self.dateSelButton];
        [self addSubview:self.typeSelBtn];
    }
    return self;
}



#pragma mark -- event response
-(void)filterAction:(UIButton *)sender{
    if ([self.viewDelegate respondsToSelector:@selector(filerViewDidClickWithIndex:)]) {
        [self.viewDelegate filerViewDidClickWithIndex:sender.tag];
    }
}

#pragma mark -- Setters
#pragma mark 日期
-(void)setDateStr:(NSString *)dateStr{
    _dateStr = dateStr;
    [self.dateSelButton setTitle:dateStr forState:UIControlStateNormal];
}

#pragma mark 类型
-(void)setTypeStr:(NSString *)typeStr{
    _typeStr = typeStr;
    [self.typeSelBtn setTitle:typeStr forState:UIControlStateNormal];
}

#pragma mark -- getters
#pragma mark 日期
-(UILabel *)dateLabel{
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 50,IS_IPAD?32:20)];
        _dateLabel.textColor = [UIColor colorWithHexString:@"#6D6D6D"];
        _dateLabel.font = [UIFont regularFontWithSize:13.0f];
        _dateLabel.text = @"日期";
    }
    return _dateLabel;
}

#pragma mark 选择日期
-(UIButton *)dateSelButton{
    if (!_dateSelButton) {
        _dateSelButton = [[UIButton alloc] initWithFrame:CGRectMake(self.dateLabel.right, 5,IS_IPAD?186:138,IS_IPAD?40:30)];
        _dateSelButton.backgroundColor = [UIColor colorWithHexString:@"#F7F8F9"];
        [_dateSelButton setTitleColor:[UIColor colorWithHexString:@"#9B9B9B"] forState:UIControlStateNormal];
        [_dateSelButton setImage:[UIImage imageNamed:@"record_arrow_choose"] forState:UIControlStateNormal];
        _dateSelButton.titleLabel.font = [UIFont regularFontWithSize:13.0f];
        _dateSelButton.layer.cornerRadius = 4.0;
        _dateSelButton.titleEdgeInsets = UIEdgeInsetsMake(0, -35, 0, 0);
        _dateSelButton.imageEdgeInsets = UIEdgeInsetsMake(0, _dateSelButton.width-20, 0, 0);
        _dateSelButton.tag = 0;
        [_dateSelButton addTarget:self action:@selector(filterAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _dateSelButton;
}

#pragma mark 类型
-(UIButton *)typeSelBtn{
    if (!_typeSelBtn) {
        _typeSelBtn = [[UIButton alloc] initWithFrame:IS_IPAD?CGRectMake(kScreenWidth-180, 5, 160, 40):CGRectMake(kScreenWidth-130, 5, 110,30)];
        _typeSelBtn.backgroundColor = [UIColor colorWithHexString:@"#F7F8F9"];
        [_typeSelBtn setTitleColor:[UIColor colorWithHexString:@"#9B9B9B"] forState:UIControlStateNormal];
        [_typeSelBtn setImage:[UIImage imageNamed:@"record_arrow_choose"] forState:UIControlStateNormal];
        _typeSelBtn.titleLabel.font = [UIFont regularFontWithSize:13.0f];
        _typeSelBtn.layer.cornerRadius = 4.0;
        _typeSelBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
        _typeSelBtn.imageEdgeInsets = UIEdgeInsetsMake(0,IS_IPAD?140:90, 0, 0);
        _typeSelBtn.tag = 1;
        [_typeSelBtn addTarget:self action:@selector(filterAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _typeSelBtn;
}


@end

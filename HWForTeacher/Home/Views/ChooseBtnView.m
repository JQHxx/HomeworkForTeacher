//
//  ChooseBtnView.m
//  HWForTeacher
//
//  Created by vision on 2019/9/28.
//  Copyright © 2019 vision. All rights reserved.
//

#import "ChooseBtnView.h"

@interface ChooseBtnView ()

@property (nonatomic,strong) UIButton *valueBtn;
@property (nonatomic,strong) UIButton *selBtn;

@end

@implementation ChooseBtnView

-(instancetype)initWithFrame:(CGRect)frame title:(nonnull NSString *)title{
    self = [super initWithFrame:frame];
    if (self) {
        _valueBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 4, frame.size.width-4, frame.size.height-4)];
        [_valueBtn setTitle:title forState:UIControlStateNormal];
        [_valueBtn setTitleColor:[UIColor colorWithHexString:@"#9C9DA8"] forState:UIControlStateNormal];
        _valueBtn.layer.cornerRadius = IS_IPAD?23:17.0;
        _valueBtn.layer.borderWidth = 0.0;
        _valueBtn.backgroundColor = [UIColor colorWithHexString:@"#EFF1F3"];
        _valueBtn.titleLabel.font = [UIFont regularFontWithSize:16];
        [self addSubview:_valueBtn];
                   
        _selBtn= [[UIButton alloc] initWithFrame:CGRectMake(_valueBtn.right-12, 0, 16, 16)];
        [_selBtn setImage:[UIImage imageNamed:@"choose_red"] forState:UIControlStateNormal];
        [self addSubview:_selBtn];
        _selBtn.hidden = YES;
        
        _myBtn = [[UIButton alloc] initWithFrame:self.bounds];
        [self addSubview:_myBtn];
    }
    return self;
}

-(void)setHasChoosed:(BOOL)hasChoosed{
    _hasChoosed = hasChoosed;
    if (hasChoosed) {
        _valueBtn.layer.borderColor = [UIColor colorWithHexString:@"#FF6262"].CGColor;
        _valueBtn.layer.borderWidth = 1.0;
        self.selBtn.hidden = NO;
    }else{
        _valueBtn.layer.borderWidth = 0.0;
        self.selBtn.hidden = YES;
    }
}


@end

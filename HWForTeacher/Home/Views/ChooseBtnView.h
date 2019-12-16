//
//  ChooseBtnView.h
//  HWForTeacher
//
//  Created by vision on 2019/9/28.
//  Copyright © 2019 vision. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ChooseBtnView : UIView

@property (nonatomic,assign) BOOL      hasChoosed;
@property (nonatomic,strong) UIButton  *myBtn;

-(instancetype)initWithFrame:(CGRect)frame title:(NSString *)title;

@end



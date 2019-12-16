//
//  MyIncomeViewController.h
//  HWForTeacher
//
//  Created by vision on 2019/9/26.
//  Copyright © 2019 vision. All rights reserved.
//

#import "BaseViewController.h"

@interface MyIncomeViewController : BaseViewController

@property (nonatomic,assign) NSInteger    type; //0 预计收益 1 提成收益 2 到手金额
@property (nonatomic,assign) double       amount;

@end


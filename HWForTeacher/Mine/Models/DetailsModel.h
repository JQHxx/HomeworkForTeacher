//
//  DetailsModel.h
//  HWForTeacher
//
//  Created by vision on 2019/9/26.
//  Copyright © 2019 vision. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DetailsModel : NSObject

@property (nonatomic, copy ) NSString *cover;    //头像
@property (nonatomic, copy ) NSString *name;    //昵称
@property (nonatomic,strong) NSNumber *create_time;    //日期
@property (nonatomic,strong) NSNumber *pay_money;    //付费
@property (nonatomic,strong) NSNumber *money;    //付费

@property (nonatomic,strong) NSNumber *type;   //到手金额明细 1日辅导 2日提成 ----- 预计收益明细1辅导2提成3转班4请假
@property (nonatomic,strong) NSNumber *status;  //1收入 2支出

@end



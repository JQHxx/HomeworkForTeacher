//
//  StudentModel.h
//  HWForTeacher
//
//  Created by vision on 2019/9/24.
//  Copyright © 2019 vision. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StudentModel : NSObject


@property (nonatomic,strong) NSNumber *id;
@property (nonatomic,strong) NSNumber *s_id;
@property (nonatomic, copy ) NSString *third_id;
@property (nonatomic, copy ) NSString *name;         //昵称
@property (nonatomic, copy ) NSString *cover;        //头像
@property (nonatomic, copy ) NSString *grade;        //年级
@property (nonatomic,strong) NSNumber *create_time;    //注册时间
@property (nonatomic, copy ) NSString *version;      //教材版本
@property (nonatomic, copy ) NSString *remark;       //备注
@property (nonatomic, copy ) NSString *status;        //辅导类型
@property (nonatomic,strong) NSNumber *end_time;      //到期时间
@property (nonatomic,strong) NSNumber *guide_status; //0未辅导 1辅导中
@property (nonatomic,strong) NSNumber *user_pay;  // 1购买了2购买过期了


@end



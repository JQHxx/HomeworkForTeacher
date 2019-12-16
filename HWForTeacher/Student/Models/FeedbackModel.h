//
//  FeedbackModel.h
//  HWForTeacher
//
//  Created by vision on 2019/9/25.
//  Copyright © 2019 vision. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FeedbackModel : NSObject

@property (nonatomic,strong) NSNumber *id;    //id
@property (nonatomic,strong) NSNumber *s_id;    //学生id
@property (nonatomic, copy ) NSString *third_id;  //融云id
@property (nonatomic, copy ) NSString *name;    //昵称
@property (nonatomic, copy ) NSString *cover;   //头像
@property (nonatomic, copy ) NSString *grade;   //年级
@property (nonatomic, copy ) NSString *version;   //教材版本
@property (nonatomic,strong) NSNumber *start_time;   //
@property (nonatomic,strong) NSNumber *end_time;   //
@property (nonatomic,strong) NSNumber *status;    //0 未填写 1已填写

@end



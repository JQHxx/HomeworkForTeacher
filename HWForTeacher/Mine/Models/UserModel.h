//
//  UserModel.h
//  HWForTeacher
//
//  Created by vision on 2019/9/24.
//  Copyright © 2019 vision. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UserModel : NSObject


@property (nonatomic,strong) NSNumber    *tid;
@property (nonatomic, copy ) NSString    *token;
@property (nonatomic, copy ) NSString    *third_id;     //融云id
@property (nonatomic, copy ) NSString    *third_token;  //融云token

//教学信息
@property (nonatomic, copy ) NSArray        *grade;       //授课年级
@property (nonatomic, copy ) NSString       *subject;      //科目

//个人信息
@property (nonatomic, copy ) NSString       *name;    //昵称
@property (nonatomic, copy ) NSString       *cover;
@property (nonatomic,strong) NSNumber       *money;
@property (nonatomic, copy ) NSArray        *label;    //标签
@property (nonatomic,strong) NSNumber       *leave;    //1请假中0正常
@property (nonatomic, copy ) NSString       *experience;     //教学经历
@property (nonatomic, copy ) NSString       *style;   //教学风格
@property (nonatomic, copy ) NSString       *idea;    //教育理念
@property (nonatomic,strong) NSNumber       *state;    //0未完成1已经完成2待审核3审核不通过

//审核信息
@property (nonatomic,strong) NSNumber       *card_state;    //证件审核状态 0未上传1身份证待审核2审核通过3审核不通过
@property (nonatomic, copy ) NSString       *card_front;
@property (nonatomic, copy ) NSString       *card_reverse;
@property (nonatomic, copy ) NSString       *license;        //教师资格证
@property (nonatomic, copy ) NSString       *evaluation;      //职称证书
@property (nonatomic,strong) NSNumber       *guide_state;   //辅导时间设置状态
@property (nonatomic,strong) NSDictionary   *guide_time;    //辅导时间
@property (nonatomic,strong) NSNumber       *video_state;    //上传视频状态 0试讲视频未完成1待审核2审核通过3审核不通过
@property (nonatomic, copy ) NSString       *video;          //视频
@property (nonatomic,strong) NSNumber       *train_state;    //岗前培训状态 1岗前培训待完成2已完成


@property (nonatomic,strong) NSNumber  *already_money;   //已到手金额
@property (nonatomic,strong) NSNumber  *predict_money;   //本月预计收益


//临时
@property (nonatomic, copy ) NSString       *tag1;          //标签1
@property (nonatomic, copy ) NSString       *tag2;          //标签2

@end

@interface GuideTimeModel : NSObject

@property (nonatomic, copy ) NSString *workday;        //工作日
@property (nonatomic, copy ) NSString *work_time;      //工作日辅导时间
@property (nonatomic, copy ) NSString *off_day;        //周末
@property (nonatomic, copy ) NSString *off_time;     //休息日

@end

@interface IncomeModel : NSObject

@property (nonatomic,strong) NSNumber *today_push_money;
@property (nonatomic,strong) NSNumber *today_class_fee;
@property (nonatomic,strong) NSNumber *today_income;      

@end


@interface StudentDataModel : NSObject

@property (nonatomic,strong) NSNumber *all;
@property (nonatomic,strong) NSNumber *pay;
@property (nonatomic,strong) NSNumber *today_pay;

@end


@interface EarningsModel : NSObject

@property (nonatomic,strong) NSNumber *already_money;
@property (nonatomic,strong) NSNumber *predict_money;


@end

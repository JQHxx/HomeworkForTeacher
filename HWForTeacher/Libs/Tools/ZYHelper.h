//
//  ZYHelper.h
//  HWForTeacher
//
//  Created by vision on 2019/9/24.
//  Copyright © 2019 vision. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZYHelper : NSObject

singleton_interface(ZYHelper)

@property (nonatomic ,assign) BOOL   isUpdateHome;
@property (nonatomic ,assign) BOOL   isUpdateMessage;
@property (nonatomic ,assign) BOOL   isUpdateStudent;
@property (nonatomic ,assign) BOOL   isUpdateMine;
@property (nonatomic ,assign) BOOL   isUpdateFeedback;

@property (nonatomic ,assign) BOOL   isUpdateWithdraw;
@property (nonatomic, assign) BOOL   isUpdateBankList;

@property (nonatomic , copy ) NSArray  *grades;  //年级
@property (nonatomic , copy ) NSArray  *subjects;  //科目
@property (nonatomic , copy ) NSDictionary  *banksDict;  //银行信息

/*
 *解析星期
 *
 * @param days 天
 * @return 星期数组
 */
-(NSMutableArray *)parseWeeksDataWithDays:(NSString *)days;

/*
 *解析年级
 *
 * @param gradeIds 年级id数组
 * @return 年级数组
 */
-(NSMutableArray *)parseGradesWithGradeIds:(NSArray *)gradeIds;

/*
* 根据科目获取年级
*/
-(NSArray *)getGradesWithSubject:(NSString *)subject;

/**
 *@bref 时间戳转化为时间
 */
- (NSString *)timeWithTimeIntervalNumber:(NSNumber *)timeNum format:(NSString *)format;

/**
 *@bref 将某个时间转化成 时间戳
 */
-(NSNumber *)timeSwitchTimestamp:(NSString *)formatTime format:(NSString *)format;

/**
* 获取缓存数据
*/
- (CGFloat)getTotalCacheSize;

/**
* 获取文件大小
*/
- (CGFloat)getFileSize:(NSString *)path;

/**
 *@bref 其他数据转json数据
 */
-(NSString *)getValueWithParams:(id)params;

/*
 * 根据银行获取银行卡代号
 */
-(NSString *)getBankCodeWithBankName:(NSString *)bankName;

/***
 * @bref  限制emoji表情输入
 */
-(BOOL)strIsContainEmojiWithStr:(NSString*)str;
/***
 * @bref  限制第三方键盘（常用的是搜狗键盘）的表情
 */
- (BOOL)hasEmoji:(NSString*)string;

-(BOOL)isNineKeyBoard:(NSString *)string;


@end



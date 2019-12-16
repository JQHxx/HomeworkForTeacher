//
//  ZYHelper.m
//  HWForTeacher
//
//  Created by vision on 2019/9/24.
//  Copyright © 2019 vision. All rights reserved.
//

#import "ZYHelper.h"
#import "SBJSON.h"
#import <SDImageCache.h>

@implementation ZYHelper

singleton_implementation(ZYHelper)

#pragma mark 获取年级
-(NSArray *)grades{
    return @[@"一年级",@"二年级",@"三年级",@"四年级",@"五年级",@"六年级",@"初一",@"初二",@"初三"];
}

#pragma mark 获取科目
-(NSArray *)subjects{
    return @[@"语文",@"数学",@"英语",@"物理",@"化学",@"生物",@"历史",@"政治",@"地理"];
}

#pragma mark  根据科目获取年级
-(NSArray *)getGradesWithSubject:(NSString *)subject{
    if ([subject isEqualToString:@"语文"]||[subject isEqualToString:@"数学"]||[subject isEqualToString:@"英语"]) {
        return @[@{@"type":@"小学",@"values":@[@"一年级",@"二年级",@"三年级",@"四年级",@"五年级",@"六年级"]},@{@"type":@"初中",@"values":@[@"初一",@"初二",@"初三"]}];
    }else{
        return @[@{@"type":@"初中",@"values":@[@"初一",@"初二",@"初三"]}];
    }
}

#pragma mark 解析星期
-(NSMutableArray *)parseWeeksDataWithDays:(NSString *)days{
    NSMutableArray *tempArr = [[NSMutableArray alloc] init];
    NSArray *daysArr = [days componentsSeparatedByString:@","];
    for (NSNumber *day in daysArr) {
        NSString *tempWeek = nil;
        if ([day integerValue]==1) {
            tempWeek = @"周一";
        }else if ([day integerValue]==2){
            tempWeek = @"周二";
        }else if ([day integerValue]==3){
            tempWeek = @"周三";
        }else if ([day integerValue]==4){
            tempWeek = @"周四";
        }else if ([day integerValue]==5){
            tempWeek = @"周五";
        }else if ([day integerValue]==6){
            tempWeek = @"周六";
        }else if ([day integerValue]==7){
            tempWeek = @"周日";
        }
        [tempArr addObject:tempWeek];
    }
    
    return tempArr;
}


#pragma mark 解析年级
-(NSMutableArray *)parseGradesWithGradeIds:(NSArray *)gradeIds{
    NSMutableArray *tempArr = [[NSMutableArray alloc] init];
    for (NSNumber *gradeId in gradeIds) {
        NSString *grade = [self.grades objectAtIndex:[gradeId integerValue]-1];
        [tempArr addObject:grade];
    }
    return tempArr;
}

#pragma mark 时间戳转化为时间
- (NSString *)timeWithTimeIntervalNumber:(NSNumber *)timeNum format:(NSString *)format{
    // 格式化时间
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:format];
    
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timeNum integerValue]];
    NSString* dateString = [formatter stringFromDate:date];
    return dateString;
}

#pragma mark 将某个时间转化成 时间戳
-(NSNumber *)timeSwitchTimestamp:(NSString *)formatTime format:(NSString *)format{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:format];
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    NSDate* date = [formatter dateFromString:formatTime];    //将字符串按formatter转成nsdate
    return [NSNumber numberWithDouble:[date timeIntervalSince1970]];
}

#pragma mark 获取缓存数据
- (CGFloat)getTotalCacheSize{
    NSUInteger imageCacheSize = [[SDImageCache sharedImageCache] totalDiskSize];
    //获取自定义缓存大小
    //用枚举器遍历 一个文件夹的内容
    //1.获取 文件夹枚举器
    NSString *myCachePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"];
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:myCachePath];
    __block NSUInteger count = 0;
    //2.遍历
    for (NSString *fileName in enumerator) {
        NSString *path = [myCachePath stringByAppendingPathComponent:fileName];
        NSDictionary *fileDict = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
        count += fileDict.fileSize;//自定义所有缓存大小
    }
    // 得到是字节  转化为M
    CGFloat totalSize = ((CGFloat)imageCacheSize+count)/1024/1024;
    return totalSize;
}

#pragma mark 获取文件大小
- (CGFloat)getFileSize:(NSString *)path{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    float filesize = -1.0;
    if ([fileManager fileExistsAtPath:path]) {
        // 获取文件的属性
        NSDictionary *fileDic = [fileManager attributesOfItemAtPath:path error:nil];
        unsigned long long size = [[fileDic objectForKey:NSFileSize] longLongValue];
        filesize = 1.0*size/1024/1024;
    } else {
        MyLog(@"没有找到相关文件");
    }
    return filesize;
}

#pragma mark --其他数据转json数据
-(NSString *)getValueWithParams:(id)params{
    SBJsonWriter *writer=[[SBJsonWriter alloc] init];
    NSString *value=[writer stringWithObject:params];
    MyLog(@"value:%@",value);
    return value;
}

#pragma mark 银行信息
-(NSDictionary *)banksDict{
    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"banks" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:filepath];
    return dict;
}

#pragma mark 根据银行获取银行卡代号
-(NSString *)getBankCodeWithBankName:(NSString *)bankName{
    __block NSString *bankCode = nil;
    [self.banksDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isEqualToString:bankName]) {
            bankCode = key;
        }
    }];
    return bankCode;
}

#pragma mark -- 限制emoji表情输入
-(BOOL)strIsContainEmojiWithStr:(NSString*)str{
    __block BOOL returnValue =NO;
    [str enumerateSubstringsInRange:NSMakeRange(0, [str length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop){
         const unichar hs = [substring characterAtIndex:0];
         if(0xd800<= hs && hs <=0xdbff){
             if(substring.length>1){
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs -0xd800) *0x400) + (ls -0xdc00) +0x10000;
                 if(0x1d000<= uc && uc <=0x1f77f){
                     returnValue =YES;
                 }
             }
         }else if(substring.length>1){
             const unichar ls = [substring characterAtIndex:1];
             if(ls ==0x20e3)
             {
                 returnValue =YES;
             }
         }else{
             // non surrogate
             if(0x2100<= hs && hs <=0x27ff&& hs !=0x263b)
             {
                 returnValue =YES;
             }
             else if(0x2B05<= hs && hs <=0x2b07)
             {
                 returnValue =YES;
             }
             else if(0x2934<= hs && hs <=0x2935)
             {
                 returnValue =YES;
             }
             else if(0x3297<= hs && hs <=0x3299)
             {
                 returnValue =YES;
             }
             else if(hs ==0xa9|| hs ==0xae|| hs ==0x303d|| hs ==0x3030|| hs ==0x2b55|| hs ==0x2b1c|| hs ==0x2b1b|| hs ==0x2b50|| hs ==0x231a)
             {
                 returnValue =YES;
             }
         }
     }];
    return returnValue;
}
#pragma mark -- 限制第三方键盘（常用的是搜狗键盘）的表情
- (BOOL)hasEmoji:(NSString*)string;
{
    NSString *pattern = @"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:string];
    return isMatch;
}

#pragma mark -- 判断当前是不是在使用九宫格输入
-(BOOL)isNineKeyBoard:(NSString *)string
{
    NSString *other = @"➋➌➍➎➏➐➑➒";
    int len = (int)string.length;
    for(int i=0;i<len;i++)
    {
        if(!([other rangeOfString:string].location != NSNotFound))
            return NO;
    }
    return YES;
}



@end

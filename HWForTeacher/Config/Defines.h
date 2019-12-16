//
//  Defines.h
//  HWForTeacher
//
//  Created by vision on 2019/9/19.
//  Copyright © 2019 vision. All rights reserved.
//

#ifndef Defines_h
#define Defines_h


#endif /* Defines_h */

/*************iPhone设备判断***********/
//iPhone 5判断
#define IS_IPHONE_5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
//iPhone 6判断
#define IS_IPHONE_6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)
#define IS_IPHONE_6P ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? (CGSizeEqualToSize(CGSizeMake(1125, 2001), [[UIScreen mainScreen] currentMode].size) || CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size)) : NO)
//iPhoneX判断
#define IS_IPHONE_X ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) && !IS_IPAD: NO)
//iPhoneXr判断
#define IS_IPHONE_Xr ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) && !IS_IPAD : NO)
//iPhoneXs判断
#define IS_IPHONE_Xs ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) && !IS_IPAD: NO)
//iPhoneXs Max判断
#define IS_IPHONE_Xs_Max ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) && !IS_IPAD : NO)
//iPhoneX、iPhoneXr、iPhoneXs、iPhoneXs Max判断
#define isXDevice     (IS_IPHONE_X==YES || IS_IPHONE_Xr == YES || IS_IPHONE_Xs == YES || IS_IPHONE_Xs_Max == YES)
//iPad 判断
#define IS_IPAD (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)


/*************屏幕尺寸相关*********************/
#define kScreenHeight     [UIScreen mainScreen].bounds.size.height
#define kScreenWidth      [UIScreen mainScreen].bounds.size.width
#define kTabHeight        (IS_IPAD?72:(isXDevice ? (49+ 34) : 49))
#define kNavHeight        (IS_IPAD?88:(isXDevice ? 88 : 64))
#define KStatusHeight     (isXDevice ? 44 : 20)


#define kRGBColor(r, g, b , a)    [UIColor colorWithRed:(r)/255.0  green:(g)/255.0 blue:(b)/255.0  alpha:a]

/*****************数据类型判断*******************/
//字符串为空判断
#define kIsEmptyString(s)       (s == nil || [s isKindOfClass:[NSNull class]] || ([s isKindOfClass:[NSString class]] && s.length == 0))
//对象为空判断
#define kIsEmptyObject(obj)     (obj == nil || [obj isKindOfClass:[NSNull class]])
//字典类型判断
#define kIsDictionary(objDict)  (objDict != nil && [objDict isKindOfClass:[NSDictionary class]])
//数组类型判断
#define kIsArray(objArray)      (objArray != nil && [objArray isKindOfClass:[NSArray class]])


/****************系统版本判断************************/
#define IOS10_OR_LATER  ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0)
#define IOS9_OR_LATER   ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)
#define IOS8_OR_LATER   ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

/****************其他常用宏定义************************/
//app版本号
#define APP_VERSION       [[NSBundle mainBundle].infoDictionary  objectForKey:@"CFBundleShortVersionString"]
//app名称
#define APP_DISPLAY_NAME  [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleDisplayName"]
//ios系统版本号
#define kIOSVersion       ([UIDevice currentDevice].systemVersion.floatValue)
// appDelegate
#define kAppDelegate    (AppDelegate *)[[UIApplication  sharedApplication] delegate]
// keyWindow
#define kKeyWindow     [UIApplication sharedApplication].keyWindow
//block weakself
#define kSelfWeak     __weak typeof(self) weakSelf = self
//block strongself
#define kSelfStrong  __strong typeof(self) strongSelf = self
//调试
#ifdef DEBUG
#define MyLog(...) NSLog(__VA_ARGS__)
#else
#define MyLog(...)
#endif

/***********************全局变量***************************/
#define kShowGuidance             @"kShowGuidance"

#define kIsLogin                  @"kIsLogin"
#define kUserId                   @"kUserId"
#define kUserToken                @"kUserToken"
#define kRongCloudID              @"kRongCloudID"         //融云用户id
#define kRongCloudToken           @"kRongCloudToken"         //融云用户token
#define kLoginPhone               @"kLoginPhone"
#define kUserGrade                @"kUserGrade"
#define kUserNickname             @"kUserNickname"
#define kUserHeadPic              @"kUserHeadPic"
#define kUserCredit               @"kUserCredit"
#define kPaySwitch                @"kPaySwitch"    //内购开关

#define kPushMsgSetting           @"kPushMsgSetting"

#define kUserTokenValue   [NSUserDefaultsInfos getValueforKey:kUserToken]

#define kReloadMsgNotification       @"kReloadMsgNotification"     //刷新消息

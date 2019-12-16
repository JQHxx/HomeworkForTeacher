//
//  ChangeModel.h
//  HWForTeacher
//
//  Created by vision on 2019/9/26.
//  Copyright © 2019 vision. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ChangeModel : NSObject

@property (nonatomic, copy ) NSString   *name;    //昵称
@property (nonatomic, copy ) NSString   *cover;       //头像
@property (nonatomic, copy ) NSString   *grade;    //年级
@property (nonatomic, copy ) NSString   *guide_name;      //类型
@property (nonatomic,strong) NSNumber   *create_time;     //日期
@property (nonatomic, copy ) NSString   *reason;          //原因
@property (nonatomic,strong) NSNumber   *status;           // 1转出 2转入

@end


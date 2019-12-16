//
//  StudentTableView.h
//  HWForTeacher
//
//  Created by vision on 2019/9/25.
//  Copyright © 2019 vision. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StudentModel.h"

@protocol StudentTableViewDelegate <NSObject>

-(void)studentTableViewDidSelectStudent:(StudentModel *)model;

-(void)studentTableViewDidShowStudentDetailsWithStudent:(StudentModel *)model;

@end

@interface StudentTableView : UITableView

@property (nonatomic, weak ) id<StudentTableViewDelegate>viewDelegate;

@property (nonatomic,strong) NSMutableArray *studentsArray;

@end


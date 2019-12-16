//
//  HomeTableView.h
//  HWForTeacher
//
//  Created by vision on 2019/9/24.
//  Copyright © 2019 vision. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StudentModel.h"

@protocol HomeTableViewDelegate <NSObject>

-(void)homeTableViewDidSelectStudent:(StudentModel *)student;

@end

@interface HomeTableView : UITableView

@property (nonatomic,weak ) id <HomeTableViewDelegate>viewDelegate;

@property (nonatomic,strong) NSMutableArray *studentsArray;

@end


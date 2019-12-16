//
//  WalletModel.h
//  HWForTeacher
//
//  Created by vision on 2019/10/10.
//  Copyright © 2019 vision. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WalletModel : NSObject

@property (nonatomic,strong) NSNumber   *money;            //到手金额
@property (nonatomic,strong) NSNumber   *predict_money;    //预计收益
@property (nonatomic,strong) NSNumber   *amort_money;      //提成预计收益
@property (nonatomic,strong) NSNumber   *withdraw_money;   //可提现金额

@end



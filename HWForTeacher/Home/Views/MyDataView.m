//
//  MyDataView.m
//  ZYForTeacher
//
//  Created by vision on 2019/1/28.
//  Copyright © 2019 vision. All rights reserved.
//

#import "MyDataView.h"

@interface MyDataView ()

@property (nonatomic,strong) UILabel *dailyzCommissionLabel;  //今日提成
@property (nonatomic,strong) UILabel *dailyClassLabel;     //今日课时费
@property (nonatomic,strong) UILabel *dailyBillLabel;      //今日收益
@property (nonatomic,strong) UILabel *myStudentsLabel;     //我的学生
@property (nonatomic,strong) UILabel *paidStudentsLabel;   //已付费学生
@property (nonatomic,strong) UILabel *dailyStudentLabel;    //今日付费学生

@end

@implementation MyDataView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        NSArray *data = @[@{@"type":@"我的收益",@"images":@[@"home_profit_royalty",@"home_profit_class_hour",@"home_profit_today"],@"titles":@[@"昨日提成",@"昨日课时费",@"昨日收益"]},@{@"type":@"我的学生",@"images":@[@"home_profit_student",@"home_profit_paying_students",@"home_profit_paya_today"],@"titles":@[@"我的学生",@"已付费学生",@"今日付费学生"]}];
        for (NSInteger i=0; i<data.count; i++) {
            NSDictionary *dict = data[i];
            UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(22, 20+(120+(IS_IPAD?27:15))*i, 100,IS_IPAD?27:15)];
            titleLab.text = dict[@"type"];
            titleLab.font = [UIFont mediumFontWithSize:17];
            titleLab.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
            [self addSubview:titleLab];
            
            //今日接单和今日流水
            CGFloat viewW = (kScreenWidth-35*2)/3.0;
            CGFloat viewH = IS_IPAD?90:78;
            NSArray *titles = dict[@"titles"];
            NSArray *images = dict[@"images"];
            for (NSInteger j=0; j<titles.count; j++) {
                UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(23+(viewW+12)*j, titleLab.bottom+15, viewW,viewH)];
                bgView.backgroundColor = [UIColor whiteColor];
                bgView.layer.cornerRadius = 5.0;
                bgView.layer.shadowColor = [[UIColor blackColor] CGColor];
                bgView.layer.shadowOffset = CGSizeMake(0.5, 0.5);
                bgView.layer.shadowRadius = 5.0;
                bgView.layer.shadowOpacity = 0.15;
                [self addSubview:bgView];
                
                UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(bgView.right-43,bgView.bottom-36, 43, 36)];
                bgImgView.image = [UIImage imageNamed:images[j]];
                [self addSubview:bgImgView];
                
                UILabel *dailyTitleLab = [[UILabel alloc] initWithFrame:CGRectMake(bgView.left+10, bgView.top+10,bgView.width-15,IS_IPAD?30:18)];
                dailyTitleLab.text = titles[j];
                dailyTitleLab.font = [UIFont regularFontWithSize:13];
                dailyTitleLab.textColor = [UIColor colorWithHexString:@"#9495A0"];
                [self addSubview:dailyTitleLab];
                
                UILabel *dailyContentLab = [[UILabel alloc] initWithFrame:CGRectMake(dailyTitleLab.left,dailyTitleLab.bottom+5,120,IS_IPAD?36:25)];
                dailyContentLab.font = [UIFont mediumFontWithSize:18];
                dailyContentLab.textColor = [UIColor colorWithHexString:@"#4C5467"];
                [self addSubview:dailyContentLab];
                if (i==0) {
                    if (j==0) {
                        self.dailyzCommissionLabel = dailyContentLab;
                    }else if (j==1){
                        self.dailyClassLabel = dailyContentLab;
                    }else{
                        self.dailyBillLabel = dailyContentLab;
                    }
                }else{
                    if (j==0) {
                        self.myStudentsLabel = dailyContentLab;
                    }else if (j==1){
                        self.paidStudentsLabel = dailyContentLab;
                    }else{
                        self.dailyStudentLabel = dailyContentLab;
                    }
                }
            }
        }
        
    }
    return self;
}

#pragma mark 我的收益
-(void)setIncomeModel:(IncomeModel *)incomeModel{
    _incomeModel = incomeModel;
    
    NSString *commissionStr = [NSString stringWithFormat:@"¥%.2f",[incomeModel.today_push_money doubleValue]];
    NSMutableAttributedString *attributeStr1 = [[NSMutableAttributedString alloc] initWithString:commissionStr];
    [attributeStr1 addAttribute:NSFontAttributeName value:[UIFont mediumFontWithSize:12.0f] range:NSMakeRange(0, 1)];
    self.dailyzCommissionLabel.attributedText = attributeStr1;
    
    NSString *classStr = [NSString stringWithFormat:@"¥%.2f",[incomeModel.today_class_fee doubleValue]];
    NSMutableAttributedString *attributeStr2 = [[NSMutableAttributedString alloc] initWithString:classStr];
    [attributeStr2 addAttribute:NSFontAttributeName value:[UIFont mediumFontWithSize:12.0f] range:NSMakeRange(0, 1)];
    self.dailyClassLabel.attributedText = attributeStr2;
    
    NSString *billStr = [NSString stringWithFormat:@"¥%.2f",[incomeModel.today_income doubleValue]];
    NSMutableAttributedString *attributeStr3 = [[NSMutableAttributedString alloc] initWithString:billStr];
    [attributeStr3 addAttribute:NSFontAttributeName value:[UIFont mediumFontWithSize:12.0f] range:NSMakeRange(0, 1)];
    self.dailyBillLabel.attributedText = attributeStr3;
}

#pragma mark 我的学生
-(void)setStudentData:(StudentDataModel *)studentData{
    _studentData = studentData;
    
    NSString *str1 = [NSString stringWithFormat:@"%ld人",[studentData.all integerValue]];
    NSMutableAttributedString *attributeStr4 = [[NSMutableAttributedString alloc] initWithString:str1];
    [attributeStr4 addAttribute:NSFontAttributeName value:[UIFont mediumFontWithSize:12.0f] range:NSMakeRange(str1.length-1, 1)];
    self.myStudentsLabel.attributedText = attributeStr4;
    
    NSString *str2 = [NSString stringWithFormat:@"%ld人",[studentData.pay integerValue]];
    NSMutableAttributedString *attributeStr5 = [[NSMutableAttributedString alloc] initWithString:str2];
    [attributeStr5 addAttribute:NSFontAttributeName value:[UIFont mediumFontWithSize:12.0f] range:NSMakeRange(str2.length-1, 1)];
    self.paidStudentsLabel.attributedText = attributeStr5;
    
    NSString *str3 = [NSString stringWithFormat:@"%ld人",[studentData.today_pay integerValue]];
    NSMutableAttributedString *attributeStr6 = [[NSMutableAttributedString alloc] initWithString:str3];
    [attributeStr6 addAttribute:NSFontAttributeName value:[UIFont mediumFontWithSize:12.0f] range:NSMakeRange(str3.length-1, 1)];
    self.dailyStudentLabel.attributedText = attributeStr6;
}

@end

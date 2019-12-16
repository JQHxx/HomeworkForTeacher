//
//  Interface.h
//  HWForTeacher
//
//  Created by vision on 2019/9/19.
//  Copyright © 2019 vision. All rights reserved.
//

#ifndef Interface_h
#define Interface_h


#endif /* Interface_h */


#define isTrueEnvironment 1

#if isTrueEnvironment
//正式环境
#define kHostURL            @"https://tpi.zuoye101.com"
#define kHostTempURL        @"https://tpi.zuoye101.com%@"


#define kRongCloudAppKey    @"y745wfm8yqb3v"


#else
//测试环境
#define kHostURL           @"https://test.zuoye101.com"
#define kHostTempURL       @"https://test.zuoye101.com%@"

//融云
#define kRongCloudAppKey    @"sfci50a7s3bwi"

#endif


//Public
#define kUploadPicAPI          @"/teacher/upload"               //上传图片
#define kUploadVideoAPI        @"/teacher/upload/video"         //上传视频
#define kUploadDeviceInfoAPI   @"/teacher/device"               //上传设备信息
#define kVersionUpdateAPI      @"/teacher/version/app_version"  //版本更新

//登录
#define kGetCodeSign           @"/admin/code/get"                   //发送手机验证码
#define kLoginAPI              @"/teacher/user/login"               //登录
#define kSetTeachInfoAPI       @"/teacher/user/set_grade_subject"   //设置年级科目

//首页
#define kHomeAPI               @"/teacher"                           //首页
#define kUploadCertAPI         @"/teacher/user/set_certificate"      //上传证件
#define kGetTrialAPI           @"/teacher/user/trial"                //试讲题目
#define kSetTrialVideoAPI      @"/teacher/user/set_trial"            //上传试讲视频
#define kSetUserInfoAPI        @"/teacher/user/complete_userinfo"    //完善个人资料
#define kSetGuideTimeAPI       @"/teacher/user/set_guide_time"       //设置辅导时间
#define kUnreadMessageAPI      @"/teacher/message/check_message"      //消息是否已读
#define kRemoteMessagesAPI     @"/teacher/message"                   //消息列表
#define kEmptyMessagesAPI      @"/teacher/message/empty_message"    //清空消息

//学生
#define kMyStudentsAPI         @"/teacher/student"                   //我的学生
#define kStudentDetailAPI      @"/teacher/student/detail"             //学生详情
#define kSubmitStudentAPI      @"/teacher/student/student_detail"    //学生详情提交
#define kStudentVersionAPI     @"/teacher/student/version"           //教材版本
#define kGuideFeedbackAPI      @"/teacher/student/feedback"           //辅导反馈
#define kFeedbackSubmitAPI     @"/teacher/student/student_feedback"    //辅导反馈提交
#define kRCUserInfoAPI         @"/teacher/student/search_student"     //根据融云id查询学生信息
#define kGetGuideIdAPI         @"/teacher/student/search_guideid"      //根据学生id查询最后一次辅导记录id

//我的
#define kMineAPI               @"/teacher/user"                        //我的
#define kChangeUserInfoAPI     @"/teacher/user/setinfo"                //修改个人信息
#define kLeaveAPI              @"/teacher/user/leave"                  //请假
#define kMyWalletAPI           @"/teacher/wallet"                      //我的钱包
#define kBankInfoAPI           @"/teacher/wallet/bank_info"            //银行信息
#define kMyBankCardAPI         @"/teacher/wallet/my_bank"             //我的银行卡
#define kAddBankCardAPI        @"/teacher/wallet/bank_card"           //绑定银行卡
#define kWalletExtractAPI      @"/teacher/wallet/doextract"           //提现
#define kSearchBankAPI         @"/teacher/bank/search"                //根据卡号查找银行
#define kWalletExtractPageAPI  @"/teacher/wallet/extract"             //提现页面
#define kIncomeDetailsAPI      @"/teacher/wallet/income"              //到手金额明细
#define kPreIncomeDetailsAPI   @"/teacher/wallet/predict_earnings"     //预计收益
#define kStudentChangeAPI      @"/teacher/user/student_change"         //学生变动

#define kLogoutAPI             @"/teacher/user/logout"               //注销账号
 

//h5
#define kUserAgreementURL      @"/agreement.html"            //用户协议
#define kRulesUrl              @"/index/teacher/system"      //规章制度
#define kAboutUsURL            @"/index/teacher/aboutus"     //关于我们

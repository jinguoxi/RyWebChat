//
//  MAConfig.h
//  SocketDemo
//
//  Created by nwk on 2017/1/4.
//  Copyright © 2017年 nwkcom.sh.n22. All rights reserved.
//

#ifndef MAConfig_h
#define MAConfig_h

//-----websocket消息类型说明

//发送和接收通用消息
typedef enum {
    MALOGON = 1,
    MALOGOUT = 2,
    MAREGISTER = 3
}MALoginStatus;

//机器人消息
typedef enum {
    ROBOT_MESSAGE_STATUS = 301,   //机器人聊天
    ROBOT_TRANSFER_MESSAGE = 302  //转人工
}MASocketRobotStatus;

//客户发送
typedef enum {
    MASEND_CHAT_REQUEST = 101,//发出聊天请求
    MACANCEL_CHAT_REQUEST = 102,//取消聊天请求
    MACLOSE_SESSION = 103,//结束聊天
    MARATE_SESSION = 104,//满意度评价
    MASEND_CHAT_MESSAGE = 110,//发送聊天消息
    MASEND_PRE_CHAT_MESSAGE = 111,//发送预消息（还没排完队时候的消息）
    MASEND_CUSTOM_MESSAGE = 199 //发送自定义消息
}MASocketSendStatus;

//客户接受
typedef enum {
    MACHAT_REQUEST_STATUS_UPDATE = 201,//聊天排队状态更新
    MACHAT_STARTED = 202,//通知客户端可以开始聊天
    MAAGENT_PUSH_RATING = 203,//坐席推送了满意度
    MAAGENT_UPDATED = 204,//坐席人员变更
    MAAGENT_CLOSE_SESSION = 205,//坐席关闭
    MAAGENT_SEND_MESSAGE = 210//收到聊天消息
}MASocketReceiveStatus;

//-----聊天消息类型说明
typedef enum {
    MATEXT = 1,
    MAIMG = 2,
    MAFILE = 3,
    MALOCATION = 4,
    MAVOICE = 5,
    MAVIDEO = 6,
    MASYSTEM_NOTICE = 99
}MAChatMsgType;


//-----聊天请求状态码

typedef enum {
    MAWAITING = 0,//等待中
    MAACCEPTED = 1,//坐席接受
    MAREFUSED = 2,//坐席拒绝
    MATIMEOUT = 3,//排队超时
    MADROPPED = 4,//异常丢失
    MANO_AGENT_ONLINE = 5,
    MAOFF_HOUR = 6,//不在工作时间
    MACANCELED_BY_CLIENT = 7,//被客户取消
    MAENTERPRISE_WECHAT_ACCEPTED = 11//坐席企业号接收
}MAChatRequestStatus;

//-----异常编码

typedef enum {
    MASUCCESS = 1,
    MAREQUEST_ALREADY_IN_ROULTING = -1,
    MAALREADY_IN_CHATTING = -2,
    MANOT_IN_WORKTIME = -3,
    MAINVAILD_SKILLGROUP = -4,
    MANO_AGENT_OFFLINE = -5,
    MAINVAILD_CLIENT_ID = -6,
    MAINVAILD_QUEUE_ID = -7,
    MAREQUEST_ERROR = -8,
    MAINVAILD_TO_USER_ID = -9,
    MAINVAILD_CHAT_REQUEST_ID = -10,
    MAINVAILD_CHAT_SESSION_ID = -11,
    MAINVAILD_MESSAGE_TYPE = -12,
    MAUPLOAD_FILE_FAILED = -13,
    MAINVAILD_PARAMETER = -14,
    MAINVAILD_TOKEN = -15,
    MAINVAILD_FILE_EXTENSION = -16,
    MAEMPTY_MESSAGE = -17,
    MAINVAILD_LOGINNAME_OR_PASSWORD = -20,
    MAINVAILD_SIGN = -30,
    MAINTERNAL_ERROR = -100
}MASocketException;

typedef enum {
    MANORMAL = 0,
    MATRACK_CHANGE = 1,
    MAPUSH_RATING = 2,
    MAAFK_ELAPSED_NOTIFY = 3,
    MAAFK_ELAPSED_CLOSE_SESSION = 4,
    MATYPING = 5,
    MAINVITE_NOTICE = 10,
    MATRANSFER_NOTICE = 11
}MANoticeMessageType;

static NSString *TXT_MSG = @"RC:TxtMsg";
static NSString *INFO_NTF = @"RC:InfoNtf";
static NSString *PROFILE_NTF = @"RC:ProfileNtf";
static NSString *CS_HS = @"RC:CsHs";
static NSString *VC_MSG = @"RC:VcMsg";
static NSString *LBS_MSG = @"RC:LBSMsg";
static NSString *IMG_MSG = @"RC:ImgMsg";
static NSString *FILE_MSG = @"RC:FileMsg";
static NSString *ELITE_MSG = @"E:Msg";

#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;
#define MAChatMsgBundle   @"MAChatMsg.bundle"
#define MAChatMsgBundleName(imageName)  [MAChatMsgBundle stringByAppendingPathComponent:imageName]

#endif /* MAConfig_h */

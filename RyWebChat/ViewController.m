//
//  ViewController.m
//  RyWebChat
//
//  Created by nwk on 2017/2/9.
//  Copyright © 2017年 nwkcom.sh.n22. All rights reserved.
//

#import "ViewController.h"
#import <RongIMKit/RongIMKit.h>
#import "MARyChatViewController.h"
#import "MJExtension.h"
#import <RongIMKit/RongIMKit.h>
#import "MAClient.h"
#import "MAEliteChat.h"
#import "MASatisfactionView.h"

//#define MACLIENTSERVERADDR @"http://118.242.18.190/webchat/rcs" //服务器地址
#define MACLIENTSERVERADDR @"http://192.168.2.80:8980/webchat/rcs" //服务器地址

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
- (IBAction)webChatPressed:(id)sender {
    
    [[MAEliteChat shareEliteChat] initAndStart:MACLIENTSERVERADDR userId:@"test" name:@"张三" portraitUri:@"https://avatars3.githubusercontent.com/u/15497804?v=3&u=fe6dfc22f6ae32639af26a096f8f67f65b892a28&s=400" queueId:1 complete:^(BOOL result) {
        if (result) [self switchChatViewController];
        else NSLog(@"初始化或启动失败");
    }];
}

- (void)switchChatViewController {
    //新建一个聊天会话View Controller对象,建议这样初始化
    
    MARyChatViewController *chat = [[MARyChatViewController alloc] initWithConversationType:ConversationType_PRIVATE targetId:CHAT_TARGET_ID];
    //设置聊天会话界面要显示的标题
    chat.title = CHAT_TITLE;
    chat.mapType = MAMAPTYPE_Baidu;
    dispatch_sync(dispatch_get_main_queue(), ^{
        //显示聊天会话界面
        [self.navigationController pushViewController:chat animated:YES];
    });
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

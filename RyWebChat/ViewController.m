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
#import "MAChat.h"
#import "MASatisfactionView.h"
#import "MAMessageUtils.h"

//#define MACLIENTSERVERADDR @"https://cht.1919.cn/EliteWebChat"
//#define MACLIENTSERVERADDR @"http://dev.elitecrm.com/webchat" //服务器地址
//#define MACLIENTSERVERADDR @"http://192.168.2.80:8980/webchat" //服务器地址

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *userId;
@property (weak, nonatomic) IBOutlet UITextField *headUrl;
@property (weak, nonatomic) IBOutlet UITextField *queueId;
@property (weak, nonatomic) IBOutlet UITextField *serverAddr;

@property (strong, nonatomic) MARyChatViewController *chatViewController;

@end

@implementation ViewController

- (MARyChatViewController *)chatViewController {
    NSString *chatTargetId = [[MAChat getInstance] getChatTargetId];
    if (!_chatViewController) {
        _chatViewController = [[MARyChatViewController alloc] initWithConversationType:ConversationType_PRIVATE targetId:chatTargetId];
    }
    
    return _chatViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *U_Name = [ user objectForKey:@"userName"];
    NSString *U_Id = [ user objectForKey:@"userId"];
    NSString *H_Url = [ user objectForKey:@"headUrl"];
    NSString *Q_Id = [ user objectForKey:@"queueId"];
    NSString *Q_ServerAddr = [ user objectForKey:@"serverAddr"];
    
    self.userName.text = U_Name;
    self.userId.text = U_Id;
    self.headUrl.text = H_Url?H_Url:@"https://avatars3.githubusercontent.com/u/15497804?v=3&u=fe6dfc22f6ae32639af26a096f8f67f65b892a28&s=400";
    self.queueId.text = Q_Id?Q_Id:@"1";
    self.serverAddr.text = Q_ServerAddr?Q_ServerAddr:@"http://dev.elitecrm.com/webchat";
    
}
- (IBAction)webChatPressed:(id)sender {
    [self.userName resignFirstResponder];
    [self.userId resignFirstResponder];
    [self.headUrl resignFirstResponder];
    [self.queueId resignFirstResponder];
    [self.serverAddr resignFirstResponder];
    
    if([self.userName.text isEqualToString:@""] ||
       [self.userId.text isEqualToString:@""]) {
        [[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"用户名或用户ID不能为空" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil] show];
        
        return;
    }
    NSString *h_uri = self.headUrl.text;
    if([h_uri isEqualToString:@""]){
        h_uri = @"https://avatars3.githubusercontent.com/u/15497804?v=3&u=fe6dfc22f6ae32639af26a096f8f67f65b892a28&s=400";
    }
    NSString *q_id = self.queueId.text;
    if([q_id isEqualToString:@""]){
        q_id = @"1";
    }
    NSString *q_serverAddr = self.serverAddr.text;
    if([q_serverAddr isEqualToString:@""]){
        q_serverAddr = @"http://dev.elitecrm.com/webchat";
    }
    int parseQueueId = [q_id intValue];
    
    __weak typeof(self) myself = self;
    // NSString *chatTargetId = [[MAChat getInstance] getChatTargetId];
    [[MAEliteChat shareEliteChat] initAndStart:q_serverAddr userId:self.userId.text name:self.userName.text portraitUri:h_uri chatTargetId:@"1919" queueId:parseQueueId ngsAddr:nil complete:^(BOOL result) {
        if (result) {
            [myself switchChatViewController];
            
            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
            [user setObject:self.userName.text forKey:@"userName"];
            [user setObject:self.userId.text forKey:@"userId"];
            [user setObject:self.headUrl.text forKey:@"headUrl"];
            [user setObject:self.queueId.text forKey:@"queueId"];
            [user setObject:self.serverAddr.text forKey:@"serverAddr"];
        }
        else NSLog(@"初始化或启动失败");
    }];
}

- (void)switchChatViewController {
    //删除会话页面
    if (_chatViewController) {
        [self.chatViewController.view removeFromSuperview];
        self.chatViewController = nil;
    }
    
    self.chatViewController.title = CHAT_TITLE;
    self.chatViewController.mapType = MAMAPTYPE_Baidu;
    //显示聊天会话界面
    [self.navigationController pushViewController:self.chatViewController animated:YES];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

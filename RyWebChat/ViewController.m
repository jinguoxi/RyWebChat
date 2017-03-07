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
#import "MAMessageUtils.h"

#define MACLIENTSERVERADDR @"http://118.242.18.190/webchat" //服务器地址
//#define MACLIENTSERVERADDR @"http://192.168.2.80:8980/webchat" //服务器地址

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *userId;
@property (weak, nonatomic) IBOutlet UITextField *headUrl;
@property (weak, nonatomic) IBOutlet UITextField *queueId;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *U_Name = [ user objectForKey:@"userName"];
    NSString *U_Id = [ user objectForKey:@"userId"];
    NSString *H_Url = [ user objectForKey:@"headUrl"];
    NSString *Q_Id = [ user objectForKey:@"queueId"];
    
    self.userName.text = U_Name;
    self.userId.text = U_Id;
    self.headUrl.text = H_Url?H_Url:@"https://avatars3.githubusercontent.com/u/15497804?v=3&u=fe6dfc22f6ae32639af26a096f8f67f65b892a28&s=400";
    self.queueId.text = Q_Id?Q_Id:@"1";
    
}
- (IBAction)webChatPressed:(id)sender {
    [self.userName resignFirstResponder];
    [self.userId resignFirstResponder];
    [self.headUrl resignFirstResponder];
    [self.queueId resignFirstResponder];
    
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
    int parseQueueId = [q_id intValue];
    [[MAEliteChat shareEliteChat] initAndStart:MACLIENTSERVERADDR userId:self.userId.text name:self.userName.text portraitUri:h_uri queueId:parseQueueId ngsAddr:nil complete:^(BOOL result) {
        if (result) {
            [self switchChatViewController];
            
            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
            [user setObject:self.userName.text forKey:@"userName"];
            [user setObject:self.userId.text forKey:@"userId"];
            [user setObject:self.headUrl.text forKey:@"headUrl"];
            [user setObject:self.queueId.text forKey:@"queueId"];
        }
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

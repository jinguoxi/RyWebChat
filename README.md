# WebChat App SDK 对接说明 #

### 在第三方的app中，可以与我们WebChat服务进行对接，其中对接方式主要有2种：
> 1. 直接嵌入mobile的h5页面，这种方式集成方便，几乎不需要什么开发量，缺点也很明显，由于是基于h5，界面友好度不够，且只有在页面打开时候可以查看到消息，当页面关闭后，消息是没法收到的。
> 2. 使用我们提供的App SDK，做深度的集成。这种方式会对第三方app有一定的开发要求，针对ios和android，还需要有不同的开发集成。而这种方式的好处在于，用户体验很高，可以发送语音视频等多媒体消息，即使app没有打开，也可以收到消息等。

这里主要讲一下App SDK的集成方式


##基于融云的app sdk 集成

我们的移动App SDK，集成了融云的移动通讯能力。借助融云的App消息上下行的能力，实现了坐席PC与客户手机app聊天。
具体说明可以查看融云官网：[http://www.rongcloud.cn/](http://www.rongcloud.cn/ "http://www.rongcloud.cn/")

看这篇文档时候，假设你已经是个ios开发者（或者Android），并且对融云已经有大致了解。在此基础上，我们来对具体集成步骤，加以说明：

###一. 注册融云账号

1. 在融云官网注册一个自己的账户，并创建一个app。[https://developer.rongcloud.cn/app](https://developer.rongcloud.cn/app "https://developer.rongcloud.cn/app")

2. 配置服务端实时消息路由的路由地址。具体地址，由过河兵相关人员提供。
![设置服务端消息路由地址](images/webchat-sdk-guide/2.png)

###二. APP 集成

这里以IOS系统为例：

1. 导入融云相关的sdk模块，这里使用到了IMLib，IMKit，AFNETworking，MJExtension, BaiduMapKit，Masonry。并按文档说明配置相关参数。  这里有两种方式导入： 1、通过 CocoaPods 管理依赖； 2、手动导入 SDK 并管理依赖。

2. 配置融云APP_KEY，调用此方法：[[RCIM sharedRCIM] initWithAppKey:@"YourTestAppKey"]; 您在使用融云 SDK 所有功能（包括显示 SDK 中的 View 或者显示继承于 SDK 的 View ）之前，您必须先调用此方法初始化 SDK, 在 App 的整个生命周期中，您只需要将 SDK 初始化一次。具体可以查看[http://www.rongcloud.cn/docs/ios.html](http://www.rongcloud.cn/docs/ios.html "http://www.rongcloud.cn/docs/ios.html") 具体看demo代码(MaEliteChat.m)。

3. 注册相关事件如自定义消息、自定义cell，开启用户信息持久化等相关信息具体看demo代码(MaEliteChat.m)。
```objective-c
//初始化融云
[[RCIM sharedRCIM] initWithAppKey:@"YourTestAppKey"]
//注册自定义消息
[[RCIM sharedRCIM] registerMessageType:[EliteMessage class]];
//注册自定义显示消息
[[RCIMClient sharedRCIMClient]registerMessageType:SimpleMessage.class];
//注册自定义用户信息提供者
RongIM.setUserInfoProvider(new EliteUserInfoProvider(), true);
//开启用户信息和群组信息的持久化
[RCIM sharedRCIM].enablePersistentUserInfoCache = YES;
[RCIM sharedRCIM].enableMessageAttachUserInfo = YES;
```	

4. 从github上下载过河兵demo项目， 可以直接复制或者使用SDK中相关类，其中ViewController.m不需要，使用自己app中的即可。

5. 在主ViewController中，初始化并启动EliteChat
```objective-c
/**
    * EliteChat提供方法
    * 初始化EliteChat， 获取rongcloud的token，并且启动聊天。
    * 如果发现token已经存在并且融云连接状态还是连接中的，则直接进入聊天
    * @param serverAddr EliteWebChat服务地址
    * @param userId 用户登录id
    * @param name 用户名
    * @param portraitUri 用户头像uri
    * @param context 当前上下文
    * @param queueId 排队队列号
    * @param ngsAddr ngs服务地址
    * @param tracks 客户浏览轨迹 json字符串，具体格式查看相关文档
    */
- (void)initAndStart:(NSString *)serverAddr userId:(NSString *)userId name:(NSString *)name portraitUri:(NSString *)portraitUri chatTargetId:(NSString *)chatTargetId queueId:(int)queueId ngsAddr:(NSString *)ngsAddr tracks:(NSString *)tracks complete:(void (^)(BOOL result))complete
```
这里的EliteWebChat服务地址，需要找过河兵相关人员提供，用户登录id可以是你们系统中的用户名，不重复即可，这里会自动查询如果不存在与过河兵系统中，会自动创建相关客户。排队队列号也是找过河兵相关人员提供即可。

###三. SDK中更多高级方法说明
经过上述的步骤，App SDK已经可以对接起来了。客户可以发出聊天请求，排队聊天，如果有坐席接起这个聊天请求，客户就可以和坐席正常聊天了。下面再说一些高级功能：

1. 在排队之前，就发出一些预发消息
```objective-c
//发送文字消息，在调用[[MAEliteChat shareEliteChat] initAndStart]之前，就可以调用此方法，之后一旦聊天建立起来后，这个预发消息会自动发出。
[MAMessageUtils sendTxtMessage: @"firstMsg"];
//发送自定义消息，这个消息内容随便自己定义，坐席端可以收到相关消息自行做对应处理。比如这里发送一个商品信息的json字符串。坐席端可以收到后显示出对应的商品信息。
[MAMessageUtils sendCustomerMessage: @"{\"name\":\"xxx\"}"];
```

2. 如果客户已经进入过聊天，返回到app其他页面后，再次想打开聊天，这时候可以直接启动页面，而不需要再次发起排队了
```objective-c
//先判断，当前会话是否还在活动中，如果活动中则可以不发起排队，直接显示页面,并提示“继续之前的会话”
//如果会话已经结束了，或者token已经失效，则重新发起聊天请求
[[MAEliteChat shareEliteChat] initAndStart:q_serverAddr userId:self.userId.text name:self.userName.text portraitUri:h_uri chatTargetId:@"1919" queueId:parseQueueId ngsAddr:nil tracks:@"web" complete:^(BOOL result);
```

3. 如果需要使用地图发送地图消息
SDK支持高德地图和百度地图两种选择，这里以百度地图为例：
```objective-c
1. 在appDelegate.m中配置百度地图API_KEY 并调用_mapManager start方法初始化
[_mapManager start:@"Z6yG7WrkRXFfiqGosOBTIOk4MoDE9Gcl"  generalDelegate:self];

2. 在会话页面并在会话开始前需要指定地图的类型
self.chatViewController.mapType = MAMAPTYPE_Baidu    这里指定的是百度地图   高徳为： MAMAPTYPE_Gaode  
```
4.发送小视频消息
需要去融云官网下载小视频SDK 将 RongSight.framework 编译连接到自己的项目里面就可以使用小视频功能，不需要写额外的代码。

特别注意：
    1、 融云SDK版本为2.9.3以后的版本才支持发送小视频。
	2、 如不需要小视频功能 将RongSight.framework从项目移除即可
	

###**完整的相关代码说明都可以从demo示例代码中找到**

ios的GitHub代码仓库地址 ：[https://github.com/jinguoxi/RyWebChat](https://github.com/jinguoxi/RyWebChat "https://github.com/jinguoxi/RyWebChat")
android的GitHub代码仓库地址 ：[https://github.com/loriling/RCClient](https://github.com/loriling/RCClient "https://github.com/loriling/RCClient")




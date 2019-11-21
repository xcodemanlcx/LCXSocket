//
//  ServerViewController.m
//  LCXSocket
//
//  Created by lcx on 2019/11/21.
//  Copyright © 2019 lcx. All rights reserved.
//

#import "ServerViewController.h"
#import "SocketServer.h"

#define kWeakSelf  __weak typeof(self) weakSelf = self
#define kStrongSelf __strong typeof(weakSelf) strongSelf = weakSelf

@interface ServerViewController ()

//UI
@property (weak, nonatomic) IBOutlet UITextField *portTextField;
@property (weak, nonatomic) IBOutlet UITextField *sendMessageTextField;
@property (weak, nonatomic) IBOutlet UIButton *startListenButton;
@property (weak, nonatomic) IBOutlet UIButton *disconnectButton;
@property (weak, nonatomic) IBOutlet UIButton *sendMessageButton;
@property (weak, nonatomic) IBOutlet UITextView *showMessageTextView;

//socket
@property (nonatomic ,strong) SocketServer *socketServer;
@property (nonatomic ,strong) NSTimer *longConnectTimer;
// 客户端标识和心跳接收时间的字典
@property (nonatomic, strong) NSMutableDictionary *clientPhoneTimeDict;

@end

@implementation ServerViewController
{
    //socket
    SocketServer *_socketServer;
    NSTimer *_checkTimer;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _clientPhoneTimeDict = @{}.mutableCopy;
    [_startListenButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [_startListenButton setTitle:@"停止服务" forState:UIControlStateSelected];
}

#pragma mark - Lazy loading:Socket、timer

- (SocketServer *)socketServer{
    if (_socketServer) return _socketServer;
    //1 创建服务端
    _socketServer = [[SocketServer alloc] initWithQueue:dispatch_get_main_queue()];
    kWeakSelf;
    //2.1 接受连接成功
    _socketServer.socketAccept = ^(GCDAsyncSocket * _Nonnull sock, GCDAsyncSocket * _Nonnull newSocket) {
        kStrongSelf;
        [strongSelf showMessageWithStr:[NSString stringWithFormat:@"接受连接成功,客户端的地址: %@-端口: %d", newSocket.connectedHost, newSocket.connectedPort]];
        [strongSelf longConnectTimer];
    };
    //2.2 读取消息
    _socketServer.socketReadData = ^(GCDAsyncSocket * _Nonnull sock, NSData * _Nonnull data, long tag) {
        [weakSelf dealwithSocketData:data];
    };
    //2.3 连接断开
    _socketServer.socketDisconnect = ^(GCDAsyncSocket * _Nonnull sock, NSError * _Nonnull err) {
        kStrongSelf;
        strongSelf.startListenButton.selected = NO;
        [strongSelf showMessageWithStr:@"连接断开"];
    };
    return _socketServer;
}

- (NSTimer *)longConnectTimer{
    if (_longConnectTimer) return _longConnectTimer;
    _longConnectTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(longConnectTimerAction) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_longConnectTimer forMode:NSRunLoopCommonModes];
    return _longConnectTimer;
}

#pragma mark - Action

// 检测心跳
- (void)longConnectTimerAction{
    [_clientPhoneTimeDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        // 当前时间
        NSString *currentTimeStr = [self getCurrentTime];
        // 延迟超过10秒判断断开
        if (([currentTimeStr doubleValue] - [obj doubleValue]) > 10.0){
            [self showMessageWithStr:[NSString stringWithFormat:@"%@已经断开,连接时差%f",key,[currentTimeStr doubleValue] - [obj doubleValue]]];
            [self showMessageWithStr:[NSString stringWithFormat:@"移除%@",key]];
            [_clientPhoneTimeDict removeObjectForKey:key];
        } else{
            [self showMessageWithStr:[NSString stringWithFormat:@"%@处于连接状态,连接时差%.2f",key,[currentTimeStr doubleValue] - [obj doubleValue]]];
        }
    }];
}

- (IBAction)startListenAction:(UIButton *)sender {
    if (sender.selected == NO) {
        //监听端口:启动服务
            BOOL result = [self.socketServer startServiceOnPort:_portTextField.text.integerValue];
        sender.selected = result;
        if (result) {
            [self showMessageWithStr:@"开放成功"];
        }
    }else{
        [_socketServer stopService];
        sender.selected = NO;
    }
}

- (IBAction)sendMessageAction:(id)sender {
    if (_socketServer.clientSockets.count == 0 || _sendMessageTextField.text.length == 0) return;
    
    NSData *data = [_sendMessageTextField.text dataUsingEncoding:NSUTF8StringEncoding];
    // withTimeout -1 : 无穷大,一直等
    // tag : 消息标记
    kWeakSelf;
    [_socketServer.clientSockets enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [weakSelf.socketServer writeData:data toClient:obj];
    }];
}

#pragma mark - Other

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)showMessageWithStr:(NSString *)str
{
    _showMessageTextView.text = [_showMessageTextView.text stringByAppendingFormat:@"%@\n", str];
}

- (NSString *)getCurrentTime
{
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval currentTime = [date timeIntervalSince1970];
    NSString *currentTimeStr = [NSString stringWithFormat:@"%.0f", currentTime];
    return currentTimeStr;
}

- (void)dealwithSocketData:(NSData *)data{
    if (!data) return;

    NSString *text = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    [self showMessageWithStr:text];
    // 第一次读取到的数据直接添加
    if (_clientPhoneTimeDict.count == 0){
        [_clientPhoneTimeDict setObject:[self getCurrentTime] forKey:text];
    } else{
        [_clientPhoneTimeDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [_clientPhoneTimeDict setObject:[self getCurrentTime] forKey:text];
        }];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

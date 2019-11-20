//
//  ClientViewController.m
//  LCXSocket
//
//  Created by leichunxiang on 2019/11/20.
//  Copyright © 2019 lcx. All rights reserved.
//

#import "ClientViewController.h"
#import "SocketClient.h"

@interface ClientViewController ()

//UI
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (weak, nonatomic) IBOutlet UITextField *portTextField;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UITextField *sendMessageTextField;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;

@end

@implementation ClientViewController

{
    //socket
    SocketClient *_socketClient;
    NSTimer *_connectTimer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - Action

- (IBAction)connectAction:(id)sender {
    if (!_socketClient.isConnected)
    {
        //1 创建socket客户端
        _socketClient =[[SocketClient alloc] initWithQueue:dispatch_get_main_queue()];
        
        //2.1 设置连接回调-连接成功
        __weak typeof(self) weakSelf = self;
        _socketClient.socketConnect = ^(GCDAsyncSocket * _Nonnull sock, NSString * _Nonnull host, uint16_t port) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf showMessageWithStr:[NSString stringWithFormat:@"连接成功-服务器IP: %@,端口: %d", host,port]];
            // 连接成功,建立心跳连接
            [strongSelf addTimer];
        };
        //2.2 设置连接回调-读取数据
        _socketClient.socketReadData = ^(GCDAsyncSocket * _Nonnull sock, NSData * _Nonnull data, long tag) {
            NSString *text = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            [weakSelf showMessageWithStr:text];
        };
        //2.3 设置连接回调-断开连接
        _socketClient.socketDisConnect = ^(GCDAsyncSocket * _Nonnull sock, NSError * _Nonnull err) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf showMessageWithStr:@"断开连接"];
            [strongSelf->_connectTimer invalidate];
            strongSelf->_connectTimer = nil;
        };
        
        //3 开始连接
        [_socketClient connectToHost:self.addressTextField.text port:self.portTextField.text.integerValue];
        
        //开始连接后的提示
        [self showMessageWithStr:_socketClient.isConnected?@"客户端尝试连接":@"客户端未创建连接"];
    }else{
        [self showMessageWithStr:@"与服务器连接已建立"];
    }
}

- (IBAction)sendMessageAction:(id)sender {
    NSData *data = [self.sendMessageTextField.text dataUsingEncoding:NSUTF8StringEncoding];
    [_socketClient writeData:data];
}

- (IBAction)disconnectAction:(id)sender {
    [_socketClient disconnect];
}


- (void)longConnectTimerAction
{
    // 发送固定格式的数据
    float version = [[UIDevice currentDevice] systemVersion].floatValue;
    NSString *longConnect = [NSString stringWithFormat:@"固定格式数据:%f",version];
    NSData  *data = [longConnect dataUsingEncoding:NSUTF8StringEncoding];
    [_socketClient writeData:data];
}
#pragma mark - other

// 长连接定时器
- (void)addTimer
{
    _connectTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(longConnectTimerAction) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_connectTimer forMode:NSRunLoopCommonModes];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)showMessageWithStr:(NSString *)str
{
    self.messageTextView.text = [self.messageTextView.text stringByAppendingFormat:@"%@\n", str];
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

//
//  ClientViewController.m
//  LCXSocket
//
//  Created by leichunxiang on 2019/11/20.
//  Copyright © 2019 lcx. All rights reserved.
//

#import "ClientViewController.h"
#import "SocketClient.h"

#define kWeakSelf  __weak typeof(self) weakSelf = self
#define kStrongSelf __strong typeof(weakSelf) strongSelf = weakSelf

@interface ClientViewController ()

//UI
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (weak, nonatomic) IBOutlet UITextField *portTextField;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UITextField *sendMessageTextField;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;

//socket
@property (nonatomic ,strong) SocketClient *socketClient;
@property (nonatomic ,strong) NSTimer *longConnectTimer;

@end

@implementation ClientViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [_connectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [_connectButton setTitle:@"连接断开" forState:UIControlStateSelected];
}

#pragma mark - Lazy loading:Socket、timer

- (SocketClient *)socketClient{
    if (_socketClient) return _socketClient;
    
    //1 创建socket客户端
    _socketClient =[[SocketClient alloc] initWithQueue:dispatch_get_main_queue()];
    
    //2.1 设置连接回调-连接成功
    kWeakSelf;
    _socketClient.socketConnect = ^(GCDAsyncSocket * _Nonnull sock, NSString * _Nonnull host, uint16_t port) {
        kStrongSelf;
        [strongSelf showMessageWithStr:[NSString stringWithFormat:@"连接成功-服务器IP: %@,端口: %d", host,port]];
        // 建立心跳连接
        [strongSelf longConnectTimer];
    };
    //2.2 设置连接回调-读取数据
    _socketClient.socketReadData = ^(GCDAsyncSocket * _Nonnull sock, NSData * _Nonnull data, long tag) {
        NSString *text = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        [weakSelf showMessageWithStr:text];
    };
    //2.3 设置连接回调-连接断开
    _socketClient.socketDisconnect = ^(GCDAsyncSocket * _Nonnull sock, NSError * _Nonnull err) {
        kStrongSelf;
        strongSelf.sendButton.selected = NO;
        [strongSelf.longConnectTimer invalidate];
        strongSelf.longConnectTimer = nil;
        [strongSelf showMessageWithStr:@"连接断开"];
    };
    
    return _socketClient;
}

- (NSTimer *)longConnectTimer{
    if (_longConnectTimer) return _longConnectTimer;
    _longConnectTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(longConnectTimerAction) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_longConnectTimer forMode:NSRunLoopCommonModes];
    return _longConnectTimer;
}

#pragma mark - Action

- (IBAction)connectAction:(UIButton *)sender {
    if (sender.selected == NO)
    {
        //建立连接
        sender.selected = [self.socketClient connectToHost:_addressTextField.text port:_portTextField.text.integerValue];
        [self showMessageWithStr:sender.selected?@"客户端尝试连接":@"客户端未创建连接"];
    }else{
        [_socketClient disconnect];
        _socketClient = nil;
        sender.selected = NO;
    }
}

- (IBAction)sendMessageAction:(id)sender {
    NSData *data = [_sendMessageTextField.text dataUsingEncoding:NSUTF8StringEncoding];
    [_socketClient writeData:data];
}

- (void)longConnectTimerAction
{
    // 发送固定格式的数据
    float version = [[UIDevice currentDevice] systemVersion].floatValue;
    NSString *longConnect = [NSString stringWithFormat:@"固定格式数据:%1.f",version];
    NSData  *data = [longConnect dataUsingEncoding:NSUTF8StringEncoding];
    [_socketClient writeData:data];
}

#pragma mark - other

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)showMessageWithStr:(NSString *)str
{
    _messageTextView.text = [_messageTextView.text stringByAppendingFormat:@"%@\n", str];
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

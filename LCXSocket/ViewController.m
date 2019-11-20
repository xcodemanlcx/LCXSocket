//
//  ViewController.m
//  LCXSocket
//
//  Created by leichunxiang on 2019/11/18.
//  Copyright © 2019 lcx. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncSocket.h"

@interface ViewController ()<GCDAsyncSocketDelegate>
// 客户端socket
@property (strong, nonatomic) GCDAsyncSocket *clientSocket;
// 计时器
@property (nonatomic, strong) NSTimer *connectTimer;
@property (nonatomic, assign) BOOL connected;

@end

@implementation ViewController
UIButton *AddButton(UIView *superView, CGRect frame, NSInteger tag, id target, SEL action, UIButtonType type)
{
    UIButton *btn = [UIButton buttonWithType:type];
    btn.frame = frame;
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [btn setTag:tag];
    btn.backgroundColor = [UIColor clearColor];
    [superView addSubview:btn];
    return btn;
}

UIButton *AddTitleButton(UIView *superView, CGRect frame, NSInteger tag, id target, SEL action, NSString *title,UIFont *font, UIColor *color,  UIColor * _Nullable colorH){
    UIButton *btn = AddButton(superView, frame, tag, target, action, UIButtonTypeCustom);
    if (title)
        [btn setTitle:title forState:UIControlStateNormal];
    if (font)
        btn.titleLabel.font = font;
    if (color)
        [btn setTitleColor:color forState:UIControlStateNormal];
    if (colorH)
        [btn setTitleColor:colorH forState:UIControlStateHighlighted];
    
    return btn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    AddTitleButton(self.view, CGRectMake(0, 100, self.view.frame.size.width, 50), 101, self, @selector(conectionAction), @"连接", [UIFont systemFontOfSize:30], [UIColor orangeColor], [UIColor orangeColor]);
}

- (void)conectionAction{
    self.clientSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSError *error = nil;
    self.connected = [self.clientSocket connectToHost:@"192.168.1.88" onPort:8080 viaInterface:nil withTimeout:-1 error:&error];
    NSLog(@"连接，%i",self.connected);

}

// 添加计时器
- (void)addTimer
{
    // 长连接定时器
    self.connectTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(longConnectToSocket) userInfo:nil repeats:YES];
    // 把定时器添加到当前运行循环,并且调为通用模式
    [[NSRunLoop currentRunLoop] addTimer:self.connectTimer forMode:NSRunLoopCommonModes];
}

// 心跳连接
- (void)longConnectToSocket
{
    // 发送固定格式的数据,指令@"longConnect"
    float version = [[UIDevice currentDevice] systemVersion].floatValue;
    NSString *longConnect = [NSString stringWithFormat:@"123%f",version];
    
    NSData  *data = [longConnect dataUsingEncoding:NSUTF8StringEncoding];
    
    // withTimeout -1 : 无穷大,一直等
    // tag : 消息标记
    //发送数据
    [self.clientSocket writeData:data withTimeout:- 1 tag:0];
}
#pragma mark - GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    NSLog(@"连接成功");
    [self addTimer];
    // 读取数据
    [self.clientSocket readDataWithTimeout:- 1 tag:0];
    self.connected = YES;
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSLog(@"读到的数据：%@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
    // 读取到后，再次读取数据
    [self.clientSocket readDataWithTimeout:- 1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    NSLog(@"发送数据");
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    NSLog(@"断开连接");
    
    self.clientSocket.delegate = nil;
//    [self.clientSocket disconnect];
    self.clientSocket = nil;
    self.connected = NO;
    [self.connectTimer invalidate];
}


@end

//
//  SocketClient.m
//  LCXSocket
//
//  Created by leichunxiang on 2019/11/20.
//  Copyright © 2019 lcx. All rights reserved.
//

#import "SocketClient.h"

@interface SocketClient ()<GCDAsyncSocketDelegate>

@end

@implementation SocketClient

#pragma mark - GCDAsyncSocket

- (instancetype)initWithQueue:(dispatch_queue_t)queue {
    self = [super init];
    if (self) {
        _clientSocket  = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:queue];
    }
    return self;
}

- (BOOL)connectToHost:(NSString *)host port:(UInt16)port{
    if (!_clientSocket) return NO;
    
    _host = host;
    _port = port;
    NSError *error = nil;
    BOOL result = [_clientSocket connectToHost:host onPort:port withTimeout:-1 error:&error];
    return (result && error == nil);
}

- (void)writeData:(NSData *)data {
    
    if (!_clientSocket) return;

    // withTimeout -1 : 无穷大,一直等
    // tag : 消息标记
    [_clientSocket  writeData:data withTimeout:-1 tag:0];
}

- (void)disconnect {
    if (!_clientSocket) return;
    
        [_clientSocket  disconnect];
}

#pragma mark - GCDAsyncSocketDelegate

//连接成功
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    if (_socketConnect) {
        _socketConnect(sock,host,port);
    }
    //读取消息
    [_clientSocket  readDataWithTimeout:-1 tag:0];
}

//接收信息
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    if (_socketReadData) {
        _socketReadData(sock,data,tag);
    }
    //再次读取
    [_clientSocket  readDataWithTimeout:- 1 tag:0];
}

/*?
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    [_clientSocket readDataWithTimeout:-1 tag:0];
}
*/

//连接断开
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{

    if (_socketDisconnect) {
        _socketDisconnect(sock,err);
    }
    _clientSocket.delegate = nil;
    _clientSocket  = nil;
}
@end

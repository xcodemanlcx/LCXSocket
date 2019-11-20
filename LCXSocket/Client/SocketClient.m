//
//  SocketClient.m
//  LCXSocket
//
//  Created by leichunxiang on 2019/11/20.
//  Copyright © 2019 lcx. All rights reserved.
//

#import "SocketClient.h"

@implementation SocketClient

#pragma mark - GCDAsyncSocket

- (instancetype)initWithQueue:(dispatch_queue_t)queue {
    self = [super init];
    if (self) {
        _clientSocket  = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:queue];
    }
    return self;
}

- (void)connectToHost:(NSString *)host port:(UInt16)port{
    _host = host;
    _port = port;
    NSError *error = nil;
    _isConnected = [_clientSocket  connectToHost:host onPort:port withTimeout:-1 error:&error];
}

- (void)writeData:(NSData *)data {
    // withTimeout -1 : 无穷大,一直等
    // tag : 消息标记
    [_clientSocket  writeData:data withTimeout:-1 tag:1];
}

- (void)disconnect {
    [_clientSocket  disconnect];
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    _isConnected = YES;
    if (_socketConnect) {
        _socketConnect(sock,host,port);
    }
    //读取数据
    [_clientSocket  readDataWithTimeout:-1 tag:1];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    if (_socketReadData) {
        _socketReadData(sock,data,tag);
    }
    //再次读取
    [_clientSocket  readDataWithTimeout:- 1 tag:1];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    _isConnected = NO;
    _clientSocket .delegate = nil;
    _clientSocket  = nil;
    if (_socketDisConnect) {
        _socketDisConnect(sock,err);
    }
}
@end

//
//  SocketServer.m
//  LCXSocket
//
//  Created by lcx on 2019/11/21.
//  Copyright © 2019 lcx. All rights reserved.
//

#import "SocketServer.h"

@interface SocketServer ()<GCDAsyncSocketDelegate>

@end
@implementation SocketServer

#pragma mark - Socket

- (instancetype)initWithQueue:(dispatch_queue_t)queue {
    self = [super init];
    if (self) {
//        _socketHost = [NSString ll_IPAddress];
        _clientSockets = @[].mutableCopy;
        _serverSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:queue];
    }
    return self;
}

- (BOOL)startServiceOnPort:(UInt16)port{
    _port = port;
    NSError *error = nil;
    BOOL result =  [_serverSocket acceptOnPort:port error:&error];
    return (result && error == nil);
}

- (void)writeData:(NSData *)data toClient:(GCDAsyncSocket *)client {
    [client writeData:data withTimeout:-1 tag:0];
}

- (void)stopService {
    [_serverSocket disconnect];
}

#pragma mark - GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    // 保存客户端的socket
    [_clientSockets addObject:newSocket];
    if (_socketAccept) {
        _socketAccept(sock,newSocket);
    }
    [newSocket readDataWithTimeout:- 1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    if (_socketReadData) {
        _socketReadData(sock,data,tag);
    }
    [sock readDataWithTimeout:- 1 tag:0];
}

/* ?
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    [sock readDataWithTimeout:-1 tag:0];
}
 */

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    if (_socketDisconnect) {
        _socketDisconnect(sock,err);
    }
}

@end

//
//  SocketServer.h
//  LCXSocket
//
//  Created by lcx on 2019/11/21.
//  Copyright © 2019 lcx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

NS_ASSUME_NONNULL_BEGIN

@interface SocketServer : NSObject

#pragma mark - Socket
@property (nonatomic, readonly,strong) GCDAsyncSocket *serverSocket;
@property (nonatomic, readonly,strong) NSMutableArray *clientSockets;
@property (nonatomic, readonly, assign) UInt16 port;
@property (nonatomic, readonly, strong) NSString *host;

- (instancetype)initWithQueue:(dispatch_queue_t)queue;

//开始服务：监听端口
- (BOOL)startServiceOnPort:(UInt16)port;
//发送消息
- (void)writeData:(NSData *)data toClient:(GCDAsyncSocket *)client;
//停止服务
- (void)stopService;

#pragma mark - Block:GCDAsyncSocketDelegate

//接受连接成功
@property (nonatomic, copy) void (^socketAccept)(GCDAsyncSocket *sock,GCDAsyncSocket *newSocket) ;
//读取消息
@property (nonatomic, copy) void (^socketReadData)(GCDAsyncSocket *sock,NSData *data,long tag);
//连接断开
@property (nonatomic, copy) void (^socketDisconnect)(GCDAsyncSocket *sock,NSError *err);

@end

NS_ASSUME_NONNULL_END

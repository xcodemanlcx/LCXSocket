//
//  SocketClient.h
//  LCXSocket
//
//  Created by leichunxiang on 2019/11/20.
//  Copyright © 2019 lcx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
NS_ASSUME_NONNULL_BEGIN

@interface SocketClient : NSObject<GCDAsyncSocketDelegate>


#pragma mark - Socket
@property (nonatomic, readonly,strong) GCDAsyncSocket *clientSocket;
@property (nonatomic, readonly, assign) UInt16 port;
@property (nonatomic, readonly, strong) NSString *host;

- (instancetype)initWithQueue:(dispatch_queue_t)queue;

- (BOOL)connectToHost:(NSString *)host port:(UInt16)port;
//发送消息
- (void)writeData:(NSData *)data;

- (void)disconnect;

#pragma mark - Block:GCDAsyncSocketDelegate
//连接成功
@property (nonatomic, copy) void (^socketConnect)(GCDAsyncSocket *sock,NSString *host,uint16_t port);
//读取消息
@property (nonatomic, copy) void (^socketReadData)(GCDAsyncSocket *sock,NSData *data,long tag);
//连接断开
@property (nonatomic, copy) void (^socketDisconnect)(GCDAsyncSocket *sock,NSError *err);

@end

NS_ASSUME_NONNULL_END

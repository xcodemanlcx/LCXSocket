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
@property (nonatomic, readonly,assign) BOOL isConnected;
@property (nonatomic, readonly, assign) UInt16 port;
@property (nonatomic, readonly, strong) NSString *host;

- (instancetype)initWithQueue:(dispatch_queue_t)queue;

- (void)connectToHost:(NSString *)host port:(UInt16)port;

- (void)writeData:(NSData *)data;

- (void)disconnect;

#pragma mark - GCDAsyncSocketDelegate(Block)

@property (nonatomic, copy) void (^socketConnect)(GCDAsyncSocket *sock,NSString *host,uint16_t port);
@property (nonatomic, copy) void (^socketReadData)(GCDAsyncSocket *sock,NSData *data,long tag);
@property (nonatomic, copy) void (^socketDisConnect)(GCDAsyncSocket *sock,NSError *err);

@end

NS_ASSUME_NONNULL_END

//
//  YAsyncSocketManager.m
//  DemoSocket
//
//  Created by yxf on 2017/7/25.
//  Copyright © 2017年 yxf. All rights reserved.
//

#import "YAsyncSocketManager.h"
#import <CocoaAsyncSocket/GCDAsyncSocket.h>//tcp

static NSString * KHost = @"127.0.0.1";
static const uint16_t kPort = 6969;

@interface YAsyncSocketManager ()<GCDAsyncSocketDelegate>{
    GCDAsyncSocket *_gcdSocket;
}


@end

@implementation YAsyncSocketManager

#pragma mark - publicj func
+(instancetype)shareInstance{
    static YAsyncSocketManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        [manager initSocket];
        [manager connect];
    });
    return manager;
}

-(BOOL)connect{
    return [_gcdSocket connectToHost:KHost onPort:kPort error:nil];
}

-(void)disConnect{
    [_gcdSocket disconnect];
}

-(void)sendMsg:(NSString *)msg{
    NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
    [_gcdSocket writeData:data withTimeout:-1 tag:110];
}

-(void)pullTheMsg{
    //监听读数据的代理 -1永远监听，不超时，但是只收一次消息
    //所以每次接受到消息还得调用一次
    [_gcdSocket readDataWithTimeout:-1 tag:110];
}

#pragma mark - private func
-(void)initSocket{
    _gcdSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
}

#pragma mark - GCDAsyncSocketDelegate
//连接成功调用
-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    
    NSLog(@"连接成功,host:%@,port:%d",host,port);
    
    [self pullTheMsg];
    
    //心跳写在这
}

//断开连接的时候调用
-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    NSLog(@"断开连接,host:%@,port:%d",sock.localHost,sock.localPort);
    
    //断线重连写在这里
}

//写成功的回调
-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    NSLog(@"写的回调,tag:%ld",tag);
}

//收到消息的回调
-(void)socket:(GCDAsyncSocket *)sock didReadData:(nonnull NSData *)data withTag:(long)tag{
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"收到消息:%@",msg);
    
    [self pullTheMsg];
}

//分段去获取消息的回调
//- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag
//{
//
//    NSLog(@"读的回调,length:%ld,tag:%ld",partialLength,tag);
//
//}

//为上一次设置的读取数据代理续时 (如果设置超时为-1，则永远不会调用到)
//-(NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length
//{
//    NSLog(@"来延时，tag:%ld,elapsed:%f,length:%ld",tag,elapsed,length);
//    return 10;
//}

@end

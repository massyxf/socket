//
//  YWebSocketManager.m
//  DemoSocket
//
//  Created by yxf on 2017/7/25.
//  Copyright © 2017年 yxf. All rights reserved.
//

#import "YWebSocketManager.h"
#import <SocketRocket/SocketRocket.h>

#define dispatch_main_safe(block)\
if([NSThread isMainThread]){\
block();\
}else{\
dispatch_async(dispatch_get_main_queue(), block);\
}

@interface YWebSocketManager ()<SRWebSocketDelegate>{
    SRWebSocket *_webSocket;
    NSTimer *_heartBeat;
    NSTimeInterval _reConnectTime;
}

@end

@implementation YWebSocketManager

static NSString *kHost = @"127.0.0.1";
static const uint16_t kPort = 6969;

+(instancetype)shareInstance{
    static YWebSocketManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        [manager initSocket];
    });
    return manager;
}

-(void)connect{
    [self initSocket];
    
    //每次正常连接的时候清零重连时间
    _reConnectTime = 0;
}

-(void)disconnect{
    if (_webSocket) {
        [_webSocket close];
        _webSocket = nil;
    }
}

-(void)sendMsg:(NSString *)msg{
    if (_webSocket.readyState == SR_CONNECTING) {
        NSLog(@"connect");
    }
    
    if (_webSocket.readyState == SR_OPEN) {
        NSLog(@"open");
    }
    
    [_webSocket send:msg];
}

-(void)ping{
    [_webSocket sendPing:nil];
}

#pragma mark - private func
//初始化连接
-(void)initSocket{
    if (_webSocket) {
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"ws://%@:%zd",kHost,kPort];
    _webSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:url]];
    _webSocket.delegate = self;
    
    //设置代理线程queue
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;
    [_webSocket setDelegateOperationQueue:queue];
    
    //连接
    [_webSocket open];
    
    NSLog(@"连接,%zd",_webSocket.readyState);
    
}

-(void)reConnect{
    [self disconnect];
    
    //超过一分钟就不再重连，所以只会重连5次 2^5 = 64
    if (_reConnectTime > 64) {
        return;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_reConnectTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _webSocket = nil;
        [self initSocket];
    });
    
    if (_reConnectTime == 0) {
        _reConnectTime = 2;
    }else{
        _reConnectTime *= 2;
    }
    
}

#pragma mark - heart beat

//初始化心跳
-(void)initHeartBeat{
    
    dispatch_main_safe(^{
        [self destroyHeartBeat];
        
        _heartBeat = [NSTimer timerWithTimeInterval:3 * 60
                                             target:self
                                           selector:@selector(heartBeat)
                                           userInfo:nil
                                            repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_heartBeat forMode:NSRunLoopCommonModes];
    });
}

-(void)heartBeat{
    NSString *heart = @"heart";
    
    NSLog(@"%@",heart);
    
    //和服务器约定好发送什么作为心跳标识，尽可能的减少心跳包大小
    [self sendMsg:heart];
}

-(void)destroyHeartBeat{
    dispatch_main_safe(^{
        if (_heartBeat) {
            [_heartBeat invalidate];
            _heartBeat = nil;
        }
    });
}

#pragma mark - SRWebSocketDelegate
-(void)webSocketDidOpen:(SRWebSocket *)webSocket{
    NSLog(@"连接成功,%zd",webSocket.readyState);
    
    //开始发送心跳
    [self initHeartBeat];
}

-(void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message{
    NSLog(@"收到信息:%@",message);
}

-(void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error{
    NSLog(@"连接失败%@",error);
    
    //重连
    [self reConnect];
}

//网络连接中断被调用
-(void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean{
    NSLog(@"被关闭连接，code:%ld,reason:%@,wasClean:%d",code,reason,wasClean);
    
    //如果是被用户自己中断的那么直接断开连接，否则开始重连
    if (code == disconnectByUser) {
        [self disconnect];
    }else{
        [self reConnect];
    }
    //断开连接时销毁心跳
    [self destroyHeartBeat];
}

-(void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload{
    NSLog(@"收到pong回调");
}

//将收到的消息，是否需要把data转换为NSString，每次收到消息都会被调用，默认YES
//- (BOOL)webSocketShouldConvertTextFrameToString:(SRWebSocket *)webSocket
//{
//    NSLog(@"webSocketShouldConvertTextFrameToString");
//
//    return NO;
//}

@end

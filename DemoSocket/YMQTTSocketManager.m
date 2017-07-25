//
//  YMQTTSocketManager.m
//  DemoSocket
//
//  Created by yxf on 2017/7/25.
//  Copyright © 2017年 yxf. All rights reserved.
//

#import "YMQTTSocketManager.h"
#import <MQTTKit/MQTTKit.h>


@interface YMQTTSocketManager ()

/** mqtt*/
@property(nonatomic,strong)MQTTClient *mqttClient;

@end

static NSString *kHost = @"127.0.0.1";
static const uint16_t kPort = 6969;
static NSString *kClientID = @"y_sb";

@implementation YMQTTSocketManager

+(instancetype)shareInstance{
    static YMQTTSocketManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[YMQTTSocketManager alloc] init];
    });
    return manager;
}

-(void)connect{
    [self initSocket];
}

-(void)disconnect{
    if (_mqttClient) {
        //取消订阅
        [_mqttClient unsubscribe:_mqttClient.clientID withCompletionHandler:^{
            NSLog(@"取消订阅成功");
        }];
        
        [_mqttClient disconnectWithCompletionHandler:^(NSUInteger code) {
            NSLog(@"断开mqtt成功:%zd",code);
        }];
        _mqttClient = nil;
    }
}

-(void)sendMsg:(NSString *)msg{
    //发送一条消息，发送给自己订阅的主题
//    QOS(0),最多发送一次：如果消息没有发送过去，那么就直接丢失。
//    QOS(1),至少发送一次：保证消息一定发送过去，但是发几次不确定。
//    QOS(2),精确只发送一次：它内部会有一个很复杂的发送机制，确保消息送到，而且只发送一次。
    
    [_mqttClient publishString:msg
                       toTopic:kClientID
                       withQos:ExactlyOnce
                        retain:YES
             completionHandler:^(int mid) {
                 NSLog(@"发送消息的结果");
             }];
}

#pragma mark - private
-(void)initSocket{
    if (_mqttClient) {
        [self disconnect];
    }
    
    _mqttClient = [[MQTTClient alloc] initWithClientId:kClientID];
    _mqttClient.port = kPort;
    
    [_mqttClient setMessageHandler:^(MQTTMessage *msg){
    //收到消息的回调，前提是得先订阅
        NSString *msgStr = [[NSString alloc] initWithData:msg.payload encoding:NSUTF8StringEncoding];
        NSLog(@"收到服务端消息:%@",msgStr);
    }];
    
    __weak typeof(self) weakSelf = self;
    [_mqttClient connectToHost:kHost completionHandler:^(MQTTConnectionReturnCode code) {
        switch (code) {
            case ConnectionAccepted:
            {
                NSLog(@"mqtt 连接成功");
                //订阅自己id的消息，这样收到消息就能回调
                [weakSelf.mqttClient subscribe:weakSelf.mqttClient.clientID withCompletionHandler:^(NSArray *grantedQos) {
                    NSLog(@"订阅成功");
                }];
            }
                break;
            case ConnectionRefusedBadUserNameOrPassword:
            {
                NSLog(@"错误的用户名和密码");
            }
                break;
            default:
                NSLog(@"mqtt 连接失败:%zd",code);
                break;
        }
    }];
    
}

@end

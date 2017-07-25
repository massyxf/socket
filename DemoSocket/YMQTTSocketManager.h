//
//  YMQTTSocketManager.h
//  DemoSocket
//
//  Created by yxf on 2017/7/25.
//  Copyright © 2017年 yxf. All rights reserved.
//

#import <Foundation/Foundation.h>

//MQTT是一个聊天协议，它比webScoket更上层，属于应用层。
//它的基本模式是简单的发布订阅，也就是说当一条消息发出去的时候，谁订阅了谁就会受到。其实它并不适合IM的场景，例如用来实现有些简单IM场景，却需要很大量的、复杂的处理。
//比较适合它的场景为订阅发布这种模式的，例如微信的实时共享位置，滴滴的地图上小车的移动、客户端推送等功能。

@interface YMQTTSocketManager : NSObject

+(instancetype)shareInstance;

-(void)connect;

-(void)disconnect;

-(void)sendMsg:(NSString *)msg;

@end

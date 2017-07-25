//
//  YWebSocketManager.h
//  DemoSocket
//
//  Created by yxf on 2017/7/25.
//  Copyright © 2017年 yxf. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, GCYWCDisconnect) {
    disconnectByUser,
    disconnectByServer
};

@interface YWebSocketManager : NSObject

+(instancetype)shareInstance;

-(void)connect;

-(void)disconnect;

-(void)sendMsg:(NSString *)msg;

-(void)ping;

@end

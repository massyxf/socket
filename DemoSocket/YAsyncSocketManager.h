//
//  YAsyncSocketManager.h
//  DemoSocket
//
//  Created by yxf on 2017/7/25.
//  Copyright © 2017年 yxf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YAsyncSocketManager : NSObject

+(instancetype)shareInstance;

-(BOOL)connect;

-(void)disConnect;

-(void)sendMsg:(NSString *)msg;

-(void)pullTheMsg;

@end

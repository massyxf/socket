//
//  ViewController.m
//  DemoSocket
//
//  Created by yxf on 2017/7/25.
//  Copyright © 2017年 yxf. All rights reserved.
//

#import "ViewController.h"
#import "YOriginSocketManager.h"
#import "YAsyncSocketManager.h"
#import "YWebSocketManager.h"
#import "YMQTTSocketManager.h"

//http://www.jianshu.com/p/2dbb360886a8

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *msgField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    [YWebSocketManager shareInstance];
    [[YMQTTSocketManager shareInstance] connect];
    
}
- (IBAction)closesocket:(id)sender {
//    [[YOriginSocketManager shareInstance] disconnect];
//    [[YAsyncSocketManager shareInstance] disConnect];
//    [[YWebSocketManager shareInstance] disconnect];
    [[YMQTTSocketManager shareInstance] disconnect];
}

- (IBAction)sendMsg:(id)sender {
    if (_msgField.text.length > 0) {
//       [[YOriginSocketManager shareInstance] sendMsg:_msgField.text];
//        [[YAsyncSocketManager shareInstance] sendMsg:_msgField.text];
//        [[YWebSocketManager shareInstance] sendMsg:_msgField.text];
        [[YMQTTSocketManager shareInstance] sendMsg:_msgField.text];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

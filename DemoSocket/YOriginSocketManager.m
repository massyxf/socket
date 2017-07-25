//
//  YOriginSocketManager.m
//  DemoSocket
//
//  Created by yxf on 2017/7/25.
//  Copyright © 2017年 yxf. All rights reserved.
//

#import "YOriginSocketManager.h"

#import <sys/types.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

/*
 //socket 创建并初始化 socket，返回该 socket 的文件描述符，如果描述符为 -1 表示创建失败。
 int socket(int addressFamily, int type,int protocol)
 //关闭socket连接
 int close(int socketFileDescriptor)
 //将 socket 与特定主机地址与端口号绑定，成功绑定返回0，失败返回 -1。
 int bind(int socketFileDescriptor,sockaddr *addressToBind,int addressStructLength)
 //接受客户端连接请求并将客户端的网络地址信息保存到 clientAddress 中。
 int accept(int socketFileDescriptor,sockaddr *clientAddress, int clientAddressStructLength)
 //客户端向特定网络地址的服务器发送连接请求，连接成功返回0，失败返回 -1。
 int connect(int socketFileDescriptor,sockaddr *serverAddress, int serverAddressLength)
 //使用 DNS 查找特定主机名字对应的 IP 地址。如果找不到对应的 IP 地址则返回 NULL。
 hostent* gethostbyname(char *hostname)
 //通过 socket 发送数据，发送成功返回成功发送的字节数，否则返回 -1。
 int send(int socketFileDescriptor, char *buffer, int bufferLength, int flags)
 //从 socket 中读取数据，读取成功返回成功读取的字节数，否则返回 -1。
 int receive(int socketFileDescriptor,char *buffer, int bufferLength, int flags)
 //通过UDP socket 发送数据到特定的网络地址，发送成功返回成功发送的字节数，否则返回 -1。
 int sendto(int socketFileDescriptor,char *buffer, int bufferLength, int flags, sockaddr *destinationAddress, int destinationAddressLength)
 //从UDP socket 中读取数据，并保存发送者的网络地址信息，读取成功返回成功读取的字节数，否则返回 -1 。
 int recvfrom(int socketFileDescriptor,char *buffer, int bufferLength, int flags, sockaddr *fromAddress, int *fromAddressLength)
 */

@interface YOriginSocketManager ()

/** socket*/
@property(nonatomic,assign)int clientSocket;

@end

/*
 1.客户端调用 socket(...) 创建socket；
 2.客户端调用 connect(...) 向服务器发起连接请求以建立连接；
 3.客户端与服务器建立连接之后，就可以通过send(...)/receive(...)向客户端发送或从客户端接收数据；
 4.客户端调用 close 关闭 socket；
 */

@implementation YOriginSocketManager

+(instancetype)shareInstance{
    static YOriginSocketManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[YOriginSocketManager alloc] init];
        [manager initSocket];
        [manager pullMsg];
    });
    return manager;
}

-(void)connect{
    [self initSocket];
}

-(void)disconnect{
    //关闭连接
    close(self.clientSocket);
}

-(void)sendMsg:(NSString *)msg{
    const char *send_msg = [msg UTF8String];
    send(self.clientSocket, send_msg, strlen(send_msg) + 1, 0);
}

#pragma mark - private func
-(void)initSocket{
    //每次连接前，先断开连接
    if (_clientSocket != 0) {
        [self disconnect];
        _clientSocket = 0;
    }
    
    //创建客户端socket
    _clientSocket = CreateClientSocket();
    
    //服务器ip
    const char *server_ip = "127.0.0.1";
    
    //服务器端口
    short server_port = 6969;
    
    //等于0说明连接失败
    if (connectionTOServer(_clientSocket, server_ip, server_port) == 0) {
        NSLog(@"connect to sever error");
        return;
    }
    
    //连接成功
    NSLog(@"connect to server success");
}

-(void)pullMsg{
    NSThread *tread = [[NSThread alloc] initWithTarget:self
                                              selector:@selector(receiveAction)
                                                object:nil];
    [tread start];
}

-(void)receiveAction{
    while (1) {
        char recv_msg[1024] = {0};
        recv(self.clientSocket, recv_msg, sizeof(recv_msg), 0);
        NSLog(@"%s,%s",__func__,recv_msg);
    }
}

//创建socket
static int CreateClientSocket(){
    int clientSocket = 0;
    
    //创建一个socket，返回值为int。(注:socket其实就是int类型)
    //第一个参数addressFamily IPv4(AF_INET)或IPv6(AF_INET6)
    //第二个参数type表示socket的类型，通常是流stream(SOCK_STREAM)或数据报文datagram(SOCK_DGRAM)
    //第三个参数protocol 参数通常设置为0，以便让系统自动为我们选择合适的协议，对于stream socket来说会是tcp协议(IPPROTO_TCP)，而对于datagram来说会是udp协议(IPPROTO_UDP)
    clientSocket = socket(AF_INET, SOCK_STREAM, 0);
    
    return clientSocket;
}

//连接服务器
static int connectionTOServer(int client_socket,const char * server_ip,unsigned short port){
    
    //生成一个sockaddr_in类型结构体
    struct sockaddr_in sAddr = {0};
    sAddr.sin_len = sizeof(sAddr);
    
    //设置ipv4
    sAddr.sin_family = AF_INET;
    
    //inet_aton是一个改进的方法来将一个字符串ip地址转换为一个32位的网络序列ip地址
    //如果这个函数成功，函数的返回值非0，如果输入地址不正确则会返回0
    inet_aton(server_ip, &sAddr.sin_addr);
    
    //htons是将整形变量从主机字节顺序转变成网络字节顺序，赋值端口号
    sAddr.sin_port = htons(port);
    
    //用socket和服务端地址，发起连接
    //客户端向特定网络地址的服务器发送连接请求，连接成功返回0，失败返回-1
    //注意:该接口调用会阻塞当前线程，直到服务器返回
    if (connect(client_socket, (struct sockaddr *) &sAddr, sizeof(sAddr)) == 0) {
        return client_socket;
    }
    
    return 0;
}


@end

//
//  ViewController.m
//  semaphoreDemo
//
//  Created by gongpengyang on 2018/9/12.
//  Copyright © 2018年 gongpengyang. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking/AFNetworking.h"
@interface ViewController ()
@property (nonatomic, weak)NSOperationQueue *parseQueue;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /*
     一个页面多个网络请求 要求所有请求结束 刷新 UI      
     */
    // Do any additional setup after loading the view, typically from a nib.
//    [self operationRequest];
    [self cgdRequest];
    
    
}
- (void)operationRequest {
    
    /*
     理论上和不做异步网络请求该方法可以实现但是实际测试做了网络请求后 无法成功
     */
    //按照顺序12345622322
    NSBlockOperation *operation1 = [NSBlockOperation blockOperationWithBlock:^{
        [self request1];
        NSLog(@"request1");
    }];
    NSBlockOperation *operation2 = [NSBlockOperation blockOperationWithBlock:^{
        [self request2];
        NSLog(@"request2");
    }];
    NSBlockOperation *operation3 = [NSBlockOperation blockOperationWithBlock:^{
        //        [self request3];
        NSLog(@"request3");
    }];
    //设置依赖
    [operation3 addDependency:operation1];
    [operation3 addDependency:operation2];
    
    
    
    //创建队列并添加任务
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [queue addOperations:@[operation1,operation2] waitUntilFinished:YES];
    
    [[NSOperationQueue mainQueue] addOperation:operation3];
}
- (void)cgdRequest {
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self request1];
    }) ;
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self request2];
    }) ;
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self request3];
    }) ;
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"刷新界面");
    });
}
- (void)request1{
    //创建信号量并设置计数默认为0
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%s","http://v3.wufazhuce.com:8000/api/channel/movie/more/0?platform=ios&version=v4.0.1"];
    [manager GET:url parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *data = responseObject[@"data"];
        for (NSDictionary *dic in data) {
            NSLog(@"请求1---%@",dic[@"id"]);
        }
        //计数加1
        dispatch_semaphore_signal(semaphore);
        //11380-- data.lastObject[@"id"];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"shibai...");
        //计数加1
        dispatch_semaphore_signal(semaphore);
    }];
    //若计数为0则一直等待
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}
- (void)request2{
    //创建信号量并设置计数默认为0
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSString *url1 = [NSString stringWithFormat:@"%s","http://v3.wufazhuce.com:8000/api/channel/movie/more/11380?platform=ios&version=v4.0.1"];
    [manager GET:url1 parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *data = responseObject[@"data"];
        for (NSDictionary *dic in data) {
            NSLog(@"请求2---%@",dic[@"id"]);
        }
        //计数加1
        dispatch_semaphore_signal(semaphore);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //计数加1
        dispatch_semaphore_signal(semaphore);
    }];
    //若计数为0则一直等待
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}
- (void)request3{
    //创建信号量并设置计数默认为0
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSString *url2 = [NSString stringWithFormat:@"%s","http://v3.wufazhuce.com:8000/api/channel/movie/more/11317?platform=ios&version=v4.0.1"];
    [manager GET:url2 parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *data = responseObject[@"data"];
        for (NSDictionary *dic in data) {
            NSLog(@"请求3---%@",dic[@"id"]);
        }
        //计数加1
        dispatch_semaphore_signal(semaphore);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //计数加1
        dispatch_semaphore_signal(semaphore);
    }];
    //若计数为0则一直等待
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

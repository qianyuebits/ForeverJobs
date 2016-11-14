//
//  ThreadViewController.m
//  MyP
//
//  Created by 李全民 on 16/11/13.
//  Copyright © 2016年 李全民. All rights reserved.
//

#import "ThreadViewController.h"
#import "JobsConstants.h"

// ###### 自定义非并发Operation ######
@interface MyNonConcurrentOperation : NSOperation
@property (strong) id myData;

-(id)initWithData:(id)data;
@end

@implementation MyNonConcurrentOperation
- (id)initWithData:(id)data {
    if (self = [super init])
        _myData = data;
    return self;
}

// 类似于runnalbe
-(void)main {
    @try {
        NSLog(@"Begin custom operation.");
        NSDate *date=[NSDate dateWithTimeIntervalSinceNow:4.0];
        [NSThread sleepUntilDate:date];
        NSLog(@"End custom operation.");
    }
    @catch(...) {
        // Do not rethrow exceptions.
    }
}
@end

@interface ThreadViewController ()
-(void)generateTask:(NSString *)data;
@end

@implementation ThreadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:ANDROID_BLUE];
    
    //【判断是否是主线程以及调度到主线程】http://stackoverflow.com/questions/11582223/ios-ensure-execution-on-main-thread
    
    //
    NSInvocationOperation *operationA = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(generateTask:) object:nil];
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [queue addOperation:operationA];
    
    //
    NSBlockOperation* operationB = [NSBlockOperation blockOperationWithBlock: ^{
        NSLog(@"Begin BlockA.");
        NSDate *date=[NSDate dateWithTimeIntervalSinceNow:4.0];
        [NSThread sleepUntilDate:date];
        NSLog(@"End BlockA.");
    }];
    [operationB addExecutionBlock:^{
        NSLog(@"Begin BlockB.");
        NSDate *date=[NSDate dateWithTimeIntervalSinceNow:3.0];
        [NSThread sleepUntilDate:date];
        NSLog(@"End BlockB.");
    }];
    [operationB addExecutionBlock:^{
        NSLog(@"Begin BlockC.");
        NSDate *date=[NSDate dateWithTimeIntervalSinceNow:2.0];
        [NSThread sleepUntilDate:date];
        NSLog(@"End BlockC.");
    }];
    [operationB setCompletionBlock:^{
        NSLog(@"OperationB Completed");
    }];
    // 监听一个 Operation 完成
    [queue addOperation:operationB];
    [queue addOperation:[[MyNonConcurrentOperation alloc] initWithData:nil]];
}

-(void)generateTask:(NSString *)data{
    NSLog(@"I am sleeping.");
    // 沉睡4s
    NSDate *date=[NSDate dateWithTimeIntervalSinceNow:4.0];
    [NSThread sleepUntilDate:date];
    NSLog(@"I am waked.");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
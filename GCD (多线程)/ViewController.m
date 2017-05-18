//
//  ViewController.m
//  GCD (多线程)
//
//  Created by 一天 on 2017/5/17.
//  Copyright © 2017年 肖振阳. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    
    [self test5];
}

/**
 Dispatch Group
 */
-(void)test6{


}
/**
 dispatch_after
 注意: 该函数并不是在指定时间后执行处理,而是在指定时间追加处理到 Dispatch Queue.
 test5 函数里面的代码的作用与在 3 秒后用 dispatch_async 函数追加到 Block 到 Main Dispatch Queue 相同
 */
-(void)test5{

    //在 3 秒后将指定的 Block 追加到 Main Dispatch Queue 中的实现
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC);
    
    NSLog(@"waited at least zero seconds");

    /**
     dispatch_after
     @param time 指定时间用的 dispatch_time_t 类型的值. 该值使用 dispatch_time 函数或者 dispatch_walltime 函数生成
     @param dispatch_get_main_queue 指定要追加处理的 Dispatch Queue
     @param <#^(void)block#> 指定记述要执行处理的 Block
     */
    dispatch_after(time, dispatch_get_main_queue(), ^{
        
        NSLog(@"waited at least three seconds");
    });
    
    // dispatch_time 函数能够获取从第一个参数 dispatch_time_t 类型值中指定的时间开始,到第二个参数指定的毫微秒单位时间后的时间.第一个参数经常使用的值是下面的 DISPATCH_TIME_NOW .表示现在的时间.
    //数值和 NSEC_PER_SEC 的乘积得到单位为毫微秒的数值.
    dispatch_time_t oneTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
    
    //dispatch_walltime(<#const struct timespec * _Nullable when#>, <#int64_t delta#>)
    //dispatch_walltime 函数由 POSIX 中使用的 struct timespec 类型的时间得到 dispatch_time_t 类型的值. dispatch_time 函数通常用于计算相对时间,而 dispatch_walltime 函数用于计算绝对时间.
    dispatch_time_t tempTime = getDispatchTimeByDate([NSDate date]);
    NSLog(@"%zd",tempTime);
}
dispatch_time_t getDispatchTimeByDate(NSDate *date){

    NSTimeInterval interval;
    double second,subsecond;
    struct timespec time;
    dispatch_time_t milestone;
    
    interval = [date timeIntervalSince1970];
    subsecond = modf(interval, &second);
    time.tv_sec = second;
    time.tv_nsec = subsecond * NSEC_PER_SEC;
    milestone = dispatch_walltime(&time, 0);

    return milestone;
}
/**
 dispatch_set_target_queue 变更已经生成调度队列的执行优先级
 
 第一个 <#dispatch_queue_t  _Nullable queue#> 传入要变更执行优先级的 Dispatch Queue
 第二个 <#dispatch_queue_t  _Nullable queue#> 传入要使用的执行优先级相同优先级的 Global Dispatch Queue
 dispatch_set_target_queue(<#dispatch_queue_t  _Nullable queue#>, <#dispatch_queue_t  _Nullable queue#>)
 */
-(void)test4{

    dispatch_queue_t mySerialDispatchQueue = dispatch_queue_create("com.xiaozhenyang.www.GCD", NULL);
    
    dispatch_queue_t globalDispatchQueueBackgroud = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    
    
    dispatch_set_target_queue(mySerialDispatchQueue, globalDispatchQueueBackgroud);

    /**
     将 Dispatch Queue 指定为 dispatch_set_target_queue 函数的参数,不仅可以变更 Dispatch Queue 的执行优先级,还可以作成 Dispatch Queue 的执行阶层. 如果在多个 Seriacl Dispatch Queue 中用 dispatch_set_target_queue 函数指定目标为某一个 Seriacl Dispatch Queue 上只能同时执行一个处理.
     在必须将不可并行执行的处理追加到多个 Seriacl Dispatch Queue 中时,如果使用 dispatch_set_target_queue 函数将目标指定为某一个 Seriacl Dispatch Queue ,即可防止处理并行执行.
     */
}
/**
 Main Dispatch Queue (主调度队列) / Main Dispatch Queue (全局调度队列)
 */
-(void)test3{


    //Main Dispatch Queue  因为主线程只有一个 所以 Main Dispatch Queue 是 Serial Dispatch Queue\
    与 NSObject 的 performSelectorOnMainThread 实例方法一致
    
    //Global Dispatch Queue 是 Concurrent Dispatch Queue
    /**
     全局并发队列有四个优先级 
     #define DISPATCH_QUEUE_PRIORITY_HIGH 2 (高优先级)
     #define DISPATCH_QUEUE_PRIORITY_DEFAULT 0(默认优先级)
     #define DISPATCH_QUEUE_PRIORITY_LOW (-2)(低优先级)
     #define DISPATCH_QUEUE_PRIORITY_BACKGROUND INT16_MIN(后台优先级)
     */
    /**
     Dispatch Queue 的种类
     名称                                           Dispatch Queue 的种类      说明
     Main Dispatch Queue                           Serial Dispatch Queue     主线程执行
     Dispatch Queue PRIORITY_HIGH                  Concurrent Dispatch Queue 执行优先级:高(最高优先)
     Dispatch Queue PRIORITY_DEFAULT               Concurrent Dispatch Queue 执行优先级:默认
     Dispatch Queue PRIORITY_LOW                   Concurrent Dispatch Queue 执行优先级:低
     Dispatch Queue PRIORITY_BACKGROUND INT16_MIN  Concurrent Dispatch Queue 后台
     */

    //获取 Main Dispatch Queue
    dispatch_queue_t mainDisaptchQueue = dispatch_get_main_queue();
    
    //获取 Global Dispatch Queue (高优先级)
    dispatch_queue_t globalDispatchQueueHight = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    //获取 Global Dispatch Queue (默认优先级)
    dispatch_queue_t globalDispatchQueueDefault = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    //获取 Global Dispatch Queue (低优先级)
    dispatch_queue_t globalDispatchQueueLow = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    
    //获取 Global Dispatch Queue (后台优先级)
    dispatch_queue_t globalDispatchQueueBackground = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    
    //实例
    dispatch_async(globalDispatchQueueDefault, ^{
        
        //在这里处理并行执行的任务
       dispatch_async(mainDisaptchQueue, ^{
           
           //只能在主线程中处理的任务
       });
    });
}
/**
 dispatch_queue_create
 */
-(void)test2{
    /**
     const char *_Nullable label 指定串行调度队列的名称 推荐使用应用程序 ID 这种逆序全程域名,该名称在 Xcode 和 Instrument 的调试器中的作为 Dispatch Queue 名称显示.而且该名称也会出现在程序崩溃时所生成的 CrashLog 中
     dispatch_queue_attr_t _Nullable attr  创建 Serial 可以传 NULL 也可以传 DISPATCH_QUEUE_SERIAL
     dispatch_queue_attr_t _Nullable attr  创建 Conrrent 要传 DISPATCH_QUEUE_CONCURRENT
     
     dispatch_queue_create(const char *_Nullable label,
     dispatch_queue_attr_t _Nullable attr);
     
     dispatch_queue_create 返回值为 "dispatch_queue_t" 类型的变量
     
     */
    //dispatch_queue_create 创建一个 Serial Dispatch Queue
    dispatch_queue_t mySeriaclDispatchQueue = dispatch_queue_create("com.xiaozhenyang.www.GCD", NULL);
    
    //dispatch_queue_t mySeriaclDispatchQueue = dispatch_queue_create("com.xiaozhenyang.www.GCD", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(mySeriaclDispatchQueue, ^{
        NSLog(@"block on mySeriaclDispatchQueue");
    });
    
    //dispatch_queue_create 创建一个 Conrrent Dispatch Queue
    dispatch_queue_t myConcurrentDispatchQueue = dispatch_queue_create("com.xiaozhenyang.www.GCD", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(myConcurrentDispatchQueue, ^{
        NSLog(@"block on myConcurrentDispatchQueue");
        
    });
    
    
    /**
     ARC forbids explicit message send of 'release'
     “释放”的弧禁止显式消息发送
     dispatch_release(mySeriaclDispatchQueue);
     */
    //    dispatch_release(dispatch_queue_create);
    //    dispatch_release(<#dispatch_object_t  _Nonnull object#>)
    //    dispatch_async(<#dispatch_queue_t  _Nonnull queue#>, <#^(void)block#>)
}

/**
 Dispatch Queue
 */
-(void)test1{

    
    void(^blk0)(void) = ^{NSLog(@"blk0 = %@",[NSThread currentThread]);[NSThread sleepForTimeInterval:0];};
    void(^blk1)(void) = ^{NSLog(@"blk1 = %@",[NSThread currentThread]);[NSThread sleepForTimeInterval:1];};
    void(^blk2)(void) = ^{NSLog(@"blk2 = %@",[NSThread currentThread]);[NSThread sleepForTimeInterval:2];};
    void(^blk3)(void) = ^{NSLog(@"blk3 = %@",[NSThread currentThread]);[NSThread sleepForTimeInterval:3];};
    void(^blk4)(void) = ^{NSLog(@"blk4 = %@",[NSThread currentThread]);[NSThread sleepForTimeInterval:4];};
    void(^blk5)(void) = ^{NSLog(@"blk5 = %@",[NSThread currentThread]);[NSThread sleepForTimeInterval:5];};
    void(^blk6)(void) = ^{NSLog(@"blk6 = %@",[NSThread currentThread]);[NSThread sleepForTimeInterval:6];};
    void(^blk7)(void) = ^{NSLog(@"blk7 = %@",[NSThread currentThread]);[NSThread sleepForTimeInterval:7];};
    
    
    dispatch_queue_t queue = dispatch_queue_create("com.xiaozhenyang.www.GCD", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, blk0);
    dispatch_async(queue, blk1);
    dispatch_async(queue, blk2);
    dispatch_async(queue, blk3);
    dispatch_async(queue, blk4);
    dispatch_async(queue, blk5);
    dispatch_async(queue, blk6);
    dispatch_async(queue, blk7);
    /**
     2017-05-18 10:07:54.695 GCD (多线程)[11792:308664] blk0 = <NSThread: 0x61000006d1c0>{number = 16, name = (null)}
     2017-05-18 10:07:54.695 GCD (多线程)[11792:309093] blk1 = <NSThread: 0x61000006e940>{number = 30, name = (null)}
     2017-05-18 10:07:54.695 GCD (多线程)[11792:309075] blk2 = <NSThread: 0x60000006cd80>{number = 25, name = (null)}
     2017-05-18 10:07:54.695 GCD (多线程)[11792:309095] blk3 = <NSThread: 0x61000006e980>{number = 33, name = (null)}
     2017-05-18 10:07:54.695 GCD (多线程)[11792:309079] blk4 = <NSThread: 0x618000068280>{number = 29, name = (null)}
     2017-05-18 10:07:54.695 GCD (多线程)[11792:309043] blk5 = <NSThread: 0x6180000677c0>{number = 23, name = (null)}
     2017-05-18 10:07:54.695 GCD (多线程)[11792:309076] blk6 = <NSThread: 0x61000006d180>{number = 27, name = (null)}
     2017-05-18 10:07:54.695 GCD (多线程)[11792:308245] blk7 = <NSThread: 0x60000006b880>{number = 11, name = (null)}
                                 
     */

}
-(void)test0{

    dispatch_queue_t queue = dispatch_queue_create("com.xiaozhenyang.www.GCD", DISPATCH_QUEUE_CONCURRENT);
    
    //dispatch 调度
    //async 异步
    //queue 队列
    //serial 串行 等待现在执行中处理结束 [(3) (2) (1)] ----> 等待处理结束
    /**
     ------->不等待处理结束
     |
     concurrent 并发 不等待现在执行中处理结束 [(3) (2) (1)] ---->不等待处理结束
     |
     ------->不等待处理结束
     */
    dispatch_async(queue, ^{
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
        });
        
    });
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

//
//  ViewController.m
//  GCD (多线程)
//
//  Created by 一天 on 2017/5/17.
//  Copyright © 2017年 肖振阳. All rights reserved.
//

#import "ViewController.h"
#define ApplicationAddress "com.xiaozhenyang.www.GCD"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    
    [self test8];
}
/**
 dispatch_sync sync (synchronous(同步)) (意思是 "非异步" asynchronous(异步))
 */
-(void)test8{

    /**
     dispatch_sync 函数将指定的 Block "非同步"追加到指定的 Dispatch Queue 中. dispatch_async 函数不做任何等待.
     */
    
    //情况: 执行 Mian Dispatch Queue 时,使用另外的线程 Global Dispatch Queue 进行处理,处理之后立即使用所得到的结果.此时,要使用 dispatch_sync 函数
    
    dispatch_queue_t queue = dispatch_queue_create(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_sync(queue, ^{/**要处理的*/});
    
    /**
     注意: 一旦使用了 dispatch_sync 函数,在指定的处理结束之前,该函数不会返回.类似于 dispatch_group_wait 函数.但是该函数会造成 死锁
     */
    //死锁例子
    dispatch_queue_t queue0 = dispatch_get_main_queue();
    
    dispatch_sync(queue0, ^{NSLog(@"死锁");});
    //上面代码会卡死在 dispatch_sync(queue0, ^{NSLog(@"死锁");});. 原因是代码在 Mian Dispacth Queue 主线程执行指定的 Block,并等待其执行结束.而其实在主线程中正在执行这些代码.所以无法执行追加到 Mian Dispatch Queue 的Blcok
    
    //下面的例子与上面是一个问题
    dispatch_queue_t queue1 = dispatch_get_main_queue();
    
    dispatch_async(queue1, ^{
        dispatch_sync(queue1, ^{NSLog(@"死锁");});
    });
    //上面代码在 Mian Dispacth Queue 中执行的 Block 等待 Mian Dispatch Queue 中要执行的 Block 执行结束.这样会导致死锁.
    
    //对于 Serial Dispatch Queue 也会造成死锁
    dispatch_queue_t queue2 = dispatch_queue_create(ApplicationAddress, 0);
    dispatch_async(queue2, ^{
       dispatch_sync(queue2, ^{NSLog(@"死锁");});
    });
    
}
/**
 dispatch_barrier_async  barrier (障碍)
 */
-(void)test7{

    dispatch_queue_t queue = dispatch_queue_create(ApplicationAddress, DISPATCH_QUEUE_CONCURRENT);
    
    void(^blk_for_waiting)(void) = ^{NSLog(@"blk_for_waiting");};
    void(^blk0_for_reading)(void) = ^{NSLog(@"blk0_for_reading");};
    void(^blk1_for_reading)(void) = ^{NSLog(@"blk1_for_reading");};
    void(^blk2_for_reading)(void) = ^{NSLog(@"blk2_for_reading");};
    void(^blk3_for_reading)(void) = ^{NSLog(@"blk3_for_reading");};
    void(^blk4_for_reading)(void) = ^{NSLog(@"blk4_for_reading");};
    void(^blk5_for_reading)(void) = ^{NSLog(@"blk5_for_reading");};
    void(^blk6_for_reading)(void) = ^{NSLog(@"blk6_for_reading");};
    void(^blk7_for_reading)(void) = ^{NSLog(@"blk7_for_reading");};

    //在 blk3_for_reading 处理和 blk4_for_reading 处理之间执行写入处理,并将写入的内容读取 blk4_for_reading 处理及之后的处理中.
    dispatch_async(queue, blk0_for_reading);
    dispatch_async(queue, blk1_for_reading);
    dispatch_async(queue, blk2_for_reading);
    dispatch_async(queue, blk3_for_reading);
    /**
     写入处理,将写入的内容读取之后的处理中...
     */
    dispatch_async(queue, blk4_for_reading);
    dispatch_async(queue, blk5_for_reading);
    dispatch_async(queue, blk6_for_reading);
    dispatch_async(queue, blk7_for_reading);
    dispatch_release(queue);
    
    
    //如果像下面这样简单地在 dispatch_async 函数中加入写入处理,根据 Concurrent Dispatch Queue 性质,就有可能在追加写入处理前面的处理中读取到与期待不符的数据,还可能回因非法访问导致程序异常结束,如果追加多个写入处理,则可能发生更多问题,如数据竞争等...
    dispatch_async(queue, blk0_for_reading);
    dispatch_async(queue, blk1_for_reading);
    dispatch_async(queue, blk2_for_reading);
    dispatch_async(queue, blk3_for_reading);
    dispatch_async(queue, blk_for_waiting);
    dispatch_async(queue, blk4_for_reading);
    dispatch_async(queue, blk5_for_reading);
    dispatch_async(queue, blk6_for_reading);
    dispatch_async(queue, blk7_for_reading);
    dispatch_release(queue);
    
    //这时候就需要使用 dispatch_barrier_async 函数. dispatch_barrier_async 函数会等待追加到 Concurrent Dispatch Queue 上的并执行的处理全部结束之后,再将指定的处理追加到该 Concurrernt Dispatch Queue .然后再由 dispatch_barrier_async 函数追加的处理执行完毕后, Concurrent Dispatch Queue 才恢复为一般的动作,追加到该 Concurrent Dispatch Queue 的处理又开始并执行.
    dispatch_async(queue, blk0_for_reading);
    dispatch_async(queue, blk1_for_reading);
    dispatch_async(queue, blk2_for_reading);
    dispatch_async(queue, blk3_for_reading);
    dispatch_barrier_sync(queue, blk_for_waiting);
    dispatch_async(queue, blk4_for_reading);
    dispatch_async(queue, blk5_for_reading);
    dispatch_async(queue, blk6_for_reading);
    dispatch_async(queue, blk7_for_reading);
    dispatch_release(queue);
    
    /**
     2017-05-19 17:24:05.714 GCD (多线程)[8622:1289661] blk0_for_reading
     2017-05-19 17:24:05.714 GCD (多线程)[8622:1289662] blk1_for_reading
     2017-05-19 17:24:05.714 GCD (多线程)[8622:1287737] blk2_for_reading
     2017-05-19 17:24:05.714 GCD (多线程)[8622:1289663] blk3_for_reading
     2017-05-19 17:24:05.715 GCD (多线程)[8622:1286812] blk_for_waiting
     2017-05-19 17:24:05.715 GCD (多线程)[8622:1289663] blk4_for_reading
     2017-05-19 17:24:05.715 GCD (多线程)[8622:1287737] blk5_for_reading
     2017-05-19 17:24:05.715 GCD (多线程)[8622:1289662] blk6_for_reading
     2017-05-19 17:24:05.715 GCD (多线程)[8622:1289664] blk7_for_reading
     */
    //使用 Concurrent Dispatch Queue 和 dispatch_barrier_async 函数可以实现高效率的数据库访问和文件访问.
}
/**
 Dispatch Group
 */
-(void)test6{

    dispatch_queue_t queue = dispatch_queue_create(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group, queue, ^{
        NSLog(@"blk0");
    });
    dispatch_group_async(group, queue, ^{
        NSLog(@"blk1");
    });
    dispatch_group_async(group, queue, ^{
        NSLog(@"blk2");
    });
    
    /**
     dispatch_group_notify

     @param <#dispatch_group_t  _Nonnull group#> 指定为要监视的 Dispatch Group
     @param <#dispatch_queue_t  _Nonnull queue#> 指定下面 Block 所在执行的队列
     @param <#^(void)block#> 处理执行后要执行的任务
     */
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"done");
    });
    //该方法同 dispatch_group_notify 一样 皆是等全部处理执行结束
    
    /**
     dispatch_group_wait

     @param <#dispatch_group_t  _Nonnull group#> 指定为要监视的 Dispatch Group
     @param <#dispatch_time_t timeout#> 指定等待的时间 (超时).属于 dispatch_time_t 类型的值.下面代码使用的 DISPATCH_TIME_FOREVER 永久等待.只要属于 Dispatch Group 的处理尚未执行结束,就会一直等待,中途不会取消.
     */
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
    dispatch_release(group);
    /**
     2017-05-19 14:10:51.610 GCD (多线程)[8270:942262] blk0
     2017-05-19 14:10:51.611 GCD (多线程)[8270:942262] blk1
     2017-05-19 14:10:51.611 GCD (多线程)[8270:942262] blk2
     2017-05-19 14:10:51.611 GCD (多线程)[8270:941798] done
     */
    
    dispatch_time_t tiem = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
    
    long result = dispatch_group_wait(group, tiem);
    
    if (result == 0) {
        //属于 Dispatch Group 的全部处理执行结束
    }else{
        //属于 Dispatch Group 的某一个处理还在执行中
    }
    /**
     注意:1 如果 dispacth_group_wait 函数的返回值不为0,就意味着虽然经过了指定的时间,但属于 Dispatch Group 的某一个处理还在执行中.如果返回值为0,那么全部处理执行结束.当等待时间为 DISPATCH_TIME_FOREVER、 由 dispacth_group_wait 函数返回时,由于属于 Dispatch Group 的处理必定全部执行结束,因此返回值恒为 0.
         2 这里的 "等待"的意思是一旦调用 dispacth_group_wait 函数,该函数就处于调用的状态而不返回.即执行 dispacth_group_wait 函数的现在的(当前线程)线程停止.在经过 dispacth_group_wait 函数中指定的时间或属于指定 Dispatch Group 的处理全部执行结束之前,执行该函数的线程停止
     */
    
    //指定 DISPATCH_TIME_NOW ,则不用任何等待即可判定属于 Dispatch Group 的处理是否执行结束
    long result1 = dispatch_group_wait(group, DISPATCH_TIME_NOW);
    
    //在主线程的 RunLoop 的每次循环中,可检查执行是否结束,从而不耗费多余的等待时间.虽然这样可以,但一般这种情形下,还是用 dispatch_group_notify 函数追加结束处理到 Main Dispatch Queue 中.这是因为 dispatch_group_notify 函数可以简化代码
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

    dispatch_queue_t mySerialDispatchQueue = dispatch_queue_create(ApplicationAddress, NULL);
    
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
    dispatch_queue_t mySeriaclDispatchQueue = dispatch_queue_create(ApplicationAddress, NULL);
    
    //dispatch_queue_t mySeriaclDispatchQueue = dispatch_queue_create(ApplicationAddress, DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(mySeriaclDispatchQueue, ^{
        NSLog(@"block on mySeriaclDispatchQueue");
    });
    
    //dispatch_queue_create 创建一个 Conrrent Dispatch Queue
    dispatch_queue_t myConcurrentDispatchQueue = dispatch_queue_create(ApplicationAddress, DISPATCH_QUEUE_CONCURRENT);
    
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
    
    
    dispatch_queue_t queue = dispatch_queue_create(ApplicationAddress, DISPATCH_QUEUE_CONCURRENT);
    
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

    dispatch_queue_t queue = dispatch_queue_create(ApplicationAddress, DISPATCH_QUEUE_CONCURRENT);
    
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

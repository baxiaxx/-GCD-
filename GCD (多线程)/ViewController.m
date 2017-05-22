//
//  ViewController.m
//  GCD (多线程)
//
//  Created by 一天 on 2017/5/17.
//  Copyright © 2017年 肖振阳. All rights reserved.
//
/**
1.概念和理解
     Grand Central Dispatch（多线程的优化技术）GCD
     是一套底层API，基于C语言开发的多线程机制，提供了新的模式编写并发执行的程序。
     特点：
     1.允许将一个程序切分为多个单一任务，然后提交到工作队列中并发或者串行地执行
     2.为多核的并行运算提出了解决方案，自动合理的利用CPU内核（比如双核，四核）
     3.自动的管理线程的生命周期（创建线程、调度任务、销毁线程），完全不需要我们管理，只需要告诉它任务是什么就行
     4.配合Block，使得使用起来更加方便灵活
 2.什么是Queue队列？
     GCD使用了队列的概念，解决了NSThread难于管理的问题，队列实际上就是数组的概念，通常我们把要执行的任务放到队列中管理
     特点：
     1.按顺序执行，先进先出
     2.可以管理多线程，管理并发的任务，设置主线程
     3.GCD的队列是任务的队列，而不是线程的队列
 3.什么是任务？
     任务即操作：你想要干什么，说白了就是一段代码，在GCD中，任务就是一个block
     任务的两种执行方式：
     同步执行：只要是同步任务，都会在当前的线程执行，不会另开线程
     异步执行：只要是异步任务，都会开启新线程，在开启的线程中执行
 4.什么是串行队列？
     依次完成每一任务
 5.什么是并行队列？
     好像所有的任务都是在同一时间执行的
 6.都有哪些队列？
     Main Queue(主队列，串行)；全局队列（Global Queue）；自己创建的队列（Queue）
     从上面的概念以及gcd所解决的问题来看，使用GCD的时候就要开始转变观念了。现在我们需要考虑的只是任务，队列，队列间同步或异步的关系了。而不是考虑怎么开辟线程，怎么管理线程，所有关于线程的东西，我们都不需要考虑。整个程序完全就是由队列来自动管理了。首先，整个程序是由全局队列来管理，然后UI的刷新是由mainqueue管理，我们可以将我们的任务放到我们创建的队列中去，也可以放在主队列中，也可以放在全局队列中。
*/
/**
 1， 同步，异步，串行，并发
     同步和异步代表会不会开辟新的线程。串行和并发代表任务执行的方式。
     同步串行和同步并发，任务执行的方式是一样的。没有区别，因为没有开辟新的线程，所有的任务都是在一条线程里面执行。
     异步串行和异步并发，任务执行的方式是有区别的，异步串行会开辟一条新的线程，队列中所有任务按照添加的顺序一个一个执行，异步并发会开辟多条线程，至于具体开辟多少条线程，是由系统决定的，但是所有的任务好像就是同时执行的一样。
     开辟队列的方法：
     dispatch_queue_t myQueue = dispatch_queue_create("MyQueue", NULL);
     参数1：标签，用于区分队列
     参数2：队列的类型，表示这个队列是串行队列还是并发队列NUll表示串行队列，
     DISPATCH_QUEUE_CONCURRENT表示并发队列
     
    执行队列的方法
    异步执行
    dispatch_async(<#dispatch_queue_t queue#>, <#^(void)block#>)
    同步执行
    dispatch_sync(<#dispatch_queue_t queue#>, <#^(void)block#>)
 二，主队列
     主队列：专门负责调度主线程度的任务，没有办法开辟新的线程。所以，在主队列下的任务不管是异步任务还是同步任务都不会开辟线程，任务只会在主线程顺序执行。
     主队列异步任务：现将任务放在主队列中，但是不是马上执行，等到主队列中的其它所有除我们使用代码添加到主队列的任务的任务都执行完毕之后才会执行我们使用代码添加的任务。
     主队列同步任务：容易阻塞主线程，所以不要这样写。原因：我们自己代码任务需要马上执行，但是主线程正在执行代码任务的方法体，因此代码任务就必须等待，而主线程又在等待代码任务的完成好去完成下面的任务，因此就形成了相互等待。整个主线程就被阻塞了。
 三，全局队列
     全局队列：本质是一个并发队列，由系统提供，方便编程，可以不用创建就直接使用。
     获取全局队列的方法：dispatch_get_global_queue(long indentifier.unsigned long flags)
     
     参数说明：
     参数1：代表该任务的优先级，默认写0就行，不要使用系统提供的枚举类型，因为ios7和ios8的枚举数值不一样，使用数字可以通用。
     参数2：苹果保留关键字，一般也写0
    全局队列和并发队列的区别：
    1，全局队列没有名字，但是并发队列有名字。有名字可以便于查看系统日志
    2，全局队列是所有应用程序共享的。
    3，在mrc的时候，全局队列不用手动释放，但是并发队列需要。
 */

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

    
    [self test11];
}
/**
 Dispatch Source
 */
-(void)test15{

    /**
     Dispatch Source 的种类
     DISPATCH_SOURCE_TYPE_DATA_ADD    变量增加
     DISPATCH_SOURCE_TYPE_DATA_OR     变量 OR
     DISPATCH_SOURCE_TYPE_MACH_SEND   MACH 端口发送
     DISPATCH_SOURCE_TYPE_MACH_RECV   MACH 端口接受
     DISPATCH_SOURCE_TYPE_PROC        检测到与进程相关的事件
     DISPATCH_SOURCE_TYPE_READ        可读取文件映射
     DISPATCH_SOURCE_TYPE_SIGNAL      接收信号
     DISPATCH_SOURCE_TYPE_TIMER       定时器
     DISPATCH_SOURCE_TYPE_VNODE       文件系统有变更
     DISPATCH_SOURCE_TYPE_WRITE       可写入文件映射
    */
    //事件发生时,在指定的 Dispatch Queue 中可执行事件的处理

    __block size_t total = 0;
    size_t size =  100; //要读取的字节数
    char *buff = (char *)malloc(size);
     int sockfd = 10;
    //设定为异步映象
    fcntl(sockfd, 1);
    //获取用于追加事件的 Global Disaptch Queue
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    //基于 READ 事件时执行的处理
    dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, 1, 0, queue);
    
    //指定发生 READ 事件时执行的处理
    dispatch_source_set_event_handler(source, ^{
       
        //获取可读取的字节数
        size_t available = dispatch_source_get_data(source);
        
        //从映像中获取
        int lenght = read(sockfd, buff, available);
        
        //发生错误时取消 Dispatch Source
        if (lenght < 0 ) {
            //错误处理
            dispatch_source_cancel(source);
        }
        total += lenght;
        if (total == size) {
            
            //buff 的处理,处理结束,取消 Dispatch Source
            dispatch_source_cancel(source);
        }
    });
    
    //指定取消 Dispatch Source 时的处理
    dispatch_source_set_cancel_handler(source, ^{
        free(buff);
        close(sockfd);
        
        //释放 Dispatch Source (自身)
        dispatch_release(source);
    });
    //启动 Dispatch Source
    dispatch_resume(source);
    
    /**
     与上面源代码非常相似的代码,使用在了 Core Foundation 框架的异步网络的 API CFSocket 中,因为 Foundation 框架的异步网络 API 是通过 CFSocket 实现的,所以可享受到仅使用 Foundation 框架的 Dispatch Source (GCD) 带来的好处
     */
    //下面是一个 DISPATCH_SOURCE_TYPE_TIMER 使用例子
    /**
     指定 DISPATCH_SOURCE_TYPE_TIMER 作出 Dispatch Source.在定时器经过指定时间时设定 Main Dispatch Queue 为追加处理的 Dispatch Queue
     */
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    
    //将定时器设定为 15s 后,不指定为重复,允许延迟1s
    dispatch_source_set_timer(timer, 15 *NSEC_PER_SEC, DISPATCH_TIME_FOREVER, 1 *NSEC_PER_SEC);
    
    //指定定时器指定时间内执行的处理
    dispatch_source_set_event_handler(timer, ^{
        NSLog(@"wakeup");
        //取消 Dispatch Source
        dispatch_source_cancel(source);
    });
    
    //指定取消 Dispatch Source 时的处理
    dispatch_source_set_cancel_handler(timer, ^{
        NSLog(@"canceled");
        //释放 Dispatch Source(自身)
        dispatch_release(timer);
    });//启动 Dispatch Source
    dispatch_resume(timer);
    //从上面的代码可以看出,异步读取文件映射的代码和定时器的代码知道, Dispatch Queue 没有 "取消" 这个概念,一旦将处理追加到 Dispatch Queue 中,就没有方法可以将其移除.也没有方法可在执行中取消该处理,
    //注: Dispatch Source 和 Dispatch Queue 不同,是可以取消的, 而且取消时必须执行的处理可指定为回调的 Blok 形式.所以使用 Dispatch Source 实现 XNU 内核中发生的事件处理要比直接使用 kqueue 实现更为简单,
}
/**
 Dispatch Queue
 */
-(void)test14{

    /**
     GCD 的实现
     需要1. 用于管理追加的 Block 的 C 语言层实现的 FIFO 队列
        2. Atomic 函数中实现的用于排他控制的轻量级信号
        3. 用于管理线程的 C 语言层实现的一些容器
     */
    
    // Main Dispatch Queue 在 RunLoop 中执行的 Block\
        Global Dispatch Queue 有下面 8种
    /**
     Global Dispatch Queue (High Priority)
     Global Dispatch Queue (Default Priority)
     Global Dispatch Queue (Low Priority)
     Global Dispatch Queue (Background Priority)
     Global Dispatch Queue (High Overcommit Priority)
     Global Dispatch Queue (Default Overcommit Priority)
     Global Dispatch Queue (Low Overcommit Priority)
     Global Dispatch Queue (Background Overcommit Priority)
     */
    //注: 优先级附有 Overcommit 的 Global Dispatch Queue 使用在 Serial Dispatch Queue 中.如 Overcommit 这个名称所示,不管系统状态如何,都会强制生成线程的 Dispatch Queue.
    
}
/**
 Dispatch I/O (实现一次使用多个线程更快速的读取数据)
 */
-(void)test13{

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{/** 读取    0  ~ 8191 字节*/});
    dispatch_async(queue, ^{/** 读取  8192 ~ 16383 字节*/});
    dispatch_async(queue, ^{/** 读取 16384 ~ 24575 字节*/});
    dispatch_async(queue, ^{/** 读取 24576 ~ 32767 字节*/});
    dispatch_async(queue, ^{/** 读取 32768 ~ 40959 字节*/});
    dispatch_async(queue, ^{/** 读取 40960 ~ 49151 字节*/});
    dispatch_async(queue, ^{/** 读取 49152 ~ 57343 字节*/});
    dispatch_async(queue, ^{/** 读取 57344 ~ 65535 字节*/});

    //上面是将文件分割一块块的进行读取处理, 这样的读取数据可以使用 Dispatch Data
    
    //下面是苹果提供的例子
    /**
    static int
    _asl_auxiliary(aslmsg msg, const charchar *title, const charchar *uti, const charchar *url, intint *out_fd)
    {
        asl_msg_t *merged_msg;
        asl_msg_aux_t aux;
        asl_msg_aux_0_t aux0;
        fileport_t fileport;
        kern_return_t kstatus;
        uint32_t outlen, newurllen, len, where;
        int status, fd, fdpair[2];
        caddr_t out, newurl;
        dispatch_queue_t pipe_q;
        dispatch_io_t pipe_channel;
        dispatch_semaphore_t sem;
        ..... 此处省略若干代码.....
        
        // 创建串行队列
        pipe_q = dispatch_queue_create("PipeQ", NULL);
        // 创建 Dispatch I／O
        pipe_channel = dispatch_io_create(DISPATCH_IO_STREAM, fd, pipe_q, ^(int err){
            close(fd);
        });
        
        *out_fd = fdpair[1];
        
        // 该函数设定一次读取的大小（分割大小）
        dispatch_io_set_low_water(pipe_channel, SIZE_MAX);
        //
        dispatch_io_read(pipe_channel, 0, SIZE_MAX, pipe_q, ^(bool done, dispatch_data_t pipedata, int err){
            if (err == 0) // err等于0 说明读取无误
            {
                // 读取完“单个文件块”的大小
                size_t len = dispatch_data_get_size(pipedata);
                if (len > 0)
                {
                    // 定义一个字节数组bytes
                    const charchar *bytes = NULL;
                    charchar *encoded;
                    
                    dispatch_data_t md = dispatch_data_create_map(pipedata, (const voidvoid **)&bytes, &len);
                    encoded = asl_core_encode_buffer(bytes, len);
                    asl_set((aslmsg)merged_msg, ASL_KEY_AUX_DATA, encoded);
                    free(encoded);
                    _asl_send_message(NULL, merged_msg, -1, NULL);
                    asl_msg_release(merged_msg);
                    dispatch_release(md);
                }
            }
            
            if (done)
            {  
                dispatch_semaphore_signal(sem);  
                dispatch_release(pipe_channel);  
                dispatch_release(pipe_q);  
            }  
        });  
    }
    */
    
    /**
     dispatch_io_create
     @param <#dispatch_io_type_t type#> 读写操作按顺序依次顺序进行。在读或写开始时，操作总是在文件指针位置读或写数据。读和写操作可以在同一个信道上同时进行。随机访问文件。读和写操作可以同时执行这种类型的通道,文件描述符必须是可寻址的。
     @param <#dispatch_fd_t fd#> 文件描述符
     @param <#dispatch_queue_t  _Nonnull queue#> 发生错误时用来执行处理的 Dispatch Queue
     @param error <#^(int error)cleanup_handler#> 发生错误时用来执行处理的 Block
     dispatch_io_create(<#dispatch_io_type_t type#>, <#dispatch_fd_t fd#>, <#dispatch_queue_t  _Nonnull queue#>, <#^(int error)cleanup_handler#>)
     */
    
    /**
     dispatch_io_set_low_water
     @param <#dispatch_io_t  _Nonnull channel#>
     @param <#size_t low_water#> 设定一次读取的大小(分割大小).
     dispatch_io_set_low_water(<#dispatch_io_t  _Nonnull channel#>, <#size_t low_water#>)
     */
    
    /**
     dispatch_io_read 使用 Global Dispatch Queue 开始并列读取.每当各个分割的文件读取结果结束时,将含有文件块数据的 Dispatch Data 传递给 Dispatch_io_read 函数指定的读取结束时回调用的 Block. 回调用的 Block 分析传递过来的 Dispatch Data 并进行结合处理.
     @param <#dispatch_io_t  _Nonnull channel#>
     @param <#off_t offset#>
     @param <#size_t length#>
     @param <#dispatch_queue_t  _Nonnull queue#>
     @param done <#done description#>
     @param data <#data description#>
     @param error <#error description#>
     dispatch_io_read(<#dispatch_io_t  _Nonnull channel#>, <#off_t offset#>, <#size_t length#>, <#dispatch_queue_t  _Nonnull queue#>, <#^(bool done, dispatch_data_t  _Nullable data, int error)io_handler#>)
     */
   //注:以上3个函数的使用 http://www.cocoachina.com/industry/20130821/6842.html
}
/**
 dispatch_once (保证代码在程序中只执行一次)
 */
-(void)test12{

    static int initialized = NO;
    
    if (initialized == NO) {
        //初始化
        initialized = YES;
    }
    //使用 dispatch_once
    
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        //初始化
    });
}
/**
 Dispatch Semaphore (Semaphore 信号)
 */
-(void)test11{

    //情况: 在不考虑顺序下,将所有数据追加到 NSMutableArray 中
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    NSMutableArray *array = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < 100000; i++) {
        dispatch_async(queue, ^{
            [array addObject:[NSNumber numberWithInt:i]];
        });
    }
    //以上代码执行后会出现由于内存错误导致应用异常结束的概率较高,此时应该使用 Dispatch Semaphore 函数
    /**
     Dispatch Semaphore 是持有计数的信号,该计数是多线程编程中的计数类型信号.在 Dispatch Semaphore 中,使用计数来实现该功能.计数为 0 时等待,计数为 1 或是大于 1 时,减去 1 而不等待.
     */
    // 初始化 dispatch_semaphore_t 例子代码将计数值初始化为 1. 从 create 可以看出该函数与 Dispatch Queue 和 Dispatch Group 一样.需要通过 dispatch_release 释放 dispatch_retain 持有
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    
     /**
      dispatch_semaphore_wait
      @param <#dispatch_semaphore_t  _Nonnull dsema#>
      @param <#dispatch_time_t timeout#> 指定等待的时间 (超时).属于 dispatch_time_t 类型的值.与 dispatch_group_wait 函数等相同
      dispatch_semaphore_wait(<#dispatch_semaphore_t  _Nonnull dsema#>, <#dispatch_time_t timeout#>)
      dispatch_semaphore_wait 函数等待 Dispatch Semaphore 的计数值到大于或等于 1. 当计数值大于等于 1,或者在待机中计数值大于等于 1时,对该计数进行减法并从 dispatch_semaphore_wait 函数返回.第二个参数与 dispatch_group_wait 函数等相同.下面的代码是永久等待. 而且 dispatch_semaphore_wait 的返回值与 dispatch_group_wait 一样
      */
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    //例子
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
    
    long result = dispatch_semaphore_wait(semaphore, time);
    
    if (result == 0) {
        /**
         由于 Dispatch Semaphore 的计数值达到大于等于 1.或者在待机中的指定时间内, Dispatch Semaphore 的计数值达到大于等于 1.所以 Dispatch Semaphore 的计数值减去 1.可执行需要进行排他控制的处理.
         */
        NSLog(@"%ld",result);
    }else{
        /**
         由于 Dispatch Semaphore 的计数值为 0 所以在达到指定时间为止待机.
         */
        NSLog(@"%ld",result);
    }
    // dispatch_semaphore_wait 函数返回 0时,可安全地执行需要进行排他控制的处理.该处理结束时通过 dispatch_semaphore_signal 函数将 Dispatch Semaphore 的计数值加 1.

    dispatch_queue_t queue1 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_semaphore_t semaphore1 = dispatch_semaphore_create(1);
    NSMutableArray *array1 = [[NSMutableArray alloc]init];
    for (int i = 0; i < 100000; i++) {
        dispatch_async(queue1, ^{
            /**
             等待 Dispatch Semaphore 直到 Dispatch Semaphore 的计数值达到大于等于 1.
             */
            dispatch_semaphore_wait(semaphore1, DISPATCH_TIME_FOREVER);
            
            /**
             由于 Dispatch Semaohore 的计数值达到等于 1.所以将 Dispatch Semaphore 的计数值减去 1. dispatch_semaphore_wait 函数执行返回.即执行到此时的 Dispatch Semaphore 的计数值恒为 "0".由于可访问 NSMutableArray 类对象的线程,只有 1个.因此可安全地进行更新
             */
            [array1 addObject:[NSNumber numberWithInt:i]];
            
            /**
             排他控制处理结束,所以通过 dispatch_semaphore_sigal 函数,将 Dispatch Semaphore 的计数值加1 .如果有通过 dispatch_semaphore_wait 函数等待 Dispatch Semaphore 的计数值增加的线程,就由最先等待的线程执行
             */
            dispatch_semaphore_signal(semaphore1);
        });
    }
    /**
     使用结束后释放 semaphore1
     */
    dispatch_release(semaphore1);
}
/**
 dispatch_suspend (suspend 暂停/挂起) / dispatch_resume (resume 继续/恢复)
 */
-(void)test10{

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    /**
     dispatch_suspend
     @param <#dispatch_object_t  _Nonnull object#> 要挂起的 Dispatch Queue
     dispatch_suspend(<#dispatch_object_t  _Nonnull object#>)
     */
    dispatch_suspend(queue);
    /**
     dispatch_resume
     @param <#dispatch_object_t  _Nonnull object#> 要恢复的 Dispatch Queue
     dispatch_resume(<#dispatch_object_t  _Nonnull object#>)
     */
    dispatch_resume(queue);

    //注:这些函数对已执行的处理没有任何影响.挂起后,追加到 Dispatch Queue 中但尚未执行的处理在此之后停止执行.而恢复则使得这些处理能够继续执行.
}
/**
 dispatch_apply (apply 应用)
 */
-(void)test9{


    /**
     dispatch_sync 函数是 dispatch_sync 函数和 Dispatch Group 的关联 API. 该函数按指定的次数将指定的 Block 追加到指定的 Dispatch Queue 中,并等待全部执行结束.
     */
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    /**
     dispatch_apply
     @param <#size_t iterations#> 重复次数
     @param <#dispatch_queue_t  _Nonnull queue#> 追加对象的 Dispatch Queue
     @param <#^(size_t)block#> 追加的处理 该参数的 Block 带有参数
     dispatch_apply(<#size_t iterations#>, <#dispatch_queue_t  _Nonnull queue#>, <#^(size_t)block#>)
     */
    dispatch_apply(10, queue, ^(size_t index) {
        NSLog(@"%zu",index);
    });
    NSLog(@"done");
    /**
     2017-05-21 12:02:31.763 GCD (多线程)[6736:99643] 0
     2017-05-21 12:02:31.763 GCD (多线程)[6736:101912] 1
     2017-05-21 12:02:31.763 GCD (多线程)[6736:101913] 2
     2017-05-21 12:02:31.763 GCD (多线程)[6736:101115] 3
     2017-05-21 12:02:31.764 GCD (多线程)[6736:99643] 4
     2017-05-21 12:02:31.764 GCD (多线程)[6736:101912] 5
     2017-05-21 12:02:31.764 GCD (多线程)[6736:101115] 7
     2017-05-21 12:02:31.764 GCD (多线程)[6736:101913] 6
     2017-05-21 12:02:31.765 GCD (多线程)[6736:101912] 9
     2017-05-21 12:02:31.765 GCD (多线程)[6736:99643] 8
     2017-05-21 12:02:31.765 GCD (多线程)[6736:99643] done
     */
    //从输出结果可以看出,最后输出的 done 是因为 dispatch_apply 函数会等待全部执行处理结束才会执行.
    
    //例子
    NSArray *array = @[@"123",@123,@"张三",@"李四"];
    
    dispatch_queue_t queue1 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_apply(array.count, queue1, ^(size_t index) {
        NSLog(@"%zu:%@",index,[array objectAtIndex:index]);
        NSLog(@"%@",[NSThread currentThread]);
    });
    //从上面的例子可以看出,dispatch_apply 函数与 dispatch_sync 函数相同,会等待处理执行结束.所以可以使用在 dispatch_async 函数中异步执行 dispatch_apply 函数.
    
    dispatch_queue_t queue2 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    /**
     在 Global Dispatch Queue 这异步执行
     */
    dispatch_async(queue, ^{
        /**
         Global Dispatch Queue 等待 dispatch_apply 函数全部处理执行结束.
         */
        dispatch_apply(array.count, queue2, ^(size_t index) {
            /**
             并列处理包含在 NSArray 对象的全部对象
             */
            NSLog(@"%zu:%@",index,[array objectAtIndex:index]);
            NSLog(@"%@",[NSThread currentThread]);
        });
    });
    /**
     在 Main Dispatch Queue 中异步执行
     */
    
    dispatch_async(dispatch_get_main_queue(), ^{
        /**
         在 Main Dispatch Queue 中执行处理,用户界面更新.
         */
        dispatch_apply(array.count, queue2, ^(size_t index) {
            /**
             并列处理包含在 NSArray 对象的全部对象
             */
            NSLog(@"done finishing");
        });
    });
    /**
     2017-05-22 10:32:31.037 GCD (多线程)[1140:298792] done finishing
     2017-05-22 10:32:31.038 GCD (多线程)[1140:306428] 0:123
     2017-05-22 10:32:31.038 GCD (多线程)[1140:303255] done finishing
     2017-05-22 10:32:31.038 GCD (多线程)[1140:306426] done finishing
     2017-05-22 10:32:31.038 GCD (多线程)[1140:306427] done finishing
     2017-05-22 10:32:31.038 GCD (多线程)[1140:306430] 1:123
     2017-05-22 10:32:31.038 GCD (多线程)[1140:306434] 2:张三
     2017-05-22 10:32:31.038 GCD (多线程)[1140:306436] 3:李四
     2017-05-22 10:32:31.039 GCD (多线程)[1140:306428] <NSThread: 0x60800006e6c0>{number = 21, name = (null)}
     2017-05-22 10:32:31.039 GCD (多线程)[1140:306430] <NSThread: 0x618000073400>{number = 22, name = (null)}
     2017-05-22 10:32:31.040 GCD (多线程)[1140:306434] <NSThread: 0x60800006e440>{number = 23, name = (null)}
     2017-05-22 10:32:31.040 GCD (多线程)[1140:306436] <NSThread: 0x60800006e240>{number = 24, name = (null)}
     */
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

//
//  MyObject.m
//  GCD (多线程)
//
//  Created by 一天 on 2017/5/17.
//  Copyright © 2017年 肖振阳. All rights reserved.
//

#import "MyObject.h"

@implementation MyObject

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        
        [self performSelectorInBackground:@selector(doWork) withObject:nil];
        
    }
    return self;
}

/**
 后台线程处理方法
 */
-(void)doWork{

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    
    /**
     长时间处理
     耗时操作
     */
    
    [self performSelectorOnMainThread:@selector(doneWork) withObject:nil waitUntilDone:NO];

    [pool drain];
    /**
     虽然ARC引入之后NSAutoReleasePool的使用有了很大变化，但是了解NSAutoReleasePool的机制还是十分必要的，下面主要说一下：
     NSAutoReleasePool * pool = [NSAutoReleasePool alloc] init];
     //do something
     之后，
     [pool drain] 和 [pool release] 的区别：
     release，在引用计数环境下，由于NSAutoReleasePool是一个不可以被retain的类型，所以release会直接dealloc pool对象。当pool被dealloc的时候，pool向所有在pool中的对象发出一个release的消息，如果一个对象在这个pool中autorelease了多次，pool对这个对象的每一次autorelease都会release。在GC环境下release是一个no-op操作（代表没有操作，是一个占据进行很少的空间但是指出没有操作的计算机指令）。
     drain，在引用计数环境下，它的行为和release是一样的。在GC的环境下，这个方法调用objc_collect_if_needed出发GC。
     因此，重点是：在GC环境下，release是一个no-op，所以除非你不希望在GC环境下出发GC，你都应该使用drain而不是使用release来释放pool。
     */
}

/**
 主线程处理方法
 */
-(void)doneWork{

    /**
     只在主线程可以执行的处理,
     刷新 UI 之类的
     */
    
}
@end

//
//  SWGProxy.m
//  HotFixDemo
//
//  Created by gaowenjie3 on 2020/12/10.
//

#import "SWGProxy.h"

@interface SWGProxy()

{
     id realObject1;
 }

@end

@implementation SWGProxy


//- (void)forwardMethod{
//    NSLog(@"==========");
//}

-(id)initWithTarget1:(id)t1
{
      realObject1 = t1;
      return self;
}
-(void)forwardInvocation:(NSInvocation *)invocation
{
       id target = [realObject1 methodSignatureForSelector:invocation.selector];
       [invocation invokeWithTarget:target];
}
-(NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
     NSMethodSignature *signature;
     signature = [realObject1 methodSignatureForSelector:sel];
     if (signature) {
          return signature;
     }
     return signature;
}
-(BOOL)respondsToSelector:(SEL)aSelector
{
    return NO;
}


@end

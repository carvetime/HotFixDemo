//
//  SWGProxy.m
//  HotFixDemo
//
//  Created by gaowenjie3 on 2020/12/10.
//

#import "SWGProxy.h"
#import <objc/runtime.h>
#import "SWGNeedleConst.h"
#import "SWGCompatibilityMacros.h"

static const NSMutableDictionary *SWGMethods;

@implementation SWGProxy

void overrideMethod(Class cls, NSString *selName, JSValue *jsMethod){
    SEL selector = NSSelectorFromString(selName);
    NSString *clsName = NSStringFromClass(cls);
    NSMethodSignature *methodSignature = [cls instanceMethodSignatureForSelector:selector];
    Method method = class_getInstanceMethod(cls, selector);
    char *typeDesc = (char *)method_getTypeEncoding(method);
//    IMP orgImp = class_respondsToSelector(cls, selector);
    class_replaceMethod(cls, selector, class_getMethodImplementation(cls, @selector(__JPSImplementSelector)), typeDesc);
    IMP forwadImp = class_replaceMethod(cls, @selector(forwardInvocation:), (IMP)(JSPForwardInvocation), @"v@:@");
    NSString *swgSelName = SWG_FORT_STRING(SWGNeedlePrefixName, selName);
    SEL swgSel = NSSelectorFromString(swgSelName);
    SWG_LAZY_INIT_DICT(SWGMethods);
    SWGMethods[clsName] = jsMethod;
    class_addMethod(cls, swgSel, commonJSImplement, typeDesc);
}


static void commonJSImplement(id slf, SEL sel){
    NSString *selectorName = NSStringFromSelector(sel);
    NSString *clsName = NSStringFromClass([slf class]);
    JSValue *jsValue = [[JSValue alloc] init];
    JSValue *func = SWGMethods[clsName];
    [func callWithArguments:nil];
}

static void JSPForwardInvocation(id slf,SEL sel,NSInvocation *invocation){
    NSString *selectorName = NSStringFromSelector(invocation.selector);
    SEL jsSelector = NSSelectorFromString(SWG_FORT_STRING(SWGNeedlePrefixName, selectorName));
    [invocation setSelector:jsSelector];
    [invocation invoke];
}



@end

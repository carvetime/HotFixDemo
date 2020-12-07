//
//  JSPCore.m
//  HotFixDemo
//
//  Created by gaowenjie3 on 2020/12/4.
//

#import "JSPCore.h"
#import <objc/runtime.h>

static JSContext *context;

@implementation JSPCore

+ (void)start{
    context = [[JSContext alloc] init];
    context[@"log"] = ^(NSString *msg){
        NSLog(@"log:%@",msg);
    };
    context[@"requireOC"] = ^(NSString *clsName){
        
        
    }
    context[@"calloc"] = ^(NSString *className,NSString *fucName,NSString *jsFucName,NSArray *args) {
        NSLog(@"%@",className);
        NSLog(@"%@",fucName);
        NSLog(@"%@",args);
        
        Class cls = NSClassFromString(className);
        NSString *fn = [NSString stringWithFormat:@"%@",fucName];
        SEL selector = NSSelectorFromString(fucName);
        Method method = class_getInstanceMethod(cls, selector);
        
        //获得viewDidLoad方法的函数指针
        IMP imp = method_getImplementation(method);
        
        //获得viewDidLoad方法的参数类型
        char *typeDescription = (char *)method_getTypeEncoding(method);
        
        //新增一个ORIGViewDidLoad方法，指向原来的viewDidLoad实现
        class_addMethod(cls, @selector(ORIGViewDidLoad), imp, typeDescription);
        
        
        NSString *string = fucName;
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@":" options:NSRegularExpressionCaseInsensitive error:&error];
        NSUInteger numberOfMatches = [regex numberOfMatchesInString:string options:0 range:NSMakeRange(0, [string length])];
        
        //把viewDidLoad IMP指向自定义新的实现
        switch (numberOfMatches) {
            case 0:
                class_replaceMethod(cls, selector, commonIMP0, typeDescription);
                break;
            case 1:
                class_replaceMethod(cls, selector, commonIMP1, typeDescription);
                break;
            case 2:
                class_replaceMethod(cls, selector, commonIMP2, typeDescription);
                break;
            default:
                break;
        }
        
    };
    NSString *path = [[NSBundle mainBundle] pathForResource:@"main" ofType:@"js"];
    NSString *jsCore = [[NSString alloc] initWithData:[[NSFileManager defaultManager] contentsAtPath:path] encoding:NSUTF8StringEncoding];
    [context evaluateScript:jsCore];
}

static void commonIMP0(id slf, SEL selector){
    NSLog(@"new commonIMP=====%@",@"0参数");
    NSString *fuc = NSStringFromSelector(selector);
    NSString *jsfunc = [NSString stringWithFormat:@"test0()"];
    [context evaluateScript:jsfunc];
}

static void commonIMP1(id slf, SEL selector, id name){
    NSLog(@"new commonIMP=====%@",name);
    NSString *fuc = NSStringFromSelector(selector);
    NSString *jsfunc = [NSString stringWithFormat:@"test1(%@)",name];
    [context evaluateScript:jsfunc];
}

static void commonIMP2(id slf, SEL selector, id name, id name2){
    NSLog(@"new commonIMP=====%@，===%@",name, name2);
    NSString *fuc = NSStringFromSelector(selector);
    NSString *jsfunc = [NSString stringWithFormat:@"test1name2(%@,%@)",name,name2];
    [context evaluateScript:jsfunc];
}

static void viewDidLoadIMP(id slf, SEL sel){
    
    NSString *name = NSStringFromSelector(sel);
    NSLog(@"new function ======%@",name);
}

static void ORIGViewDidLoad(id slf, SEL sel){
    NSString *name = NSStringFromSelector(sel);
    NSLog(@"origin function ==========%@",name);
}

@end

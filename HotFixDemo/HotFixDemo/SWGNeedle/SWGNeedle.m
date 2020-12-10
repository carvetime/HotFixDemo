//
//  SWGNeedle.m
//  HotFixDemo
//
//  Created by gaowenjie3 on 2020/12/10.
//

#import "SWGNeedle.h"
#import <objc/runtime.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <UIKit/UIKit.h>
#import "SWGUtil.h"
#import "SWGNeedleConst.h"
#import "SWGCompatibilityMacros.h"
#import "SWGProxy.h"


static const JSContext *context;
static const NSMutableDictionary *SWGMethods;

@implementation SWGNeedle

+ (void)prepare{
    
    context = [[JSContext alloc] init];

    context[@"log"] = ^(NSString *msg){
        NSLog(@"log:%@",msg);
    };
    context[@"requireClass"] = ^(NSString *clsName){
        
    };
    context[@"hookSelector"] = ^(NSString *className,JSValue *jsMethods, NSArray *args) {
        return hookSelector(className, jsMethods, args);
    };
    
    context[@"executeSelector"] = ^(NSString *className,NSString *fucName, NSArray *args) {
        return executeSelector(className, fucName, args);
    };
    NSString *path = [[NSBundle mainBundle] pathForResource:@"main" ofType:@"js"];
    NSString *jsCore = [[NSString alloc] initWithData:[[NSFileManager defaultManager] contentsAtPath:path] encoding:NSUTF8StringEncoding];
    [context evaluateScript:jsCore];
}

static id hookSelector(NSString *clsName, JSValue *jsMethods, NSArray *args){
    
    
    Class cls = NSClassFromString(clsName);
    unsigned int countOfmethods = 0;
    Method *methodsAry = class_copyMethodList(cls, &countOfmethods);
    for (unsigned int i = 0; i < countOfmethods; i++){
        Method method = methodsAry[i];
        struct objc_method_description *desc = method_getDescription(method);
        NSString *methodName = NSStringFromSelector(desc->name);
        NSString *jsFuncName = [methodName stringByReplacingOccurrencesOfString:@":" withString:@"_"];
        JSValue *function = jsMethods[methodName];
        if (!function.isUndefined) {
            overrideMethod(cls,methodName,function);
        }
    }
    return nil;
}

static void overrideMethod(Class cls, NSString *selName, JSValue *jsMethod){
    cls = NSClassFromString(@"SWGProxy");
    SEL selector = NSSelectorFromString(@"forwardMethod");
    NSString *clsName = NSStringFromClass(cls);
    NSMethodSignature *methodSignature = [cls methodSignatureForSelector:selector];
//    Method method = class_getInstanceMethod(cls, selector);
//    char *typeDesc = (char *)method_getTypeEncoding(method);
//    IMP orgImp = class_respondsToSelector(cls, selector);
//    class_replaceMethod(cls, selector, class_getMethodImplementation(cls, @selector(__JPSImplementSelector)), typeDesc);
//    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    
    SWGProxy *proxy = [[SWGProxy alloc] initWithTarget1:@"123"];
    
//    [invocation setTarget:proxy];
//    [invocation setSelector:selector];
//    [invocation invoke];
//    IMP forwadImp = class_replaceMethod(cls, @selector(forwardInvocation:), (IMP)(JSPForwardInvocation), @"v@:@");
//    NSString *JSPSelName = SWG_FORT_STRING(SWGNeedlePrefixName, selName);
//    SEL JSPSel = NSSelectorFromString(JSPSelName);
//    SWG_LAZY_INIT_DICT(SWGMethods);
//    SWGMethods[clsName] = jsMethod;
//    class_addMethod(cls, JSPSel, commonJSImplement, typeDesc);
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



static id executeSelector(NSString *clsName, NSString *selName, NSArray *args){
    Class cls = NSClassFromString(clsName);
    SEL selector = NSSelectorFromString(selName);
    NSMethodSignature *methodSignature = [cls methodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    [invocation setTarget:cls];
    [invocation setSelector:selector];
    
    NSUInteger numberOfArguments = methodSignature.numberOfArguments;
    for (NSUInteger i = 2; i < numberOfArguments; i++){
        const char *argTpye = [methodSignature getArgumentTypeAtIndex:i];
        id argValue = args[i-2];
        switch (argTpye[0]) {
                SWG_ARG_CASE('c', char, argValue, charValue)
                SWG_ARG_CASE('C', unsigned char, argValue, unsignedCharValue)
                SWG_ARG_CASE('s', short, argValue, shortValue)
                SWG_ARG_CASE('S', unsigned short, argValue, unsignedShortValue)
                SWG_ARG_CASE('i', int, argValue, intValue)
                SWG_ARG_CASE('I', unsigned int, argValue, unsignedIntValue)
                SWG_ARG_CASE('l', long, argValue,  longValue)
                SWG_ARG_CASE('L', unsigned long, argValue, unsignedLongValue)
                SWG_ARG_CASE('q', long long, argValue, longLongValue)
                SWG_ARG_CASE('Q', unsigned long long, argValue, unsignedLongLongValue)
                SWG_ARG_CASE('f', float, argValue, floatValue)
                SWG_ARG_CASE('d', double, argValue, doubleValue)
                SWG_ARG_CASE('B', BOOL, argValue, boolValue)
            case ':': {
                SEL value = NSSelectorFromString(argValue);
                [invocation setArgument:&value atIndex:i];
                break;
            }
            case '{': {
                NSString *typeString = [NSString stringWithUTF8String:argTpye];
                SWG_ARG_STRUCT(CGRect, typeString, dictToRect)
                SWG_ARG_STRUCT(CGPoint, typeString, dictToPoint)
                SWG_ARG_STRUCT(CGSize, typeString, dictToSize)
                SWG_ARG_STRUCT(NSRange, typeString, dictToRange)
                break;
            }
            default:
                // TODO
                break;
        }
    }

    [invocation invoke];
    
    const char *retType = [methodSignature methodReturnType];
    id retValue;
    if (strncmp(retType, "v", 1) != 0){
        if (strncmp(retType, "@", 1) == 0){
            id __unsafe_unretained tempResSet;
            [invocation getReturnValue:&tempResSet];
            retValue = tempResSet;
            return formatOCObj(retValue);
        } else {
            switch (retType[0]) {
                    SWG_RET_CASE('c', char, retValue)
                    SWG_RET_CASE('C', unsigned char, retValue)
                    SWG_RET_CASE('s', short, retValue)
                    SWG_RET_CASE('S', unsigned short, retValue)
                    SWG_RET_CASE('i', int, retValue)
                    SWG_RET_CASE('I', unsigned int, retValue)
                    SWG_RET_CASE('l', long, retValue)
                    SWG_RET_CASE('L', unsigned long, retValue)
                    SWG_RET_CASE('q', long long, retValue)
                    SWG_RET_CASE('Q', unsigned long long, retValue)
                    SWG_RET_CASE('f', float, retValue)
                    SWG_RET_CASE('d', double, retValue)
                    SWG_RET_CASE('B', BOOL, retValue)
                case '{': {
                    NSString *typeString = [NSString stringWithUTF8String:retType];
                    SWG_RET_STRUCT(CGRect, rectToDictionary, typeString)
                    SWG_RET_STRUCT(CGPoint, pointToDictionary, typeString)
                    SWG_RET_STRUCT(CGSize, sizeToDictionary, typeString)
                    SWG_RET_STRUCT(NSRange, rangeToDictionary, typeString)
                }
                    break;
                default:
                    break;
            }
            return retValue;
        }
    }
    return nil;
}


static id formatOCObj(id obj) {
    if ([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNumber class]]) {
        return obj;
    }
    if ([obj isKindOfClass:[NSArray class]]) {
        NSMutableArray *newArr = [[NSMutableArray alloc] init];
        for (int i = 0; i < [obj count]; i ++) {
            [newArr addObject:formatOCObj(obj[i])];
        }
        return newArr;
    }
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
        for (NSString *key in [obj allKeys]) {
            [newDict setObject:formatOCObj(obj[key]) forKey:key];
        }
        return newDict;
    }
    if ([obj isKindOfClass:NSClassFromString(@"NSBlock")]) {
        return obj;
    }
    
    return toJSObj(obj);
}

static inline CGRect dictToRect(NSDictionary *dict)
{
    return CGRectMake([dict[@"x"] intValue], [dict[@"y"] intValue], [dict[@"width"] intValue], [dict[@"height"] intValue]);
}

static inline CGPoint dictToPoint(NSDictionary *dict)
{
    return CGPointMake([dict[@"x"] intValue], [dict[@"y"] intValue]);
}

static inline CGSize dictToSize(NSDictionary *dict)
{
    return CGSizeMake([dict[@"width"] intValue], [dict[@"height"] intValue]);
}

static inline NSRange dictToRange(NSDictionary *dict)
{
    return NSMakeRange([dict[@"location"] intValue], [dict[@"length"] intValue]);
}

static inline NSDictionary *toJSObj(id obj)
{
    if (!obj) return nil;
    return @{@"__isObj": @(YES), @"cls": NSStringFromClass([obj class]), @"obj": obj};
}

static inline NSDictionary *rectToDictionary(CGRect rect)
{
    return @{@"x": @(rect.origin.x), @"y": @(rect.origin.y), @"width": @(rect.size.width), @"height": @(rect.size.height)};
}

static inline NSDictionary *pointToDictionary(CGPoint point)
{
    return @{@"x": @(point.x), @"y": @(point.y)};
}

static inline NSDictionary *sizeToDictionary(CGSize size)
{
    return @{@"width": @(size.width), @"height": @(size.height)};
}

static inline NSDictionary *rangeToDictionary(NSRange range)
{
    return @{@"location": @(range.location), @"length": @(range.length)};
}


@end

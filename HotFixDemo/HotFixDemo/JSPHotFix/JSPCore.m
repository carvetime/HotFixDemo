//
//  JSPCore.m
//  HotFixDemo
//
//  Created by gaowenjie3 on 2020/12/4.
//

#import "JSPCore.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

#define JSP_ARG_CASE(_typeSymbol,_type,func) \
case _typeSymbol:{   \
    _type value = [argValue charValue]; \
    [invocation setArgument:&value atIndex:i];  \
    break;  \
}

#define JSP_ARG_STRUCT(_type, _transFunc) \
if ([typeString rangeOfString:@#_type].location != NSNotFound) {    \
    _type value = _transFunc(argValue);   \
    [invocation setArgument:&value atIndex:i];  \
    break;  \
}

#define JSP_RET_CASE(_typeSymbol, _type) \
case _typeSymbol: {                              \
    _type tempResSet; \
    [invocation getReturnValue:&tempResSet];\
    retValue = @(tempResSet); \
    break; \
}

#define JSP_RET_STRUCT(_type, _transFunc) \
if ([typeString rangeOfString:@#_type].location != NSNotFound) {    \
    _type result;   \
    [invocation getReturnValue:&result];    \
    return _transFunc(result);    \
}

#define JSP_FORT_STRING(_preStr,_sufStr) [NSString stringWithFormat:@"%@%@",_preStr,_sufStr]

#define JSP_LAZY_INIT_METHODS if (!JSPMethods) JSPMethods = @{}.mutableCopy;



static const JSContext *context;
static const NSString *PRE_NAME = @"_JSP";
static const NSMutableDictionary *JSPMethods;

@implementation JSPCore

+ (void)start{
    
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
    SEL selector = NSSelectorFromString(selName);
    NSString *clsName = NSStringFromClass(cls);
    NSMethodSignature *methodSignature = [cls instanceMethodSignatureForSelector:selector];
    Method method = class_getInstanceMethod(cls, selector);
    char *typeDesc = (char *)method_getTypeEncoding(method);
    IMP orgImp = class_respondsToSelector(cls, selector);
    class_replaceMethod(cls, selector, class_getMethodImplementation(cls, @selector(__JPSImplementSelector)), typeDesc);
    IMP forwadImp = class_replaceMethod(cls, @selector(forwardInvocation:), (IMP)(JSPForwardInvocation), @"v@:@");
    NSString *JSPSelName = JSP_FORT_STRING(PRE_NAME, selName);
    SEL JSPSel = NSSelectorFromString(JSPSelName);
    JSP_LAZY_INIT_METHODS
    JSPMethods[clsName] = jsMethod;
    class_addMethod(cls, JSPSel, commonJSImplement, typeDesc);
}

static void commonJSImplement(id slf, SEL sel){
    NSString *selectorName = NSStringFromSelector(sel);
    NSString *clsName = NSStringFromClass([slf class]);
    JSValue *jsValue = [[JSValue alloc] init];
    JSValue *func = JSPMethods[clsName];
    [func callWithArguments:nil];
}

static void JSPForwardInvocation(id slf,SEL sel,NSInvocation *invocation){
    NSString *selectorName = NSStringFromSelector(invocation.selector);
    SEL jsSelector = NSSelectorFromString(JSP_FORT_STRING(PRE_NAME, selectorName));
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
                JSP_ARG_CASE('c', char, charValue)
                JSP_ARG_CASE('C', unsigned char, unsignedCharValue)
                JSP_ARG_CASE('s', short, shortValue)
                JSP_ARG_CASE('S', unsigned short, unsignedShortValue)
                JSP_ARG_CASE('i', int, intValue)
                JSP_ARG_CASE('I', unsigned int, unsignedIntValue)
                JSP_ARG_CASE('l', long, longValue)
                JSP_ARG_CASE('L', unsigned long, unsignedLongValue)
                JSP_ARG_CASE('q', long long, longLongValue)
                JSP_ARG_CASE('Q', unsigned long long, unsignedLongLongValue)
                JSP_ARG_CASE('f', float, floatValue)
                JSP_ARG_CASE('d', double, doubleValue)
                JSP_ARG_CASE('B', BOOL, boolValue)
            case ':': {
                SEL value = NSSelectorFromString(argValue);
                [invocation setArgument:&value atIndex:i];
                break;
            }
            case '{': {
                NSString *typeString = [NSString stringWithUTF8String:argTpye];
                JSP_ARG_STRUCT(CGRect, dictToRect)
                JSP_ARG_STRUCT(CGPoint, dictToPoint)
                JSP_ARG_STRUCT(CGSize, dictToSize)
                JSP_ARG_STRUCT(NSRange, dictToRange)
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
                    JSP_RET_CASE('c', char)
                    JSP_RET_CASE('C', unsigned char)
                    JSP_RET_CASE('s', short)
                    JSP_RET_CASE('S', unsigned short)
                    JSP_RET_CASE('i', int)
                    JSP_RET_CASE('I', unsigned int)
                    JSP_RET_CASE('l', long)
                    JSP_RET_CASE('L', unsigned long)
                    JSP_RET_CASE('q', long long)
                    JSP_RET_CASE('Q', unsigned long long)
                    JSP_RET_CASE('f', float)
                    JSP_RET_CASE('d', double)
                    JSP_RET_CASE('B', BOOL)
                case '{': {
                    NSString *typeString = [NSString stringWithUTF8String:retType];
                    JSP_RET_STRUCT(CGRect, rectToDictionary)
                    JSP_RET_STRUCT(CGPoint, pointToDictionary)
                    JSP_RET_STRUCT(CGSize, sizeToDictionary)
                    JSP_RET_STRUCT(NSRange, rangeToDictionary)
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

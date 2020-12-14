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

@implementation SWGNeedle

+ (void)prepare{
    
    context = [[JSContext alloc] init];

    context[@"SWGLog"] = ^(JSValue *val){
        NSLog(@"log:%@",[val toObject]);
    };
    context[@"requireClass"] = ^(NSString *clsName){
        
    };
    context[@"hookSelector"] = ^(NSString *className,JSValue *jsMethods, NSArray *args) {
        return hookSelector(className, jsMethods, args);
    };
    
    context[@"executeSelector"] = ^(id obj,NSString *className,NSString *fucName, NSArray *args) {
        return executeSelector(obj,className, fucName, args);
    };
    NSString *path = [[NSBundle mainBundle] pathForResource:@"demo" ofType:@"js"];
    NSString *jsCore = [[NSString alloc] initWithData:[[NSFileManager defaultManager] contentsAtPath:path] encoding:NSUTF8StringEncoding];
    NSString *tryScript = [NSString stringWithFormat:@"try{%@}catch(e){ log(e.message)}",jsCore];
    [context evaluateScript:tryScript];
   
    
}

static id hookSelector(NSString *clsName, JSValue *jsMethods, NSArray *args){
    Class cls = NSClassFromString(clsName);
    unsigned int countOfmethods = 0;
    Method *methodsAry = class_copyMethodList(cls, &countOfmethods);
    for (unsigned int i = 0; i < countOfmethods; i++){
        Method method = methodsAry[i];
        struct objc_method_description *desc = method_getDescription(method);
        NSString *methodName = NSStringFromSelector(desc->name);
        NSString *jsFuncName = [methodName stringByReplacingOccurrencesOfString:SWGNeedleColonSign withString:SWGNeedleDollaSign];
        JSValue *function = jsMethods[jsFuncName];
        if (!function.isUndefined) {
            overrideMethod(cls,methodName,function);
        }
    }
    return nil;
}


static id executeSelector(id obj,NSString *clsName, NSString *selName, NSArray *args){
    Class cls = NSClassFromString(clsName);
    NSString *selReplaced = [selName stringByReplacingOccurrencesOfString:SWGNeedleDollaSign withString:SWGNeedleColonSign];
    SEL selector = NSSelectorFromString(selReplaced);
    
    NSMethodSignature *methodSignature;
    NSInvocation *invocation;
    if (obj && ![obj isEqual:[NSNull null]]){
        methodSignature = [cls instanceMethodSignatureForSelector:selector];
        invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        [invocation setTarget:obj];
    } else {
        methodSignature = [cls methodSignatureForSelector:selector];
        invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        [invocation setTarget:cls];
    }
    [invocation setSelector:selector];
    
    NSUInteger numberOfArguments = methodSignature.numberOfArguments;
    for (NSUInteger i = 2; i < numberOfArguments; i++){
        const char *argTpye = [methodSignature getArgumentTypeAtIndex:i];
        id argValue = args[i-2];
        switch (argTpye[0]) {
                SWG_ARG_CASE(SWGNeedleSymbolType_c, char, argValue, charValue)
                SWG_ARG_CASE(SWGNeedleSymbolType_C, unsigned char, argValue, unsignedCharValue)
                SWG_ARG_CASE(SWGNeedleSymbolType_s, short, argValue, shortValue)
                SWG_ARG_CASE(SWGNeedleSymbolType_S, unsigned short, argValue, unsignedShortValue)
                SWG_ARG_CASE(SWGNeedleSymbolType_i, int, argValue, intValue)
                SWG_ARG_CASE(SWGNeedleSymbolType_I, unsigned int, argValue, unsignedIntValue)
                SWG_ARG_CASE(SWGNeedleSymbolType_l, long, argValue,  longValue)
                SWG_ARG_CASE(SWGNeedleSymbolType_L, unsigned long, argValue, unsignedLongValue)
                SWG_ARG_CASE(SWGNeedleSymbolType_q, long long, argValue, longLongValue)
                SWG_ARG_CASE(SWGNeedleSymbolType_Q, unsigned long long, argValue, unsignedLongLongValue)
                SWG_ARG_CASE(SWGNeedleSymbolType_f, float, argValue, floatValue)
                SWG_ARG_CASE(SWGNeedleSymbolType_d, double, argValue, doubleValue)
                SWG_ARG_CASE(SWGNeedleSymbolType_B, BOOL, argValue, boolValue)
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
                [invocation setArgument:&argValue atIndex:i];
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
                    SWG_RET_CASE(SWGNeedleSymbolType_c, char, retValue)
                    SWG_RET_CASE(SWGNeedleSymbolType_C, unsigned char, retValue)
                    SWG_RET_CASE(SWGNeedleSymbolType_s, short, retValue)
                    SWG_RET_CASE(SWGNeedleSymbolType_S, unsigned short, retValue)
                    SWG_RET_CASE(SWGNeedleSymbolType_i, int, retValue)
                    SWG_RET_CASE(SWGNeedleSymbolType_I, unsigned int, retValue)
                    SWG_RET_CASE(SWGNeedleSymbolType_l, long, retValue)
                    SWG_RET_CASE(SWGNeedleSymbolType_L, unsigned long, retValue)
                    SWG_RET_CASE(SWGNeedleSymbolType_q, long long, retValue)
                    SWG_RET_CASE(SWGNeedleSymbolType_Q, unsigned long long, retValue)
                    SWG_RET_CASE(SWGNeedleSymbolType_f, float, retValue)
                    SWG_RET_CASE(SWGNeedleSymbolType_d, double, retValue)
                    SWG_RET_CASE(SWGNeedleSymbolType_B, BOOL, retValue)
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





@end

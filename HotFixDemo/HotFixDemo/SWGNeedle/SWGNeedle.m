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

static const JSContext *context;
static const NSMutableDictionary *SWGMethods;
static NSArray *SWGInvocationArgs;

SWG_DEFINE_METHOD_IMP(SWGMethods,SWGInvocationArgs)

SWG_DEFINE_METHOD_IMP_RET_OBJC(id,SWGMethods,SWGInvocationArgs)

SWG_DEFINE_METHOD_IMP_RET(char,SWGMethods,SWGInvocationArgs,charValue,CharVal)
SWG_DEFINE_METHOD_IMP_RET(unsigned char,SWGMethods,SWGInvocationArgs,unsignedCharValue,UncharVal)
SWG_DEFINE_METHOD_IMP_RET(short,SWGMethods,SWGInvocationArgs,shortValue,ShtVal)
SWG_DEFINE_METHOD_IMP_RET(unsigned short,SWGMethods,SWGInvocationArgs,unsignedShortValue,UnshtVal)
SWG_DEFINE_METHOD_IMP_RET(int,SWGMethods,SWGInvocationArgs,intValue,IntVal)
SWG_DEFINE_METHOD_IMP_RET(unsigned int,SWGMethods,SWGInvocationArgs,unsignedIntValue,UnintVal)
SWG_DEFINE_METHOD_IMP_RET(long,SWGMethods,SWGInvocationArgs,longValue,longVal)
SWG_DEFINE_METHOD_IMP_RET(unsigned long,SWGMethods,SWGInvocationArgs,unsignedLongValue,UnlongVal)
SWG_DEFINE_METHOD_IMP_RET(long long,SWGMethods,SWGInvocationArgs,longLongValue,LongLongVal)
SWG_DEFINE_METHOD_IMP_RET(unsigned long long,SWGMethods,SWGInvocationArgs,unsignedLongLongValue,UnLongLongVal)
SWG_DEFINE_METHOD_IMP_RET(float,SWGMethods,SWGInvocationArgs,floatValue,FloatVal)
SWG_DEFINE_METHOD_IMP_RET(double,SWGMethods,SWGInvocationArgs,doubleValue,DoubleVal)
SWG_DEFINE_METHOD_IMP_RET(BOOL,SWGMethods,SWGInvocationArgs,boolValue,BoolVal)

SWG_DEFINE_METHOD_IMP_RET_STRUCT(CGRect,SWGMethods,SWGInvocationArgs,return dictToRect([ret toObject]),Rect)
SWG_DEFINE_METHOD_IMP_RET_STRUCT(CGSize,SWGMethods,SWGInvocationArgs,return dictToSize([ret toObject]),Size)
SWG_DEFINE_METHOD_IMP_RET_STRUCT(CGPoint,SWGMethods,SWGInvocationArgs,return dictToPoint([ret toObject]),Point)
SWG_DEFINE_METHOD_IMP_RET_STRUCT(NSRange,SWGMethods,SWGInvocationArgs,return dictToRange([ret toObject]),Range)

@implementation SWGNeedle

+ (void)prepare{
    
    context = [[JSContext alloc] init];

    context[@"SWGLog"] = ^(JSValue *val){
        NSLog(@"log:%@",[val toObject]);
    };
    
    context[@"hookSelector"] = ^(NSString *className,JSValue *jsMethods, NSArray *args) {
        return hookSelector(className, jsMethods, args);
    };
    
    context[@"executeSelector"] = ^(id obj,NSString *className,NSString *fucName, NSArray *args) {
        return executeSelector(obj,className, fucName, args);
    };
    NSString *path = [[NSBundle mainBundle] pathForResource:@"demo" ofType:@"js"];
    NSString *jsCore = [[NSString alloc] initWithData:[[NSFileManager defaultManager] contentsAtPath:path] encoding:NSUTF8StringEncoding];
    
    if (SWGNeedleDebug){
        jsCore = [NSString stringWithFormat:@"try{%@}catch(e){ log(e.message)}",jsCore];
    }
    
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



IMP SWGImplementationName(NSMethodSignature *methodSignature){
    IMP SWGImpName = nil;
    const char *retType = [methodSignature methodReturnType];
    switch (retType[0]) {
            SWG_OVERRIDE_NAME_RET_CASE(Empty, SWGNeedleSymbolType_v,SWGImpName)
            SWG_OVERRIDE_NAME_RET_CASE(Objc, SWGNeedleSymbolType_O, SWGImpName)
            SWG_OVERRIDE_NAME_RET_CASE(CharVal, SWGNeedleSymbolType_c,SWGImpName)
            SWG_OVERRIDE_NAME_RET_CASE(UncharVal, SWGNeedleSymbolType_C,SWGImpName)
            SWG_OVERRIDE_NAME_RET_CASE(ShtVal, SWGNeedleSymbolType_s,SWGImpName)
            SWG_OVERRIDE_NAME_RET_CASE(UnshtVal, SWGNeedleSymbolType_S,SWGImpName)
            SWG_OVERRIDE_NAME_RET_CASE(IntVal, SWGNeedleSymbolType_i,SWGImpName)
            SWG_OVERRIDE_NAME_RET_CASE(UnintVal, SWGNeedleSymbolType_I,SWGImpName)
            SWG_OVERRIDE_NAME_RET_CASE(longVal, SWGNeedleSymbolType_l,SWGImpName)
            SWG_OVERRIDE_NAME_RET_CASE(UnlongVal, SWGNeedleSymbolType_L,SWGImpName)
            SWG_OVERRIDE_NAME_RET_CASE(LongLongVal, SWGNeedleSymbolType_q,SWGImpName)
            SWG_OVERRIDE_NAME_RET_CASE(UnLongLongVal, SWGNeedleSymbolType_Q,SWGImpName)
            SWG_OVERRIDE_NAME_RET_CASE(FloatVal, SWGNeedleSymbolType_f,SWGImpName)
            SWG_OVERRIDE_NAME_RET_CASE(DoubleVal, SWGNeedleSymbolType_d,SWGImpName)
            SWG_OVERRIDE_NAME_RET_CASE(BoolVal, SWGNeedleSymbolType_B,SWGImpName)
    }
    return SWGImpName;
}

void overrideMethod(Class cls, NSString *selName, JSValue *jsMethod){
    SEL selector = NSSelectorFromString(selName);
    NSString *clsName = NSStringFromClass(cls);
    NSMethodSignature *methodSignature = [cls instanceMethodSignatureForSelector:selector];
    Method method = class_getInstanceMethod(cls, selector);
    char *typeDesc = (char *)method_getTypeEncoding(method);
    char *methodTypes = SWGNeedleFuncRetEmptyType;
    if ([selName hasPrefix:SWGNeedleColonSign]){
        methodTypes = SWGNeedleFuncHasRetType;
        selName = [selName substringFromIndex:1];
    }
    class_replaceMethod(cls, selector, class_getMethodImplementation(cls, @selector(__SWGImplementSelector)), typeDesc);
    class_replaceMethod(cls, @selector(forwardInvocation:), (IMP)(SWGForwardInvocation), methodTypes);
    NSString *swgSelName = SWG_FORT_STRING(SWGNeedlePrefixName, selName);
    SEL SWGSel = NSSelectorFromString(swgSelName);
    SWG_SET_METHOD_DICT(SWGMethods,clsName,swgSelName,jsMethod);
    class_addMethod(cls, SWGSel, SWGImplementationName(methodSignature), typeDesc);
}

static void SWGForwardInvocation(id slf,SEL sel,NSInvocation *invocation){
    NSMethodSignature *methodSignature = [invocation methodSignature];
    NSString *selectorName = NSStringFromSelector(invocation.selector);
    SEL jsSelector = NSSelectorFromString(SWG_FORT_STRING(SWGNeedlePrefixName, selectorName));
    
    NSMutableArray *argList = exTractArgList(slf,invocation, methodSignature);
    
    SWG_SAVE_FORT_INVCTN_ARGS(SWGInvocationArgs,argList)
    [invocation setSelector:jsSelector];
    [invocation invoke];
    SWG_CLEAR_INVCTN_ARGS(SWGInvocationArgs)
}

static NSMutableArray * exTractArgList(id slf, NSInvocation *invocation, NSMethodSignature *methodSignature){
    NSInteger numberOfArguments = [methodSignature numberOfArguments];
    NSMutableArray *argList = [[NSMutableArray alloc] init];
    if (!class_isMetaClass(object_getClass(slf))) {
        [argList addObject:slf];
    }
    for (NSUInteger i = 2; i < numberOfArguments; i++) {
        const char *argType = [methodSignature getArgumentTypeAtIndex:i];
        switch(argType[0]) {
                SWG_FWD_ARG_CASE(SWGNeedleSymbolType_c, char, argList, i)
                SWG_FWD_ARG_CASE(SWGNeedleSymbolType_C, unsigned char, argList, i)
                SWG_FWD_ARG_CASE(SWGNeedleSymbolType_s, short, argList, i)
                SWG_FWD_ARG_CASE(SWGNeedleSymbolType_S, unsigned short, argList, i)
                SWG_FWD_ARG_CASE(SWGNeedleSymbolType_i, int, argList, i)
                SWG_FWD_ARG_CASE(SWGNeedleSymbolType_I, unsigned int, argList, i)
                SWG_FWD_ARG_CASE(SWGNeedleSymbolType_l, long, argList, i)
                SWG_FWD_ARG_CASE(SWGNeedleSymbolType_L, unsigned long, argList, i)
                SWG_FWD_ARG_CASE(SWGNeedleSymbolType_q, long long, argList, i)
                SWG_FWD_ARG_CASE(SWGNeedleSymbolType_Q, unsigned long long, argList, i)
                SWG_FWD_ARG_CASE(SWGNeedleSymbolType_f, float, argList, i)
                SWG_FWD_ARG_CASE(SWGNeedleSymbolType_d, double, argList, i)
                SWG_FWD_ARG_CASE(SWGNeedleSymbolType_B, BOOL, argList, i)
                SWG_FWD_OBJ_ARG_CASE(argType,argList,i)
            case '{': {
                NSString *typeString = [NSString stringWithUTF8String:argType];
                SWG_FWD_ARG_STRUCT(CGRect, typeString, argList, i, rectToDictionary)
                SWG_FWD_ARG_STRUCT(CGPoint, typeString, argList, i, pointToDictionary)
                SWG_FWD_ARG_STRUCT(CGSize, typeString, argList, i, sizeToDictionary)
                SWG_FWD_ARG_STRUCT(NSRange, typeString, argList, i, rangeToDictionary)
                break;
            }
            default: {
                NSLog(@"error type %s", argType);
                break;
            }
        }
    }
    return argList;
}





@end

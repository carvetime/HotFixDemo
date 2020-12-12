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
#import "SWGUtil.h"
#import "SWGMethodModel.h"

static const NSMutableDictionary *SWGMethods;
static NSArray *SWGInvocationArgs;


@implementation SWGProxy

#pragma mark - js function implement
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


IMP SWGImplementationName(NSMethodSignature *methodSignature){
    IMP SWGImpName;
    const char *retType = [methodSignature methodReturnType];
    switch (retType[0]) {
            SWG_OVERRIDE_NAME_RET_CASE(Empty, 'v',SWGImpName)
            SWG_OVERRIDE_NAME_RET_CASE(Objc, '@', SWGImpName)
            SWG_OVERRIDE_NAME_RET_CASE(CharVal, 'c',SWGImpName)
            SWG_OVERRIDE_NAME_RET_CASE(UncharVal, 'C',SWGImpName)
            SWG_OVERRIDE_NAME_RET_CASE(ShtVal, 's',SWGImpName)
            SWG_OVERRIDE_NAME_RET_CASE(UnshtVal, 'S',SWGImpName)
            SWG_OVERRIDE_NAME_RET_CASE(IntVal, 'i',SWGImpName)
            SWG_OVERRIDE_NAME_RET_CASE(UnintVal, 'I',SWGImpName)
            SWG_OVERRIDE_NAME_RET_CASE(longVal, 'l',SWGImpName)
            SWG_OVERRIDE_NAME_RET_CASE(UnlongVal, 'L',SWGImpName)
            SWG_OVERRIDE_NAME_RET_CASE(LongLongVal, 'q',SWGImpName)
            SWG_OVERRIDE_NAME_RET_CASE(UnLongLongVal, 'Q',SWGImpName)
            SWG_OVERRIDE_NAME_RET_CASE(FloatVal, 'f',SWGImpName)
            SWG_OVERRIDE_NAME_RET_CASE(DoubleVal, 'd',SWGImpName)
            SWG_OVERRIDE_NAME_RET_CASE(BoolVal, 'B',SWGImpName)
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
    if ([selName hasPrefix:@":"]){
        methodTypes = SWGNeedleFuncHasRetType;
        selName = [selName substringFromIndex:1];
    }
    class_replaceMethod(cls, selector, class_getMethodImplementation(cls, @selector(__SWGImplementSelector)), typeDesc);
    IMP forwadImp = class_replaceMethod(cls, @selector(forwardInvocation:), (IMP)(SWGForwardInvocation), methodTypes);
    NSString *swgSelName = SWG_FORT_STRING(SWGNeedlePrefixName, selName);
    SEL SWGSel = NSSelectorFromString(swgSelName);
    SWG_SET_METHOD_DICT(SWGMethods,clsName,swgSelName,jsMethod);
    class_addMethod(cls, SWGSel, SWGImplementationName(methodSignature), typeDesc);
}

static void SWGForwardInvocation(id slf,SEL sel,NSInvocation *invocation){
    NSMethodSignature *methodSignature = [invocation methodSignature];
    NSInteger numberOfArguments = [methodSignature numberOfArguments];
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
                SWG_FWD_ARG_CASE('c', char, argList, i)
                SWG_FWD_ARG_CASE('C', unsigned char, argList, i)
                SWG_FWD_ARG_CASE('s', short, argList, i)
                SWG_FWD_ARG_CASE('S', unsigned short, argList, i)
                SWG_FWD_ARG_CASE('i', int, argList, i)
                SWG_FWD_ARG_CASE('I', unsigned int, argList, i)
                SWG_FWD_ARG_CASE('l', long, argList, i)
                SWG_FWD_ARG_CASE('L', unsigned long, argList, i)
                SWG_FWD_ARG_CASE('q', long long, argList, i)
                SWG_FWD_ARG_CASE('Q', unsigned long long, argList, i)
                SWG_FWD_ARG_CASE('f', float, argList, i)
                SWG_FWD_ARG_CASE('d', double, argList, i)
                SWG_FWD_ARG_CASE('B', BOOL, argList, i)
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

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


IMP SWGIMPName(NSMethodSignature *methodSignature){
    IMP SWGImplementationName;
    const char *retType = [methodSignature methodReturnType];
    switch (retType[0]) {
            SWG_OVERRIDE_NAME_RET_CASE(Empty, 'v',SWGImplementationName)
            SWG_OVERRIDE_NAME_RET_CASE(Objc, '@', SWGImplementationName)
            SWG_OVERRIDE_NAME_RET_CASE(CharVal, 'c',SWGImplementationName)
            SWG_OVERRIDE_NAME_RET_CASE(UncharVal, 'C',SWGImplementationName)
            SWG_OVERRIDE_NAME_RET_CASE(ShtVal, 's',SWGImplementationName)
            SWG_OVERRIDE_NAME_RET_CASE(UnshtVal, 'S',SWGImplementationName)
            SWG_OVERRIDE_NAME_RET_CASE(IntVal, 'i',SWGImplementationName)
            SWG_OVERRIDE_NAME_RET_CASE(UnintVal, 'I',SWGImplementationName)
            SWG_OVERRIDE_NAME_RET_CASE(longVal, 'l',SWGImplementationName)
            SWG_OVERRIDE_NAME_RET_CASE(UnlongVal, 'L',SWGImplementationName)
            SWG_OVERRIDE_NAME_RET_CASE(LongLongVal, 'q',SWGImplementationName)
            SWG_OVERRIDE_NAME_RET_CASE(UnLongLongVal, 'Q',SWGImplementationName)
            SWG_OVERRIDE_NAME_RET_CASE(FloatVal, 'f',SWGImplementationName)
            SWG_OVERRIDE_NAME_RET_CASE(DoubleVal, 'd',SWGImplementationName)
            SWG_OVERRIDE_NAME_RET_CASE(BoolVal, 'B',SWGImplementationName)
    }
    return SWGImplementationName;
}

void overrideMethod(Class cls, NSString *selName, JSValue *jsMethod){
    SEL selector = NSSelectorFromString(selName);
    NSString *clsName = NSStringFromClass(cls);
    NSMethodSignature *methodSignature = [cls instanceMethodSignatureForSelector:selector];
    Method method = class_getInstanceMethod(cls, selector);
    char *typeDesc = (char *)method_getTypeEncoding(method);
//    IMP orgImp = class_respondsToSelector(cls, selector);
    class_replaceMethod(cls, selector, class_getMethodImplementation(cls, @selector(__JPSImplementSelector)), typeDesc);
    IMP forwadImp = class_replaceMethod(cls, @selector(forwardInvocation:), (IMP)(SWGForwardInvocation), @"v@:@");
    NSString *swgSelName = SWG_FORT_STRING(SWGNeedlePrefixName, selName);
    SEL swgSel = NSSelectorFromString(swgSelName);
    SWG_SET_METHOD_DICT(SWGMethods,swgSelName,jsMethod);
    SWGMethods[clsName] = jsMethod;
    class_addMethod(cls, swgSel, SWGIMPName(methodSignature), typeDesc);
}

static void SWGForwardInvocation(id slf,SEL sel,NSInvocation *invocation){
    NSMethodSignature *methodSignature = [invocation methodSignature];
    NSInteger numberOfArguments = [methodSignature numberOfArguments];
    NSString *selectorName = NSStringFromSelector(invocation.selector);
    SEL jsSelector = NSSelectorFromString(SWG_FORT_STRING(SWGNeedlePrefixName, selectorName));
    
    NSMutableArray *argList = exTractArgList(invocation, methodSignature);
    
    SWG_SAVE_FORT_INVCTN_ARGS(SWGInvocationArgs,argList)
    [invocation setSelector:jsSelector];
    [invocation invoke];
    SWG_CLEAR_INVCTN_ARGS(SWGInvocationArgs)
}

static NSMutableArray * exTractArgList(NSInvocation *invocation,NSMethodSignature *methodSignature){
    NSInteger numberOfArguments = [methodSignature numberOfArguments];
    NSMutableArray *argList = [[NSMutableArray alloc] init];
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

//
//  SWGProxy.h
//  HotFixDemo
//
//  Created by gaowenjie3 on 2020/12/10.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
NS_ASSUME_NONNULL_BEGIN

@interface SWGProxy : NSProxy

FOUNDATION_EXPORT void overrideMethod(Class cls, NSString *selName, JSValue *jsMethod);

@end

NS_ASSUME_NONNULL_END

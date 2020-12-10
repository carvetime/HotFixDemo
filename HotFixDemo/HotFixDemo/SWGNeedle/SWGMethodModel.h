//
//  SWGMethodModel.h
//  HotFixDemo
//
//  Created by gaowenjie3 on 2020/12/10.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
NS_ASSUME_NONNULL_BEGIN

@interface SWGMethodModel : NSObject

@property (nonatomic, copy) NSString *clsName;
@property (nonatomic, strong) JSValue *jsValue;

@end

NS_ASSUME_NONNULL_END

//
//  SWGUtil.h
//  HotFixDemo
//
//  Created by gaowenjie3 on 2020/12/10.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SWGUtil : NSObject


FOUNDATION_EXPORT id formatOCObj(id obj);

FOUNDATION_EXPORT CGRect dictToRect(NSDictionary *dict);

FOUNDATION_EXPORT CGPoint dictToPoint(NSDictionary *dict);

FOUNDATION_EXPORT CGSize dictToSize(NSDictionary *dict);

FOUNDATION_EXPORT NSRange dictToRange(NSDictionary *dict);

FOUNDATION_EXPORT NSDictionary *toJSObj(id obj);

FOUNDATION_EXPORT NSDictionary *rectToDictionary(CGRect rect);

FOUNDATION_EXPORT NSDictionary *pointToDictionary(CGPoint point);

FOUNDATION_EXPORT NSDictionary *sizeToDictionary(CGSize size);

FOUNDATION_EXPORT NSDictionary *rangeToDictionary(NSRange range);

@end

NS_ASSUME_NONNULL_END

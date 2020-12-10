//
//  SWGCompatibilityMacros.h
//  HotFixDemo
//
//  Created by gaowenjie3 on 2020/12/10.
//

#ifndef SWGCompatibilityMacros_h
#define SWGCompatibilityMacros_h


#define SWG_FORT_STRING(_preStr,_sufStr) [NSString stringWithFormat:@"%@%@",_preStr,_sufStr]

#define SWG_LAZY_INIT_DICT(dict) if (!dict) dict = @{}.mutableCopy;

#define SWG_ARG_STRUCT(_type, typeString, _transFunc) \
if ([typeString rangeOfString:@#_type].location != NSNotFound) {    \
    _type value = _transFunc(argValue);   \
    [invocation setArgument:&value atIndex:i];  \
    break;  \
}

#define SWG_ARG_CASE(_typeSymbol,_type,_value,_valueTpe) \
case _typeSymbol:{   \
    _type value = [_value _valueTpe]; \
    [invocation setArgument:&value atIndex:i];  \
    break;  \
}

#define SWG_RET_CASE(_typeSymbol, _type, _retValue) \
case _typeSymbol: {                              \
    _type tempResSet; \
    [invocation getReturnValue:&tempResSet];\
    _retValue = @(tempResSet); \
    break; \
}

#define SWG_RET_STRUCT(_type, _transFunc, _typeString) \
if ([typeString rangeOfString:@#_type].location != NSNotFound) {    \
    _type result;   \
    [invocation getReturnValue:&result];    \
    return _transFunc(result);    \
}

#endif /* SWGCompatibilityMacros_h */

//
//  SWGCompatibilityMacros.h
//  HotFixDemo
//
//  Created by gaowenjie3 on 2020/12/10.
//

#ifndef SWGCompatibilityMacros_h
#define SWGCompatibilityMacros_h


#define SWG_FORT_STRING(_preStr,_sufStr) [NSString stringWithFormat:@"%@%@",_preStr,_sufStr]

#define SWG_SET_METHOD_DICT(_dict, _name, _jsValue) \
if (!_dict) _dict = @{}.mutableCopy;  \
if (!_dict[_name]) _dict[_name] = _jsValue

#define SWG_GET_JS_METHOD(_dict,_name) _dict ? _dict[_name] : nil;


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

#define SWG_FWD_ARG_CASE(_typeChar, _type, _argList, _index) \
case _typeChar: {   \
    _type arg;  \
    [invocation getArgument:&arg atIndex:_index];    \
    [_argList addObject:@(arg)]; \
    break;  \
}
#define SWG_FWD_OBJ_ARG_CASE(_argType, _argList, _index)    \
case '@': { \
    void *arg;  \
    [invocation getArgument:&arg atIndex:_index];    \
    static const char *blockType = @encode(typeof(^{}));    \
    if (!strcmp(_argType, blockType)) { \
        [_argList addObject:[(__bridge id)arg copy]];    \
    } else {    \
        [_argList addObject:(__bridge id)arg];   \
    }   \
    break;  \
}

#define SWG_FWD_ARG_STRUCT(_type, typeString, _argList, _index, _transFunc) \
if ([typeString rangeOfString:@#_type].location != NSNotFound) {    \
    _type arg; \
    [invocation getArgument:&arg atIndex:_index];    \
    [_argList addObject:_transFunc(arg)];  \
    break; \
}


#define SWG_SAVE_FORT_INVCTN_ARGS(_invoctnArgs,_argList) _invoctnArgs = formatOCObj(_argList);

#define SWG_CLEAR_INVCTN_ARGS(_invoctnArgs) _invoctnArgs = nil;

#endif /* SWGCompatibilityMacros_h */

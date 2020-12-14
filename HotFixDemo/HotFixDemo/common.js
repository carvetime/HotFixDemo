
var global = this

;(function(){
    
    var _transToArray = function(agrs){
         var arr = [];
         for(var i = 0,len = agrs.length; i < len; i++){
             var obj = agrs[i];
             if (obj && obj["obj"]){
                 arr[i] = obj["obj"]
             } else {
                 arr[i] = obj
             }
         }
        return arr;
     }
    
    var __s = function(){
        var outArgs = arguments;
        var callMethod = function(){
            var ary = _transToArray(arguments);
            var ret = executeSelector(outArgs[2],outArgs[1],outArgs[0],ary)
            if (ret) {
                ret["__s"] = function(fucName){
                    return __s(fucName,ret["cls"],ret["obj"])
                }
                return ret
            }
        }
        return callMethod
    }
    
    var _SWGRequire = function(clsName){
        if (!global[clsName]){
            global[clsName] = {
                isClass: true,
                cls: clsName,
                __s:function(funcName){
                    return __s(funcName,this.cls)
                }
            }
        }
        return global[clsName]
    }
    
    var _SWGHook = function(clsName, methods){
        for (var key in methods){
            var mth = methods[key];
            methods[key] = function(){
                if (arguments.length > 0){
                    var slf = arguments[0];
                    slf["__s"] = function(fucName){
                        return __s(fucName,slf["cls"],slf["obj"])
                    }
                }
               return mth.apply(this,arguments)
            };
        }
        return hookSelector(clsName,methods)
    }
    
    global.SWGRequire = _SWGRequire;
    global.SWGHook = _SWGHook;

})();


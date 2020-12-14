
var global = this

;(function(){
    
    var _transToArray = function(s){
         var arr = [];
         for(var i = 0,len = s.length; i < len; i++){
             var obj = s[i];
             if (obj && obj["obj"]){
                 arr[i] = obj["obj"]
             } else {
                 arr[i] = obj
             }
         }
        return arr;
     }
    
    var __s = function(){
        var agr0 = null;
        var arg1 = null;
        var arg2 = null;
        if (arguments.length > 0) {
            arg0 = arguments[0]// 方法名
        }
        if (arguments.length > 1) {
            arg1 = arguments[1] // 类名
        }
        if (arguments.length > 2) {
            arg2 = arguments[2] // 对象
        }
        var callMethod = function(){
            var ary = _transToArray(arguments);
            var ret = executeSelector(arg2,arg1,arg0,ary)
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




SWGRequire("UIView")
SWGRequire("UIColor")
SWGHook("ViewController",{
    test3$name3$:function(self,arg1,arg2){
        var redView = UIView.__s("alloc")().__s("initWithFrame$")({x:20, y:20, width:100, height:100});
        var redColor = UIColor.__s("redColor")();
        redView.__s("setBackgroundColor$")(redColor)
        self.__s("view")().__s("addSubview$")(redView);
        SWGLog("hook finished!")
    }
})



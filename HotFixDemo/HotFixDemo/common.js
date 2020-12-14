
var global = this

var Methods = {}

;(function(){
    
    var toArray = function(s){
         try{
             return Array.prototype.slice.__s("call")(s);
         } catch(e){
                 var arr = [];
                 for(var i = 0,len = s.length; i < len; i++){
                       arr[i] = s[i];
                 }
                return arr;
         }
     }
    
    var _callOC = function(instance,clsName,funcName,args){
        var ret = executeSelector(instance,clsName,funcName,args)
        return ret
    }
    var _hookOC = function(clsName,funcName){
        return hookSelector(clsName,funcName)
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
            var ary = toArray(arguments);
            var ret = _callOC(arg2,arg1,arg0,ary)
            if (ret) {
                ret["__s"] = function(fucName){
                    return __s(fucName,ret["cls"],ret["obj"])
                }
                return ret
            }
        }
        return callMethod
    }
    
    var SWGRequire = function(clsName){
        if (!global[clsName]){
            global[clsName] = {
                isClass: true,
                cls: clsName,
                __s:function(funcName){
                    log(funcName)
                    return __s(funcName,this.cls)
                }
            }
        }
        return global[clsName]
    }
    
    var SWGHook = function(clsName, methods){
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
        return _hookOC(clsName, methods)
    }
    
    global.SWGRequire = SWGRequire;
    global.SWGHook = SWGHook;

})();









//SWGHook("ViewController",{
//    test2$name2$:function($,arg1,arg2){
////        var name = _callOC($["obj"],"ViewController","haha:",["xiaowang"]);
//        var vAlloc = _callOC(null,"UIView","alloc",null);
//        var view = _callOC(vAlloc["obj"],"UIView","initWithFrame:",[{x:20, y:20, width:100, height:100}])
//        var color = _callOC(null,"UIColor","greenColor",null)
//        _callOC(view["obj"],"UIView","setBackgroundColor:",[color["obj"]]);
//        return view["obj"]
//    }
//})

//SWGHook("ViewController",{
//    test3$name3$:function($,arg1,arg2){
////        var name = _callOC($["obj"],"ViewController","haha:",["xiaowang"]);
//        var vAlloc = _callOC(null,"UIView","alloc",null);
//        var view = _callOC(vAlloc["obj"],"UIView","initWithFrame:",[{x:20, y:20, width:100, height:100}])
//        var color = _callOC(null,"UIColor","redColor",null)
//        _callOC(view["obj"],"UIView","setBackgroundColor:",[color["obj"]]);
//        var superView =  _callOC($["obj"],"ViewController","view",null);
//        _callOC(superView["obj"],"UIView","addSubview:",[view["obj"]]);
//    }
//})



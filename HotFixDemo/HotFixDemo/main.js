
var golbal = this

var Methods = {}

;(function(){
    
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
        var callMethod = function(args){
            log(args)
            var ret = _callOC(arg2,arg1,arg0,args)
            if (ret) {
                ret["__s"] = function(fucName){
                    log(fucName)
                    return __s(fucName,ret["cls"],ret["obj"])
                }
                return ret
            }
        }
        return callMethod
    }
    
    var SWGRequire = function(clsName){
        if (!golbal[clsName]){
            golbal[clsName] = {
                isClass: true,
                cls: clsName,
                __s:function(funcName){
                    return __s(funcName,this.cls)
                }
            }
        }
        return golbal[clsName]
    }
    
    var SWGHook = function(clsName, func, hookFunc){
        _hookOC(clsName, func,hookFunc)
    }
    
    
    SWGRequire("UIView")
    SWGRequire("UIColor")
    SWGHook("ViewController",{
        test3$name3$:function(self,arg1,arg2){
            var redView = UIView.__s("alloc")().__s("initWithFrame$")([{x:20, y:20, width:100, height:100}]);
            var redColor = UIColor.__s("redColor")();
            redView.__s("setBackgroundColor$")([redColor["obj"]]);
//            log(redColor)
//            log(redView);
            
            
//            var vcView = $["obj"].__s("view")();
//            log(vcView)
            var vcView = _callOC(self["obj"],"ViewController","view",null);
            _callOC(vcView["obj"],"UIView","addSubview$",[redView["obj"]]);
            log($)
        }
    })
    
    
})()









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



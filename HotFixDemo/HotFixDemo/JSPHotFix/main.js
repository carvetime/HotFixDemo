
var golbal = this



function _callOC(instance,clsName,funcName,args){
    var ret = executeSelector(instance,clsName,funcName,args)
    return ret
}

function _hookOC(clsName,funcName){
    return hookSelector(clsName,funcName)
}

function SWGRequire(clsName){
    if (!golbal[clsName]){
        golbal[clsName] = {
            isClass: true,
            clsName: clsName
        }
    }
    return golbal[clsName]
}

function SWGHook(clsName, func, hookFunc){
    _hookOC(clsName, func,hookFunc)
}


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

SWGHook("ViewController",{
    test3$name3$:function($,arg1,arg2){
//        var name = _callOC($["obj"],"ViewController","haha:",["xiaowang"]);
        var vAlloc = _callOC(null,"UIView","alloc",null);
        var view = _callOC(vAlloc["obj"],"UIView","initWithFrame:",[{x:20, y:20, width:100, height:100}])
        var color = _callOC(null,"UIColor","redColor",null)
        _callOC(view["obj"],"UIView","setBackgroundColor:",[color["obj"]]);
        var superView =  _callOC($["obj"],"ViewController","view",null);
        _callOC(superView["obj"],"UIView","addSubview:",[view["obj"]]);
    }
})

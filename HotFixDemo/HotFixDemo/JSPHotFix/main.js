
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


SWGHook("ViewController",{
    test2$name2$:function($,arg1,arg2){
        _callOC($["obj"],"ViewController","haha:",["xiaowang"])
    }
})

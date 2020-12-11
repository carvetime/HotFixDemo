
var golbal = this



function _callOC(clsName,funcName){
    var list = []
    list.push("js args")
    var ret = executeSelector(clsName,funcName,list)
    return ret
}

function _hookOC(clsName,funcName,hookFunc){
    return hookSelector(clsName,funcName,hookFunc)
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

function SWGHook(clsName, funcName, hookFunc){
    _hookOC(clsName, funcName, hookFunc)
}

SWGRequire("UIView")
SWGRequire("NSLog")
SWGHook("ViewController",{
    test1_name2_:function(arg1,arg2){
        var ary = ["a","b", "c"];
        log(ary[1])
}})


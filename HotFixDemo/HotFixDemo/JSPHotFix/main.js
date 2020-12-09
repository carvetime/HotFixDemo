
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

function JSPRequire(clsName){
    if (!golbal[clsName]){
        golbal[clsName] = {
            isClass: true,
            clsName: clsName
        }
    }
    return golbal[clsName]
}

function JSPHook(clsName, funcName, hookFunc){
    _hookOC(clsName, funcName, hookFunc)
}

JSPRequire("UIView")
JSPHook("ViewController",{"test": function(){
    log("444444444");
}})

    
//log(_callOC("ViewController","test0"))
//log(_callOC("UIView","alloc"))


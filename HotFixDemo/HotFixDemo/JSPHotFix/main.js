
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

//SWGRequire("UIView")
//SWGHook("ViewController",{
//    _test2_$_name3$:function(arg1,arg2){
//        log(arg1)
//    },
//    $_test1_$_name2$:function(arg1,arg2){
//        log(arg1)
//        return arg1
//    },
//})


SWGHook("ViewController",{
    test2$name2$:function(arg1,arg2){
            log(arg1)
        }
})

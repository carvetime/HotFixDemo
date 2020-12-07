
var golbal = this

var jspClassMap = {}

function JSPRequire(clsName){
    global.__defineGetter__(clsName,function(){
        return JSPRequire(clsName)
    })
    if (!jspClassMap[clsName]){
        jspClassMap[clsName] = {
            isClass: true,
            clsName: clsName
        }
    }
    return jspClassMap[clsName]
}

function _callOC(clsName,func){
    var ret = callOC(clsName,func)
    return ret
}

JSPRequire("UIView")
console.log(UIView)


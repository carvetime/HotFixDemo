
var golbal = this

function hook(cls,ocFuc,jsFuc){
    var fucNew = ocFuc.replace(/:/g,"")
    log("wenjie:" + fucNew)
    golbal[fucNew] = jsFuc
    calloc(cls,ocFuc)
}

function callOC(clsName,fucName,args){
    return calloc(className,fucName,args)
}

function requireOC(cls){
    return {"className"; cls};
}

requireOC("UIView")
;(function(){
    hook("ViewController","test1:name2:",function(name1,name2){
        log("js =========  test2==================:" + name1 + name2)
        var view = UIView.alloc().init()
        
    })
})()

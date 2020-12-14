

SWGRequire("UIView")
SWGRequire("UIColor")
SWGHook("ViewController",{
    test3$name3$:function(self,arg1,arg2){
        log("=========")
        var redView = UIView.alloc().initWithFrame$({x:20, y:20, width:100, height:100});
        var redColor = UIColor.redColor();
        redView.setBackgroundColor$(redColor["obj"])
        var vcView = self.view();
        log(vcView)
        vcView.addSubview$(redView["obj"]);
        
//        vcView["obj"].addSubview$(redColor["obj"])
    }
})



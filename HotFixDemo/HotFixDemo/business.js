

SWGRequire("UIView")
SWGRequire("UIColor")
SWGHook("ViewController",{
    test3$name3$:function(self,arg1,arg2){
        var redView = UIView.alloc().initWithFrame$({x:20, y:20, width:100, height:100});
        var redColor = UIColor.redColor();
        redView.setBackgroundColor$(redColor)
        self.view().addSubview$(redView);
        SWGLog("hook finished!")
    }
})



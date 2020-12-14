

SWGRequire("UITextView")
SWGRequire("UIColor")
SWGHook("ViewController",{
    test1$test2$:function(self,arg1,arg2){
        var redView = UITextView.alloc().initWithFrame$({x:20, y:20, width:300, height:500});
        var redColor = UIColor.redColor();
        redView.setBackgroundColor$(redColor)
        redView.setText$( "arg1:" + arg1 + "\n" + "arg2:" + arg2);
        self.view().addSubview$(redView);
        SWGLog("hook finished!")
    }
})



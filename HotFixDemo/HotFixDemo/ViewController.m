//
//  ViewController.m
//  HotFixDemo
//
//  Created by gaowenjie3 on 2020/12/1.
//

#import "ViewController.h"
#import "SWGNeedle.h"

@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [SWGNeedle prepare];
    // Do any additional setup after loading the view.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
//    NSString *test =  [self _test1_:@"has ret" _name2:@"xiaoming"];
//    NSLog(@"%@",test);
//    UIView *view = [self test2:@"no ret" name2:@"xiaoming"];
//    [self.view addSubview:view];
    [self test3:@"add subviwe" name3:@"green"];
}


- (UIView *)test2:(NSString *)name name2:(NSString *)name2{
    NSMutableArray *ary1 = @[].mutableCopy;
    ary1[0] = @"a";
    ary1[1] = @"b";
    NSLog(@"%@",ary1[2]);
    UIView *view;
    return nil;
}

- (void)test3:(NSString *)name name3:(NSString *)name2{
    NSMutableArray *ary1 = @[].mutableCopy;
    ary1[0] = @"a";
    ary1[1] = @"b";
    NSLog(@"%@",ary1[2]);
}



- (NSString *)_test1_:(NSString *)name _name2:(NSString *)name2{
    NSMutableArray *ary1 = @[].mutableCopy;
    ary1[0] = @"a";
    ary1[1] = @"b";
    return ary1[2];
}


- (NSString *)haha:(NSString *)name{
    NSLog(@"haha %@",name);
    return name;
}

@end

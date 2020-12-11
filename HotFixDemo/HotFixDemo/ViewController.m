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
    [self test1:@"nihao" name2:@"xiaoming"];
}



- (void)test1:(NSString *)name name2:(NSString *)name2{
    NSMutableArray *ary1 = @[].mutableCopy;
    ary1[0] = @"a";
    ary1[1] = @"b";
    NSLog(@" ary1[2] = %@",ary1[2]);
}

@end

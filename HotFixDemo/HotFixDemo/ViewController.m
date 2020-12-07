//
//  ViewController.m
//  HotFixDemo
//
//  Created by gaowenjie3 on 2020/12/1.
//

#import "ViewController.h"
#import "JSPCore.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [JSPCore start];
    // Do any additional setup after loading the view.
    dispatch_after(1, dispatch_get_main_queue(), ^{
        [self test0];
    });
    
    dispatch_after(2, dispatch_get_main_queue(), ^{
        [self performSelector:@selector(test1:) withObject:@"888888"];
    });
    
    dispatch_after(3, dispatch_get_main_queue(), ^{
        [self performSelector:@selector(test1:name2:) withObject:@"888888" withObject:@"999999"];
    });
}

- (void)test0{
    NSLog(@"test-=========");
}

- (void)test1:(NSString *)name{
    NSLog(@"test-=========%@",name);
}

- (void)test1:(NSString *)name name2:(NSString *)name2{
    NSLog(@"test333-=========%@",name);
}

@end

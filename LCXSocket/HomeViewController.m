//
//  HomeViewController.m
//  LCXSocket
//
//  Created by lcx on 2019/11/22.
//  Copyright © 2019 lcx. All rights reserved.
//

#import "HomeViewController.h"
#import "ClientViewController.h"
#import "ServerViewController.h"
@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)clientAction:(id)sender {
    [self.navigationController pushViewController:[ClientViewController new] animated:YES];
}

- (IBAction)serverAction:(id)sender {
    [self.navigationController pushViewController:[ServerViewController new] animated:YES];

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

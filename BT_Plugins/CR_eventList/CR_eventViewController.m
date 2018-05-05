//
//  CR_eventViewController.m
//  EQYOOTHTSAKYIIEIGHES
//
//  Created by Christopher Ruddell on 8/4/14.
//  Copyright (c) 2014 Buzztouch. All rights reserved.
//

#import "CR_eventViewController.h"

@interface CR_eventViewController ()

@end

@implementation CR_eventViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UITextField *tmpField = [UITextField new];
    [self.view addSubview:tmpField];
    [tmpField becomeFirstResponder];
    [tmpField resignFirstResponder];
    [tmpField removeFromSuperview];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UITextField *tmpField = [UITextField new];
    [self.view addSubview:tmpField];
    [tmpField becomeFirstResponder];
    [tmpField resignFirstResponder];
    [tmpField removeFromSuperview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

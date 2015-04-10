//
//  LoginViewController.m
//  YouTube Direct Lite for iOS
//
//  Created by imybags.com on 9/4/15.
//  Copyright (c) 2015 Google. All rights reserved.
//

#import "LoginViewController.h"
#import "CategoriesTableViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //chuyển qua Controller khác
    [self performSegueWithIdentifier:@"CategoriesTable" sender:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"CategoriesTable"]) {
        
        // Get destination view
         //CategoriesTableViewController *vc = [segue destinationViewController];
        
        // Get button tag number (or do whatever you need to do here, based on your object
        //NSInteger tagIndex = [(UIButton *)sender tag];
        
        // Pass the information to your destination view
        //[vc setSelectedButton:tagIndex];
    }
}


@end

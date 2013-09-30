//
//  ViewController.m
//  Demo
//
//  Created by Alejandro Paredes Alva on 2/11/13.
//  Copyright (c) 2013 Alejandro Paredes Alva. All rights reserved.
//

#import "ViewController.h"
#import "GIDACalculateTextField.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UIButton *solveButton;
@property (strong, nonatomic) GIDACalculateTextField *textField;
@property (strong, nonatomic) IBOutlet UILabel *solutionLabel;
-(IBAction)solver:(id)sender;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _textField = [[GIDACalculateTextField alloc] initWithFrame:CGRectMake(20, 30, 280, 30)];
    [self.view addSubview:_textField];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)solver:(id)sender {
    NSNumber *solved = [GIDACalculateString solveString:[_textField text]];
    if (solved) {
        [_solutionLabel setText:[solved stringValue]];
    } else {
        [_solutionLabel setText:@"Incorrect operation"];
    }
    NSLog(@"Solution: %@", [solved stringValue]);
}
@end

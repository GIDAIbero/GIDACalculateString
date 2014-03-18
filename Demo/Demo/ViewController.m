//
//  ViewController.m
//  Demo
//
//  Created by Alejandro Paredes Alva on 2/11/13.
//  Copyright (c) 2013 Alejandro Paredes Alva. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UIButton *solveButton;
@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) IBOutlet UILabel *solutionLabel;
-(IBAction)solver:(id)sender;
@end

@implementation ViewController
@synthesize textField = _textField;
@synthesize solutionLabel = _solutionLabel;
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Attributes for textfields that are not the solution column
    _textField.borderStyle=UITextBorderStyleRoundedRect;
    _textField.adjustsFontSizeToFitWidth=YES;
    _textField.font=[UIFont fontWithName:@"CourierNewPS-BoldMT" size:20];
    _textField.textColor=[UIColor blackColor];
    _textField.keyboardType=UIKeyboardTypeDecimalPad;
    
    //Attributes for textfields that are not the solution column
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *plus  = [[UIBarButtonItem alloc] initWithTitle:@"+" style:UIBarButtonItemStylePlain target:self action:@selector(option:)];
    UIBarButtonItem *minus  = [[UIBarButtonItem alloc] initWithTitle:@"-" style:UIBarButtonItemStylePlain target:self action:@selector(option:)];
    UIBarButtonItem *times  = [[UIBarButtonItem alloc] initWithTitle:@"*" style:UIBarButtonItemStylePlain target:self action:@selector(option:)];
    UIBarButtonItem *fraction  = [[UIBarButtonItem alloc] initWithTitle:@"/" style:UIBarButtonItemStylePlain target:self action:@selector(option:)];
    UIBarButtonItem *openPar  = [[UIBarButtonItem alloc] initWithTitle:@"(" style:UIBarButtonItemStylePlain target:self action:@selector(option:)];
    UIBarButtonItem *closePar  = [[UIBarButtonItem alloc] initWithTitle:@")" style:UIBarButtonItemStylePlain target:self action:@selector(option:)];
    UIBarButtonItem *betweenArrowsSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [betweenArrowsSpace setWidth:18];
    UIBarButtonItem *betweenSignAndArrowSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [betweenSignAndArrowSpace setWidth:25];
    
    UIToolbar *kbtb = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 30)];
    [kbtb setBarStyle:UIBarStyleBlackTranslucent];
    [kbtb setItems:[NSArray arrayWithObjects: space, plus, space, minus, space, times, space, fraction, space, openPar, space, closePar, space, nil]];
    
    
    
    _textField.inputAccessoryView = kbtb;
    _textField.keyboardAppearance = UIKeyboardAppearanceAlert;
    _textField.returnKeyType      = UIReturnKeyNext;
    _textField.delegate           = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)option:(id)sender {
    UITextRange *selectedRange = [_textField selectedTextRange];
    int pos = [_textField offsetFromPosition:_textField.endOfDocument toPosition:selectedRange.start];
    int length = [[_textField text] length];
    NSRange range = NSMakeRange(length+pos, 0);
    
    if ([GIDACalculateString usingThis:[_textField text] addThis:[sender title] here:range])
        [_textField setText:[GIDACalculateString stringFrom:[_textField text] withThis:[sender title] here:range]];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return [GIDACalculateString usingThis:[textField text] addThis:string here:range];
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

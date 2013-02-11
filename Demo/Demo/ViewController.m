//
//  ViewController.m
//  Demo
//
//  Created by Alejandro Paredes Alva on 2/11/13.
//  Copyright (c) 2013 Alejandro Paredes Alva. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (retain, nonatomic) IBOutlet UITextField *textField;

@end

@implementation ViewController
@synthesize textField = _textField;
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
    
    UIToolbar *kbtb = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 30)] autorelease];
    [kbtb setBarStyle:UIBarStyleBlackTranslucent];
    [kbtb setItems:[NSArray arrayWithObjects: space, plus, space, minus, space, times, space, fraction, space, nil]];
    
    [space release];
    [plus release];
    [openPar release];
    [closePar release];
    
    [betweenArrowsSpace release];
    [betweenSignAndArrowSpace release];
    
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
    
    if ([GIDACalculateString usingThis:[_textField text] canIAddThis:[sender title] aroundThis:range])
        [_textField setText:[GIDACalculateString makeStringFrom:[_textField text] withThis:[sender title] aroundThis:range]];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return [GIDACalculateString usingThis:[textField text] canIAddThis:string aroundThis:range];
}

- (void)dealloc {
    [_textField release];
    [super dealloc];
}
@end

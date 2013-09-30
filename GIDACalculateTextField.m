//
//  GIDACalculateTextField.m
//  Demo
//
//  Created by Alejandro Paredes Alva on 9/25/13.
//  Copyright (c) 2013 Alejandro Paredes Alva. All rights reserved.
//

#import "GIDACalculateTextField.h"
#import "GIDACalculateString.h"

@interface GIDACalculateTextField ()
@property (nonatomic, strong) UIToolbar *kbtb;
@end

@implementation GIDACalculateTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self initialize];
    }
    return self;
}

-(id)init {
    if (self = [super init]) {
        [self initialize];
    }
    return  self;
}

-(void)initialize {
    //Attributes for textfields that are not the solution column
    self.borderStyle=UITextBorderStyleRoundedRect;
    self.adjustsFontSizeToFitWidth = YES;
    [self setFont:[UIFont systemFontOfSize:20]];
    [self setTextColor:[UIColor blackColor]];
    self.keyboardType=UIKeyboardTypeDecimalPad;
    
    //Attributes for textfields that are not the solution column
    UIBarButtonItem *space     = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *plus      = [[UIBarButtonItem alloc] initWithTitle:@"+" style:UIBarButtonItemStylePlain target:self action:@selector(option:)];
    UIBarButtonItem *minus     = [[UIBarButtonItem alloc] initWithTitle:@"-" style:UIBarButtonItemStylePlain target:self action:@selector(option:)];
    UIBarButtonItem *times     = [[UIBarButtonItem alloc] initWithTitle:@"*" style:UIBarButtonItemStylePlain target:self action:@selector(option:)];
    UIBarButtonItem *fraction  = [[UIBarButtonItem alloc] initWithTitle:@"/" style:UIBarButtonItemStylePlain target:self action:@selector(option:)];
    UIBarButtonItem *root      = [[UIBarButtonItem alloc] initWithTitle:@"√" style:UIBarButtonItemStylePlain target:self action:@selector(option:)];
    UIBarButtonItem *imaginary = [[UIBarButtonItem alloc] initWithTitle:@"i" style:UIBarButtonItemStylePlain target:self action:@selector(option:)];
    UIBarButtonItem *openPar   = [[UIBarButtonItem alloc] initWithTitle:@"(" style:UIBarButtonItemStylePlain target:self action:@selector(option:)];
    UIBarButtonItem *closePar  = [[UIBarButtonItem alloc] initWithTitle:@")" style:UIBarButtonItemStylePlain target:self action:@selector(option:)];
    UIBarButtonItem *betweenArrowsSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    [betweenArrowsSpace setWidth:18];
    UIBarButtonItem *betweenSignAndArrowSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [betweenSignAndArrowSpace setWidth:25];
    
    _kbtb = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    [_kbtb setBarStyle:UIBarStyleBlackTranslucent];
    [_kbtb setItems:[NSArray arrayWithObjects: space, plus, space, minus, space, times, space, fraction, space, root, space, imaginary, space, openPar, space, closePar, space, nil]];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >=7.0) {
        [_kbtb setTintColor:[UIColor whiteColor]];
    }
    
    self.inputAccessoryView = _kbtb;
    self.keyboardAppearance = UIKeyboardAppearanceAlert;
    self.returnKeyType      = UIReturnKeyNext;
    self.delegate           = self;
}

-(void)option:(id)sender {
    UITextRange *selectedRange = [self selectedTextRange];
    int pos = [self offsetFromPosition:self.endOfDocument toPosition:selectedRange.start];
    int length = [[self text] length];
    NSRange range = NSMakeRange(length+pos, 0);
    
    if ([GIDACalculateString usingThis:[self text] addThis:[sender title] here:range])
        [self setText:[GIDACalculateString stringFrom:[self text] withThis:[sender title] here:range]];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return [GIDACalculateString usingThis:[textField text] addThis:string here:range];
}

@end

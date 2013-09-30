//
//  GIDACalculateString.m
//  Demo
//
//  Created by Alejandro Paredes Alva on 2/11/13.
//  Copyright (c) 2013 Alejandro Paredes Alva. All rights reserved.
//

#import "GIDACalculateString.h"
#import <Accelerate/Accelerate.h>

enum {
    GIDAOperatorNone,
    GIDAOperatorOpenParentheses,
    GIDAOperatorCloseParentheses,
    GIDAOperatorFraction,
    GIDAOperatorTimes,
    GIDAOperatorPlus,
    GIDAOperatorMinus,
    GIDAOperatorRoot
};
typedef NSUInteger GIDAOperator;

@interface ComplexObject ()
@property (nonatomic) double radius;
@property (nonatomic) double angle;
@end

@implementation ComplexObject

-(id)initWithReal:(double)r andImaginary:(double)i {
    self = [super init];
    if (self) {
        _real      = r;
        _imaginary = i;
        _radius    = sqrt(pow(r,2)+pow(i,2));
        if (_real != 0) {
            if (_imaginary == 0) {
                _angle = 0;
            } else {
                _angle = asin(i/_radius);
            }
        } else {
            if (_imaginary != 0) {
                _angle = 90.0;
            } else {
                _angle = 0.0;
            }
        }
        
    }
    return self;
}
-(void)setReal:(double)real {
    _real      = real;
    _radius    = sqrt(pow(_real,2)+pow(_imaginary,2));
    if (_real != 0) {
        if (_imaginary == 0) {
            _angle = 0;
        } else {
            _angle = asin(_imaginary/_radius);
        }
    } else {
        if (_imaginary != 0) {
            _angle = 90.0;
        } else {
            _angle = 0.0;
        }
    }
}
-(void)setImaginary:(double)imaginary {
    _imaginary      = imaginary;
    _radius    = sqrt(pow(_real,2)+pow(_imaginary,2));
    if (_real != 0) {
        if (_imaginary == 0) {
            _angle = 0;
        } else {
            _angle = asin(_imaginary/_radius);
        }
    } else {
        if (_imaginary != 0) {
            _angle = 90.0;
        } else {
            _angle = 0.0;
        }
    }
}
-(void)squareRoot {
    if (_real < 0) {
        _angle = 90.0;
    } else {
        _angle = _angle / 2.0;
    }
    
    _radius = sqrt(_radius);
    double rad = _angle * M_PI / 180.0;
    _real      = _radius * cos(rad);
    if (_angle == 90.0) {
        _real = 0;
    }
    
    _imaginary = _radius * sin(rad);
    if (_imaginary == 0 || _imaginary == -0) {
        _imaginary = 0;
    }
    NSLog(@"%f",_angle);
}
-(NSString *)stringValue{
    if ((_real > 0 || _real < -0) && _imaginary != 0 ) {
        return [NSString stringWithFormat:@"%f+%fi",self.real, self.imaginary];
    }
    if (_real == 0 && _imaginary != 0) {
        return [NSString stringWithFormat:@"%fi", self.imaginary];
    }
    if (_real != 0 && _imaginary == 0) {
        return [NSString stringWithFormat:@"%f", self.real];
    }
    return @"0";
}

@end

@interface GIDACalculateString ()
+(BOOL)checkFor:(char)character inThis:(NSString *)string fromThis:(int)position whereThisAre:(NSCharacterSet *)notAllowed andThisHelps:(NSCharacterSet *)toStop;
+(BOOL)checkThis:(NSString *)string atThis:(int)position ifLeftDoesNotHave:(NSCharacterSet *)leftCheck norRightHas:(NSCharacterSet *)rightCheck allowFirst:(BOOL)first;
+(int)openParenthesesFor:(NSString *)string toLocation:(int)position;
+(NSString *)fixString:(NSString *)string;

@end

@implementation GIDACalculateString

//String appending newString to String.
+(NSString *)stringFrom:(NSString *)string withThis:(NSString *)newString {
    return [string stringByAppendingString:newString];
}

//String by cutting at the range location and putting the newString in between.
+(NSString *)stringFrom:(NSString *)string withThis:(NSString *)newString here:(NSRange)range {
    NSString *fullString = nil;
    if ([self usingThis:string addThis:newString here:range]) {
        NSString *preString = [string substringToIndex:range.location];
        NSString *postString = [string substringFromIndex:range.location];
        fullString = [[preString stringByAppendingString:newString] stringByAppendingString:postString];
    } else {
        fullString = string;
    }
    return fullString;
}

//Check if the character at position and its left is not included in a list of characters. Each side has special characters not allowed.
+(BOOL)checkThis:(NSString *)string atThis:(int)position ifLeftDoesNotHave:(NSCharacterSet *)leftCheck norRightHas:(NSCharacterSet *)rightCheck allowFirst:(BOOL)first{
    BOOL success = YES;
    
    //Do a check to the left character.
    if (position!= 0) {
        if ([leftCheck characterIsMember:[string characterAtIndex:position-1]])
            success = NO;
    } else {
        //If the position is 0 and it is not allowed to be the first character, then say it can't be placed there.
        if (!first) {
            success = NO;
        }
    }
    
    //Do a check to the right of there the character will be. (its the position)
    if (position < [string length]) {
        if ([rightCheck characterIsMember:[string characterAtIndex:position]]) {
            success = NO;
        }
    }
    
    return success;
}

//Go from position to left and right to check if there is a character not allowed. Can use extra characters to stop search.
+(BOOL)checkFor:(char)character inThis:(NSString *)string fromThis:(int)position whereThisAre:(NSCharacterSet *)notAllowed andThisHelps:(NSCharacterSet *)toStop {
    BOOL success = YES;
    
    //Check from the begining until: the position, found a character that helps the stop or found a not allowed character.
    for (int i = position; i >= 0; i--) {
        if ([notAllowed characterIsMember:[string characterAtIndex:i]]) {
            success = NO;
            i = -1;
        } else {
            if ([toStop characterIsMember:[string characterAtIndex:i]]) {
                i = -1;
            }
        }
    }
    
    //Check to the right until: the end, found a character that helps the stop or found a not allowed character.
    for (int i = position; i < [string length]; i++) {
        if ([notAllowed characterIsMember:[string characterAtIndex:i]]) {
            success = NO;
            i = [string length];
        } else {
            if ([toStop characterIsMember:[string characterAtIndex:i]]) {
                i = [string length];
            }
        }
    }
    
    return success;
}

//Check if the string contains parentheses. Split the string with '('.
//If more than 1 object at array that means there is at least 1 parenthesis.
+(BOOL)hasParentheses:(NSString *)string {
    NSArray *array = [string componentsSeparatedByString:@"("];
    if ([array count] > 1) {
        return YES;
    }
    return NO;
}

//How many parentheses are left open from begining of string to position.
+(int)openParenthesesFor:(NSString *)string toLocation:(int)position {
    int open = 0;
    int close = 0;
    
    for (int i = 0; i < position; i++) {
        switch ([string characterAtIndex:i]) {
            case '(':
                open++;
                break;
            case ')':
                close++;
                break;
        }
    }
    
    return open - close;
}

//call the same function but with the position at the end. Use this if it is always at the end.
//If not use the same but with aroundThis:range.
+(BOOL)usingThis:(NSString *)string addThis:(NSString *)newString {
    return [self usingThis:string addThis:newString here:(NSMakeRange(0, [string length]))];
}

//Check if the newString is a valid string or character to add to the string in the range position.
+(BOOL)usingThis:(NSString *)string addThis:(NSString *)newString here:(NSRange)range {
    BOOL success = YES;
    
    //if newString is empty then it means it wants to delete.
    //As default all deletions are allowed.
    if ([newString length] == 0) {
        return YES;
    }
    
    //Selecting several characters to delete and insert new character at position.
    //Cut string, remove the middle part and put together the sides.
    if (range.length > 0) {
        NSString *preString = [string substringToIndex:range.location];
        NSString *postString = [string substringFromIndex:range.location+range.length];
        string = [preString stringByAppendingString:postString];
    }
    
    //If the newString has more than one character.
    //Go through each character checking if it is allowed in the string.
    //If the character is allowed it is appended to the string to continue checking the next character.
    if ([newString length] > 1) {
        range.length = 0;
        for (int i = 0; i < [newString length]; i++) {
            if ([self usingThis:string addThis:[NSString stringWithFormat:@"%c",[newString characterAtIndex:i]] here:range]) {
                string = [string stringByAppendingFormat:@"%c",[newString characterAtIndex:i]];
                range.location ++;
            } else {
                success = NO;
                i = [newString length];
            }
        }
    } else {
        //newString is of 1 character.
        
        //If its the first character to input, check if it is an allowed character.
        //Allowed characters as first character of input are '.', '-', '(' and numbers from 0 to 9.
        if ([string length] == 0 || range.location == 0) {
            if ([newString characterAtIndex:0] == '.' || [newString characterAtIndex:0] == '-'  || [newString characterAtIndex:0] == '(' || ([newString characterAtIndex:0] >= '0' && [newString characterAtIndex:0] <= '9')) {
                success = YES;
            } else {
                success = NO;
            }
        } else {
            NSCharacterSet *notAllowed;
            NSCharacterSet *toStop;
            NSCharacterSet *left;
            NSCharacterSet *right;
            
            //Depending on the character to add differend operations are handled.
            switch ([newString characterAtIndex:0]) {
                case '.':
                    //The user is not allowed to put only ONE '.' in a series of numbers in between operators.
                    notAllowed = [NSCharacterSet characterSetWithCharactersInString:@"."];
                    toStop = [NSCharacterSet characterSetWithCharactersInString:@"()/+-*"];
                    success = [self checkFor:'.' inThis:string fromThis:range.location-1 whereThisAre:notAllowed andThisHelps:toStop];
                    break;
                case '+':
                    //The user is not allowed to put a '+' sign when on the left there is a  '(', '+', '-', '*', or '/'.
                    //To the right of a '+' sign there can not be a ')', '+', '-', '*', or '/'.
                    left = [NSCharacterSet characterSetWithCharactersInString:@"(+-*/"];
                    right = [NSCharacterSet characterSetWithCharactersInString:@"+-*/)"];
                    success = [self checkThis:string atThis:range.location ifLeftDoesNotHave:left norRightHas:right allowFirst:NO];
                    break;
                case '-':
                    //The user is not allowed to put a '-' sign when on the left there is a '-'.
                    //To the right of a '-' sign there can not be a ')', '+', '-', '*', or '/'.
                    left = [NSCharacterSet characterSetWithCharactersInString:@"-"];
                    right = [NSCharacterSet characterSetWithCharactersInString:@"+-*/)"];
                    success = [self checkThis:string atThis:range.location ifLeftDoesNotHave:left norRightHas:right allowFirst:YES];
                    break;
                case '*':
                    //The user is not allowed to put a '*' sign when on the left there is a  '(', '+', '-', '*', or '/'.
                    //To the right of a '*' sign there can not be a ')', '+', '-', '*', or '/'.
                    left = [NSCharacterSet characterSetWithCharactersInString:@"(+-*/"];
                    right = [NSCharacterSet characterSetWithCharactersInString:@"+-*/)"];
                    success = [self checkThis:string atThis:range.location ifLeftDoesNotHave:left norRightHas:right allowFirst:NO];
                    break;
                case '/':
                    //The user is not allowed to put a '/' sign when on the left there is a  '(', '+', '-', '*', or '/'.
                    //To the right of a '/' sign there can not be a ')', '+', '-', '*', or '/'.
                    left = [NSCharacterSet characterSetWithCharactersInString:@"(+-*/"];
                    right = [NSCharacterSet characterSetWithCharactersInString:@"+*/)"];
                    success = [self checkThis:string atThis:range.location ifLeftDoesNotHave:left norRightHas:right allowFirst:NO];
                    break;
                case '(':
                    //To put a '(', there can not be a ')', '+', '-', '*', or '/' to the right.
                    //There is no limitation to the left. '(' can go after any character
                    left = [NSCharacterSet characterSetWithCharactersInString:@""];
                    right = [NSCharacterSet characterSetWithCharactersInString:@"+*/)"];
                    success = [self checkThis:string atThis:range.location ifLeftDoesNotHave:left norRightHas:right allowFirst:NO];
                    break;
                case ')':
                    //To put a ')', there can not be a ')', '+', '-', '*', or '/' to the left.
                    //There is no limitation to the right. ')' can go before any character.
                    //Except if there is no open parentheses from the begining of the string to its position.
                    left = [NSCharacterSet characterSetWithCharactersInString:@"(+-*/"];
                    right = [NSCharacterSet characterSetWithCharactersInString:@""];
                    success = [self checkThis:string atThis:range.location ifLeftDoesNotHave:left norRightHas:right allowFirst:NO];
                    if (success) {
                        if ([self openParenthesesFor:string toLocation:range.location] <= 0) {
                            success = NO;
                        }
                    }
                    break;
                default:
                    //Numbers can go anywhere.
                    success = YES;
                    break;
            }
        }
    }
    return success;
}

//Fix the string in case the string presents operation simplifications.
//First replace with keywords so that no error is done when replacing.
//Replace keywords with correct syntax.
+(NSString *)fixString:(NSString *)string {
    NSMutableString *mutable = [NSMutableString stringWithString:string];
    
    //---THIS COULD BE OPTIMIZED?? ---//
    [mutable replaceOccurrencesOfString:@")(" withString:@"CO"   options:NSLiteralSearch range:NSMakeRange(0, [string length])];
    [mutable replaceOccurrencesOfString:@"--" withString:@"MM"   options:NSLiteralSearch range:NSMakeRange(0, [string length])];
    [mutable replaceOccurrencesOfString:@"-(" withString:@"BM"   options:NSLiteralSearch range:NSMakeRange(0, [string length])];
    [mutable replaceOccurrencesOfString:@")-" withString:@"CM"   options:NSLiteralSearch range:NSMakeRange(0, [string length])];
    [mutable replaceOccurrencesOfString:@"(-" withString:@"OM"   options:NSLiteralSearch range:NSMakeRange(0, [string length])];
    [mutable replaceOccurrencesOfString:@"*-" withString:@"TM"   options:NSLiteralSearch range:NSMakeRange(0, [string length])];
    [mutable replaceOccurrencesOfString:@"/-" withString:@"FM"   options:NSLiteralSearch range:NSMakeRange(0, [string length])];
    [mutable replaceOccurrencesOfString:@"√-" withString:@"NR"   options:NSLiteralSearch range:NSMakeRange(0, [string length])];
    [mutable replaceOccurrencesOfString:@"+-" withString:@"PM"   options:NSLiteralSearch range:NSMakeRange(0, [string length])];
    
    [mutable replaceOccurrencesOfString:@"-"  withString:@"+-"   options:NSLiteralSearch range:NSMakeRange(0, [string length])];
    
    [mutable replaceOccurrencesOfString:@"NR"  withString:@"√-"  options:NSLiteralSearch range:NSMakeRange(0, [string length])];
    [mutable replaceOccurrencesOfString:@"MM" withString:@"+"    options:NSLiteralSearch range:NSMakeRange(0, [string length])];
    [mutable replaceOccurrencesOfString:@"PM" withString:@"+-"   options:NSLiteralSearch range:NSMakeRange(0, [string length])];
    [mutable replaceOccurrencesOfString:@"FM" withString:@"/-"   options:NSLiteralSearch range:NSMakeRange(0, [string length])];
    [mutable replaceOccurrencesOfString:@"TM" withString:@"*-"   options:NSLiteralSearch range:NSMakeRange(0, [string length])];
    [mutable replaceOccurrencesOfString:@"OM" withString:@"(-"   options:NSLiteralSearch range:NSMakeRange(0, [string length])];
    [mutable replaceOccurrencesOfString:@"CM" withString:@")+-"  options:NSLiteralSearch range:NSMakeRange(0, [string length])];
    [mutable replaceOccurrencesOfString:@"BM" withString:@"-1*(" options:NSLiteralSearch range:NSMakeRange(0, [string length])];
    [mutable replaceOccurrencesOfString:@"CO" withString:@")*("  options:NSLiteralSearch range:NSMakeRange(0, [string length])];
    
    return mutable;
}

+(ComplexObject *)parenthesisAndRegEx:(NSString *)string {
    NSError *error = nil;
    NSRegularExpression *regex = nil;
    
     regex = [NSRegularExpression regularExpressionWithPattern:@"(√)(-*(\\d|[.i])+)"
                                                       options:NSRegularExpressionCaseInsensitive
                                                         error:&error];
     string = [regex stringByReplacingMatchesInString:string
                                              options:0
                                                range:NSMakeRange(0, [string length])
                                         withTemplate:@"√($2)"];
    
    regex = [NSRegularExpression regularExpressionWithPattern:@"(\\d)(√)"
                                                      options:NSRegularExpressionCaseInsensitive
                                                        error:&error];
    string = [regex stringByReplacingMatchesInString:string
                                             options:0
                                               range:NSMakeRange(0, [string length])
                                        withTemplate:@"$1*$2"];
    
    
    
    regex = [NSRegularExpression regularExpressionWithPattern:@"\\(((\\d|[+-/*√i.])*)\\)"
                                                      options:NSRegularExpressionCaseInsensitive
                                                        error:&error];
    
    NSRange textRange = NSMakeRange(0, string.length);
    NSArray *matches = [regex matchesInString:string options:NSMatchingReportCompletion range:textRange];
    
    NSMutableArray *splitString = nil;
    if (matches) {
        int i = 0;
        int position = 0;
        NSRange range ;
        for (NSTextCheckingResult *result in matches) {
            if (!splitString) {
                splitString = [NSMutableArray array];
            }
            
            range = result.range;
            
            [splitString addObject:[string substringWithRange:NSMakeRange(position, (range.location)-position)]];
            position = range.location + range.length;
            range.length   -= 2;
            range.location += 1;
            NSString *sub  = [string substringWithRange:range];
            ComplexObject *numb = [self plusAndRegEx:sub];
            if (!numb) {
                return nil;
            }
            [splitString addObject:numb];
            i++;
        }
        if (!i) {
            return  [self plusAndRegEx:string];
        } else {
            position = range.location + range.length + 1;
            [splitString addObject:[string substringWithRange:NSMakeRange(position, [string length]-position)]];
            for (int i = 0; i < [splitString count]; i++) {
                if ([[splitString objectAtIndex:i] isKindOfClass:[ComplexObject class]]) {
                    
                    ComplexObject *complex = (ComplexObject *)[splitString objectAtIndex:i];
                    NSString *complexString = [complex stringValue];
                    
                    [splitString setObject:complexString atIndexedSubscript:i];
                }
            }
            return [self parenthesisAndRegEx:[splitString componentsJoinedByString:@""]];
            
        }
    } else {
        NSLog(@"Error in REGEX: %@",error.description);
        return  nil;
    }
}

+(ComplexObject *)plusAndRegEx:(NSString *)string {
    NSError *error = nil;
    NSRegularExpression *regex = nil;
    
    regex = [NSRegularExpression regularExpressionWithPattern:@"(\\d|[-i*√/.])*"
                                                      options:NSRegularExpressionCaseInsensitive
                                                        error:&error];
    
    NSRange textRange = NSMakeRange(0, string.length);
    NSArray *matches = [regex matchesInString:string options:NSMatchingReportCompletion range:textRange];
    
    NSMutableArray *splitString = nil;
    if (matches) {
        int i = 0;
        int position = 0;
        NSRange range ;
        for (NSTextCheckingResult *result in matches) {
            if (!splitString) {
                splitString = [NSMutableArray array];
            }
            
            range = result.range;
            
            if (range.length > 0) {
                NSString *sub = [string substringWithRange:range];
                
                ComplexObject *times = [self timesAndRegEx:sub];
                [splitString addObject:times];
            }
            
            i++;
        }
        if (!i) {
            ComplexObject *complex = [[ComplexObject alloc] initWithReal:[string doubleValue] andImaginary:0];
            return  complex;
        } else {
            position = range.location + range.length + 1;
            if (position < [string length]) {
                [splitString addObject:[string substringWithRange:NSMakeRange(position, [string length]-position)]];
            }
            ComplexObject *total  = [[ComplexObject alloc] initWithReal:0 andImaginary:0];
            for (ComplexObject *part in splitString) {
                total.real += part.real;
                total.imaginary += part.imaginary;
            }
            return total;
        }
    } else {
        NSLog(@"Error in REGEX: %@",error.description);
        return  nil;
    }
    
}

+(ComplexObject *)timesAndRegEx:(NSString *)string {
    NSError *error = nil;
    NSRegularExpression *regex = nil;
    
    regex = [NSRegularExpression regularExpressionWithPattern:@"(\\d|[-/i.√])*"
                                                      options:NSRegularExpressionCaseInsensitive
                                                        error:&error];
    
    NSRange textRange = NSMakeRange(0, string.length);
    NSArray *matches = [regex matchesInString:string options:NSMatchingReportCompletion range:textRange];
    
    NSMutableArray *splitString = nil;
    if (matches) {
        int i = 0;
        int position = 0;
        NSRange range ;
        for (NSTextCheckingResult *result in matches) {
            if (!splitString) {
                splitString = [NSMutableArray array];
            }
            
            range = result.range;
            
            if (range.length > 0) {
                NSString *sub   = [string substringWithRange:range];
                ComplexObject *times = [self divisionAndRegEx:sub];
                [splitString addObject:times];
            }
            
            i++;
        }
        if (!i) {
            ComplexObject *complex = [[ComplexObject alloc] initWithReal:[string doubleValue] andImaginary:0];
            return  complex;
        } else {
            position = range.location + range.length + 1;
            if (position < [string length]) {
                [splitString addObject:[string substringWithRange:NSMakeRange(position, [string length]-position)]];
            }
            int firstreal = 0;
            int firstimag = 0;
            ComplexObject *total  = [[ComplexObject alloc] initWithReal:0 andImaginary:0];
            int imagetimes = 0;
            
            for (ComplexObject *part in splitString) {
                if (part.imaginary != 0) {
                    if (!firstimag){
                        firstimag++;
                        total = part;
                    } else {
                        total.imaginary *= part.imaginary;
                    }
                    imagetimes++;
                }  else {
                    if (firstimag) {
                        total.imaginary *= part.real;
                    } else {
                        if (!firstreal) {
                            total = part;
                            firstreal++;
                        } else {
                            total.real *= part.real;
                        }
                    }
                }
            }
            
            if (firstimag && imagetimes%2 == 0) {
                if (!firstreal) {
                total.real = (-1 * total.imaginary);
                } else {
                    total.real *= (-1 * total.imaginary);
                }
                total.imaginary = 0;
            }
            return total;
        }
    } else {
        NSLog(@"Error in REGEX: %@",error.description);
        return  nil;
    }
}

+(ComplexObject *)divisionAndRegEx:(NSString *)string {
    NSError *error = nil;
    NSRegularExpression *regex = nil;
    
    regex = [NSRegularExpression regularExpressionWithPattern:@"(\\d|[-.i√])*"
                                                      options:NSRegularExpressionCaseInsensitive
                                                        error:&error];
    
    NSRange textRange = NSMakeRange(0, string.length);
    NSArray *matches = [regex matchesInString:string options:NSMatchingReportCompletion range:textRange];
    
    NSMutableArray *splitString = nil;
    if (matches) {
        int i = 0;
        int position = 0;
        NSRange range ;
        for (NSTextCheckingResult *result in matches) {
            if (!splitString) {
                splitString = [NSMutableArray array];
            }
            
            range = result.range;
            
            if (range.length > 0) {
                NSString *sub  = [string substringWithRange:range];
                ComplexObject *root = [self rootAndRegEx:sub];
                [splitString addObject:root];
            }
            
            i++;
        }
        if (!i) {
            ComplexObject *complex = [[ComplexObject alloc] initWithReal:[string doubleValue] andImaginary:0];
            return  complex;
        } else {
            position = range.location + range.length + 1;
            if (position < [string length]) {
                [splitString addObject:[string substringWithRange:NSMakeRange(position, [string length]-position)]];
            }
            
            ComplexObject *total;
            int i = 0;
            for (ComplexObject *part in splitString) {
                if (i == 0) {
                    total = part;
                    i++;
                } else {
                    if (total.imaginary != 0) {
                        if (part.imaginary != 0) {
                            total.imaginary /= part.imaginary;
                        } else {
                            total.imaginary /= part.real;
                        }
                    } else {
                        total.real      /= part.real;
                    }
                    //total.imaginary /= part.imaginary;
                }
            }
            return total;
        }
    } else {
        NSLog(@"Error in REGEX: %@",error.description);
        return  nil;
    }
}

+(ComplexObject *)rootAndRegEx:(NSString *)string {
    NSError *error = nil;
    NSRegularExpression *regex = nil;
    
    regex = [NSRegularExpression regularExpressionWithPattern:@"√((\\d|[-.i])*)"
                                                      options:NSRegularExpressionCaseInsensitive
                                                        error:&error];
    
    NSRange textRange = NSMakeRange(0, string.length);
    NSArray *matches = [regex matchesInString:string options:NSMatchingReportCompletion range:textRange];
    
    NSMutableArray *splitString = nil;
    if (matches) {
        int i = 0;
        NSRange range ;
        for (NSTextCheckingResult *result in matches) {
            if (!splitString) {
                splitString = [NSMutableArray array];
            }
            
            range = result.range;
            range.length -= 1;
            range.location += 1;
            if (range.length > 0) {
                NSString *sub      = [string substringWithRange:range];
                ComplexObject *com = [self complexAndRegEx:sub];
                [splitString addObject:com];
            }
            
            i++;
        }
        if (!i) {
            ComplexObject *complex = [self complexAndRegEx:string];
            
            return complex;
        } else {
            ComplexObject *total  = nil;
            for (ComplexObject *part in splitString) {
                total = part;
            }
            /*
            ComplexObject *complex = nil;
            if (total.imaginary != 0) {
                double real = total.imaginary * cos(0.785398163);
                double imag = total.imaginary * sin(0.785398163);
                complex = [[ComplexObject alloc] initWithReal:real
                                                 andImaginary:imag];
            } else {
            if (total.real < 0) {
                complex = [[ComplexObject alloc] initWithReal:0 andImaginary:sqrt(fabsf(total.real))];
            } else {
                complex = [[ComplexObject alloc] initWithReal:sqrt(total.real) andImaginary:0];
            }
            }*/
            [total squareRoot];
            return total;
        }
    } else {
        NSLog(@"Error in REGEX: %@",error.description);
        return  nil;
    }
}

+(ComplexObject *)complexAndRegEx:(NSString *)string {
    NSError *error = nil;
    NSRegularExpression *regex = nil;
    
    regex = [NSRegularExpression regularExpressionWithPattern:@"((\\d|[-.])*)i"
                                                      options:NSRegularExpressionCaseInsensitive
                                                        error:&error];
    
    NSRange textRange = NSMakeRange(0, string.length);
    NSArray *matches = [regex matchesInString:string options:NSMatchingReportCompletion range:textRange];
    
    NSMutableArray *splitString = nil;
    if (matches) {
        int i = 0;
        NSRange range ;
        for (NSTextCheckingResult *result in matches) {
            if (!splitString) {
                splitString = [NSMutableArray array];
            }
            
            range = result.range;
            range.length -= 1;
            if (range.length > 0) {
                NSString *sub  = [string substringWithRange:range];
                [splitString addObject:sub];
            }
            
            i++;
        }
        if (!i) {
            ComplexObject *complex = [[ComplexObject alloc] initWithReal:[string doubleValue] andImaginary:0];
            
            return complex;
        } else {
             ComplexObject *complex = [[ComplexObject alloc] initWithReal:0
                                                             andImaginary:[[splitString objectAtIndex:0] doubleValue]];
            return complex;
        }
    } else {
        NSLog(@"Error in REGEX: %@",error.description);
        return  nil;
    }
}

//Solve the NSString.
//With a string, solve its content if it is an operation if it is not a valid operation returns nil.
+(ComplexObject *)solveString:(NSString *)string {
    ComplexObject *result = nil;
    
    //Check if it is a valid expression based on parenthesis.
    //If it has the same number of open as of close parentheses, it is considered valid.
    if ([self openParenthesesFor:string toLocation:[string length]] == 0) {
        //Fix the string. String might need some help to process eg. )( should be )*(
        string = [self fixString:string];
        result = [self parenthesisAndRegEx:string];
    }
    
    return result;
}


@end

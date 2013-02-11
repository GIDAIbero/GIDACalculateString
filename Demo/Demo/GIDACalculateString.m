//
//  GIDACalculateString.m
//  Demo
//
//  Created by Alejandro Paredes Alva on 2/11/13.
//  Copyright (c) 2013 Alejandro Paredes Alva. All rights reserved.
//

#import "GIDACalculateString.h"

@interface GIDACalculateString ()

+(BOOL)checkFor:(char)character inThis:(NSString *)string fromThis:(int)position whereThisAre:(NSCharacterSet *)notAllowed andThisHelps:(NSCharacterSet *)toStop;
+(BOOL)checkThis:(NSString *)string atThis:(int)position ifLeftDoesNotHave:(NSCharacterSet *)leftCheck norRightHas:(NSCharacterSet *)rightCheck allowFirst:(BOOL)first;
+(int)openParenthesesFor:(NSString *)string toLocation:(int)position;

@end

@implementation GIDACalculateString


//String appending newString to String.
+(NSString *)makeStringFrom:(NSString *)string withThis:(NSString *)newString {
    return [string stringByAppendingString:newString];
}

//String by cutting at the range location and putting the newString in between.
+(NSString *)makeStringFrom:(NSString *)string withThis:(NSString *)newString aroundThis:(NSRange)range {
    NSString *preString = [string substringToIndex:range.location];
    NSString *postString = [string substringFromIndex:range.location];
    NSString *fullString = [[preString stringByAppendingString:newString] stringByAppendingString:postString];
    return fullString;
}

//Check if the character at position and its left is not included in a list of characters. Each side has special characters not allowed.
+(BOOL)checkThis:(NSString *)string atThis:(int)position ifLeftDoesNotHave:(NSCharacterSet *)leftCheck norRightHas:(NSCharacterSet *)rightCheck allowFirst:(BOOL)first{
    BOOL success = YES;
    
    if (position!= 0) {
        if ([leftCheck characterIsMember:[string characterAtIndex:position-1]])
            success = NO;
    } else {
        if (!first) {
            success = NO;
        }
    }
    
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
+(BOOL)usingThis:(NSString *)string canIAddThis:(NSString *)newString {
    return [self usingThis:string canIAddThis:newString aroundThis:(NSMakeRange(0, [string length]))];
}

//Check if the newString is a valid string or character to add to the string in the range position.
+(BOOL)usingThis:(NSString *)string canIAddThis:(NSString *)newString aroundThis:(NSRange)range {
    NSLog(@"Len: %d\tLoc: %d",range.length, range.location);
    BOOL success = YES;
    
    if ([newString length] == 0) {
        return YES;
    }
    
    if ([newString length] > 1) {
        for (int i = 0; i < [newString length]; i++) {
            if ([self usingThis:string canIAddThis:[NSString stringWithFormat:@"%c",[newString characterAtIndex:i]] aroundThis:range]) {
                string = [string stringByAppendingFormat:@"%c",[newString characterAtIndex:i]];
                range.location ++;
            } else {
                success = NO;
                i = [newString length];
            }
        }
    } else {
        if ([string length] == 0) {
            if ([newString characterAtIndex:0] == '.' || [newString characterAtIndex:0] == '-' || ([newString characterAtIndex:0] >= '0' && [newString characterAtIndex:0] <= '9')) {
                success = YES;
            } else {
                success = NO;
            }
        } else {
            if (range.length > 0) {
                NSLog(@"Pre:  %@",string);                
                NSString *preString = [string substringToIndex:range.location];
                NSString *postString = [string substringFromIndex:range.location+range.length];
                string = [preString stringByAppendingString:postString];
                NSLog(@"Post: %@",string);
            }
            NSCharacterSet *notAllowed;
            NSCharacterSet *toStop;
            NSCharacterSet *left;
            NSCharacterSet *right;
            switch ([newString characterAtIndex:0]) {
                case '.':
                    notAllowed = [NSCharacterSet characterSetWithCharactersInString:@"."];
                    toStop = [NSCharacterSet characterSetWithCharactersInString:@"()/"];
                    success = [self checkFor:'.' inThis:string fromThis:range.location-1 whereThisAre:notAllowed andThisHelps:toStop];
                    break;
                case '+':
                    left = [NSCharacterSet characterSetWithCharactersInString:@"(+-*/"];
                    right = [NSCharacterSet characterSetWithCharactersInString:@"+-*/)"];
                    success = [self checkThis:string atThis:range.location ifLeftDoesNotHave:left norRightHas:right allowFirst:NO];
                    break;
                case '-':
                    left = [NSCharacterSet characterSetWithCharactersInString:@"-"];
                    right = [NSCharacterSet characterSetWithCharactersInString:@"+-*/)"];
                    success = [self checkThis:string atThis:range.location ifLeftDoesNotHave:left norRightHas:right allowFirst:YES];
                    break;
                case '*':
                    left = [NSCharacterSet characterSetWithCharactersInString:@"(+-*/"];
                    right = [NSCharacterSet characterSetWithCharactersInString:@"+-*/)"];
                    success = [self checkThis:string atThis:range.location ifLeftDoesNotHave:left norRightHas:right allowFirst:NO];
                    break;
                case '/':
                    left = [NSCharacterSet characterSetWithCharactersInString:@"(+-*/"];
                    right = [NSCharacterSet characterSetWithCharactersInString:@"+*/)"];
                    success = [self checkThis:string atThis:range.location ifLeftDoesNotHave:left norRightHas:right allowFirst:NO];
                    break;
                case '(':
                    left = [NSCharacterSet characterSetWithCharactersInString:@""];
                    right = [NSCharacterSet characterSetWithCharactersInString:@"+*/)"];
                    success = [self checkThis:string atThis:range.location ifLeftDoesNotHave:left norRightHas:right allowFirst:NO];
                    break;
                case ')':
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
                    success = YES;
                    break;
            }
        }
    }
    return success;
}

@end

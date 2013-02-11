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
            if ([self usingThis:string canIAddThis:[NSString stringWithFormat:@"%c",[newString characterAtIndex:i]] aroundThis:range]) {
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
            if ([newString characterAtIndex:0] == '.' || [newString characterAtIndex:0] == '-' || [newString characterAtIndex:0] == '(' || ([newString characterAtIndex:0] >= '0' && [newString characterAtIndex:0] <= '9')) {
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
                    //The user is not allowed to put a '+' sign when on the left there is a '-'.
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

@end

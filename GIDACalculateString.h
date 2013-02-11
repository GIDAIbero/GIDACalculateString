//
//  GIDACalculateString.h
//  Demo
//
//  Created by Alejandro Paredes Alva on 2/11/13.
//  Copyright (c) 2013 Alejandro Paredes Alva. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GIDACalculateString : NSObject

+(BOOL)usingThis:(NSString *)string canIAddThis:(NSString *)newString;
+(BOOL)usingThis:(NSString *)string canIAddThis:(NSString *)newString aroundThis:(NSRange)range;

+(NSString *)makeStringFrom:(NSString *)string withThis:(NSString *)newString;
+(NSString *)makeStringFrom:(NSString *)string withThis:(NSString *)newString aroundThis:(NSRange)range;

@end

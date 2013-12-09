//
//  NSString+WTModel.m
//  WalterTrent
//
//  Created by Cody Coons on 11/12/13.
//  Copyright (c) 2013 Cody Coons. All rights reserved.
//

#import "NSString+WTModel.h"

@implementation NSString (WTModel)

- (id)initWithDatabaseString:(NSString *)databaseString
{
    NSString *unescapedString = [databaseString stringByReplacingOccurrencesOfString:@"''" withString:@"'"];
    return [self initWithString:unescapedString];
}

- (NSString *)databaseValueString
{
    NSString *valueString = [NSString stringWithFormat:@"%@", self];
    NSString *escapedValueString = [valueString stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    return [NSString stringWithFormat:@"'%@'", escapedValueString];
}

@end

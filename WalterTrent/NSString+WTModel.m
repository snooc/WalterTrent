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
    return [self initWithString:databaseString];
}

- (NSString *)databaseValueString
{
    return [NSString stringWithFormat:@"'%@'", self];
}

@end

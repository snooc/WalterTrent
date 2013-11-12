//
//  NSNumber+WTModel.m
//  WalterTrent
//
//  Created by Cody Coons on 11/12/13.
//  Copyright (c) 2013 Cody Coons. All rights reserved.
//

#import "NSNumber+WTModel.h"

@implementation NSNumber (WTModel)

- (id)initWithDatabaseString:(NSString *)databaseString
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *number = [formatter numberFromString:databaseString];
    return [self initWithDouble:[number doubleValue]];
}

- (NSString *)databaseValueString
{
    return [self stringValue];
}

@end

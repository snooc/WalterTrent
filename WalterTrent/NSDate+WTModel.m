//
//  NSDate+WTModel.m
//  WalterTrent
//
//  Created by Cody Coons on 11/12/13.
//  Copyright (c) 2013 Cody Coons. All rights reserved.
//

#import "NSDate+WTModel.h"

@implementation NSDate (WTModel)

- (id)initWithDatabaseString:(NSString *)databaseString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSDate *date = [dateFormatter dateFromString:databaseString];
    NSTimeInterval ti = [date timeIntervalSinceNow];
    return [self initWithTimeIntervalSinceNow:ti];
}

- (NSString *)databaseValueString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyy-MM-dd";
    return [NSString stringWithFormat:@"'%@'", [dateFormatter stringFromDate:self]];
}

@end

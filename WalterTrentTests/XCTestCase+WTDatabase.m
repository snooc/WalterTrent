//
//  XCTestCase+WTDatabase.m
//  WalterTrent
//
//  Created by Cody Coons on 11/1/13.
//  Copyright (c) 2013 Cody Coons. All rights reserved.
//

#import "XCTestCase+WTDatabase.h"

@implementation XCTestCase (WTDatabase)

#pragma mark - Temp Database Initialization and Deletion

+ (NSURL *)tempDatabaseURL
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *identifer = [[bundle infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSString *path = NSTemporaryDirectory();
    path = [path stringByAppendingPathComponent:identifer];
    NSURL *url = [NSURL fileURLWithPath:path];
    
    [[NSFileManager defaultManager] createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:nil];
    
    url = [url URLByAppendingPathComponent:[NSString stringWithFormat:@"database-test-%i.sqlite", arc4random_uniform(9999)]];
    
    return url;
}

+ (void)deleteTempDatabaseWithURL:(NSURL *)databaseURL
{
    NSFileManager *manger = [NSFileManager defaultManager];
    [manger removeItemAtURL:databaseURL error:nil];
}

@end

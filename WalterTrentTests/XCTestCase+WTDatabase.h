//
//  XCTestCase+WTDatabase.h
//  WalterTrent
//
//  Created by Cody Coons on 11/1/13.
//  Copyright (c) 2013 Cody Coons. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface XCTestCase (WTDatabase)

+ (NSURL *)tempDatabaseURL;
+ (void)deleteTempDatabaseWithURL:(NSURL *)databaseURL;

@end

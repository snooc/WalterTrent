//
//  WTDatabaseManager.m
//  WalterTrent
//
//  Created by Cody Coons on 11/1/13.
//  Copyright (c) 2013 Cody Coons. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "XCTestCase+WTDatabase.h"
#import "XCTAsyncTestCase.h"
#import "WTDatabaseManager.h"

@interface WTDatabaseManagerTests : XCTAsyncTestCase

@end

@implementation WTDatabaseManagerTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testOpeningAndClosingDatabase
{
    WTDatabaseManager *manager = [[WTDatabaseManager alloc] initWithDatabaseURL:[[self class] tempDatabaseURL]];
    [manager open];
    [manager executeQuery:@"SELECT COUNT(*) FROM sqlite_master;" handler:^(sqlite3 *database, sqlite3_stmt *stmt, BOOL databaseHasError) {
        XCTAssertFalse(databaseHasError, @"Should be able to execute query for database");
    }];
    [manager close];
    
    [[self class] deleteTempDatabaseWithURL:manager.databaseURL];
}

- (void)testOpeningDatabaseWithKey
{
    WTDatabaseManager *manager = [[WTDatabaseManager alloc] initWithDatabaseURL:[[self class] tempDatabaseURL]];
    [manager openDatabaseWithKey:@"secret" completion:^(BOOL databaseHasError) {
        XCTAssertFalse(databaseHasError, @"Database should not have an error when keying");
    }];
    [manager execute:@"CREATE TABLE people (id integer PRIMARY KEY AUTOINCREMENT NOT NULL, name text, rank integer);" completion:^(BOOL databaseHasError, NSError *error) {
        XCTAssertFalse(databaseHasError, @"Should create people table");
    }];
    [manager execute:@"INSERT INTO people (name, rank) VALUES('Johnny Appleseed', 52);" completion:^(BOOL databaseHasError, NSError *error) {
        XCTAssertFalse(databaseHasError, @"Should insert Johnny Appleseed record into table");
    }];
    [manager close];
    
    [manager executeQuery:@"SELECT * FROM people;" handler:^(sqlite3 *database, sqlite3_stmt *stmt, BOOL databaseHasError) {
        XCTAssertTrue(databaseHasError, @"Bad command should fail.");
    }];
    
    [manager openDatabaseWithKey:@"secret" completion:^(BOOL databaseHasError) {
        XCTAssertFalse(databaseHasError, @"Should successfully key database");
    }];
    [manager executeQuery:@"SELECT name FROM people WHERE rank = 52" handler:^(sqlite3 *database, sqlite3_stmt *stmt, BOOL databaseHasError) {
        NSString *name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 0)];
        XCTAssertTrue([name isEqualToString:@"Johnny Appleseed"], @"Should find Johnny Appleseed in database.");
    }];
    [manager close];
    
    [[self class] deleteTempDatabaseWithURL:manager.databaseURL];
}

@end

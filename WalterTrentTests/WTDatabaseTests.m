//
//  WTDatabaseTests.m
//  WalterTrent
//
//  Created by Cody Coons on 10/31/13.
//  Copyright (c) 2013 Cody Coons. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <sqlite3.h>

#import "XCTestCase+WTDatabase.h"

#import "WTDatabase.h"

@interface WTDatabaseTests : XCTestCase

@property (nonatomic, strong) WTDatabase *db;
@property (nonatomic, strong) NSURL *databaseURL;

@end

@implementation WTDatabaseTests

#pragma mark - Setup/Tear Down

- (void)setUp
{
    [super setUp];
    
    self.databaseURL = [self.class tempDatabaseURL];
    self.db = [WTDatabase databaseWithURL:self.databaseURL];
    
    [self.db open];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
    
    [self.db close];
    [self.class deleteTempDatabaseWithURL:self.databaseURL];
}

#pragma mark - Query Execution

- (void)testDatabaseQueryExecutionWithHandler
{
    [self.db executeQuery:@"SELECT COUNT(*) FROM sqlite_master;" handler:^(sqlite3 *database, sqlite3_stmt *stmt, BOOL databaseHasError) {
        XCTAssertTrue(databaseHasError == NO, @"Should be able to execute query for database");
    }];
}

- (void)testDatabaseQueryExecutionWithOutHandler
{
    [self.db execute:@"CREATE TABLE people (id integer PRIMARY KEY AUTOINCREMENT NOT NULL, name text, rank integer);" completion:^(BOOL databaseHasError, NSError *error) {
        XCTAssertFalse(databaseHasError, @"Should create people table");
    }];
    
    [self.db execute:@"INSERT INTO people (name, rank) VALUES('Johnny Appleseed', 52);" completion:^(BOOL databaseHasError, NSError *error) {
        XCTAssertFalse(databaseHasError, @"Should insert Johnny Appleseed record into table");
    }];
    
    [self.db execute:@"INSERT INTO people (name, rank) VALUES('Walter Trent', 1);" completion:^(BOOL databaseHasError, NSError *error) {
        XCTAssertFalse(databaseHasError, @"Should insert Walter Trent record into table");
    }];
    
    [self.db executeQuery:@"SELECT COUNT(id) FROM people" handler:^(sqlite3 *database, sqlite3_stmt *stmt, BOOL databaseHasError) {
        int count = sqlite3_column_int(stmt, 0);
        XCTAssertTrue(count == 2, @"Should have two records in database.");
    }];
    
    [self.db executeQuery:@"SELECT name FROM people WHERE rank = 1" handler:^(sqlite3 *database, sqlite3_stmt *stmt, BOOL databaseHasError) {
        NSString *name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 0)];
        XCTAssertTrue([name isEqualToString:@"Walter Trent"], @"Should find Walter Trent in database.");
    }];
    
    [self.db execute:@"fsdfsdafsafasfaf;" completion:^(BOOL databaseHasError, NSError *error) {
        XCTAssertTrue(databaseHasError, @"Bad command should fail.");
        XCTAssertTrue(error, @"Error should exist");
    }];
}

#pragma mark - Database Keying

- (void)testDatabaseKeying
{
    __weak WTDatabaseTests *weakSelf = self;
    [weakSelf.db setKey:@"secret" completion:^(BOOL databaseHasError, NSError *error) {
        XCTAssertFalse(databaseHasError, @"Database should not have a keying error");
    }];
}

@end

//
//  WTDatabaseTests.m
//  WalterTrent
//
//  Created by Cody Coons on 10/31/13.
//  Copyright (c) 2013 Cody Coons. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <sqlite3.h>
#import "WTDatabase.h"

@interface WTDatabaseTests : XCTestCase

@property (nonatomic, strong) WTDatabase *db;
@property (nonatomic, strong) NSURL *databaseURL;

+ (NSURL *)tempDatabaseURL;
+ (void)deleteTempDatabaseWithURL:(NSURL *)databaseURL;

@end

@implementation WTDatabaseTests

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
    [self.db execute:@"SELECT COUNT(*) FROM sqlite_master;" handler:^(sqlite3 *database, sqlite3_stmt *stmt, BOOL databaseHasError) {
        XCTAssertTrue(databaseHasError == NO, @"Should be able to execute query for database");
    }];
}

- (void)testDatabaseQueryExecutionWithOutHandler
{
    BOOL executed;
    
    executed = [self.db execute:@"CREATE TABLE people (id integer PRIMARY KEY AUTOINCREMENT NOT NULL, name text, rank integer);" error:nil];
    XCTAssertTrue(executed, @"Should create people table");
    
    executed = [self.db execute:@"INSERT INTO people (name, rank) VALUES('Johnny Appleseed', 52);" error:nil];
    XCTAssertTrue(executed, @"Should insert Johnny Appleseed record into table");
    
    executed = [self.db execute:@"INSERT INTO people (name, rank) VALUES('Walter Trent', 1);" error:nil];
    XCTAssertTrue(executed, @"Should insert Walter Trent record into table");
    
    [self.db execute:@"SELECT COUNT(id) FROM people" handler:^(sqlite3 *database, sqlite3_stmt *stmt, BOOL databaseHasError) {
        int count = sqlite3_column_int(stmt, 0);
        XCTAssertTrue(count == 2, @"Should have two records in database.");
    }];
    
    [self.db execute:@"SELECT name FROM people WHERE rank = 1" handler:^(sqlite3 *database, sqlite3_stmt *stmt, BOOL databaseHasError) {
        NSString *name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 0)];
        XCTAssertTrue([name isEqualToString:@"Walter Trent"], @"Should find Walter Trent in database.");
    }];
    
    NSError *error;
    executed = [self.db execute:@"fsdfsdafsafasfaf;" error:&error];
    XCTAssertFalse(executed, @"Bad command should fail.");
    XCTAssertTrue(error, @"Error should exist");
}

@end

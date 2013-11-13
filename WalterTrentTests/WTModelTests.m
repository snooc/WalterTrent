//


//  WTModelTests.m
//  WalterTrent
//
//  Created by Cody Coons on 11/12/13.
//  Copyright (c) 2013 Cody Coons. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "XCTestCase+WTDatabase.h"
#import "WTDatabaseManager.h"
#import "WTCar.h"

@interface WTModelTests : XCTestCase

@end

@implementation WTModelTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testExample
{
    WTCar *coolCar = [[WTCar alloc] init];
    XCTAssertNotNil(coolCar, @"Cool Car Object should not be nil");
}

- (void)testSelectQueryString
{
    WTCar *coolerCar = [[WTCar alloc] init];
    NSString *query = [coolerCar selectQueryString];
    XCTAssertTrue([query isEqualToString:@"SELECT id, make, model, year, date_of_birth, untagged FROM cars"], @"Select query should be correct");
}

- (void)testInsertQueryString
{
    WTCar *coolestCar = [[WTCar alloc] init];
    coolestCar.make = @"Ford";
    coolestCar.model = @"F150";
    coolestCar.year = [NSNumber numberWithInteger:2012];
    coolestCar.dateOfBirth = [NSDate date];
    coolestCar.untagged = @"Not sure what this is....";
    NSString *query = [coolestCar insertQueryString];
    XCTAssertTrue([query isEqualToString:@"INSERT OR REPLACE INTO cars (id, make, model, year, date_of_birth, untagged) VALUES (NULL, 'Ford', 'F150', 2012, '2013-11-13', 'Not sure what this is....')"], @"Insert query should be correct");
}

- (void)testDatabaseFetching
{
    NSURL *dbURL = [[self class] tempDatabaseURL];
    WTDatabaseManager *dbm = [[WTDatabaseManager alloc] initWithDatabaseURL:dbURL];
    
    [dbm open];
    
    NSString *create = @"CREATE TABLE cars (id integer PRIMARY KEY AUTOINCREMENT NOT NULL, make text, model text, year integer, date_of_birth text, untagged text);";
    [dbm execute:create completion:^(BOOL databaseHasError, NSError *error) {
        XCTAssertFalse(databaseHasError, @"Should create table");
    }];
    
    [dbm execute:@"INSERT INTO cars (id, make, model, year, date_of_birth, untagged) VALUES (NULL, 'Ford', 'F150', 2012, '2013-11-12', 'Not sure what this is....');" completion:^(BOOL databaseHasError, NSError *error) {
        XCTAssertFalse(databaseHasError, @"Should insert record");
    }];
    
    [dbm executeQuery:@"SELECT COUNT(*) FROM cars" handler:^(sqlite3 *database, sqlite3_stmt *stmt, BOOL databaseHasError) {
        int count = sqlite3_column_int(stmt, 0);
        XCTAssert(count > 0, @"Should have record");
    }];
    
    __block NSInteger theID;
    [dbm executeQuery:@"SELECT id FROM cars LIMIT 1" handler:^(sqlite3 *database, sqlite3_stmt *stmt, BOOL databaseHasError) {
        int dbid = sqlite3_column_int(stmt, 0);
        theID = dbid;
    }];
    XCTAssert(theID > 0, @"should find id");
    
    WTCar *car = [WTCar modelByFetchingWithPrimaryKey:theID databaseManager:dbm];
    
    XCTAssertTrue([car.make isEqualToString:@"Ford"], @"Should be a FORD!");
    
    [dbm close];
    
    [[self class] deleteTempDatabaseWithURL:dbURL];
}

- (void)testDatabaseSyncing
{
    NSURL *dbURL = [[self class] tempDatabaseURL];
    WTDatabaseManager *dbm = [[WTDatabaseManager alloc] initWithDatabaseURL:dbURL];
    
    [dbm open];
    
    NSString *create = @"CREATE TABLE cars (id integer PRIMARY KEY AUTOINCREMENT NOT NULL, make text, model text, year integer, date_of_birth text, untagged text);";
    [dbm execute:create completion:^(BOOL databaseHasError, NSError *error) {
        XCTAssertFalse(databaseHasError, @"Should create table");
    }];
    
    [dbm execute:@"INSERT INTO cars (id, make, model, year, date_of_birth, untagged) VALUES (NULL, 'Ford', 'F150', 2012, '2013-11-12', 'Not sure what this is....');" completion:^(BOOL databaseHasError, NSError *error) {
        XCTAssertFalse(databaseHasError, @"Should insert record");
    }];
    
    [dbm executeQuery:@"SELECT COUNT(*) FROM cars" handler:^(sqlite3 *database, sqlite3_stmt *stmt, BOOL databaseHasError) {
        int count = sqlite3_column_int(stmt, 0);
        XCTAssert(count > 0, @"Should have record");
    }];
    
    __block NSInteger theID;
    [dbm executeQuery:@"SELECT id FROM cars LIMIT 1" handler:^(sqlite3 *database, sqlite3_stmt *stmt, BOOL databaseHasError) {
        int dbid = sqlite3_column_int(stmt, 0);
        theID = dbid;
    }];
    XCTAssert(theID > 0, @"should find id");
    
    WTCar *car = [WTCar modelByFetchingWithPrimaryKey:theID databaseManager:dbm];
    
    XCTAssertTrue([car.make isEqualToString:@"Ford"], @"Should be a FORD!");
    
    car.model = @"Taurus";
    [car saveWithDatabaseManager:dbm];
    
    WTCar *car2 = [WTCar modelByFetchingWithPrimaryKey:theID databaseManager:dbm];
    
    XCTAssertTrue([car2.make isEqualToString:@"Ford"], @"Car two should be a Ford");
    XCTAssertTrue([car2.model isEqualToString:@"Taurus"], @"Car two should be a Taurus");
    XCTAssertTrue([car2.year intValue] == 2012, @"Car two should be a 2012");
    XCTAssertTrue([car2.dbID intValue] == theID, @"ID should be correct");
    
    [dbm close];
    
    [[self class] deleteTempDatabaseWithURL:dbURL];
}

- (void)testFetchAllFromDatabase
{
    NSURL *dbURL = [[self class] tempDatabaseURL];
    WTDatabaseManager *dbm = [[WTDatabaseManager alloc] initWithDatabaseURL:dbURL];
    
    [dbm open];
    
    NSString *create = @"CREATE TABLE cars (id integer PRIMARY KEY AUTOINCREMENT NOT NULL, make text, model text, year integer, date_of_birth text, untagged text);";
    [dbm execute:create completion:^(BOOL databaseHasError, NSError *error) {
        XCTAssertFalse(databaseHasError, @"Should create table");
    }];
    
    [dbm execute:@"INSERT INTO cars (id, make, model, year, date_of_birth, untagged) VALUES (NULL, 'Ford', 'F150', 2012, '2013-11-12', 'Not sure what this is....');" completion:^(BOOL databaseHasError, NSError *error) {
        XCTAssertFalse(databaseHasError, @"Should insert record");
    }];
    [dbm execute:@"INSERT INTO cars (id, make, model, year, date_of_birth, untagged) VALUES (NULL, 'GMC', '2500', 2012, '2011-09-02', 'Cool!');" completion:^(BOOL databaseHasError, NSError *error) {
        XCTAssertFalse(databaseHasError, @"Should insert record");
    }];
    
    NSArray *all = [WTCar fetchAllWithDatebaseManager:dbm];
    XCTAssertTrue([all count] == 2, @"There should be two models");
    
    [dbm close];
    
    [[self class] deleteTempDatabaseWithURL:dbURL];
}

@end

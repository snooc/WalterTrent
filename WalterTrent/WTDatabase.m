//
//  WTDatabase.m
//  WalterTrent
//
//  Created by Cody Coons on 10/31/13.
//  Copyright (c) 2013 Cody Coons. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "WTDatabase.h"

static NSUInteger const kWTDatabaseDefaultKDFIteration = 64000;
static BOOL const kWTDatabaseDefaultHMACPageProtection = YES;

NSString *const kWTDatabaseErrorDomain = @"WTDatabaseErrorDomain";
int const kWTDatabaseSQLStatementFailedCode = -1;

@interface WTDatabase ()

+ (NSError *)errorWithSQLiteErrorPointer:(char *)errorPointer;

@end

@implementation WTDatabase

@dynamic databasePath, databaseFile;

#pragma mark - Factory Methods

+ (id)databaseWithURL:(NSURL *)databaseURL
{
    return [[self.class alloc] initWithDatabaseURL:databaseURL];
}

+ (id)databaseWithURL:(NSURL *)databaseURL KDFIterations:(NSUInteger)KDFIterations
{
    return [[self.class alloc] initWithDatabaseURL:databaseURL KDFIterations:KDFIterations];
}

+ (id)databaseWithURL:(NSURL *)databaseURL KDFIterations:(NSUInteger)KDFIterations HMACPageProtection:(BOOL)HMACPageProtection
{
    return [[self.class alloc] initWithDatabaseURL:databaseURL KDFIterations:KDFIterations HMACPageProtection:HMACPageProtection];
}

#pragma mark - Lifecycle

- (id)initWithDatabaseURL:(NSURL *)databaseURL
{
    return [self initWithDatabaseURL:databaseURL KDFIterations:kWTDatabaseDefaultKDFIteration HMACPageProtection:kWTDatabaseDefaultHMACPageProtection];
}

- (id)initWithDatabaseURL:(NSURL *)databaseURL KDFIterations:(NSUInteger)KDFIterations
{
    return [self initWithDatabaseURL:databaseURL KDFIterations:KDFIterations HMACPageProtection:kWTDatabaseDefaultHMACPageProtection];
}

- (id)initWithDatabaseURL:(NSURL *)databaseURL KDFIterations:(NSUInteger)KDFIterations HMACPageProtection:(BOOL)HMACPageProtection
{
    self = [super init];
    if (self) {
        _databaseURL = databaseURL;
        _KDFIterations = KDFIterations;
        _HMACPageProtection = HMACPageProtection;
    }
    return self;
}

#pragma mark - Database Execution

- (BOOL)execute:(NSString *)statement error:(NSError *__autoreleasing *)error
{
    return [self execute:statement queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) error:error];
}

- (void)execute:(NSString *)statement handler:(WTDatabaseHandlerBlock)handlerBlock
{
    [self execute:statement queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) handler:handlerBlock];
}

- (BOOL)execute:(NSString *)statement queue:(dispatch_queue_t)queue error:(NSError *__autoreleasing *)error
{
    __block BOOL executionSuccess = NO;
    __weak WTDatabase *weakSelf = self;
    dispatch_sync(queue, ^() {
        WTDatabase *strongSelf = weakSelf;
        char *errorPointer;
        
        if (sqlite3_exec(strongSelf.database, [statement UTF8String], NULL, NULL, &errorPointer) == SQLITE_OK) {
            executionSuccess = YES;
        } else {
            if (error) {
                *error = [[self class] errorWithSQLiteErrorPointer:errorPointer];
                sqlite3_free(errorPointer);
                
                executionSuccess = NO;
            }
        }
    });
    
    return executionSuccess;
}

- (void)execute:(NSString *)statement queue:(dispatch_queue_t)queue handler:(WTDatabaseHandlerBlock)handlerBlock
{
    __weak WTDatabase *weakSelf = self;
    dispatch_sync(queue, ^() {
        WTDatabase *strongSelf = weakSelf;
        sqlite3_stmt *stmt;
        
        if (sqlite3_prepare_v2(strongSelf.database, [statement UTF8String], -1, &stmt, NULL) == SQLITE_OK) {
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                if (handlerBlock) {
                    handlerBlock(strongSelf.database, stmt, NO);
                }
            }
        }
        
        sqlite3_finalize(stmt);
    });
}

#pragma mark - Open and Close Database

- (void)open
{
    sqlite3_open([self.databasePath UTF8String], &_database);
}

- (void)close
{
    sqlite3_close(self.database);
}

#pragma mark - SQLite Error Handling

+ (NSError *)errorWithSQLiteErrorPointer:(char *)errorPointer
{
    NSString *errorMessage = [NSString stringWithCString:errorPointer encoding:NSUTF8StringEncoding];
    NSString *description = @"An error has occured when executing a SQL statement";
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:description, NSLocalizedDescriptionKey, errorMessage, NSLocalizedFailureReasonErrorKey, nil];
    return [[NSError alloc] initWithDomain:kWTDatabaseErrorDomain code:kWTDatabaseSQLStatementFailedCode userInfo:userInfo];
}

#pragma mark - Dynamic Property Getter and Setters

- (NSString *)databasePath
{
    return self.databaseURL.path;
}

- (NSString *)databaseFile
{
    return self.databaseURL.lastPathComponent;
}
    
@end

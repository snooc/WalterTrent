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
int const kWTDatabaseSQLKeyFailedCode = -10;

@interface WTDatabase ()

+ (NSError *)errorWithSQLiteErrorPointer:(char *)errorPointer;
+ (NSError *)errorForSQLiteKeying;

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

#pragma mark - Database Keying

- (void)setKey:(NSString *)key completion:(WTDatabaseKeyingCompletionBlock)completion
{
    NSData *keyData = [NSData dataWithBytes:[key UTF8String] length:(NSUInteger)strlen([key UTF8String])];
    
    [self setKeyWithData:keyData queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) completion:completion];
}

- (void)setKey:(NSString *)key queue:(dispatch_queue_t)queue completion:(WTDatabaseKeyingCompletionBlock)completion
{
    NSData *keyData = [NSData dataWithBytes:[key UTF8String] length:(NSUInteger)strlen([key UTF8String])];
    
    [self setKeyWithData:keyData queue:queue completion:completion];
}

- (void)setKeyWithData:(NSData *)keyData queue:(dispatch_queue_t)queue completion:(WTDatabaseKeyingCompletionBlock)completion
{
    __weak WTDatabase *weakSelf = self;
    dispatch_sync(queue, ^{
        WTDatabase *strongSelf = weakSelf;
        NSError *error;
        BOOL databaseHasError = NO;
        
        if (sqlite3_key(strongSelf.database, [keyData bytes], (int)[keyData length]) == SQLITE_OK) {
            databaseHasError = NO;
        } else {
            error = [[strongSelf class] errorForSQLiteKeying];
            databaseHasError = YES;
        }
        
        completion(databaseHasError, error);
    });
}

#pragma mark - Database Execution

- (void)execute:(NSString *)statement completion:(WTDatabaseCompletionBlock)completion
{
    [self execute:statement queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) completion:completion];
}

- (void)execute:(NSString *)statement queue:(dispatch_queue_t)queue completion:(WTDatabaseCompletionBlock)completion
{
    __weak WTDatabase *weakSelf = self;
    dispatch_sync(queue, ^() {
        WTDatabase *strongSelf = weakSelf;
        NSError *error;
        char *errorPointer;
        BOOL databaseHasError = NO;
        
        if (sqlite3_exec(strongSelf.database, [statement UTF8String], NULL, NULL, &errorPointer) == SQLITE_OK) {
            databaseHasError = NO;
        } else {
            error = [[strongSelf class] errorWithSQLiteErrorPointer:errorPointer];
            sqlite3_free(errorPointer);
            
            databaseHasError = YES;
        }
       
        if (completion) {
            completion(databaseHasError, error);
        }
    });
}

- (void)executeQuery:(NSString *)statement handler:(WTDatabaseHandlerBlock)handler
{
    [self executeQuery:statement queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) handler:handler];
}

- (void)executeQuery:(NSString *)statement queue:(dispatch_queue_t)queue handler:(WTDatabaseHandlerBlock)handler
{
    __weak WTDatabase *weakSelf = self;
    dispatch_sync(queue, ^() {
        WTDatabase *strongSelf = weakSelf;
        sqlite3_stmt *stmt;
        
        if (sqlite3_prepare_v2(strongSelf.database, [statement UTF8String], -1, &stmt, NULL) == SQLITE_OK) {
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                if (handler) {
                    handler(strongSelf.database, stmt, NO);
                }
            }
        }
        
        sqlite3_finalize(stmt);
    });
}

#pragma mark - Open and Close Database

- (void)open
{
    [self openWithQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}

- (void)openWithQueue:(dispatch_queue_t)queue
{
    __weak WTDatabase *weakSelf = self;
    dispatch_sync(queue, ^() {
        WTDatabase *strongSelf = weakSelf;
        sqlite3 *db = strongSelf.database;
        
        sqlite3_open([strongSelf.databasePath UTF8String], &db);
        
        strongSelf.database = db;
    });
}

- (void)close
{
    [self closeWithQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}

- (void)closeWithQueue:(dispatch_queue_t)queue
{
    __weak WTDatabase *weakSelf = self;
    dispatch_sync(queue, ^() {
        WTDatabase *strongSelf = weakSelf;
        
        sqlite3_close(strongSelf.database);
    });
}

#pragma mark - SQLite Error Handling

+ (NSError *)errorWithSQLiteErrorPointer:(char *)errorPointer
{
    NSString *errorMessage = [NSString stringWithCString:errorPointer encoding:NSUTF8StringEncoding];
    NSString *description = @"An error has occured when executing a SQL statement";
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:description, NSLocalizedDescriptionKey, errorMessage, NSLocalizedFailureReasonErrorKey, nil];
    return [[NSError alloc] initWithDomain:kWTDatabaseErrorDomain code:kWTDatabaseSQLStatementFailedCode userInfo:userInfo];
}

+ (NSError *)errorForSQLiteKeying
{
    NSString *errorMessage = @"Unable to set SQLCipher key";
    NSString *description = @"An error has occured when executing SQLite Key";
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:description, NSLocalizedDescriptionKey, errorMessage, NSLocalizedFailureReasonErrorKey, nil];
    return [[NSError alloc] initWithDomain:kWTDatabaseErrorDomain code:kWTDatabaseSQLKeyFailedCode userInfo:userInfo];
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

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
int const kWTDatabaseSQLiteErrorCode = -20;

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

#pragma mark - Database Opening and Closing

- (void)open
{
    sqlite3 *database;
    sqlite3_open([self.databasePath UTF8String], &database);
    self.database = database;
}

- (void)openWithKey:(NSString *)key completion:(WTDatabaseOpenCompletionBlock)completion
{
    NSData *keyData = [NSData dataWithBytes:[key UTF8String] length:(NSUInteger)strlen([key UTF8String])];
    sqlite3 *database;
    BOOL databaseHasError = NO;
    
    if (sqlite3_open([self.databasePath UTF8String], &database) == SQLITE_OK) {
        if (sqlite3_key(database, [keyData bytes], (int)[keyData length]) == SQLITE_OK) {
            databaseHasError = NO;
        } else {
            databaseHasError = YES;
        }
    } else {
        databaseHasError = YES;
    }
    
    self.database = database;
    
    if (completion) {
        completion(databaseHasError);
    }
}

- (void)close
{
    sqlite3_close(self.database);
}

#pragma mark - Database Keying

- (void)setKeyWithString:(NSString *)key
{
    NSData *keyData = [NSData dataWithBytes:[key UTF8String] length:(NSUInteger)strlen([key UTF8String])];
    [self setKeyWithData:keyData];
}

- (void)setKeyWithData:(NSData *)keyData
{
    sqlite3_key(self.database, [keyData bytes], (int)[keyData length]);
    // TODO: Set KDF_Iterations and Cipher
}

#pragma mark - Database Execution

- (void)execute:(NSString *)statement completion:(WTDatabaseCompletionBlock)completion
{
    NSError *error;
    char *errorPointer;
    BOOL databaseHasError = NO;
    
    if (sqlite3_exec(self.database, [statement UTF8String], NULL, NULL, &errorPointer) == SQLITE_OK) {
        databaseHasError = NO;
    } else {
        error = [[self class] errorWithSQLiteErrorPointer:errorPointer];
        sqlite3_free(errorPointer);
        
        databaseHasError = YES;
    }
   
    if (completion) {
        completion(databaseHasError, error);
    }
}

- (void)executeQuery:(NSString *)query handler:(WTDatabaseHandlerBlock)handler
{
    [self executeQuery:query handler:handler completion:nil];
}

- (void)executeQuery:(NSString *)query handler:(WTDatabaseHandlerBlock)handler completion:(WTDatabaseCompletionBlock)completion
{
    sqlite3_stmt *stmt;
    NSError *error;
    BOOL databaseHasError = NO;
    
    if (sqlite3_prepare_v2(self.database, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK) {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            if (handler) {
                handler(self.database, stmt, NO);
            }
        }
        databaseHasError = NO;
    } else {
        error = [[self class] errorWithSQLiteErrorCode:sqlite3_errcode(self.database) message:[NSString stringWithUTF8String:sqlite3_errmsg(self.database)]];
        databaseHasError = YES;
    }
    
    sqlite3_finalize(stmt);
    
    if (completion) {
        completion(databaseHasError, error);
    }
}


#pragma mark - SQLite Error Handling

+ (NSError *)errorWithSQLiteErrorPointer:(char *)errorPointer
{
    NSString *errorMessage = [NSString stringWithCString:errorPointer encoding:NSUTF8StringEncoding];
    NSString *description = @"An error has occured when executing a SQL statement";
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:description, NSLocalizedDescriptionKey, errorMessage, NSLocalizedFailureReasonErrorKey, nil];
    return [[NSError alloc] initWithDomain:kWTDatabaseErrorDomain code:kWTDatabaseSQLStatementFailedCode userInfo:userInfo];
}
                   
+ (NSError *)errorWithSQLiteErrorCode:(NSUInteger)errorCode message:(NSString *)message
{
    NSString *errorMessage = [NSString stringWithFormat:@"SQLite Error: %i", errorCode];
    NSString *description = message;
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:description, NSLocalizedDescriptionKey, errorMessage, NSLocalizedFailureReasonErrorKey, nil];
    return [[NSError alloc] initWithDomain:kWTDatabaseErrorDomain code:kWTDatabaseSQLStatementFailedCode userInfo:userInfo];
}

+ (NSError *)errorForSQLiteKeying
{
    NSString *errorMessage = @"Unable to set SQLCipher key";
    NSString *description = @"An error has occured when executing SQLite Key";
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:description, NSLocalizedDescriptionKey, errorMessage, NSLocalizedFailureReasonErrorKey, nil];
    return [[NSError alloc] initWithDomain:kWTDatabaseErrorDomain code:kWTDatabaseSQLiteErrorCode userInfo:userInfo];
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

//
//  WTDatabase.h
//  WalterTrent
//
//  Created by Cody Coons on 10/31/13.
//  Copyright (c) 2013 Cody Coons. All rights reserved.
//

#import <sqlite3.h>
#import "WTBlocks.h"

extern NSString *const kWTDatabaseErrorDomain;
extern int const kWTDatabaseSQLStatementFailedCode;
extern int const kWTDatabaseSQLKeyFailedCode;
extern int const kWTDatabaseSQLiteErrorCode;

@interface WTDatabase : NSObject

#pragma mark - Properies
@property (nonatomic) sqlite3 *database;
@property (nonatomic) NSUInteger schemaVersion;
@property (nonatomic) NSUInteger KDFIterations;
@property (nonatomic, getter = isUsingHMACPageProtection) BOOL HMACPageProtection;
@property (nonatomic, getter = isDatabaseOpen) BOOL databaseOpen;
@property (nonatomic, strong) NSURL *databaseURL;
@property (nonatomic, strong, readonly) NSString *databasePath;
@property (nonatomic, strong, readonly) NSString *databaseFile;

#pragma mark - Factory Methods
+ (id)databaseWithURL:(NSURL *)databaseURL;
+ (id)databaseWithURL:(NSURL *)databaseURL KDFIterations:(NSUInteger)KDFIterations;
+ (id)databaseWithURL:(NSURL *)databaseURL KDFIterations:(NSUInteger)KDFIterations HMACPageProtection:(BOOL)HMACPageProtection;

#pragma mark - Lifecycle
- (id)initWithDatabaseURL:(NSURL *)databaseURL;
- (id)initWithDatabaseURL:(NSURL *)databaseURL KDFIterations:(NSUInteger)KDFIterations;
- (id)initWithDatabaseURL:(NSURL *)databaseURL KDFIterations:(NSUInteger)KDFIterations HMACPageProtection:(BOOL)HMACPageProtection;

#pragma mark - Database Opening and Closing
- (void)open;
- (void)openWithKey:(NSString *)key completion:(WTDatabaseOpenCompletionBlock)completion;
- (void)close;

#pragma mark - iDatabase eying
- (void)setKeyWithString:(NSString *)key;
- (void)setKeyWithData:(NSData *)keyData;

#pragma mark - Database Execution
- (void)execute:(NSString *)statement completion:(WTDatabaseCompletionBlock)completion;
- (void)executeQuery:(NSString *)query handler:(WTDatabaseHandlerBlock)handler;
- (void)executeQuery:(NSString *)query handler:(WTDatabaseHandlerBlock)handler completion:(WTDatabaseCompletionBlock)completion;

@end

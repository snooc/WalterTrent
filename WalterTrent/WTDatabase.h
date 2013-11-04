//
//  WTDatabase.h
//  WalterTrent
//
//  Created by Cody Coons on 10/31/13.
//  Copyright (c) 2013 Cody Coons. All rights reserved.
//

#import <sqlite3.h>

typedef void (^WTDatabaseHandlerBlock)(sqlite3 *database, sqlite3_stmt *stmt, BOOL databaseHasError);
typedef void (^WTDatabaseCompletionBlock)(BOOL databaseHasError, NSError *error);
typedef void (^WTDatabaseKeyingCompletionBlock)(BOOL databaseHasError, NSError *error);

extern NSString *const kWTDatabaseErrorDomain;
extern int const kWTDatabaseSQLStatementFailedCode;
extern int const kWTDatabaseSQLKeyFailedCode;

@interface WTDatabase : NSObject

@property (nonatomic) sqlite3 *database;
@property (nonatomic) NSUInteger schemaVersion;
@property (nonatomic) NSUInteger KDFIterations;
@property (nonatomic, getter = isUsingHMACPageProtection) BOOL HMACPageProtection;
@property (nonatomic, getter = isDatabaseOpen) BOOL databaseOpen;
@property (nonatomic, strong) NSURL *databaseURL;
@property (nonatomic, strong, readonly) NSString *databasePath;
@property (nonatomic, strong, readonly) NSString *databaseFile;

+ (id)databaseWithURL:(NSURL *)databaseURL;
+ (id)databaseWithURL:(NSURL *)databaseURL KDFIterations:(NSUInteger)KDFIterations;
+ (id)databaseWithURL:(NSURL *)databaseURL KDFIterations:(NSUInteger)KDFIterations HMACPageProtection:(BOOL)HMACPageProtection;

- (id)initWithDatabaseURL:(NSURL *)databaseURL;
- (id)initWithDatabaseURL:(NSURL *)databaseURL KDFIterations:(NSUInteger)KDFIterations;
- (id)initWithDatabaseURL:(NSURL *)databaseURL KDFIterations:(NSUInteger)KDFIterations HMACPageProtection:(BOOL)HMACPageProtection;

- (void)setKey:(NSString *)key completion:(WTDatabaseKeyingCompletionBlock)completion;
- (void)setKey:(NSString *)key queue:(dispatch_queue_t)queue completion:(WTDatabaseKeyingCompletionBlock)completion;
- (void)setKeyWithData:(NSData *)keyData queue:(dispatch_queue_t)queue completion:(WTDatabaseKeyingCompletionBlock)completion;

- (void)execute:(NSString *)statement completion:(WTDatabaseCompletionBlock)completion;
- (void)execute:(NSString *)statement queue:(dispatch_queue_t)queue completion:(WTDatabaseCompletionBlock)completion;
- (void)executeQuery:(NSString *)statement handler:(WTDatabaseHandlerBlock)handler;
- (void)executeQuery:(NSString *)statement queue:(dispatch_queue_t)queue handler:(WTDatabaseHandlerBlock)handler;

- (void)open;
- (void)openWithQueue:(dispatch_queue_t)queue;
- (void)close;
- (void)closeWithQueue:(dispatch_queue_t)queue;

@end

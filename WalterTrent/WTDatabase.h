//
//  WTDatabase.h
//  WalterTrent
//
//  Created by Cody Coons on 10/31/13.
//  Copyright (c) 2013 Cody Coons. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^WTDatabaseHandlerBlock)(sqlite3 *database, sqlite3_stmt *stmt, BOOL databaseHasError);

extern NSString *const kWTDatabaseErrorDomain;
extern int const kWTDatabaseSQLStatementFailedCode;

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

- (BOOL)execute:(NSString *)statement error:(NSError **)error;
- (void)execute:(NSString *)statement handler:(WTDatabaseHandlerBlock)handlerBlock;
- (BOOL)execute:(NSString *)statement queue:(dispatch_queue_t)queue error:(NSError **)error;
- (void)execute:(NSString *)statement queue:(dispatch_queue_t)queue handler:(WTDatabaseHandlerBlock)handlerBlock;

- (void)open;
- (void)close;

@end

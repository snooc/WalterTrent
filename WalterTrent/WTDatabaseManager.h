//
//  WTDatabaseManager.h
//  WalterTrent
//
//  Created by Cody Coons on 10/31/13.
//  Copyright (c) 2013 Cody Coons. All rights reserved.
//

#import <sqlite3.h>
#import "WTBlocks.h"

@interface WTDatabaseManager : NSObject

@property (nonatomic, strong) NSURL *databaseURL;

#pragma mark - Singleton
+ (WTDatabaseManager *)sharedManager;
+ (void)setSharedManager:(WTDatabaseManager *)databaseManager;

#pragma mark - Lifecycle
- (id)initWithDatabaseURL:(NSURL *)databaseURL;

#pragma mark - Database Existance 
- (BOOL)databaseExists;

#pragma mark - Database Opening and Closing
- (void)openDatabaseWithKey:(NSString *)key completion:(WTDatabaseOpenCompletionBlock)completion;
- (void)open;
- (void)close;

#pragma mark - Database Keying
- (void)setKey:(NSString *)key;

#pragma mark - Database Statement and Query execution
- (void)execute:(NSString *)statement completion:(WTDatabaseCompletionBlock)completion;
- (void)executeQuery:(NSString *)query handler:(WTDatabaseHandlerBlock)handler;
- (void)executeQuery:(NSString *)query handler:(WTDatabaseHandlerBlock)handler completion:(WTDatabaseCompletionBlock)completion;

- (NSNumber *)numberForQuery:(NSString *)query;

#pragma mark - Support Methods
+ (NSURL *)defaultDatabaseURL;

@end

//
//  WTDatabaseManager.h
//  WalterTrent
//
//  Created by Cody Coons on 10/31/13.
//  Copyright (c) 2013 Cody Coons. All rights reserved.
//

#import <sqlite3.h>

typedef void (^WTDatabaseManagerKeyCompletionBlock)(BOOL databaseWasKeyed);
typedef void (^WTDatabaseHandlerBlock)(sqlite3 *database, sqlite3_stmt *stmt, BOOL databaseHasError);
typedef void (^WTDatabaseCompletionBlock)(BOOL databaseHasError, NSError *error);

@interface WTDatabaseManager : NSObject

+ (WTDatabaseManager *)sharedManager;
+ (void)setSharedManager:(WTDatabaseManager *)databaseManager;

- (id)initWithDatabaseURL:(NSURL *)databaseURL;

- (BOOL)databaseExists;

- (void)openDatabaseWithKey:(NSString *)key completion:(WTDatabaseManagerKeyCompletionBlock)completion;
- (void)close;

- (void)execute:(NSString *)statement completion:(WTDatabaseCompletionBlock)completion;
- (void)executeQuery:(NSString *)statement handler:(WTDatabaseHandlerBlock)handler;

+ (NSURL *)defaultDatabaseURL;

@end

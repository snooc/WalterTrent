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

+ (WTDatabaseManager *)sharedManager;
+ (void)setSharedManager:(WTDatabaseManager *)databaseManager;

- (id)initWithDatabaseURL:(NSURL *)databaseURL;

- (BOOL)databaseExists;

- (void)openDatabaseWithKey:(NSString *)key completion:(WTDatabaseOpenCompletionBlock)completion;
- (void)open;
- (void)close;

- (void)setKey:(NSString *)key;

- (void)execute:(NSString *)statement completion:(WTDatabaseCompletionBlock)completion;
- (void)executeQuery:(NSString *)statement handler:(WTDatabaseHandlerBlock)handler;

+ (NSURL *)defaultDatabaseURL;

@end

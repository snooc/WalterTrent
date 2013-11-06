//
//  WTBlocks.h
//  WalterTrent
//
//  Created by Cody Coons on 11/6/13.
//  Copyright (c) 2013 Cody Coons. All rights reserved.
//

#ifndef WalterTrent_WTBlocks_h
#define WalterTrent_WTBlocks_h

typedef void (^WTDatabaseHandlerBlock)(sqlite3 *database, sqlite3_stmt *stmt, BOOL databaseHasError);
typedef void (^WTDatabaseCompletionBlock)(BOOL databaseHasError, NSError *error);
typedef void (^WTDatabaseKeyingCompletionBlock)(BOOL databaseHasError, NSError *error);
typedef void (^WTDatabaseOpenCompletionBlock)(BOOL databaseHasError);

#endif

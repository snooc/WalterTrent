//
//  WTDatabaseSchemaManager.h
//  WalterTrent
//
//  Created by Cody Coons on 10/31/13.
//  Copyright (c) 2013 Cody Coons. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WTDatabaseManager;

@interface WTDatabaseSchemaManager : NSObject

@property (nonatomic) NSInteger schemaVersion;

#pragma mark - Factory Methods
+ (id)schemaManagerWithDatabaseManager:(WTDatabaseManager *)databaseManager maximumMigration:(NSInteger)maximumMigration;

#pragma mark - Lifecycle
- (id)initWithDatabaseManager:(WTDatabaseManager *)databaseManager maximumMigration:(NSInteger)maximumMigration;

#pragma mark - Migrations
- (void)performMigrations;

@end

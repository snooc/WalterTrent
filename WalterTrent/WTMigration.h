//
//  WTMigration.h
//  WalterTrent
//
//  Created by Cody Coons on 11/7/13.
//  Copyright (c) 2013 Cody Coons. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WTDatabaseManager;

@interface WTMigration : NSObject

@property (nonatomic) NSUInteger number;
@property (nonatomic, strong) NSURL *migrationURL;

#pragma mark - Factory Methods
+ (id)migrationWithInteger:(NSUInteger)number databaseManager:(WTDatabaseManager *)databaseManager;

#pragma mark - Lifecycle
- (id)initWithInteger:(NSUInteger)number databaseManager:(WTDatabaseManager *)databaseManager;

#pragma mark - Migration Execution
- (void)execute;

@end

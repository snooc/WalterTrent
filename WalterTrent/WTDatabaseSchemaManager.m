//
//  WTDatabaseSchemaManager.m
//  WalterTrent
//
//  Created by Cody Coons on 10/31/13.
//  Copyright (c) 2013 Cody Coons. All rights reserved.
//

#import "WTDatabaseSchemaManager.h"
#import "WTDatabaseManager.h"
#import "WTMigration.h"

static NSString * const kWTDatabaseSchemaManagerSchemaKey = @"user_version";

@interface WTDatabaseSchemaManager ()

@property (nonatomic, strong) WTDatabaseManager *databaseManager;
@property (nonatomic) NSInteger maximumMigration;

@end

@implementation WTDatabaseSchemaManager

@dynamic schemaVersion;

#pragma mark - Factory Methods

+ (id)schemaManagerWithDatabaseManager:(WTDatabaseManager *)databaseManager maximumMigration:(NSInteger)maximumMigration
{
    return [[self alloc] initWithDatabaseManager:databaseManager maximumMigration:maximumMigration];
}

#pragma mark - Lifecycle

- (id)initWithDatabaseManager:(WTDatabaseManager *)databaseManager maximumMigration:(NSInteger)maximumMigration
{
    self = [super init];
    if (self) {
        _databaseManager = databaseManager;
        _maximumMigration = maximumMigration;
    }
    return self;
}

#pragma mark - Migrations

- (void)performMigrations
{
    NSInteger currentSchemaVersion = self.schemaVersion;
    
    if (currentSchemaVersion < self.maximumMigration) {
        NSInteger start = currentSchemaVersion + 1;
        NSInteger end = self.maximumMigration;
        
        for (int m = start; m <= end; m++) {
            WTMigration *migration = [WTMigration migrationWithInteger:m databaseManager:self.databaseManager];
            [migration execute];
        }
        
        self.schemaVersion = self.maximumMigration;
    }
}

#pragma mark - Dynamic Setters and Getters

- (void)setSchemaVersion:(NSInteger)schemaVersion
{
    NSString *schemaStatement = [NSString stringWithFormat:@"PRAGMA %@ = %i;", kWTDatabaseSchemaManagerSchemaKey, schemaVersion];
    [self.databaseManager execute:schemaStatement completion:nil];
}

- (NSInteger)schemaVersion
{
    NSString *schemaQuery = [NSString stringWithFormat:@"PRAGMA %@;", kWTDatabaseSchemaManagerSchemaKey];
    NSNumber *schemaVersion = [self.databaseManager numberForQuery:schemaQuery];
    return [schemaVersion integerValue];
}

@end

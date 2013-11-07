//
//  WTMigration.m
//  WalterTrent
//
//  Created by Cody Coons on 11/7/13.
//  Copyright (c) 2013 Cody Coons. All rights reserved.
//

#import "WTMigration.h"
#import "WTDatabaseManager.h"

@interface WTMigration ()

@property (nonatomic, strong) WTDatabaseManager *databaseManager;

- (NSString *)migrationFileName;

@end

@implementation WTMigration

#pragma mark - Factory Methods

+ (id)migrationWithInteger:(NSUInteger)number databaseManager:(WTDatabaseManager *)databaseManager
{
    return [[self alloc] initWithInteger:number databaseManager:databaseManager];
}

#pragma mark - Lifecycle

- (id)initWithInteger:(NSUInteger)number databaseManager:(WTDatabaseManager *)databaseManager
{
    self = [super init];
    if (self) {
        _number = number;
        _databaseManager = databaseManager;
    }
    return self;
}

#pragma mark - Migration Execution

- (void)execute
{
    __block NSString *migration = [NSString stringWithContentsOfURL:[[self class] defaultMigrationURLWithFileName:self.migrationFileName] encoding:NSUTF8StringEncoding error:nil];
    [self.databaseManager execute:migration completion:nil];
}

#pragma mark - Support Methods

- (NSString *)migrationFileName
{
    return [NSString stringWithFormat:@"migration-%i", self.number];
}

+ (NSURL *)defaultMigrationURLWithFileName:(NSString *)filename
{
    return [[NSBundle mainBundle] URLForResource:filename withExtension:@"sql"];
}

@end

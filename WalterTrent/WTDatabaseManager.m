//
//  WTDatabaseManager.m
//  WalterTrent
//
//  Created by Cody Coons on 10/31/13.
//  Copyright (c) 2013 Cody Coons. All rights reserved.
//

#import "WTDatabaseManager.h"
#import "WTDatabase.h"

static NSString * const kWTDatabaseManagerDatabaseFileName = @"data.sqlite";
static NSString * const kWTDatabaseManagerQueueName = @"waltertrent.databasemanager";

static WTDatabaseManager *_sharedManager = nil;
static dispatch_once_t _onceToken = 0;

@interface WTDatabaseManager ()

@property (nonatomic, strong) WTDatabase *database;
@property (nonatomic, strong) dispatch_queue_t queue;

@end

@implementation WTDatabaseManager

#pragma mark - Shared Manager

+ (WTDatabaseManager *)sharedManager
{
    dispatch_once(&_onceToken, ^{
        if (_sharedManager == nil) {
            _sharedManager = [[WTDatabaseManager alloc] init];
        }
    });
    return _sharedManager;
}

+ (void)setSharedManager:(WTDatabaseManager *)databaseManager
{
    _onceToken = 0;
    _sharedManager = databaseManager;
}

#pragma mark - Lifecycle

- (id)init
{
    return [self initWithDatabaseURL:[[self class] defaultDatabaseURL]];
}

- (id)initWithDatabaseURL:(NSURL *)databaseURL
{
    self = [super init];
    if (self) {
        _queue = dispatch_queue_create([kWTDatabaseManagerQueueName UTF8String], NULL);
    }
    return self;
}

#pragma mark - Database Existance

- (BOOL)databaseExists
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:self.database.databasePath];
}

#pragma mark - Open/Close Database

- (void)openDatabaseWithKey:(NSString *)key completion:(WTDatabaseManagerKeyCompletionBlock)completion
{
    [self.database openWithQueue:self.queue];
    
    [self.database setKey:key queue:self.queue completion:^(BOOL databaseHasError, NSError *error) {
        if (databaseHasError) {
            completion(NO);
        } else {
            completion(YES);
        }
    }];
}

- (void)close
{
    [self.database closeWithQueue:self.queue];
}

#pragma mark - Database Execution

- (void)execute:(NSString *)statement completion:(WTDatabaseCompletionBlock)completion
{
    [self.database execute:statement queue:self.queue completion:completion];
}

- (void)executeQuery:(NSString *)statement handler:(WTDatabaseHandlerBlock)handler
{
    [self.database executeQuery:statement queue:self.queue handler:handler];
}

#pragma mark - Support Methods

+ (NSURL *)defaultDatabaseURL
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = ([paths count] > 0) ? [paths firstObject] : nil;
    NSString *databasePath = [documentsPath stringByAppendingString:kWTDatabaseManagerDatabaseFileName];
    return [NSURL fileURLWithPath:databasePath];
}

@end

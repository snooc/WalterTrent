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
static NSString * const kWTDatabaseManagerQueueName = @"waltertrent.databasemanager.serial";

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
        _databaseURL = databaseURL;
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
- (void)open
{
    self.database = [[WTDatabase alloc] initWithDatabaseURL:self.databaseURL];
    
    __weak WTDatabaseManager *weakSelf = self;
    dispatch_sync(self.queue, ^{
        __strong WTDatabaseManager *strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf.database open];
        }
    });
}

- (void)openDatabaseWithKey:(NSString *)key completion:(WTDatabaseOpenCompletionBlock)completion
{
    self.database = [[WTDatabase alloc] initWithDatabaseURL:self.databaseURL];
    
    __weak WTDatabaseManager *weakSelf = self;
    dispatch_sync(self.queue, ^{
        __strong WTDatabaseManager *strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf.database openWithKey:key completion:completion];
        }
    });
}

- (void)close
{
    __weak WTDatabaseManager *weakSelf = self;
    dispatch_sync(self.queue, ^{
        __strong WTDatabaseManager *strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf.database close];
        }
    });
}

#pragma mark - Database Keying

- (void)setKey:(NSString *)key
{
    __weak WTDatabaseManager *weakSelf = self;
    dispatch_sync(self.queue, ^{
        __strong WTDatabaseManager *strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf.database setKeyWithString:key];
        }
    });
}

#pragma mark - Database Statement and Query Execution

- (void)execute:(NSString *)statement completion:(WTDatabaseCompletionBlock)completion
{
    __weak WTDatabaseManager *weakSelf = self;
    dispatch_sync(self.queue, ^{
        __strong WTDatabaseManager *strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf.database execute:statement completion:completion];
        }
    });
}

- (void)executeQuery:(NSString *)query handler:(WTDatabaseHandlerBlock)handler
{
    __weak WTDatabaseManager *weakSelf = self;
    dispatch_sync(self.queue, ^{
        __strong WTDatabaseManager *strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf.database executeQuery:query handler:handler];
        }
    });
}

- (void)executeQuery:(NSString *)query handler:(WTDatabaseHandlerBlock)handler completion:(WTDatabaseCompletionBlock)completion
{
    __weak WTDatabaseManager *weakSelf = self;
    dispatch_sync(self.queue, ^{
        __strong WTDatabaseManager *strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf.database executeQuery:query handler:handler completion:completion];
        }
    });
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

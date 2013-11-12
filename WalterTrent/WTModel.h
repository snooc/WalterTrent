//
//  WTModel.h
//  WalterTrent
//
//  Created by Cody Coons on 10/31/13.
//  Copyright (c) 2013 Cody Coons. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NSString+WTModel.h"

#define WT_MODEL_COLUMN
#define WT_MODEL_PK_COLUMN

@class WTDatabaseManager;

@interface WTModel : NSObject

@property (nonatomic, strong, readonly) NSString *tableName;
@property (nonatomic, strong, readonly) NSArray *propertyKeys;
@property (nonatomic, strong, readonly) NSArray *propertyTypes;
@property (nonatomic, strong, readonly) NSArray *databaseColumns;

+ (NSString *)tableName;
+ (NSString *)primaryKeyColumn;
+ (NSString *)primaryKeyProperty;

- (NSString *)columnStringForQuery;
- (NSString *)selectQueryString;
- (NSString *)insertQueryString;

+ (instancetype)modelByFetchingWithPrimaryKey:(NSUInteger)primaryKey databaseManager:(WTDatabaseManager *)databaseManager;

@end

//
//  WTModel.m
//  WalterTrent
//
//  Created by Cody Coons on 10/31/13.
//  Copyright (c) 2013 Cody Coons. All rights reserved.
//

#import <objc/runtime.h>
#import <objc/message.h>

#import "NSString+Inflections.h"

#import "WTModel.h"
#import "WTDatabaseManager.h"

static NSString * const kWTModelDefaultPrimaryKeyProperty = @"dbID";
static NSString * const kWTModelDefaultPrimaryKeyColumn = @"id";

@interface WTModel ()

+ (NSArray *)databaseColumnsForClass;
+ (NSArray *)propertyNamesForClass;
+ (NSArray *)propertyTypesForClass;
+ (NSString *)databaseStringForObject:(id)object;

@end

@implementation WTModel

#pragma mark - Lifecycle

- (id)init
{
    self = [super init];
    if (self) {
        _tableName = [[self class] tableName];
        _propertyKeys = [[self class] propertyNamesForClass];
        _propertyTypes = [[self class] propertyTypesForClass];
        _databaseColumns = [[self class] databaseColumnsForClass];
    }
    return self;
}

#pragma mark - Primary Key

+ (NSString *)primaryKeyProperty
{
    return kWTModelDefaultPrimaryKeyProperty;
}

+ (NSString *)primaryKeyColumn
{
    return kWTModelDefaultPrimaryKeyColumn;
}

#pragma mark - Table

+ (NSString *)tableName
{
    // table name is the class without a prefix, underscored and lowercase
    NSString *className = NSStringFromClass([self class]);
    NSString *classNameWithoutPrefix = [className substringFromIndex:2];
    return [[classNameWithoutPrefix wt_underscore] lowercaseString];
}

#pragma mark - Query and Statement Strings

+ (NSString *)columnStringForQuery
{
    NSArray *databaseColumns = [[self class] databaseColumnsForClass];
    NSMutableString *columns = [NSMutableString string];
    NSInteger columnsCount = [databaseColumns count];
    for (int c = 0; c < columnsCount; c++) {
        NSString *column = [databaseColumns objectAtIndex:c];
        
        if (c == (columnsCount - 1)) {
            [columns appendString:column];
        } else {
            [columns appendString:[NSString stringWithFormat:@"%@, ", column]];
        }
    }
    return columns;
}

+ (NSString *)selectQueryString
{
    NSString *query = [NSString stringWithFormat:@"SELECT %@ FROM %@", [[self class] columnStringForQuery], [[self class] tableName]];
    return query;
}

- (NSString *)selectQueryString
{
    NSString *query = [NSString stringWithFormat:@"SELECT %@ FROM %@", [[self class] columnStringForQuery], [[self class] tableName]];
    return query;
}

- (NSString *)insertQueryString
{
    NSMutableString *values = [NSMutableString string];
    NSInteger propertyCount = [self.propertyKeys count];
    for (int p = 0; p < propertyCount; p++) {
        NSString *property = [self.propertyKeys objectAtIndex:p];
        //NSString *column = [self.databaseColumns objectAtIndex:p];
        
        id value = [self valueForKey:property];
        NSString *valueString = [[self class] databaseStringForObject:value];
        
        if (p == (propertyCount -1)) {
            [values appendString:[NSString stringWithFormat:@"%@", valueString]];
        } else {
            [values appendString:[NSString stringWithFormat:@"%@, ", valueString]];
        }
    }
    NSString *tableName = [self tableName];
    NSString *columns = [[self class] columnStringForQuery];
    NSString *query = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (%@) VALUES (%@)", tableName, columns, values];
    return query;
}

#pragma mark - Database Helpers

+ (NSArray *)databaseColumnsForClass
{
    NSArray *properties = [[self class] propertyNamesForClass];
    NSMutableArray *columns = [NSMutableArray arrayWithCapacity:[properties count]];
    for (NSString *property in properties) {
        if ([property isEqualToString:[[self class] primaryKeyProperty]]) {
            [columns addObject:[NSString stringWithString:[[self class] primaryKeyColumn]]];
        } else {
            // DB Column goes from camelCase to underscore and lower
            [columns addObject:[[property wt_underscore] lowercaseString]];
        }
    }
    return columns;
}

+ (NSString *)databaseStringForObject:(id)object
{
    SEL selector = NSSelectorFromString(@"databaseValueString");
    if ([object respondsToSelector:selector]) {
        return objc_msgSend(object, selector);
    } else {
        if (object == nil) {
            return @"NULL";
        } else {
            NSAssert(YES, @"Does not support object.");
        }
    }
    
    return nil;
}

#pragma mark - Database Fetch

+ (NSArray *)fetchAllWithDatebaseManager:(WTDatabaseManager *)databaseManager
{
    __block NSMutableArray *models = [NSMutableArray array];
    
    NSString *query = [[self class] selectQueryString];
    [databaseManager executeQuery:query handler:^(sqlite3 *database, sqlite3_stmt *stmt, BOOL databaseHasError) {
        if (databaseHasError) {
            NSAssert(YES, @"Unable to fetch all");
        }
       
        WTModel *model = [[self alloc] init];
        int columnCount = sqlite3_column_count(stmt);
        for (int c = 0; c < columnCount; c++) {
            NSString *column = [NSString stringWithUTF8String:sqlite3_column_name(stmt, c)];
            
            NSInteger columnIndex = [model.databaseColumns indexOfObject:column];
            NSString *property = [model.propertyKeys objectAtIndex:columnIndex];
            NSString *propertyType = [model.propertyTypes objectAtIndex:columnIndex];
            
            id value;
            const unsigned char *propertyCString = sqlite3_column_text(stmt, c);
            if (propertyCString) {
                NSString *propertyValue = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, c)];
                
                if (propertyValue) {
                    Class propertyClass = NSClassFromString(propertyType);
                    if (propertyClass) {
                        value = [propertyClass alloc];
                        
                        SEL selector = NSSelectorFromString(@"initWithDatabaseString:");
                        if ([value respondsToSelector:selector]) {
                            value = objc_msgSend(value, selector, propertyValue);
                        }
                    } else {
                        value = nil;
                    }
                } else {
                    value = nil;
                }
            }
            
            [model setValue:value forKey:property];
        }
        [models addObject:model];
    }];
    
    return models;
}

+ (instancetype)modelByFetchingWithPrimaryKey:(NSUInteger)primaryKey databaseManager:(WTDatabaseManager *)databaseManager
{
    __block WTModel *model = [[self alloc] init];
    
    NSString *query = [NSString stringWithFormat:@"%@ WHERE %@ = %i", [model selectQueryString], [self primaryKeyColumn], primaryKey];
    [databaseManager executeQuery:query handler:^(sqlite3 *database, sqlite3_stmt *stmt, BOOL databaseHasError) {
        if (databaseHasError) {
            NSAssert(YES, @"Houston we have a problem");
        }
        
        int columnCount = sqlite3_column_count(stmt);
        for (int c = 0; c < columnCount; c++) {
            NSString *column = [NSString stringWithUTF8String:sqlite3_column_name(stmt, c)];
            
            NSInteger columnIndex = [model.databaseColumns indexOfObject:column];
            NSString *property = [model.propertyKeys objectAtIndex:columnIndex];
            NSString *propertyType = [model.propertyTypes objectAtIndex:columnIndex];
            
            NSString *propertyValue = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, c)];
            
            id value;
            if (propertyValue) {
                Class propertyClass = NSClassFromString(propertyType);
                if (propertyClass) {
                    value = [propertyClass alloc];
                    
                    SEL selector = NSSelectorFromString(@"initWithDatabaseString:");
                    if ([value respondsToSelector:selector]) {
                        value = objc_msgSend(value, selector, propertyValue);
                    }
                } else {
                    value = nil;
                }
            } else {
                value = nil;
            }
            
            [model setValue:value forKey:property];
        }
    }];
    
    return model;
}

#pragma mark - Database Sync

- (void)saveWithDatabaseManager:(WTDatabaseManager *)databaseManager
{
    [databaseManager execute:[self insertQueryString] completion:^(BOOL databaseHasError, NSError *error) {
        NSAssert(!databaseHasError, @"Database had an error: %@", error.localizedFailureReason);
    }];
}

#pragma mark - Property Helpers

+ (NSArray *)propertyNamesForClass
{
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        NSString *name = [NSString stringWithUTF8String:property_getName(property)];
        [results addObject:name];
    }
    
    free(properties);
    
    return results;
}

static const char *getPropertyType(objc_property_t property) {
    const char *attributes = property_getAttributes(property);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T' && attribute[1] != '@') {
            NSString *name = [[NSString alloc] initWithBytes:attribute + 1 length:strlen(attribute) - 1 encoding:NSASCIIStringEncoding];
            return (const char *)[name cStringUsingEncoding:NSASCIIStringEncoding];
        }
        else if (attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) == 2) {
            return "id";
        }
        else if (attribute[0] == 'T' && attribute[1] == '@') {
            NSString *name = [[NSString alloc] initWithBytes:attribute + 3 length:strlen(attribute) - 4 encoding:NSASCIIStringEncoding];
            return (const char *)[name cStringUsingEncoding:NSASCIIStringEncoding];
        }
    }
    return "";
}

+ (NSArray *)propertyTypesForClass
{
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:count];
    for (unsigned int i = 0; i < count; i++) {
        const char *type = getPropertyType(properties[i]);
        [results addObject:[NSString stringWithUTF8String:type]];
    }
    
    free(properties);
    
    return results;
}

@end

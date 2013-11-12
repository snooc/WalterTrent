//
//  NSNumber+WTModel.h
//  WalterTrent
//
//  Created by Cody Coons on 11/12/13.
//  Copyright (c) 2013 Cody Coons. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (WTModel)

- (id)initWithDatabaseString:(NSString *)databaseString;
- (NSString *)databaseValueString;

@end

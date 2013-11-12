//
//  WTCar.h
//  WalterTrent
//
//  Created by Cody Coons on 11/12/13.
//  Copyright (c) 2013 Cody Coons. All rights reserved.
//

#import "WTModel.h"

@interface WTCar : WTModel

@property (nonatomic, copy, readonly) NSNumber *dbID WT_MODEL_PK_COLUMN;
@property (nonatomic, copy) NSString *make WT_MODEL_COLUMN;
@property (nonatomic, copy) NSString *model WT_MODEL_COLUMN;
@property (nonatomic, copy) NSNumber *year WT_MODEL_COLUMN;
@property (nonatomic, copy) NSDate *dateOfBirth WT_MODEL_COLUMN;
@property (nonatomic, copy) NSString *untagged;

@end

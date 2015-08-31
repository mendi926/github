//
//  AssocStore.h
//  WordAssoc
//
//  Created by Armend H on 03/08/15.
//  Copyright (c) 2015 Armend H. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AssocStore : NSObject

@property (nonatomic) NSMutableArray *assocSet;
@property (nonatomic) NSMutableArray *assocSetProgress;

+ (instancetype)sharedStore;
- (void)loadAssoc:(int)number;
- (void)loadAssocProgress:(int)number;
- (void)insertLoadAssocProgress:(NSMutableArray *)assocSetProgress indexNumber:(int)number;
- (void)resetAssocProgress:(int)number;
- (void)revealSet:(int)number;

@end

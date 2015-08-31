//
//  NSString+Levenshtein.h
//  WordAssoc
//
//  Created by Armend H on 27/08/15.
//  Copyright (c) 2015 Armend H. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (Levenshtein)

-(int) computeLevenshteinDistanceWithString:(NSString *) string;

@end
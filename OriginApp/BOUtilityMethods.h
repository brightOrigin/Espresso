//
// Created by Tony Papale on 5/30/14.
// Copyright (c) 2014 Bright Origin. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

@interface BOUtilityMethods : NSObject

+ (NSURL *) applicationDocumentsDirectory;

@end
//
// Created by Tony Papale on 6/2/14.
// Copyright (c) 2014 Bright Origin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BOBaseManagedObject.h"

#define kVenueImportDidFinishNotification       @"VenueImportDidFinishNotification"

@interface Venue : BOBaseManagedObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSNumber *verified;
@property (nonatomic, strong) NSNumber *distance;

+ (void) searchVenuesForTerm:(NSString *)searchTerm
                    latitude:(NSNumber *)latitude
                   longitude:(NSNumber *)longitude;

+ (void) searchVenuesForTerm:(NSString *)searchTerm
                        near:(NSString *)nearLocation;

@end
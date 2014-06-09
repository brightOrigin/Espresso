//
// Created by Tony Papale on 6/3/14.
// Copyright (c) 2014 Bright Origin. All rights reserved.
//

#import "VenueImportOperation.h"
#import "Venue.h"


@implementation VenueImportOperation

- (void)main
{
    [super main];

    NSArray *resultsArray = [self.operationDataDictionary objectForKey:@"venues"];

    // process new/updates in bg
    [Venue processNewOrUpdatedObjects:resultsArray inContext:self.context];

    // process any objects that need to be updated
//    [Venue processUpdatedObjects:[self.operationDataDictionary objectForKey:@"updated"] inContext:self.context];

    // process any objects that need to be deleted
//    [Venue processDeletedObjects:[self.operationDataDictionary objectForKey:@"deleted"] inContext:self.context];

    [[BOStore sharedInstance] saveContext:self.context];
}

@end
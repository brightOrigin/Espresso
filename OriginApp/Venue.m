//
// Created by Tony Papale on 6/2/14.
// Copyright (c) 2014 Bright Origin. All rights reserved.
//

#import "Venue.h"
#import "VenueImportOperation.h"


@implementation Venue

- (void) buildEntityAttributeToServerNameMapping
{
    [super buildEntityAttributeToServerNameMapping];

    [self.entityAttributeToServerNameMapping setValue:@"name" forKey:@"name"];
    [self.entityAttributeToServerNameMapping setValue:@"url" forKey:@"url"];

    // relationships
//    [self.entityAttributeToServerNameMapping setValue:@"invitee" forKey:@"invitees"];

}

+ (void) searchVenuesForTerm:(NSString *)searchTerm
                    latitude:(NSNumber *)latitude
                   longitude:(NSNumber *)longitude
                  categoryID:(NSNumber *)categoryID
{
    // build parameter list
    NSMutableDictionary *parametersDict = [[NSMutableDictionary alloc] init];

    [parametersDict setValue:latitude forKey:@"latitude"];
    [parametersDict setValue:longitude forKey:@"longitude"];
    [parametersDict setValue:categoryID forKey:@"categoryId"];
    [parametersDict setValue:searchTerm forKey:@"search_term"];

    [[ServerManager sharedManager] initRequestForType:kServerRequestSearchEvents
                                       withParameters:parametersDict
                                            showModal:YES
                                       successHandler:^(ServerManager *manager, id response, NSError *error)
                                       {
                                           if ([response isKindOfClass:[NSDictionary class]])
                                           {
//                                               [self importObjects:[response valueForKey:@"venues"]];
                                               [self importObjects:response];
                                           }
                                       }
                                       failureHandler:^(ServerManager *manager, id response, NSError *error)
                                       {

                                       }];
}

+ (void) importObjects:(NSDictionary *)importDataDictionary
{
    VenueImportOperation *venueImportOp = [[VenueImportOperation alloc]
                                                                 initWithImportDataDictionary:importDataDictionary];
    [venueImportOp setCompletionBlock:^
            {
                // post notification
                DLog(@"venue import done");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter]
                                           postNotificationName:kVenueImportDidFinishNotification
                                                         object:nil];
                });
            }];

    [[BOStore sharedInstance] addOperationToBackgroundCoreDataQueue:venueImportOp];
}

@end
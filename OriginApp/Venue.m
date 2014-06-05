//
// Created by Tony Papale on 6/2/14.
// Copyright (c) 2014 Bright Origin. All rights reserved.
//

#import "Venue.h"
#import "VenueImportOperation.h"
#import "BOAPIClient.h"


@implementation Venue

@dynamic name;
@dynamic address;
@dynamic url;
@dynamic verified;
@dynamic distance;

- (void) buildEntityAttributeToServerNameMapping
{
    [super buildEntityAttributeToServerNameMapping];

    [self.entityAttributeToServerNameMapping setValue:@"name" forKey:@"name"];
    [self.entityAttributeToServerNameMapping setValue:@"location.address" forKey:@"address"];
    [self.entityAttributeToServerNameMapping setValue:@"url" forKey:@"url"];
    [self.entityAttributeToServerNameMapping setValue:@"verified" forKey:@"verified"];
    [self.entityAttributeToServerNameMapping setValue:@"location.distance" forKey:@"distance"];
}

+ (void) searchVenuesForTerm:(NSString *)searchTerm
                    latitude:(NSNumber *)latitude
                   longitude:(NSNumber *)longitude
{
    // build parameter list
    NSMutableDictionary *parametersDict = [[NSMutableDictionary alloc] init];

    [parametersDict setValue:[NSString stringWithFormat:@"%@,%@",latitude, longitude]
                      forKey:@"ll"];
//    [parametersDict setValue:searchTerm forKey:@"query"];
    [parametersDict setValue:@"4bf58dd8d48988d1e0931735" forKey:@"categoryId"];
    [parametersDict setValue:@"2UQPKGUSVLXJD1EZDPMU40GY1C2XVFGNNZO1QOAZEZNY1Z4U" forKey:@"client_secret"];
    [parametersDict setValue:@"T5QGLBP4UIP32WD5KLSRRRMMPSJRQE0SZX5JZVDQBTRKDTSL" forKey:@"client_id"];
    [parametersDict setValue:@"20140118" forKey:@"v"];


    [[BOAPIClient sharedClient]
                  GET:@"venues/search"
           parameters:parametersDict
              success:^(NSURLSessionDataTask *__unused task, id JSON)
            {
                if ([JSON isKindOfClass:[NSDictionary class]])
                {
                    [self importObjects:[JSON objectForKey:@"response"]];
                }
            }
              failure:^(NSURLSessionDataTask *__unused task, NSError *error)
            {
                NSLog(@"ERROR!! in searchVenues %@", error.localizedDescription);
            }];
}

+ (void) searchVenuesForTerm:(NSString *)searchTerm
                        near:(NSString *)nearLocation
{
    // build parameter list
    NSMutableDictionary *parametersDict = [[NSMutableDictionary alloc] init];

    [parametersDict setValue:nearLocation
                      forKey:@"near"];
    [parametersDict setValue:searchTerm forKey:@"query"];

    [parametersDict setValue:@"4bf58dd8d48988d1e0931735" forKey:@"categoryId"];
    [parametersDict setValue:@"2UQPKGUSVLXJD1EZDPMU40GY1C2XVFGNNZO1QOAZEZNY1Z4U" forKey:@"client_secret"];
    [parametersDict setValue:@"T5QGLBP4UIP32WD5KLSRRRMMPSJRQE0SZX5JZVDQBTRKDTSL" forKey:@"client_id"];
    [parametersDict setValue:@"20140118" forKey:@"v"];


    [[BOAPIClient sharedClient]
                  GET:@"venues/search"
           parameters:parametersDict
              success:^(NSURLSessionDataTask *__unused task, id JSON)
            {
                if ([JSON isKindOfClass:[NSDictionary class]])
                {
                    [self importObjects:[JSON objectForKey:@"response"]];
                }
            }
              failure:^(NSURLSessionDataTask *__unused task, NSError *error)
            {
                NSLog(@"ERROR!! in searchVenues %@", error.localizedDescription);
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
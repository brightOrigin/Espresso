//
// Created by Tony Papale on 6/3/14.
// Copyright (c) 2014 Bright Origin. All rights reserved.
//

#import "BOAPIClient.h"

static NSString *const FourSquareAPIBaseURLString = @"http://api.foursquare.com/";

@implementation BOAPIClient

+ (instancetype) sharedClient
{
    static BOAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        _sharedClient = [[BOAPIClient alloc] initWithBaseURL:[NSURL URLWithString:FourSquareAPIBaseURLString]];
    });

    return _sharedClient;
}

@end
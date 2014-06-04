//
// Created by Tony Papale on 6/3/14.
// Copyright (c) 2014 Bright Origin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AFHTTPSessionManager;


@interface BOAPIClient : AFHTTPSessionManager

+ (instancetype) sharedClient;

@end
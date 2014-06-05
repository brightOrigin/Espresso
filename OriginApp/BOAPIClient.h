//
// Created by Tony Papale on 6/3/14.
// Copyright (c) 2014 Bright Origin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"

static NSString *const kAPIRequestDidFailNotification = @"APIRequestDidFailNotification";

@interface BOAPIClient : AFHTTPSessionManager

+ (instancetype) sharedClient;

@end
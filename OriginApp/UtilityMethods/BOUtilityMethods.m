//
// Created by Tony Papale on 5/30/14.
// Copyright (c) 2014 Bright Origin. All rights reserved.
//

#import "BOUtilityMethods.h"


@implementation BOUtilityMethods

/**
 Returns the URL to the application's Documents directory.
 */
+ (NSURL *) applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager]
                            URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask]
                            lastObject];
}

@end
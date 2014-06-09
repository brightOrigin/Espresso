//
// Created by Tony Papale on 5/30/14.
// Copyright (c) 2014 Bright Origin. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
*
* This class handles all communication to the local data store including the
* building of the Core Data stack as well as the creation of private contexts
* for background processing of objects.
*
*/
@interface BOStore : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectContext *mainManagedObjectContext;

+ (BOStore *) sharedInstance;
- (BOOL) resetCoreDB;
- (void) releaseCoreDataStack;
- (void) saveContext;
- (void)saveContext:(NSManagedObjectContext *)context;
- (NSManagedObjectContext *) newPrivateContext;

- (NSOperationQueue *)getBackgroundCoreDataQueue;
+ (NSUInteger)backgroundCoreDataQueueCount;
- (void)addOperationToBackgroundCoreDataQueue:(NSOperation*)operation;

@end
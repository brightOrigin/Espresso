//
// Created by Tony Papale on 5/30/14.
// Copyright (c) 2014 Bright Origin. All rights reserved.
//

#import "BOBaseManagedObject.h"
#import "BOCDImportOperation.h"
#import "NSDictionary+Extensions.h"

@implementation BOBaseManagedObject

@dynamic id;

#pragma mark -
#pragma mark Data Importing methods

+ (void) importObjects:(NSDictionary *)importDataDictionary
{
    BOCDImportOperation *importOp = [[BOCDImportOperation alloc] initWithImportDataDictionary:importDataDictionary];
    [importOp setCompletionBlock:^
    {
        DLog(@"data import done");
    }];

    [[BOStore sharedInstance] addOperationToBackgroundCoreDataQueue:importOp];
}

+ (void) importObjectsWithArray:(NSArray *)importDataArray
{
    BOCDImportOperation *importOp = [[BOCDImportOperation alloc] initWithImportDataArray:importDataArray];
    [importOp setCompletionBlock:^
    {
        DLog(@"data import done");
    }];

    [[BOStore sharedInstance] addOperationToBackgroundCoreDataQueue:importOp];
}

- (void) buildEntityAttributeToServerNameMapping
{
    [super buildEntityAttributeToServerNameMapping];

    [self.serverNameToEntityAttributeMapping setValue:@"id" forKey:@"id"];
}

- (id) getValueForKeyAttributeWithName:(NSString *)keyAttributeName value:(id)value
{
//    if ([value isKindOfClass:[NSString class]])
//    {
//        return [NSNumber numberWithInteger:[value integerValue]];
//    }
//    else
//    {
//        return value;
//    }

    return value;
}

#pragma mark -
#pragma mark Data processing methods

+ (NSSet *) processNewOrUpdatedObjects:(NSArray *)theObjects inContext:(NSManagedObjectContext *)context
{
    return [self processNewOrUpdatedObjects:theObjects
                       withKeyAttributeName:@"id"
                     serverKeyAttributeName:@"id"
                                  inContext:context];
}

+ (NSArray *) getArrayForAttribute:(NSString *)attributeName fromResults:(NSArray *)resultsArray
{
    if (!resultsArray || !attributeName)
    {
        return nil;
    }

    NSMutableArray *returnArray = [[NSMutableArray alloc] initWithCapacity:[resultsArray count]];
    for (NSDictionary *currentResult in resultsArray)
    {
//        [returnArray addObject:[NSNumber numberWithInt:[[currentResult safeNullValueForKey:attributeName] intValue]]];
        [returnArray addObject:[currentResult safeNullValueForKey:attributeName]];
    }

    return returnArray;
}

+ (void) processUpdatedObjects:(NSArray *)updatedObjects inContext:(NSManagedObjectContext *)context
{
    [self processUpdatedObjects:updatedObjects withKey:@"id" inContext:context];
}


+ (void)processDeletedObjects:(NSArray *)deletedObjects inContext:(NSManagedObjectContext *)context
{
    [self processDeletedObjects:deletedObjects withKey:@"id" inContext:context];
}

@end
//
// Created by Tony Papale on 5/30/14.
// Copyright (c) 2014 Bright Origin. All rights reserved.
//

#import "BOManagedObject.h"
#import "BOStore.h"

@interface BOBaseManagedObject : BOManagedObject

//@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, copy) NSString * id;

+ (void) importObjects:(NSDictionary *)importDataDictionary;
+ (void) importObjectsWithArray:(NSArray *)importDataArray;


+ (NSSet *) processNewOrUpdatedObjects:(NSArray *)theObjects inContext:(NSManagedObjectContext *)context;
+ (void) processUpdatedObjects:(NSArray *)updatedObjects inContext:(NSManagedObjectContext *)context;
+ (void) processDeletedObjects:(NSArray *)deletedObjects inContext:(NSManagedObjectContext *)context;


@end
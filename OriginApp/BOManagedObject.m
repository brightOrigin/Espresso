//
// Created by Tony Papale on 5/30/14.
// Copyright (c) 2014 Bright Origin. All rights reserved.
//

#import "BOManagedObject.h"
#import "NSDictionary+SafeAccess.h"
#import "BOStringIDManagedObject.h"
#import "NSString+Decoding.h"

@implementation BOManagedObject

@synthesize serverNameToEntityAttributeMapping;

#pragma mark -
#pragma mark Convenience methods

+ (NSString *) entityName
{
    return NSStringFromClass([self class]);
}

+ (instancetype) insertNewObjectIntoContext:(NSManagedObjectContext *)context
{
    DLog(@"+++++++ Inserting new %@ entity", [self entityName]);
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName]
                                         inManagedObjectContext:context];
}

+ (NSEntityDescription *) getEntityDescriptionWithName:(NSString *)attributeName
                                             inContext:(NSManagedObjectContext *)context
{
    return ((NSEntityDescription *) [[[NSEntityDescription entityForName:[self entityName]
                                                  inManagedObjectContext:context]
                                                           propertiesByName]
                                                           objectForKey:attributeName]);
}

- (NSDictionary *) getPropertiesInContext:(NSManagedObjectContext *)context
{
    return [[BOManagedObject getEntityDescriptionWithName:[BOManagedObject entityName] inContext:context]
                             propertiesByName];
}

+ (instancetype) fetchOrCreateEntityInContext:(NSManagedObjectContext *)context
                                withPredicate:(id)stringOrPredicate, ...
{
    return [self fetchOrCreateEntityWithName:[self entityName]
                                   inContext:context
                               withPredicate:stringOrPredicate];
}

+ (instancetype) fetchOrCreateEntityWithName:(NSString *)entityName
                                   inContext:(NSManagedObjectContext *)context
                               withPredicate:(id)stringOrPredicate, ...
{
    NSArray *results = [self fetchEntitiesWithName:entityName
                                         inContext:context
                               withSortDescriptors:nil
                                     withPredicate:stringOrPredicate];

    if (results && [results count] == 1)
    {
        return [results firstObject];
    }
    else
    {
        return [self insertNewObjectIntoContext:context];
    }
}

+ (NSArray *) getArrayForAttribute:(NSString *)attributeName
                       fromResults:(NSArray *)resultsArray
                         inContext:(NSManagedObjectContext *)context
{
    if (!resultsArray || !attributeName)
    {
        return nil;
    }

    NSMutableArray *returnArray = [[NSMutableArray alloc] initWithCapacity:[resultsArray count]];

    NSAttributeType attributeType = [self typeForAttributeWithName:attributeName
                                                         inContext:context];

    if (attributeType == NSStringAttributeType)
    {
        for (NSDictionary *currentResult in resultsArray)
        {
            [returnArray addObject:[currentResult safeNullValueForKey:attributeName]];
        }
    }
    else if (attributeType == NSInteger16AttributeType ||
            attributeType == NSInteger32AttributeType ||
            attributeType == NSInteger64AttributeType)
    {
        for (NSDictionary *currentResult in resultsArray)
        {
            [returnArray addObject:[NSNumber numberWithInt:[[currentResult safeNullValueForKey:attributeName]
                         intValue]]];
        }
    }

    return returnArray;
}

- (NSString *) getValueAsString
{
    id name = [self valueForKey:@"name"];
    if (name && [name isKindOfClass:[NSString class]] && [name isNotBlank])
    {
        return name;
    }

    return @"";
}

+ (id) getValueForKeyAttributeWithName:(NSString *)keyAttributeName value:(id)value
{
    ALog(@"This should be implemented by subclass");

    return value;
}

#pragma mark -
#pragma mark Data processing methods

+ (NSSet *) processNewOrUpdatedObjects:(NSArray *)theObjects inContext:(NSManagedObjectContext *)context
{
    ALog(@"processNewOrUpdatedObjects should be implemented by subclass!!");
    return [self processNewOrUpdatedObjects:theObjects
                       withKeyAttributeName:nil
                     serverKeyAttributeName:nil
                                  inContext:context];
}

+ (NSArray *) getObjectsMatchingKeys:(NSArray *)objectKeys
                        forAttribute:(NSString *)keyAttribute
                           inContext:(NSManagedObjectContext *)context
{
    return [self fetchEntitiesInContext:context
                    withSortDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc]
                 initWithKey:keyAttribute ascending:YES]]
                          withPredicate:[NSPredicate predicateWithFormat:@"(%K IN %@)", keyAttribute, objectKeys]];
}

+ (NSSet *) processNewOrUpdatedObjects:(NSArray *)theObjects
                  withKeyAttributeName:(NSString *)keyAttribute
                serverKeyAttributeName:(NSString *)serverKeyAttribute
                             inContext:(NSManagedObjectContext *)context
{
    if (!theObjects || [theObjects count] == 0)
    {
        return nil;
    }

    NSMutableSet *objectsSet = [[NSMutableSet alloc] init];
    NSArray *updatedObjectKeys;
    NSArray *objectsMatchingKeys;

    if (keyAttribute && ![keyAttribute isEqualToString:@""])
    {
//        theObjects = [theObjects sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:keyAttribute ascending:YES selector:@selector(localizedStandardCompare:)]]];
        theObjects = [theObjects sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:keyAttribute ascending:YES selector:@selector(localizedCompare:)]]];

        updatedObjectKeys = [self getArrayForAttribute:serverKeyAttribute
                                           fromResults:theObjects
                                             inContext:context];

        objectsMatchingKeys = [self getObjectsMatchingKeys:updatedObjectKeys
                                              forAttribute:keyAttribute
                                                 inContext:context];
    }
    else
    {
        DLog(@"processNewOrUpdatedObjects keyAttribute is %@", keyAttribute);
    }

    // walk through the arrays
    int existingIndex = 0;
    for (int updateIndex = 0; updateIndex < [updatedObjectKeys count]; updateIndex++)
    {
        NSDictionary *currentUpdatedObject = [theObjects objectAtIndex:updateIndex];

        BOManagedObject *currentExistingObject = nil;
        if (existingIndex < [objectsMatchingKeys count])
        {
            currentExistingObject = [objectsMatchingKeys objectAtIndex:existingIndex];
        }

        BOManagedObject *newOrExistingObject;


        // create new object if nil or id doesn't match
//        int updateKey = [[currentUpdatedObject safeNullValueForKey:serverKeyAttribute] intValue];
//        int existingKey = [[currentExistingObject valueForKey:keyAttribute] intValue];
//
//        if (!currentExistingObject || (updateKey != existingKey))
//        {
//            newOrExistingObject = [self insertNewObjectIntoContext:context];
//        }
//                // existing object
//        else
//        {
//            newOrExistingObject = currentExistingObject;
//            existingIndex++;
//        }

        // create new object if nil or id doesn't match
        if ([self doesUpdateKey:[currentUpdatedObject safeNullValueForKey:serverKeyAttribute]
               matchExistingKey:[currentExistingObject valueForKey:keyAttribute]
                  attributeType:[self typeForAttributeWithName:keyAttribute inContext:context]])
        {
            newOrExistingObject = currentExistingObject;
            existingIndex++;
        }
        else
        {
            newOrExistingObject = [self insertNewObjectIntoContext:context];
        }


        [newOrExistingObject updateWithDictionary:currentUpdatedObject];

        [objectsSet addObject:newOrExistingObject];
    }

    return objectsSet;
}

+ (BOOL) doesUpdateKey:(id)updateKey
      matchExistingKey:(id)existingKey
         attributeType:(NSAttributeType)attributeType
{
    if (!updateKey || !existingKey)
    {
        return false;
    }

    if (attributeType == NSStringAttributeType)
    {
        // TODO: should check to make sure updateKey & existingKey are the same type
        if ([updateKey isEqualToString:existingKey])
        {
            return true;
        }
    }
    else if (attributeType == NSInteger16AttributeType ||
            attributeType == NSInteger32AttributeType ||
            attributeType == NSInteger64AttributeType)
    {
        if (([updateKey intValue] == [existingKey intValue]))
        {
            return true;
        }
    }

    return false;
}

+ (void) processUpdatedObjects:(NSArray *)updatedObjects
                       withKey:(NSString *)key
                     inContext:(NSManagedObjectContext *)context
{
    if (!updatedObjects || [updatedObjects count] == 0)
    {
        DLog(@"No objects to update");
        return;
    }

    NSArray *objectsMatchingKeys = [self getObjectsMatchingKeys:updatedObjects
                                                   forAttribute:key
                                                      inContext:context];

//    NSArray *objectsMatchingKeys = [self fetchEntitiesInContext:context
//                                            withSortDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc]
//                                                                                                            initWithKey:key ascending:YES]]
//                                                  withPredicate:[NSPredicate predicateWithFormat:@"(%K IN %@)", key, updatedObjects]];
//
    DLog(@"^^^^^^^ Updating following objects %@", objectsMatchingKeys);

    for (BOManagedObject *objectToUpdate in objectsMatchingKeys)
    {
        [objectToUpdate update];
    }
}

+ (void) processDeletedObjects:(NSArray *)deletedObjects inContext:(NSManagedObjectContext *)context
{
    [self processDeletedObjects:deletedObjects withKey:nil inContext:context];
}

+ (void) processDeletedObjects:(NSArray *)deletedObjects
                       withKey:(NSString *)key
                     inContext:(NSManagedObjectContext *)context
{
    if (!deletedObjects || [deletedObjects count] == 0)
    {
        DLog(@"No objects to delete");
        return;
    }

    NSArray *objectsMatchingKeys = [self getObjectsMatchingKeys:deletedObjects
                                                   forAttribute:key
                                                      inContext:context];


//    NSArray *objectsMatchingKeys = [self fetchEntitiesInContext:context
//                                            withSortDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc]
//                                                                                                            initWithKey:key ascending:YES]]
//                                                  withPredicate:[NSPredicate predicateWithFormat:@"(%K IN %@)", key, deletedObjects]];
//
    DLog(@"------- Deleting following objects %@", objectsMatchingKeys);
    for (BOManagedObject *objectToDelete in objectsMatchingKeys)
    {
        [self deleteObject:objectToDelete inContext:context];
    }
}

+ (void) deleteObject:(BOManagedObject *)object inContext:(NSManagedObjectContext *)context
{
    [context deleteObject:object];
}

- (void) update
{
    // subclass should implement:ie set dirty flag on object so that it know to update if its is requested
    // optionally batch update objects in the bg?
}

+ (NSAttributeType) typeForAttributeWithName:(NSString *)attributeName inContext:(NSManagedObjectContext *)context
{

    NSPropertyDescription *currentAttribute = [[[NSEntityDescription entityForName:[self entityName]
                                                            inManagedObjectContext:context]
                                                                     propertiesByName]
                                                                     objectForKey:attributeName];

    if ([currentAttribute isKindOfClass:[NSAttributeDescription class]])
    {
        return [((NSAttributeDescription *) currentAttribute) attributeType];
    }

    return NSUndefinedAttributeType;
}

- (void) updateWithDictionary:(NSDictionary *)data
{
    NSDictionary *properties = [[self entity] propertiesByName];

    NSArray *attributes = [properties allKeys];

    for (NSString *currentAttributeName in attributes)
    {
        NSString *serverName = [self.serverNameToEntityAttributeMapping valueForKey:currentAttributeName];

        if (!serverName)
        {
            DLog(@"No server parameter found with name %@ in server object for %@ entity", currentAttributeName, [self class]);
        }
        else
        {
            NSPropertyDescription *currentAttribute = (NSPropertyDescription *) [properties valueForKey:currentAttributeName];

            if ([currentAttribute isKindOfClass:[NSAttributeDescription class]])
            {
                NSAttributeType attributeType = [((NSAttributeDescription *) currentAttribute) attributeType];

                if (attributeType == NSStringAttributeType)
                {
                    [self updateAttribute:currentAttributeName
                                withValue:[data safeNullValueForKey:serverName]];
                }
                else if (attributeType == NSDateAttributeType)
                {
                    [self updateAttribute:currentAttributeName
                                withValue:[NSDate dateWithTimeIntervalSince1970:([[data safeNullValueForKey:serverName]
                                                                                        doubleValue])]];
                }
                else if (attributeType == NSInteger16AttributeType ||
                        attributeType == NSInteger32AttributeType ||
                        attributeType == NSInteger64AttributeType)
                {
                    // if value is a string and "" then that means its either Null or has no value in which case we shouldnt update it
                    if ([[data safeNullValueForKey:serverName] isKindOfClass:[NSString class]])
                    {
                        if ([[data safeNullValueForKey:serverName] isNotBlank])
                        {
                            [self updateAttribute:currentAttributeName
                                        withValue:[NSNumber numberWithInteger:[[data safeNullValueForKey:serverName]
                                  integerValue]]];
                        }
                    }
                    else
                    {
                        if ([data safeNullValueForKey:serverName])
                        {
                            [self updateAttribute:currentAttributeName
                                        withValue:[NSNumber numberWithInteger:[[data safeNullValueForKey:serverName]
                                  integerValue]]];
                        }
                    }
                }
                else if (attributeType == NSFloatAttributeType)
                {
                    // if value is a string and "" then that means its either Null or has no value in which case we shouldnt update it
                    if ([[data safeNullValueForKey:serverName] isKindOfClass:[NSString class]])
                    {
                        if ([[data safeNullValueForKey:serverName] isNotBlank])
                        {
                            [self updateAttribute:currentAttributeName
                                        withValue:[NSNumber numberWithFloat:[[data safeNullValueForKey:serverName]
                                  floatValue]]];

                        }
                    }
                    else
                    {
                        [self updateAttribute:currentAttributeName
                                    withValue:[NSNumber numberWithFloat:[[data safeNullValueForKey:serverName]
                              floatValue]]];

                    }
                }
                else if (attributeType == NSDoubleAttributeType)
                {
                    // if value is a string and "" then that means its either Null or has no value in which case we shouldnt update it
                    if ([[data safeNullValueForKey:serverName] isKindOfClass:[NSString class]])
                    {
                        if ([[data safeNullValueForKey:serverName] isNotBlank])
                        {
                            [self updateAttribute:currentAttributeName
                                        withValue:[NSNumber numberWithDouble:[[data safeNullValueForKey:serverName]
                                  doubleValue]]];

                        }
                    }
                    else
                    {
                        [self updateAttribute:currentAttributeName
                                    withValue:[NSNumber numberWithDouble:[[data safeNullValueForKey:serverName]
                              doubleValue]]];

                    }
                }
                else if (attributeType == NSBooleanAttributeType)
                {
                    [self updateAttribute:currentAttributeName
                                withValue:[NSNumber numberWithBool:[[data safeNullValueForKey:serverName] boolValue]]];
                }

            }
            else if ([currentAttribute isKindOfClass:[NSRelationshipDescription class]])
            {
                id serverObject = [data safeNullValueForKey:serverName];

                // to-many relationship
                if ([((NSRelationshipDescription *) currentAttribute) isToMany])
                {
                    // if the relationship object contains the full or partial object then process the whole thing
                    if ([serverObject isKindOfClass:[NSArray class]])
                    {
                        NSSet *relationshipObjects;

                        if ([serverObject count] > 0)
                        {
                            Class baseManagedObjectClass = NSClassFromString([[((NSRelationshipDescription *) currentAttribute) destinationEntity]
                                                                                                                                managedObjectClassName]);

                            relationshipObjects = [baseManagedObjectClass processNewOrUpdatedObjects:((NSArray *) [data safeNullValueForKey:serverName])
                                                                                           inContext:self.managedObjectContext];
                        }
                        else
                        {
                            // if relationship no longer has any objects then set to empty set
                            relationshipObjects = [NSSet set];
                        }

//                        [self setValue:relationshipObjects forKey:currentAttributeName];


                        [self setToManyRelationshipWithObjects:relationshipObjects
                                              relationshipName:currentAttributeName
                                                     inContext:self.managedObjectContext];

                    }
                    else if ([serverObject isKindOfClass:[NSDictionary class]])
                    {
                        NSSet *relationshipObjects;

                        if ([serverObject count] > 0)
                        {
                            Class baseManagedObjectClass = NSClassFromString([[((NSRelationshipDescription *) currentAttribute) destinationEntity]
                                                                                                                                managedObjectClassName]);
                            relationshipObjects = [baseManagedObjectClass processNewOrUpdatedObjects:[NSArray arrayWithObject:((NSDictionary *) [data safeNullValueForKey:serverName])]
                                                                                           inContext:self.managedObjectContext];
                        }
                        else
                        {
                            // if relationship no longer has any objects then set to empty set
                            relationshipObjects = [NSSet set];
                        }

//                        [self setValue:relationshipObjects forKey:currentAttributeName];

                        [self setToManyRelationshipWithObjects:relationshipObjects
                                              relationshipName:currentAttributeName
                                                     inContext:self.managedObjectContext];

                    }
                }
                    // to-one relationship
                else
                {
                    if ([serverObject isKindOfClass:[NSDictionary class]])
                    {
                        if ([serverObject count] > 0)
                        {
                            [self updateRelationship:currentAttributeName
                                          withEntity:[[((NSRelationshipDescription *) currentAttribute) destinationEntity]
                                  name]
                                                data:serverObject
                                             context:self.managedObjectContext];
                        }
                        else
                        {
                            // if relationship no longer has any objects then set to empty set
//                            [self setValue:nil forKey:currentAttributeName];
                            [self setToOneRelationshipWithObject:nil
                                                relationshipName:currentAttributeName
                                                       inContext:self.managedObjectContext];
                        }
                    }
                        // if the relationship is just an id then we just need to link the object to this object
                    else if (([serverObject isKindOfClass:[NSString class]] && [((NSString *) serverObject) isNotBlank]) ||
                            ([serverObject isKindOfClass:[NSNumber class]] && [[data safeNullValueForKey:serverName]
                                                                                     integerValue] != 0))
                    {
                        // TODO: update this to use the processNewOrUpdatedObject: method that will allow for the subclass to specify
                        // TODO: a different id name like user_id
                        [self updateRelationship:currentAttributeName
                                      withEntity:[[((NSRelationshipDescription *) currentAttribute) destinationEntity] name]
                                          withID:[NSNumber numberWithInt:[[data safeNullValueForKey:serverName]
                              integerValue]]];
                    }
                        // this is a special case which allows a relationship entity to use the parents dictionary to update itself
                    else if ([serverName isNotBlank] && [serverName isEqualToString:kEntityAttributeToServerNameSelf])
                    {
                        [self updateRelationship:currentAttributeName
                                      withEntity:[[((NSRelationshipDescription *) currentAttribute) destinationEntity]
                              name]
                                            data:data
                                         context:self.managedObjectContext];
                    }
                }
            }
        }
    }
}

- (void) setToOneRelationshipWithObject:(BOManagedObject *)relationshipObject
                       relationshipName:(NSString *)relationshipName
                              inContext:(NSManagedObjectContext *)context
{
    BOManagedObject *existingRelationshipObjectToDelete = [self valueForKey:relationshipName];

    if (!existingRelationshipObjectToDelete && relationshipObject)
    {
        [self setValue:relationshipObject forKey:relationshipName];
    }
    else if (relationshipObject != existingRelationshipObjectToDelete)
    {
        [context deleteObject:existingRelationshipObjectToDelete];
        [self setValue:relationshipObject forKey:relationshipName];
    }

//    [self setValue:relationshipObject forKey:relationshipName];
}

- (void) setToManyRelationshipWithObjects:(NSSet *)relationshipObjects
                         relationshipName:(NSString *)relationshipName
                                inContext:(NSManagedObjectContext *)context
{
    NSMutableSet *existingRelationshipObjects = [self mutableSetValueForKey:relationshipName];
//    NSMutableArray *existingRelationshipObjects = [[self valueForKey:relationshipName] allObjects];

    NSMutableArray *existingRelationshipObjectsToDelete = [NSMutableArray array];
    NSMutableArray *newRelationshipObjectsToAdd = [NSMutableArray array];

    // if the current relationship set is empty then set the new relationship objects
    if (!existingRelationshipObjects && relationshipObjects)
    {
        [self setValue:relationshipObjects forKey:relationshipName];
    }
    else
    {
        // delete any exisitng objects that are not in the new set of relationship objects
        for (BOManagedObject *existingManagedObject in existingRelationshipObjects)
        {
            if (![relationshipObjects containsObject:existingManagedObject])
            {
//                [existingRelationshipObjects removeObject:existingManagedObject];
                [existingRelationshipObjectsToDelete addObject:existingManagedObject];
                [context deleteObject:existingManagedObject];
            }
        }

        // add any new relationship objects to the set
        for (BOManagedObject *newManagedObject in relationshipObjects)
        {
            if (![existingRelationshipObjects containsObject:newManagedObject])
            {
                [newRelationshipObjectsToAdd addObject:newManagedObject];
//                [existingRelationshipObjects addObject:newManagedObject];
            }
        }
    }

    // remove any objects we need to delete
    for (BOManagedObject *objectToDelete in existingRelationshipObjectsToDelete)
    {
        [existingRelationshipObjects removeObject:objectToDelete];
    }


    [existingRelationshipObjects addObjectsFromArray:newRelationshipObjectsToAdd];



//    NSMutableSet *existingRelationshipObjects = [self valueForKey:relationshipName];
//
//    [existingRelationshipObjects minusSet:relationshipObjects];
//
//    for (BOManagedObject *toDelete in existingRelationshipObjects)
//    {
//        [context deleteObject:toDelete];
//    }
//
//    [self setValue:relationshipObjects forKey:relationshipName];
}


- (void) updateAttribute:(NSString *)attributeName withValue:(id)value
{
    if (!value || !attributeName || [attributeName isEqualToString:@""])
    {
        return;
    }

    if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSConstantString class]])
    {
        NSString *unescapedValue = [value decodeHtml];

        if (![[self valueForKey:attributeName] isEqualToString:unescapedValue])
        {
            if ([value isEqualToString:@""] && [[self valueForKey:attributeName] isNotBlank])
            {
                [self setValue:unescapedValue forKey:attributeName];
            }
            else if ([value isNotBlank])
            {
                [self setValue:unescapedValue forKey:attributeName];
            }
        }
    }
    else if ([value isKindOfClass:[NSNumber class]])
    {
        if (![((NSNumber *) [self valueForKey:attributeName]) isEqualToNumber:value])
        {
            [self setValue:value forKey:attributeName];
        }
    }
    else if ([value isKindOfClass:[NSDate class]])
    {
        if (![[self valueForKey:attributeName] isEqualToDate:value])
        {
            [self setValue:value forKey:attributeName];
        }
    }
    else if ([value isKindOfClass:[NSNull class]])
    {
        return;
    }
    else
    {
        ALog(@"Value type not recognized, comparison might be inaccurate");
        if (![[self valueForKey:attributeName] isEqual:value])
        {
            [self setValue:value forKey:attributeName];
        }
    }
}

- (void) updateRelationship:(NSString *)relationshipName
                 withEntity:(NSString *)relationshipEntityName
                     withID:(NSNumber *)entityID
{
    if (!entityID || !relationshipName || [relationshipName isEqualToString:@""])
    {
        return;
    }

    BOStringIDManagedObject *theObject = [[BOManagedObject fetchEntitiesWithName:relationshipEntityName
                                                                   inContext:self.managedObjectContext
                                                         withSortDescriptors:nil
                                                               withPredicate:[NSPredicate predicateWithFormat:@"id = %@", entityID]]
                                                       firstObject];

    if (theObject &&
            (![self valueForKey:relationshipName] || [theObject.id isEqualToString:[[self valueForKey:relationshipName]
                                                                   valueForKey:@"id"]]))
//    if (theObject && (![self valueForKey:relationshipName] || [theObject.id integerValue] != [[[self valueForKey:relationshipName]
//                                                                            valueForKey:@"id"]
//                                                                            integerValue]))
    {
        [self setToOneRelationshipWithObject:theObject
                            relationshipName:relationshipName
                                   inContext:self.managedObjectContext];
    }
    else
    {
        // TODO: look into automatically downloading the missing object from the server
    }
}

- (void) updateRelationship:(NSString *)relationshipName
                 withEntity:(NSString *)relationshipEntityName
                       data:(NSDictionary *)data
                    context:(NSManagedObjectContext *)context
{
    if (!data || !relationshipName || [relationshipName isEqualToString:@""] || [data count] == 0)
    {
        return;
    }

    Class baseManagedObjectClass = NSClassFromString(relationshipEntityName);
    NSSet *relationships = [baseManagedObjectClass processNewOrUpdatedObjects:[NSArray arrayWithObject:data]
                                                                    inContext:context];

//    [self setValue:[relationships anyObject] forKey:relationshipName];
    [self setToOneRelationshipWithObject:[relationships anyObject]
                        relationshipName:relationshipName
                               inContext:context];
}

- (void) updateToManyRelationship:(NSString *)relationshipName
                       withEntity:(NSString *)relationshipEntityName
                          objects:(NSArray *)objects
                          context:(NSManagedObjectContext *)context
{
    if (!objects || [objects count] == 0 || !relationshipName || [relationshipName isEqualToString:@""])
    {
        return;
    }

    Class baseManagedObjectClass = NSClassFromString(relationshipEntityName);
    NSSet *relationships = [baseManagedObjectClass processNewOrUpdatedObjects:objects
                                                                    inContext:context];

//    [self setValue:relationships forKey:relationshipName];
    [self setToManyRelationshipWithObjects:relationships
                          relationshipName:relationshipName
                                 inContext:context];
}

- (void) updateToOneRelationship:(NSString *)relationshipName
                      withEntity:(NSString *)relationshipEntityName
                         objects:(NSArray *)objects
                         context:(NSManagedObjectContext *)context
{
    if (!objects || [objects count] == 0 || !relationshipName || [relationshipName isEqualToString:@""])
    {
        return;
    }

    Class baseManagedObjectClass = NSClassFromString(relationshipEntityName);
    NSSet *relationships = [baseManagedObjectClass processNewOrUpdatedObjects:objects
                                                                    inContext:context];

//    [self setValue:[relationships anyObject] forKey:relationshipName];
    [self setToOneRelationshipWithObject:[relationships anyObject]
                        relationshipName:relationshipName
                               inContext:context];
}

#pragma mark -
#pragma mark Fetching methods


+ (NSArray *) fetchAllObjectsForAttribute:(NSString *)attributeName inContext:(NSManagedObjectContext *)context
{
    NSArray *resultsArray = [self fetchEntitiesInContext:context
                                     withSortDescriptors:@[[[NSSortDescriptor alloc]
                                                                              initWithKey:attributeName ascending:YES]
                                     ]
                                       propertiesToFetch:[NSArray arrayWithObject:[self getEntityDescriptionWithName:attributeName
                                                                                                           inContext:context]]
                                  includesPropertyValues:YES
                                           withPredicate:nil];

    NSMutableArray *returnArray = nil;

    if (resultsArray)
    {
        returnArray = [NSMutableArray arrayWithCapacity:[resultsArray count]];

        for (NSDictionary *idDict in resultsArray)
        {
            [returnArray addObject:[idDict objectForKey:@"id"]];
        }
    }

    return returnArray ? returnArray : [NSArray array];
}

+ (NSArray *) fetchAllObjectsForAttribute:(NSString *)attributeName
                            withPredicate:(NSPredicate *)predicate
                                inContext:(NSManagedObjectContext *)context
{
    NSArray *resultsArray = [self fetchEntitiesInContext:context
                                     withSortDescriptors:@[[[NSSortDescriptor alloc]
                                                                              initWithKey:attributeName ascending:YES]
                                     ]
                                       propertiesToFetch:[NSArray arrayWithObject:[self getEntityDescriptionWithName:attributeName
                                                                                                           inContext:context]]
                                  includesPropertyValues:YES
                                           withPredicate:predicate];

    NSMutableArray *returnArray = nil;

    if (resultsArray)
    {
        returnArray = [NSMutableArray arrayWithCapacity:[resultsArray count]];

        for (NSDictionary *idDict in resultsArray)
        {
            [returnArray addObject:[idDict objectForKey:@"id"]];
        }
    }

    return returnArray ? returnArray : [NSArray array];
}

+ (NSSet *) fetchEntitiesInContext:(NSManagedObjectContext *)context
                     withPredicate:(id)stringOrPredicate, ...
{
    NSSet *results = [NSSet setWithArray:[self fetchEntitiesInContext:context
                                                  withSortDescriptors:nil
                                               includesPropertyValues:YES
                                                        withPredicate:stringOrPredicate]];
    return results;
}

+ (NSArray *) fetchEntitiesInContext:(NSManagedObjectContext *)context
                 withSortDescriptors:(NSArray *)sortDescriptors
                       withPredicate:(id)stringOrPredicate, ...
{
    return [self fetchEntitiesInContext:context
                    withSortDescriptors:sortDescriptors
                 includesPropertyValues:YES
                          withPredicate:stringOrPredicate];
}

+ (NSArray *) fetchEntitiesWithName:(NSString *)entityName
                          inContext:(NSManagedObjectContext *)context
                withSortDescriptors:(NSArray *)sortDescriptors
                      withPredicate:(id)stringOrPredicate, ...
{
    return [self fetchEntitiesWithName:entityName
                             inContext:context
                   withSortDescriptors:sortDescriptors
                     propertiesToFetch:nil
                includesPropertyValues:YES
                  returnDistinctValues:NO
                         withPredicate:stringOrPredicate];
}

+ (NSArray *) fetchEntitiesInContext:(NSManagedObjectContext *)context
                 withSortDescriptors:(NSArray *)sortDescriptors
              includesPropertyValues:(BOOL)includeProperties
                       withPredicate:(id)stringOrPredicate, ...
{
    return [self fetchEntitiesInContext:context
                    withSortDescriptors:sortDescriptors
                      propertiesToFetch:nil
                 includesPropertyValues:includeProperties
                          withPredicate:stringOrPredicate];
}

+ (NSArray *) fetchEntitiesInContext:(NSManagedObjectContext *)context
                 withSortDescriptors:(NSArray *)sortDescriptors
                   propertiesToFetch:(NSArray *)propertiesToFetch
              includesPropertyValues:(BOOL)includeProperties
                       withPredicate:(id)stringOrPredicate, ...
{
    return [self fetchEntitiesWithName:[self entityName]
                             inContext:context
                   withSortDescriptors:sortDescriptors
                     propertiesToFetch:propertiesToFetch
                includesPropertyValues:includeProperties
                  returnDistinctValues:NO
                         withPredicate:stringOrPredicate];
}

+ (NSArray *) fetchEntitiesWithName:(NSString *)entityName
                          inContext:(NSManagedObjectContext *)context
                withSortDescriptors:(NSArray *)sortDescriptors
                  propertiesToFetch:(NSArray *)propertiesToFetch
             includesPropertyValues:(BOOL)includeProperties
               returnDistinctValues:(BOOL)returnsDistinctValues
                      withPredicate:(id)stringOrPredicate, ...
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];

    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setReturnsDistinctResults:returnsDistinctValues];

    if (stringOrPredicate)
    {
        NSPredicate *predicate;
        if ([stringOrPredicate isKindOfClass:[NSString class]])
        {
            va_list variadicArguments;
            va_start(variadicArguments, stringOrPredicate);
            predicate = [NSPredicate predicateWithFormat:stringOrPredicate
                                               arguments:variadicArguments];
            va_end(variadicArguments);
        }
        else
        {
            NSAssert2([stringOrPredicate isKindOfClass:[NSPredicate class]],
                      @"Second parameter passed to %s is of unexpected class %@",
                      sel_getName(_cmd), NSStringFromClass(stringOrPredicate));
            predicate = (NSPredicate *) stringOrPredicate;
        }
        [request setPredicate:predicate];
    }

    if (sortDescriptors)
    {
        [request setSortDescriptors:sortDescriptors];
    }

    if (!includeProperties)
    {
        [request setIncludesPropertyValues:includeProperties];
    }

    if (propertiesToFetch)
    {
        [request setPropertiesToFetch:propertiesToFetch];
        request.resultType = NSDictionaryResultType;
    }

    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (error != nil)
    {
        ALog(@"Error performing fetch request %@, %@", [error description], [error userInfo]);
//        [NSException raise:NSGenericException format:@"%@", [error description]];
    }

//    DLog(@"Found %i results for fetch request %@", [results count], request);
    return [results count] > 0 ? results : nil;
}

- (void) buildEntityAttributeToServerNameMapping
{
    serverNameToEntityAttributeMapping = [[NSMutableDictionary alloc] init];
}

- (NSMutableDictionary *) serverNameToEntityAttributeMapping
{
    if (!serverNameToEntityAttributeMapping)
    {
        [self buildEntityAttributeToServerNameMapping];
    }

    return serverNameToEntityAttributeMapping;
}

@end
//
// Created by Tony Papale on 5/30/14.
// Copyright (c) 2014 Bright Origin. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const kEntityAttributeToServerNameSelf = @"___SELF___";

/**
*
* This class is the superclass for all managed objects within the app. It provides a bunch
* of useful utility methods such as creating and fetching objects from the data store.
*
* It also acts as a mapping layer between server side objects and the local object graph
* making it trivial to modify server/local object models as well as handling changes/deletions/insertions.
*
*/

@interface BOManagedObject : NSManagedObject
{
    NSMutableDictionary *serverNameToEntityAttributeMapping;
}

@property (nonatomic, retain) NSMutableDictionary *serverNameToEntityAttributeMapping;

+ (NSString *) entityName;
+ (NSEntityDescription *) getEntityDescriptionWithName:(NSString *)attributeName inContext:(NSManagedObjectContext *)context;

- (NSDictionary *) getPropertiesInContext:(NSManagedObjectContext *)context;
- (NSString *) getValueAsString;

+ (id) getValueForKeyAttributeWithName:(NSString *)keyAttributeName value:(id)value;
+ (instancetype) insertNewObjectIntoContext:(NSManagedObjectContext *)context;
+ (instancetype) fetchOrCreateEntityInContext:(NSManagedObjectContext *)context withPredicate:(id)stringOrPredicate, ...;
+ (instancetype) fetchOrCreateEntityWithName:(NSString *)entityName inContext:(NSManagedObjectContext *)context withPredicate:(id)stringOrPredicate, ...;


+ (NSArray *)getObjectsMatchingKeys:(NSArray *)objectKeys forAttribute:(NSString *)keyAttribute inContext:(NSManagedObjectContext *)context;

+ (NSArray *) getArrayForAttribute:(NSString *)attributeName fromResults:(NSArray *)resultsArray inContext:(NSManagedObjectContext *)context;
+ (BOOL) doesUpdateKey:(id)updateKey matchExistingKey:(id)existingKey attributeType:(NSAttributeType)attributeType;

/**
* Object and attribute processing
*/
+ (NSSet *) processNewOrUpdatedObjects:(NSArray *)theObjects inContext:(NSManagedObjectContext *)context;
+ (NSSet *) processNewOrUpdatedObjects:(NSArray *)theObjects withKeyAttributeName:(NSString *)keyAttribute serverKeyAttributeName:(NSString *)serverKeyAttribute inContext:(NSManagedObjectContext *)context;
+ (void) processUpdatedObjects:(NSArray *)updatedObjects withKey:(NSString *)key inContext:(NSManagedObjectContext *)context;
+ (void) processDeletedObjects:(NSArray *)deletedObjects inContext:(NSManagedObjectContext *)context;
+ (void) processDeletedObjects:(NSArray *)deletedObjects withKey:(NSString *)key inContext:(NSManagedObjectContext *)context;
+ (void) deleteObject:(BOManagedObject *)object inContext:(NSManagedObjectContext *)context;

- (void) updateAttribute:(NSString *)attributeName withValue:(id)value;

/**
* Relationship processing
*/
- (void) updateRelationship:(NSString *)relationshipName withEntity:(NSString *)relationshipEntityName withID:(NSNumber *)entityID;
- (void) updateRelationship:(NSString *)relationshipName withEntity:(NSString *)relationshipEntityName data:(NSDictionary *)data context:(NSManagedObjectContext *)context;
- (void) updateToManyRelationship:(NSString *)relationshipName withEntity:(NSString *)relationshipEntityName objects:(NSArray *)objects context:(NSManagedObjectContext *)context;
- (void) updateToOneRelationship:(NSString *)relationshipName withEntity:(NSString *)relationshipEntityName objects:(NSArray *)objects context:(NSManagedObjectContext *)context;
- (void) setToOneRelationshipWithObject:(BOManagedObject *)relationshipObject relationshipName:(NSString *)relationshipName inContext:(NSManagedObjectContext *)context;
- (void) setToManyRelationshipWithObjects:(NSSet *)relationshipObjects relationshipName:(NSString *)relationshipName inContext:(NSManagedObjectContext *)context;

/**
* Object fetching
*/
+ (NSArray *) fetchAllObjectsForAttribute:(NSString *)attributeName inContext:(NSManagedObjectContext *)context;
+ (NSArray *) fetchAllObjectsForAttribute:(NSString *)attributeName withPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context;
+ (NSSet *) fetchEntitiesInContext:(NSManagedObjectContext *)context withPredicate:(id)stringOrPredicate, ...;
+ (NSArray *) fetchEntitiesWithName:(NSString *)entityName inContext:(NSManagedObjectContext *)context withSortDescriptors:(NSArray *)sortDescriptors withPredicate:(id)stringOrPredicate, ...;
+ (NSArray *) fetchEntitiesInContext:(NSManagedObjectContext *)context withSortDescriptors:(NSArray *)sortDescriptors withPredicate:(id)stringOrPredicate, ...;
+ (NSArray *) fetchEntitiesInContext:(NSManagedObjectContext *)context withSortDescriptors:(NSArray *)sortDescriptors includesPropertyValues:(BOOL)includeProperties withPredicate:(id)stringOrPredicate, ...;
+ (NSArray *) fetchEntitiesInContext:(NSManagedObjectContext *)context withSortDescriptors:(NSArray *)sortDescriptors propertiesToFetch:(NSArray *)propertiesToFetch includesPropertyValues:(BOOL)includeProperties withPredicate:(id)stringOrPredicate, ...;
+ (NSArray *) fetchEntitiesWithName:(NSString *)entityName inContext:(NSManagedObjectContext *)context withSortDescriptors:(NSArray *)sortDescriptors propertiesToFetch:(NSArray *)propertiesToFetch includesPropertyValues:(BOOL)includeProperties returnDistinctValues:(BOOL)returnsDistinctValues withPredicate:(id)stringOrPredicate, ...;


- (void) buildEntityAttributeToServerNameMapping;
- (void) updateWithDictionary:(NSDictionary *)data;
- (void) update;

@end
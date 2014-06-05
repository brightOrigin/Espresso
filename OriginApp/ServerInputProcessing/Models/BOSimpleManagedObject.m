//
// Created by Tony Papale on 5/30/14.
// Copyright (c) 2014 Bright Origin. All rights reserved.
//

#import "BOSimpleManagedObject.h"

@implementation BOSimpleManagedObject

@dynamic name;
@dynamic modifiedDate;

- (void) buildEntityAttributeToServerNameMapping
{
    [super buildEntityAttributeToServerNameMapping];
    [self.serverNameToEntityAttributeMapping setValue:@"last_updated" forKey:@"modifiedDate"];
    [self.serverNameToEntityAttributeMapping setValue:@"name" forKey:@"name"];
}


- (void) updateWithDictionary:(NSDictionary *)data
{
    [super updateWithDictionary:data];
}

- (NSString *) getValueAsString
{
    // even though this is a set it will always only be a single currency
    return self.name;
}

@end
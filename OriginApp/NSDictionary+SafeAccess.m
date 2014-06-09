
@implementation NSDictionary (SafeAccess)


- (id)safeNullValueForKey:(NSString *)key
{
    if (((NSNull *)[self valueForKey:key]) == [NSNull null])
    {
        return @"";
    }

    return [self valueForKeyPath:key];
}

@end

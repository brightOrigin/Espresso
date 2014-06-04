//
// Created by Tony on 11/18/13.
//


#import "NSFetchedResultsController+LoggedFetch.h"


@implementation NSFetchedResultsController (LoggedFetch)

- (void) executeLoggedFetchRequest
{
    NSError *error = nil;
    if (![self performFetch:&error])
    {
        // Update to handle the error appropriately.
        ALog(@"ERROR!!!! Unresolved error performing fetch with allEventsFetchedResultsController %@, %@", error, [error userInfo]);
    }
}
@end
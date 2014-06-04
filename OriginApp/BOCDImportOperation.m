//
// Created by Tony on 10/21/13.
//


#import "BOCDImportOperation.h"
#import "BOStore.h"


@implementation BOCDImportOperation

@synthesize context;
@synthesize operationDataDictionary;
@synthesize operationDataArray;

- (id) initWithImportDataDictionary:(NSDictionary *)dataDictionary
{
    self = [super init];
    if (self)
    {
        self.operationDataDictionary = dataDictionary;
    }
    return self;
}

- (id) initWithImportDataArray:(NSArray *)dataArray
{
    self = [super init];
    if (self)
    {
        self.operationDataArray = dataArray;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) main
{
    self.context = [[BOStore sharedInstance] newPrivateContext];
    DLog(@"created new private context");

    // Register context with the notification center
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(mergeChanges:)
                               name:NSManagedObjectContextDidSaveNotification
                             object:self.context];

    DLog(@"added observer");

}

- (void) mergeChanges:(NSNotification *)notification
{
    NSManagedObjectContext *mainContext = [[BOStore sharedInstance] mainManagedObjectContext];

    // Merge changes into the main context on the main thread
    DLog(@"Merging changes onto main thread");
    [mainContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:)
                                  withObject:notification
                               waitUntilDone:YES];

    DLog(@"mergeChanges done");
}

@end
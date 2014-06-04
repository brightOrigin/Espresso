//
// Created by Tony Papale on 5/30/14.
// Copyright (c) 2014 Bright Origin. All rights reserved.
//

#import "BOStore.h"
#import "BOUtilityMethods.h"

#define kCoreDataName                   @"CoreDataWrapper"
#define kCoreDataFile                   @"CoreDataWrapper.sqlite"
#define kCoreDataSHMFile                @"CoreDataWrapper.sqlite-shm"
#define kCoreDataWALFile                @"CoreDataWrapper.sqlite-wal"

@interface BOStore ()

@property (nonatomic, strong) NSOperationQueue *backgroundCoreDataQueue;
@property (nonatomic, strong, readwrite) NSManagedObjectContext *mainManagedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation BOStore

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Setup

- (id) init
{
    self = [super init];
    if (self)
    {
//        [self setupSaveNotification];
        self.mainManagedObjectContext = [self mainManagedObjectContext];

        // Set up the background queue.
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [queue setName:@"com.brightorigin.backgroundCoreData"];
        [queue setMaxConcurrentOperationCount:1];
//        [queue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
        self.backgroundCoreDataQueue = queue;
    }

    return self;
}

+ (BOStore *) sharedInstance
{
    static dispatch_once_t pred;
    static BOStore *sharedInstance = nil;

    dispatch_once(&pred, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void) setupSaveNotification
{
    [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note)
            {
                NSManagedObjectContext *moc = self.mainManagedObjectContext;
                if (note.object != moc)
                {
                    [moc performBlock:^()
                            {
                                [moc mergeChangesFromContextDidSaveNotification:note];
                            }];
                }
            }];
}

#pragma mark - Core Date MOC Methods

- (void) saveContext
{
    [self saveContext:self.mainManagedObjectContext];
}

- (void) saveContext:(NSManagedObjectContext *)context
{
    NSError *error = nil;
    if (context != nil)
    {
        if ([context hasChanges])
        {
            DLog(@"Saving changes for context %@", context);

            if (![context save:&error])
            {
                DLog(@"Failed to save to data store: %@", [error localizedDescription]);
                NSArray *detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
                if (detailedErrors != nil && [detailedErrors count] > 0)
                {
                    for (NSError *detailedError in detailedErrors)
                    {
                        ALog(@"  DetailedError: %@", [detailedError userInfo]);
                    }
                }
                else
                {
                    ALog(@"  %@", [error userInfo]);
                }
            }
            else
            {
                DLog(@"Saved context %@ to data store", context);
            }
        }
        else
        {
            DLog(@"No changes to save for context %@", context);
        }
    }
}

/**
Resets core data stack after deletion so it can be rebuilt
*/
- (void) releaseCoreDataStack
{
    _mainManagedObjectContext = nil;
    _managedObjectModel = nil;
    _persistentStoreCoordinator = nil;

//    [Boutility getMOContext];
}

- (BOOL) resetCoreDB
{
    // if storeCoordinator is nil then most likely apps first launch
    if (!_persistentStoreCoordinator)
    {
        return YES;
    }

    NSURL *storeURL = [[BOUtilityMethods applicationDocumentsDirectory] URLByAppendingPathComponent:kCoreDataFile];

    NSPersistentStore *store = [_persistentStoreCoordinator persistentStoreForURL:storeURL];

    NSError *error;

    ALog(@"WARNING - Resetting persistent store %@", storeURL);

    if (![_persistentStoreCoordinator removePersistentStore:store error:&error])
    {
        ALog(@"Error removing persistent store %@", error);
        return NO;
    }

    // remove .sqlite file
    if (![[NSFileManager defaultManager]
                         removeItemAtPath:storeURL.path error:&error])
    {
        ALog(@"Error removing persistent store file %@", error);
        return NO;
    }

    // remove .sqlite-shm file
    if (![[NSFileManager defaultManager]
                         removeItemAtPath:[[BOUtilityMethods applicationDocumentsDirectory]
                                                             URLByAppendingPathComponent:kCoreDataSHMFile].path
                                    error:&error])
    {
        ALog(@"Error removing persistent store file %@", error);
        return NO;
    }

    // remove .sqlite-wal file
    if (![[NSFileManager defaultManager]
                         removeItemAtPath:[[BOUtilityMethods applicationDocumentsDirectory]
                                                             URLByAppendingPathComponent:kCoreDataWALFile].path
                                    error:&error])
    {
        ALog(@"Error removing persistent store file %@", error);
        return NO;
    }

    ALog(@"Successfully reset persistent store");

    // now rebuild stack
    [self releaseCoreDataStack];

    return YES;
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *) mainManagedObjectContext
{
    if (_mainManagedObjectContext != nil)
    {
        return _mainManagedObjectContext;
    }

    _mainManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    _mainManagedObjectContext.persistentStoreCoordinator = [self persistentStoreCoordinator];
    [_mainManagedObjectContext setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];

    return _mainManagedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *) managedObjectModel
{
    if (_managedObjectModel != nil)
    {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:kCoreDataName withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *) persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil)
    {
        return _persistentStoreCoordinator;
    }
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:kCoreDataFile];

    // automatic lightweight migration options
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithBool:YES],
                                                  NSMigratePersistentStoresAutomaticallyOption,
                                                  [NSNumber numberWithBool:YES],
                                                  NSInferMappingModelAutomaticallyOption,
                                                  nil];

    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                                                 initWithManagedObjectModel:[self managedObjectModel]];

    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil URL:storeURL
                                                         options:options
                                                           error:&error])
    {
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];

        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                       configuration:nil URL:storeURL
                                                             options:options
                                                               error:&error])
        {
            ALog(@"\nUnresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }

    return _persistentStoreCoordinator;
}

#pragma mark - Operation queues


- (NSOperationQueue *) getBackgroundCoreDataQueue
{
    return self.backgroundCoreDataQueue;
}


+ (NSUInteger) backgroundCoreDataQueueCount
{
    return [self sharedInstance].backgroundCoreDataQueue.operationCount;
}

- (void) addOperationToBackgroundCoreDataQueue:(NSOperation *)operation
{
    [self.backgroundCoreDataQueue addOperation:operation];
}

#pragma mark - Private MOC

- (NSManagedObjectContext *) newPrivateContext
{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc]
                                                               initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    context.persistentStoreCoordinator = self.persistentStoreCoordinator;
    [context setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
    context.undoManager = nil;
    return context;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *) applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager]
                            URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask]
                            lastObject];
}


@end
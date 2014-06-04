//
// Created by Tony Papale on 6/2/14.
// Copyright (c) 2014 Bright Origin. All rights reserved.
//

#import "FRCDataSource.h"
#import "NSFetchedResultsController+LoggedFetch.h"

@interface FRCDataSource ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) CellConfigureBlock configureCellBlock;

@end

@implementation FRCDataSource

- (void) dealloc
{
    DLog(@"Dealloc FRCDataSource");
}

- (void) setup
{

    // add any necessary setup code here

//    self.tableView.dataSource = self;
//    self.fetchedResultsController.delegate = self;
}

- (void) setFRC:(NSFetchedResultsController *)aFetchedResultsController
{
    self.fetchedResultsController = aFetchedResultsController;

    if (!self.paused)
    {
        self.fetchedResultsController.delegate = self;
        [self.fetchedResultsController executeLoggedFetchRequest];
    }

    [self reloadData];
}

- (id) initWithTableView:(UITableView *)aTableView
          cellIdentifier:(NSString *)aCellIdentifier
      configureCellBlock:(CellConfigureBlock)aConfigureCellBlock
{
    self = [super init];
    if (self)
    {
        self.tableView = aTableView;
        self.tableView.dataSource = self;
        self.reuseIdentifier = aCellIdentifier;
        self.configureCellBlock = aConfigureCellBlock;

//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(reloadTableData:)
//                                                     name:kGalleryImportDidFinishNotification object:nil];

        [self setup];
    }
    return self;
}

- (void) reloadData
{
    [self.tableView reloadData];
}

#pragma mark FRC Update Methods

- (void) changePredicate:(NSPredicate *)predicate
{
    NSAssert(self.fetchedResultsController.cacheName == NULL, @"Can't change predicate when you have a caching fetched results controller");

    NSFetchRequest *fetchRequest = self.fetchedResultsController.fetchRequest;
    fetchRequest.predicate = predicate;

    [self.fetchedResultsController executeLoggedFetchRequest];

    [self reloadData];


//    [self.tableView reloadData];
//    [self.tableView setContentOffset:CGPointMake(0.0f, -self.tableView.contentInset.top) animated:YES];
}

- (id <NSFetchedResultsSectionInfo>) getInfoForSection:(NSInteger)section
{
    if ([[self.fetchedResultsController sections] count] > 0)
    {
        return [[self.fetchedResultsController sections] objectAtIndex:(NSUInteger) section];
    }
    return nil;
}

- (NSString *)sectionNameForSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo>sectionInfo = [self getInfoForSection:section];
    return [sectionInfo name];
}

- (id) objectAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.fetchedResultsController objectAtIndexPath:indexPath];
}

- (NSInteger) numberOfSections
{
    return self.fetchedResultsController.sections.count;
}

- (NSInteger) numberOfRowsInSection:(NSInteger)sectionIndex
{
    id <NSFetchedResultsSectionInfo> section = self.fetchedResultsController.sections[sectionIndex];
    return section.numberOfObjects;
}

- (NSInteger) numberOfObjects
{
    if (!self.fetchedResultsController)
    {
        return 0;
    }

    return [[self.fetchedResultsController fetchedObjects] count];
}

- (NSArray *) getAllItems
{
    return self.fetchedResultsController.fetchedObjects;
}


#pragma mark TableViewDataSource methods

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self numberOfSections];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return [self numberOfRowsInSection:sectionIndex];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id cell = [tableView dequeueReusableCellWithIdentifier:self.reuseIdentifier forIndexPath:indexPath];

    id object = [self objectAtIndexPath:indexPath];

    self.configureCellBlock(cell, object);

//    if (indexPath.row == [[self.fetchedResultsController ] objectAtIndex:indexPath.section] count] - 1)
//    {
//        ((CollectionFilterTableViewCell *) cell).cellBottomSeparatorView.hidden = YES;
//    }
//    else
//    {
//        ((CollectionFilterTableViewCell *) cell).cellBottomSeparatorView.hidden = NO;
//    }

    return cell;
}


#pragma mark NSFetchedResultsControllerDelegate

- (void) controller:(NSFetchedResultsController *)controller
   didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
            atIndex:(NSUInteger)sectionIndex
      forChangeType:(NSFetchedResultsChangeType)type
{
    if (self.tableView)
    {
        switch (type)
        {
            case NSFetchedResultsChangeInsert:
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                              withRowAnimation:UITableViewRowAnimationFade];
                break;

            case NSFetchedResultsChangeDelete:
                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                              withRowAnimation:UITableViewRowAnimationFade];
                break;
            case NSFetchedResultsChangeMove:
            case NSFetchedResultsChangeUpdate:
                break;
        }
    }
}

- (void) controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void) controllerDidChangeContent:(NSFetchedResultsController *)controller
{
        [self.tableView endUpdates];
}


- (void) controller:(NSFetchedResultsController *)controller
    didChangeObject:(id)anObject
        atIndexPath:(NSIndexPath *)indexPath
      forChangeType:(NSFetchedResultsChangeType)type
       newIndexPath:(NSIndexPath *)newIndexPath
{
    if (type == NSFetchedResultsChangeInsert)
    {
        [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else if (type == NSFetchedResultsChangeMove)
    {
        [self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
    }
    else if (type == NSFetchedResultsChangeDelete)
    {
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else
    {
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void) setPaused:(BOOL)paused
{
    _paused = paused;
    if (paused)
    {
        self.fetchedResultsController.delegate = nil;
    }
    else
    {
        self.fetchedResultsController.delegate = self;
        [self.fetchedResultsController executeLoggedFetchRequest];
        [self reloadData];
    }
}

@end
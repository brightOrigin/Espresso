//
// Created by Tony Papale on 6/4/14.
// Copyright (c) 2014 Bright Origin. All rights reserved.
//

#import "BOVenueTableViewController.h"
#import "BOVenueTableViewCell.h"
#import "BOVenueTableViewCell+ConfigureCell.h"
#import "BOUtilityMethods.h"


@implementation BOVenueTableViewController

- (instancetype) init
{
    self.frcViewControllerDelegate = self;

    self = [super initWithFetchRequest:[self fetchRequestForFRCViewController:self]
                    sectionKeyNamePath:[self sectionKeyNamePathForFRCViewController:self]
                             cacheName:[self cacheNameForFRCViewController:self]];
    if (self)
    {

    }

    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.title = @"SOMA Espresso Bars";

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadData)
                                                 name:kVenueImportDidFinishNotification
                                               object:nil];

}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    // run search
    [Venue searchVenuesForTerm:@"espresso"
                      latitude:[NSNumber numberWithDouble:37.782749]
                     longitude:[NSNumber numberWithDouble:-122.406495]];

//    [Venue searchVenuesForTerm:@"espresso" near:@"SoMA, San Francisco, CA"];
}

#pragma mark Subclass Setup methods

- (UITableView *) tableViewForController
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds
                                                          style:UITableViewStylePlain];
    tableView.rowHeight = 60;
    tableView.backgroundColor = RGB(225, 225, 225);

    return tableView;
}

- (Class) getTableViewCellClass
{
    return [BOVenueTableViewCell class];
}

- (NSString *) cellReuseIdentifier
{
    return kVenueTableCellIdentifier;
}

- (CellConfigureBlock) blockToConfigureTableCell
{
    return ^(BOVenueTableViewCell *cell, Venue *venue) {
        [cell configureCell:venue];
    };
}

#pragma mark FRCViewControllerDelegate Methods

- (NSFetchRequest *) fetchRequestForFRCViewController:(FRCViewController *)frcViewController
{
    if (self.fetchRequest)
    {
        return self.fetchRequest;
    }

    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Venue"];
    self.fetchRequest = fetchRequest;

    // Use if you need a more refined search
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@""];
//    self.fetchRequest.predicate = predicate;

    BOOL sortAscending = YES;

    NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"distance"
                                                                       ascending:sortAscending];

    self.fetchRequest.sortDescriptors = @[nameSortDescriptor];

    return self.fetchRequest;
}

- (NSString *) sectionKeyNamePathForFRCViewController:(FRCViewController *)frcViewController
{
    return nil;
}

- (NSString *) cacheNameForFRCViewController:(FRCViewController *)frcViewController
{
    return nil;
}

@end
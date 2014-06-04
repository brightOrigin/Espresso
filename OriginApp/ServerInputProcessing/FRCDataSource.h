//
// Created by Tony Papale on 6/2/14.
// Copyright (c) 2014 Bright Origin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CellConfigureBlock)(id cell, id item);

@interface FRCDataSource : NSObject <NSFetchedResultsControllerDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, copy) NSString *reuseIdentifier;
@property (nonatomic) BOOL paused;
@property (nonatomic) BOOL paging;

- (void) setup;
- (void) setFRC:(NSFetchedResultsController *)aFetchedResultsController;
- (void) changePredicate:(NSPredicate *)predicate;
//- (void) refetchFromCoreData;

- (id <NSFetchedResultsSectionInfo>) getInfoForSection:(NSInteger)section;
- (NSString *) sectionNameForSection:(NSInteger)section;

- (NSInteger) numberOfSections;
- (NSInteger) numberOfRowsInSection:(NSInteger)sectionIndex;
- (NSInteger) numberOfObjects;
- (NSArray *) getAllItems;

- (id) objectAtIndexPath:(NSIndexPath *)indexPath;
- (void) reloadData;
//- (id) selectedItem;

- (id) initWithTableView:(UITableView *)aTableView
          cellIdentifier:(NSString *)aCellIdentifier
      configureCellBlock:(CellConfigureBlock)aConfigureCellBlock;

@end
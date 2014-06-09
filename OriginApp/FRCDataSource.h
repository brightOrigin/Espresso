//
// Created by Tony Papale on 6/2/14.
// Copyright (c) 2014 Bright Origin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CellConfigureBlock)(id cell, id item);

/**
*
* Acts as the data source for @FRCViewController
*
*/
@interface FRCDataSource : NSObject <NSFetchedResultsControllerDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, copy) NSString *reuseIdentifier;
@property (nonatomic) BOOL paused;

- (id) initWithTableView:(UITableView *)aTableView cellIdentifier:(NSString *)aCellIdentifier configureCellBlock:(CellConfigureBlock)aConfigureCellBlock;

- (void) setup;
- (void) setFRC:(NSFetchedResultsController *)aFetchedResultsController;
- (void) changePredicate:(NSPredicate *)predicate;
- (id <NSFetchedResultsSectionInfo>) getInfoForSection:(NSInteger)section;
- (NSString *) sectionNameForSection:(NSInteger)section;
- (NSInteger) numberOfSections;
- (NSInteger) numberOfRowsInSection:(NSInteger)sectionIndex;
- (NSInteger) numberOfObjects;
- (NSArray *) getAllItems;
- (id) objectAtIndexPath:(NSIndexPath *)indexPath;
- (void) reloadData;

@end
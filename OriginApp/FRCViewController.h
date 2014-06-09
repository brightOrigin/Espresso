//
// Created by Tony Papale on 6/2/14.
// Copyright (c) 2014 Bright Origin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRCDataSource.h"


@class FRCViewController;

@protocol FRCViewControllerDelegate <NSObject>

- (NSFetchRequest *) fetchRequestForFRCViewController:(FRCViewController *)frcViewController;
- (NSString *) sectionKeyNamePathForFRCViewController:(FRCViewController *)frcViewController;
- (NSString *) cacheNameForFRCViewController:(FRCViewController *)frcViewController;

@optional
- (void) frcViewController:(FRCViewController *)frcViewController getObjectsFromServerForPageCount:(NSInteger)pageCount pageNum:(NSInteger)pageNum;
- (BOOL) moreServerObjectsAvailableForFRCViewController:(FRCViewController *)frcViewController;
- (void) frcViewController:(FRCViewController *)frcViewController didSelectObject:(id)selectedObject atIndex:(NSInteger)index;
- (void) frcViewController:(FRCViewController *)frcViewController didSetFRCDataSourceWithObjects:(NSArray *)fetchedObjects;
- (void) frcViewControllerShouldRefreshObjectsFromServer:(FRCViewController *)frcViewController;

@end




static NSString *const kTableCellIdentifier = @"TableViewCell";

/**
*
* Together with the #FRCDataSource these two classes managed the FRC for the
* view controllers
*
*/
@interface FRCViewController : UIViewController <UITableViewDelegate>

@property (nonatomic, strong) FRCDataSource *frcDataSource;
@property (nonatomic, weak) id <FRCViewControllerDelegate> frcViewControllerDelegate;
@property (nonatomic, strong) NSFetchRequest *fetchRequest;
@property (nonatomic, strong) NSString *sectionKeyNamePath;
@property (nonatomic, strong) NSString *cacheName;

- (id) initWithFetchRequest:(NSFetchRequest *)fetchRequest sectionKeyNamePath:(NSString *)sectionKeyNamePath cacheName:(NSString *)cacheName;
- (void) setupView;
- (void) setFRC;

- (FRCDataSource *) dataSourceForController;
- (NSString *) cellReuseIdentifier;
- (CellConfigureBlock) blockToConfigureTableCell;

@end
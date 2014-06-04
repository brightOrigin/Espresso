//
// Created by Tony Papale on 6/2/14.
// Copyright (c) 2014 Bright Origin. All rights reserved.
//

#import "FRCViewController.h"
#import "BOStore.h"
#import "BOUtilityMethods.h"
#import "BOVenueTableViewCell.h"
#import "BOVenueTableViewCell+ConfigureCell.h"

@interface FRCViewController ()

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation FRCViewController

#pragma mark lifecycle methods

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id) initWithFetchRequest:(NSFetchRequest *)fetchRequest
         sectionKeyNamePath:(NSString *)sectionKeyNamePath
                  cacheName:(NSString *)cacheName
{
    self = [super init];
    if (self)
    {
        _fetchRequest = fetchRequest;
        _sectionKeyNamePath = sectionKeyNamePath;
        _cacheName = cacheName;
    }

    return self;
}

- (void) loadView
{
    UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                             0,
                                                             [UIScreen mainScreen].bounds.size.width,
                                                             [UIScreen mainScreen].bounds.size.height)];
    aView.backgroundColor = [UIColor darkGrayColor];
    self.view = aView;

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}


- (void) viewDidLoad
{
    [super viewDidLoad];

//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(reloadData)
//                                                 name:kServerRequestDidFailNotification
//                                               object:nil];
//
//
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(updateNoResultsView)
//                                                 name:NSManagedObjectContextDidSaveNotification
//                                               object:nil];
//
//    self.pageNum = 1;
//    self.pageCount = 25;

    [self setupView];
    [self setupDataSource];
    [self setFRC];
//    [self setupPaginationView];
//    [self setupNoResultsView];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.frcDataSource.paused = NO;

//    [self updateNoResultsView];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    self.frcDataSource.paused = YES;
}

#pragma mark Subclass Setup methods

- (void) setupView
{
    self.tableView = [self tableViewForController];
    self.tableView.delegate = self;
    [self.tableView registerClass:[self getTableViewCellClass] forCellReuseIdentifier:[self cellReuseIdentifier]];

    self.tableView.contentInset = UIEdgeInsetsMake(44 + 20, 0.0, 0.0, 0.0);

    [self.view addSubview:self.tableView];

//    self.pullToRefreshView = [[SSPullToRefreshView alloc] initWithScrollView:self.tableView
//                                                                    delegate:self];
//    self.pullToRefreshView.contentView = [[PullToRefreshContentView alloc] initWithFrame:CGRectZero];
}


- (void) setupDataSource
{
    self.frcDataSource = [self dataSourceForController];
}


- (NSString *) cellReuseIdentifier
{
    return kTableCellIdentifier;
}

- (CellConfigureBlock) blockToConfigureTableCell
{
    return ^(BOVenueTableViewCell *cell, Event *event)
    {
        [cell configureCell:event];
    };
}

- (void) setFRC
{
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc]
                                                                   initWithFetchRequest:[self.frcViewControllerDelegate fetchRequestForFRCViewController:self]
                                                                   managedObjectContext:[[BOStore sharedInstance] mainManagedObjectContext]
                                                                     sectionNameKeyPath:[self.frcViewControllerDelegate sectionKeyNamePathForFRCViewController:self]
                                                                              cacheName:[self.frcViewControllerDelegate cacheNameForFRCViewController:self]];

    [self.frcDataSource setFRC:frc];

//    [self updateNoResultsView];

    if ([self.frcViewControllerDelegate respondsToSelector:@selector(frcViewController:didSetFRCDataSourceWithObjects:)])
    {
        return [self.frcViewControllerDelegate frcViewController:self
                                  didSetFRCDataSourceWithObjects:self.frcDataSource.fetchedResultsController.fetchedObjects];
    }
}


- (UITableView *) tableViewForController
{
    return [[UITableView alloc] initWithFrame:self.view.bounds
                                        style:UITableViewStyleGrouped];
}

- (Class) getTableViewCellClass
{
    return [UITableViewCell class];
}


- (FRCDataSource *) dataSourceForController
{
    return [[FRCDataSource alloc] initWithTableView:self.tableView
                                     cellIdentifier:[self cellReuseIdentifier]
                                 configureCellBlock:[self blockToConfigureTableCell]];
}


#pragma mark UITableViewDelegate Methods

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if ([self.frcViewControllerDelegate respondsToSelector:@selector(frcViewController:didSelectObject:atIndex:)])
    {
        id selectedObject = [self.frcDataSource objectAtIndexPath:indexPath];
        [self.frcViewControllerDelegate frcViewController:self
                                          didSelectObject:selectedObject
                                                  atIndex:[self.frcDataSource.fetchedResultsController.fetchedObjects indexOfObject:selectedObject]];
    }
}


- (void) startServerRefresh:(NSNotification *)notification
{
    // reset the pagination flags
//    [self updatePageNum:1];
//    [self.frcViewControllerDelegate frcViewController:self
//                     getObjectsFromServerForPageCount:[self currentPageCount]
//                                              pageNum:[self currentPageNum]];
}

#pragma mark FRCViewControllerDelegate Methods

- (void) container:(FRCContainerViewController *)containerController didChangePredicate:(NSPredicate *)predicate
{
    [self.frcDataSource changePredicate:predicate ? predicate : self.fetchRequest.predicate];
}

- (void) reloadData
{
    [self setFRC];
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;

    float reload_distance = 250;

    if (y > (h - reload_distance))
    {
        // trigger more results method
    }

}


@end
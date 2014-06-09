//
// Created by Tony Papale on 6/2/14.
// Copyright (c) 2014 Bright Origin. All rights reserved.
//

#import "FRCViewController.h"
#import "BOStore.h"
#import "BOUtilityMethods.h"
#import "BOVenueTableViewCell.h"
#import "BOVenueTableViewCell+ConfigureCell.h"
#import "BOAPIClient.h"

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

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadData)
                                                 name:kAPIRequestDidFailNotification
                                               object:nil];

    [self setupView];
    [self setupDataSource];
    [self setFRC];
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
}


- (void) setupDataSource
{
    self.frcDataSource = [self dataSourceForController];
}

- (void) setFRC
{
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc]
                                                                   initWithFetchRequest:[self.frcViewControllerDelegate fetchRequestForFRCViewController:self]
                                                                   managedObjectContext:[[BOStore sharedInstance] mainManagedObjectContext]
                                                                     sectionNameKeyPath:[self.frcViewControllerDelegate sectionKeyNamePathForFRCViewController:self]
                                                                              cacheName:[self.frcViewControllerDelegate cacheNameForFRCViewController:self]];

    [self.frcDataSource setFRC:frc];

    if ([self.frcViewControllerDelegate respondsToSelector:@selector(frcViewController:didSetFRCDataSourceWithObjects:)])
    {
        return [self.frcViewControllerDelegate frcViewController:self
                                  didSetFRCDataSourceWithObjects:self.frcDataSource.fetchedResultsController.fetchedObjects];
    }
}


- (UITableView *) tableViewForController
{
    return [[UITableView alloc] initWithFrame:self.view.bounds
                                        style:UITableViewStylePlain];
}

- (Class) getTableViewCellClass
{
    return [UITableViewCell class];
}

- (NSString *) cellReuseIdentifier
{
    return kVenueTableCellIdentifier;
}

- (CellConfigureBlock) blockToConfigureTableCell
{
    return ^(BOVenueTableViewCell *cell, Venue *venue)
    {
        [cell configureCell:venue];
    };
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


- (void) reloadData
{
    [self setFRC];
}
@end
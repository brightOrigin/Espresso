//
// Created by Tony Papale on 6/2/14.
// Copyright (c) 2014 Bright Origin. All rights reserved.
//

#import "BORootTableViewController.h"
#import "FRCDataSource.h"


@implementation BORootTableViewController


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


@end
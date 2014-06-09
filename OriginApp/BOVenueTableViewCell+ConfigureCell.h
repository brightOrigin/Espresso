//
// Created by Tony Papale on 6/2/14.
// Copyright (c) 2014 Bright Origin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BOVenueTableViewCell.h"
#import "Venue.h"

/**
*
* This category is used to populate the data for the cell and separate it
* from the actual cell creation and layout located in @BOVenueTableViewCell
*
*/
@interface BOVenueTableViewCell (ConfigureCell)

- (void) configureCell:(Venue *)venue;

@end
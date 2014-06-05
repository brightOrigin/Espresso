//
// Created by Tony Papale on 6/2/14.
// Copyright (c) 2014 Bright Origin. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const kVenueTableCellIdentifier = @"VenueTableViewCell";

@interface BOVenueTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *venueNameLbl;
@property (nonatomic, strong) UILabel *venueAddressLbl;

@end
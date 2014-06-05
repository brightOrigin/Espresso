//
// Created by Tony Papale on 6/2/14.
// Copyright (c) 2014 Bright Origin. All rights reserved.
//

#import "BOVenueTableViewCell+ConfigureCell.h"


@implementation BOVenueTableViewCell (ConfigureCell)

- (void) configureCell:(Venue *)venue
{
    self.venueNameLbl.text = venue.name;
    self.venueAddressLbl.text = venue.address;

    double distanceInMiles = ([venue.distance doubleValue]/1000)*0.6;
    self.venueDistanceLbl.text = [NSString stringWithFormat:@"%.1fmi", distanceInMiles];
}

@end

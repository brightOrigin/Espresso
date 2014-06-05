//
// Created by Tony Papale on 6/2/14.
// Copyright (c) 2014 Bright Origin. All rights reserved.
//

#import "BOVenueTableViewCell.h"
#import "UILabel+(QuickCreate).h"
#import "BOUtilityMethods.h"


@implementation BOVenueTableViewCell

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = RGB(236, 236, 236);


        self.venueNameLbl = [UILabel newLabelWithFrame:CGRectMake(20,
                                                                  5,
                                                                  self.frame.size.width - 30,
                                                                  30)
                                             textColor:RGB(159, 25, 29)
                                       backgroundColor:self.backgroundColor
                                         textAlignment:NSTextAlignmentLeft
                                                  font:[UIFont fontWithName:@".HelveticaNeueInterface-M3"
                                                                       size:17]];
        [self.contentView addSubview:self.venueNameLbl];


        self.venueAddressLbl = [UILabel newLabelWithFrame:CGRectMake(20,
                                                                 35,
                                                                 self.frame.size.width - 75,
                                                                 15)
                                            textColor:[UIColor darkGrayColor]
                                      backgroundColor:self.backgroundColor
                                        textAlignment:NSTextAlignmentLeft
                                                 font:[UIFont boldSystemFontOfSize:13]];
        [self.contentView addSubview:self.venueAddressLbl];

        self.venueDistanceLbl = [UILabel newLabelWithFrame:CGRectMake(self.frame.size.width - 65,
                                                                 35,
                                                                 50,
                                                                 15)
                                            textColor:[UIColor grayColor]
                                      backgroundColor:self.backgroundColor
                                        textAlignment:NSTextAlignmentRight
                                                 font:[UIFont boldSystemFontOfSize:13]];
        [self.contentView addSubview:self.venueDistanceLbl];
    }

    return self;
}

@end
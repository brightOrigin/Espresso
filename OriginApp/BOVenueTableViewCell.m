//
// Created by Tony Papale on 6/2/14.
// Copyright (c) 2014 Bright Origin. All rights reserved.
//

#import "BOVenueTableViewCell.h"
#import "UILabel+(QuickCreate).h"


@implementation BOVenueTableViewCell

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = [UIColor darkGrayColor];


        self.venueNameLbl = [UILabel newLabelWithFrame:CGRectMake(20,
                                                                  5,
                                                                  self.frame.size.width - 30,
                                                                  30)
                                             textColor:[UIColor lightTextColor]
                                       backgroundColor:self.backgroundColor
                                         textAlignment:NSTextAlignmentLeft
                                                  font:[UIFont fontWithName:@".HelveticaNeueInterface-M3"
                                                                       size:17]];
        [self.contentView addSubview:self.venueNameLbl];


        self.venueAddressLbl = [UILabel newLabelWithFrame:CGRectMake(20,
                                                                 35,
                                                                 self.frame.size.width - 30,
                                                                 15)
                                            textColor:[UIColor lightTextColor]
                                      backgroundColor:self.backgroundColor
                                        textAlignment:NSTextAlignmentLeft
                                                 font:[UIFont boldSystemFontOfSize:13]];
        [self.contentView addSubview:self.venueAddressLbl];
    }

    return self;
}

@end
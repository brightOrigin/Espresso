//
// Created by Tony on 11/13/13.
//


#import <Foundation/Foundation.h>

@interface NSString (Decoding)

- (BOOL)isNotBlank;
- (NSString *) decodeHtml;
- (NSString *) decodeUTF8;

@end
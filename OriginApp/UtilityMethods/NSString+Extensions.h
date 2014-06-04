//
// Created by Tony on 11/13/13.
//


#import <Foundation/Foundation.h>

@interface NSString (Extensions)

- (BOOL)isNotBlank;
- (NSString *) decodeHtml;
- (NSString *) decodeUTF8;
- (NSInteger) heightForStringWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode minHeight:(NSInteger)minHeight;

@end
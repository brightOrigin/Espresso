//
// Created by Tony on 11/13/13.
//


#import "NSString+Decoding.h"


@implementation NSString (Decoding)

- (BOOL)isNotBlank
{
    if (self && ![self isEqualToString:@""])
    {
        return YES;
    }
    return NO;
}

- (NSString *) decodeHtml
{
    NSMutableString *decodedString = [[NSMutableString alloc] initWithString:self];
    [decodedString replaceOccurrencesOfString:@"&apos;"
                                   withString:@"'"
                                      options:0
                                        range:NSMakeRange(0, [decodedString length])];
    [decodedString replaceOccurrencesOfString:@"&#039;"
                                   withString:@"'"
                                      options:0
                                        range:NSMakeRange(0, [decodedString length])];
    [decodedString replaceOccurrencesOfString:@"&#39;"
                                   withString:@"'"
                                      options:0
                                        range:NSMakeRange(0, [decodedString length])];
    [decodedString replaceOccurrencesOfString:@"&amp;"
                                   withString:@"&"
                                      options:0
                                        range:NSMakeRange(0, [decodedString length])];
    [decodedString replaceOccurrencesOfString:@"&quot;"
                                   withString:@"\""
                                      options:0
                                        range:NSMakeRange(0, [decodedString length])];
    [decodedString replaceOccurrencesOfString:@"&#34;"
                                   withString:@"\""
                                      options:0
                                        range:NSMakeRange(0, [decodedString length])];
    [decodedString replaceOccurrencesOfString:@"&gt;"
                                   withString:@">"
                                      options:0
                                        range:NSMakeRange(0, [decodedString length])];
    [decodedString replaceOccurrencesOfString:@"&lt;"
                                   withString:@"<"
                                      options:0
                                        range:NSMakeRange(0, [decodedString length])];
    [decodedString replaceOccurrencesOfString:@"&hellip;"
                                   withString:@"..."
                                      options:0
                                        range:NSMakeRange(0, [decodedString length])];
    [decodedString replaceOccurrencesOfString:@"<br />"
                                   withString:@""
                                      options:0
                                        range:NSMakeRange(0, [decodedString length])];

    return decodedString;
}

- (NSString *) decodeUTF8
{
    return [NSString stringWithCString:[self cStringUsingEncoding:NSISOLatin1StringEncoding]
                              encoding:NSUTF8StringEncoding];
}

@end
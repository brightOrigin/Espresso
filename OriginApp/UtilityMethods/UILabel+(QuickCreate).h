
@interface UILabel (QuickCreate)

+ (UILabel *) newLabelWithPrimaryColor:(UIColor *)primaryColor
                       backgroundColor:(UIColor *)backgroundColor
                         textAlignment:(NSTextAlignment)textAlignment
                              fontSize:(CGFloat)fontSize
                                  bold:(BOOL)bold
                                opaque:(BOOL)opaque;

+ (UILabel *) newLabelWithTextColor:(UIColor *)textColor
                    backgroundColor:(UIColor *)backgroundColor
                      textAlignment:(NSTextAlignment)textAlignment
                               font:(UIFont *)font
                             opaque:(BOOL)opaque;

+ (UILabel *) newLabelWithFrame:(CGRect)frame
                      textColor:(UIColor *)textColor
                backgroundColor:(UIColor *)backgroundColor
           highlightedTextColor:(UIColor *)highlightedTextColor
                  textAlignment:(NSTextAlignment)textAlignment
                           font:(UIFont *)font;

+ (UILabel *) newLabelWithFrame:(CGRect)frame
                      textColor:(UIColor *)textColor
                backgroundColor:(UIColor *)backgroundColor
                  textAlignment:(NSTextAlignment)textAlignment
                           font:(UIFont *)font;

@end
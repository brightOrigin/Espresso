@implementation UILabel (QuickCreate)

+ (UILabel *)newLabelWithPrimaryColor:(UIColor *)primaryColor
                      backgroundColor:(UIColor *)backgroundColor
                        textAlignment:(NSTextAlignment)textAlignment
                             fontSize:(CGFloat)fontSize
                                 bold:(BOOL)bold
                               opaque:(BOOL)opaque
{
    UIFont *font;
    if (bold)
    {
        font = [UIFont boldSystemFontOfSize:fontSize];
    }
    else
    {
        font = [UIFont systemFontOfSize:fontSize];
    }

    UILabel *newLabel = [[UILabel alloc]
                                  initWithFrame:CGRectZero];
    newLabel.backgroundColor = [UIColor whiteColor];
    newLabel.opaque = opaque;
    newLabel.textColor = primaryColor;
    newLabel.textAlignment = textAlignment;
    newLabel.backgroundColor = backgroundColor;
    newLabel.font = font;

    return newLabel;
}

+ (UILabel *) newLabelWithTextColor:(UIColor *)textColor
                    backgroundColor:(UIColor *)backgroundColor
                      textAlignment:(NSTextAlignment)textAlignment
                               font:(UIFont *)font
                             opaque:(BOOL)opaque
{
    return [self newLabelWithFrame:CGRectZero textColor:textColor backgroundColor:backgroundColor highlightedTextColor:nil textAlignment:textAlignment font:font];
}

+ (UILabel *) newLabelWithFrame:(CGRect)frame
                      textColor:(UIColor *)textColor
                backgroundColor:(UIColor *)backgroundColor
           highlightedTextColor:(UIColor *)highlightedTextColor
                  textAlignment:(NSTextAlignment)textAlignment
                           font:(UIFont *)font
{
    UILabel *newLabel = [[UILabel alloc] initWithFrame:frame];
    newLabel.textColor = textColor;
    newLabel.textAlignment = textAlignment;
    newLabel.backgroundColor = backgroundColor;

    if (highlightedTextColor)
    {
        newLabel.highlightedTextColor = highlightedTextColor;
    }

    newLabel.font = font;

    return newLabel;
}

+ (UILabel *) newLabelWithFrame:(CGRect)frame
                      textColor:(UIColor *)textColor
                backgroundColor:(UIColor *)backgroundColor
                  textAlignment:(NSTextAlignment)textAlignment
                           font:(UIFont *)font
{
    UILabel *newLabel = [[UILabel alloc] initWithFrame:frame];
    newLabel.textColor = textColor;
    newLabel.textAlignment = textAlignment;
    newLabel.backgroundColor = backgroundColor;
    newLabel.font = font;

    return newLabel;
}

@end

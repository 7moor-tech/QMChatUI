//
//  QMInsetLabel.m
//  IMSDK
//
//  Created by wt on 2025/8/7.
//

#import "QMInsetLabel.h"

@implementation QMInsetLabel

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
    // 1. 计算包含内边距的文本区域
    CGRect rect = [super textRectForBounds:UIEdgeInsetsInsetRect(bounds, _textInsets)
                   limitedToNumberOfLines:numberOfLines];
    // 2. 扩展矩形以容纳内边距
    rect.origin.x -= _textInsets.left;
    rect.origin.y -= _textInsets.top;
    rect.size.width += (_textInsets.left + _textInsets.right);
    rect.size.height += (_textInsets.top + _textInsets.bottom);
    return rect;
}

- (void)drawTextInRect:(CGRect)rect {
    // 3. 应用内边距后绘制文本
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, _textInsets)];
}

@end

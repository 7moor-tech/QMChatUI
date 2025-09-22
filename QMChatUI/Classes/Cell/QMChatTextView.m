//
//  QMChatTextView.m
//  IMSDK
//
//  Created by 焦林生 on 2021/12/9.
//

#import "QMChatTextView.h"
#import "QMHeader.h"
#import "Masonry.h"
@implementation QMChatTextView

- (instancetype)init {
    if (self = [super init]) {
        UIColor *color = [UIColor colorWithHexString:QMColor_News_Custom];
        self.linkTextAttributes = @{NSForegroundColorAttributeName: color};
        self.editable = NO;
        self.scrollEnabled = NO;
//        self.layoutManager.allowsNonContiguousLayout = NO;

    }
    return self;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {

    if (action == @selector(copy:)) {
        return YES;
    }
    return false;
}

- (void)copy:(id)sender {
    [super copy:sender];
    [self endEditing:YES];
}

@end

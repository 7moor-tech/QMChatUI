//
//  UIScrollView+EmptyData.m
//  IMSDK
//
//  Created by wt on 2025/5/19.
//

#import "UIScrollView+EmptyData.h"
#import <objc/runtime.h>
#import "EmptyDataView.h"

static char kEmptyDataViewKey;

@implementation UIScrollView (EmptyData)

- (EmptyDataView *)emptyDataView {
    return objc_getAssociatedObject(self, &kEmptyDataViewKey);
}

- (void)setEmptyDataView:(EmptyDataView *)emptyDataView {
    objc_setAssociatedObject(self, &kEmptyDataViewKey, emptyDataView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)showEmptyMessage:(NSString *)message {
    if (!self.emptyDataView) {
        self.emptyDataView = [EmptyDataView emptyViewWithMessage:message];
        self.emptyDataView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.emptyDataView];
        
        [NSLayoutConstraint activateConstraints:@[
            [self.emptyDataView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
            [self.emptyDataView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor constant:-50],
            [self.emptyDataView.widthAnchor constraintEqualToAnchor:self.widthAnchor multiplier:0.8],
            [self.emptyDataView.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.leadingAnchor constant:20],
            [self.emptyDataView.trailingAnchor constraintLessThanOrEqualToAnchor:self.trailingAnchor constant:-20]
        ]];
    }
    if ([self isKindOfClass:[UITableView class]]) {
        ((UITableView *)self).separatorStyle = UITableViewCellSeparatorStyleNone;
    }
}

- (void)hideEmptyMessage {
    if (self.emptyDataView) {
        [self.emptyDataView removeFromSuperview];
        self.emptyDataView = nil;
    }
        
    if ([self isKindOfClass:[UITableView class]]) {
        ((UITableView *)self).separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
}


@end

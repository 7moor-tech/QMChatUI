//
//  EmptyDataView.m
//  IMSDK
//
//  Created by wt on 2025/5/19.
//

#import "EmptyDataView.h"

NS_ASSUME_NONNULL_BEGIN

@implementation EmptyDataView

+ (instancetype)emptyViewWithMessage:(NSString *)message {
    EmptyDataView *emptyView = [[EmptyDataView alloc] init];
    emptyView.messageLabel.text = message;
    return emptyView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    // 文字
    _messageLabel = [[UILabel alloc] init];
    _messageLabel.textAlignment = NSTextAlignmentCenter;
    _messageLabel.textColor = [UIColor grayColor];
    _messageLabel.font = [UIFont systemFontOfSize:16];
    _messageLabel.numberOfLines = 0;
    _messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_messageLabel];
    
    // 约束
    [NSLayoutConstraint activateConstraints:@[
        [_messageLabel.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        [_messageLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:20],
        [_messageLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-20]
    ]];
}

@end

NS_ASSUME_NONNULL_END

//
//  EmptyDataView.h
//  IMSDK
//
//  Created by wt on 2025/5/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EmptyDataView : UIView

@property (nonatomic, strong) UILabel *messageLabel;
+ (instancetype)emptyViewWithMessage:(NSString *)message;

@end

NS_ASSUME_NONNULL_END

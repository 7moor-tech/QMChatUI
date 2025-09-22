//
//  UIScrollView+EmptyData.h
//  IMSDK
//
//  Created by wt on 2025/5/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIScrollView (EmptyData)

- (void)showEmptyMessage:(NSString *)message;
- (void)hideEmptyMessage;

@end

NS_ASSUME_NONNULL_END

//
//  QMChatQuoteView.h
//  IMSDK
//
//  Created by ZCZ on 2023/7/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QMChatQuoteView : UIView
- (void)setData:(NSString *)content;
- (void)setBackColor:(BOOL)isLeft;
@end

NS_ASSUME_NONNULL_END

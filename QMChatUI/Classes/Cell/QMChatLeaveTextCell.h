//
//  QMChatLeaveTextCell.h
//  IMSDK
//
//  Created by wt on 2025/8/28.
//

#import <UIKit/UIKit.h>
@class CustomMessage;

NS_ASSUME_NONNULL_BEGIN

@interface QMChatLeaveTextCell : UITableViewCell

@property (nonatomic, copy) void(^tapNetAddress)(NSString *);

@property (nonatomic, copy) void(^tapNumberAction)(NSString *);

- (void)setData:(CustomMessage *)message;

@end

NS_ASSUME_NONNULL_END

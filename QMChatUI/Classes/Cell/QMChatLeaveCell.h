//
//  QMChatLeaveCell.h
//  IMSDK
//
//  Created by wt on 2025/8/14.
//

#import "QMChatBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface QMChatLeaveCell : QMChatBaseCell

@property (nonatomic, strong) void(^showFileBlock)(CustomMessage *message);

@end


NS_ASSUME_NONNULL_END

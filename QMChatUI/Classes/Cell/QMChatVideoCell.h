//
//  QMChatVideoCell.h
//  IMSDK
//
//  Created by ZCZ on 2022/10/17.
//

#import "QMChatBaseCell.h"
#import <SDWebImage/SDWebImage.h>

NS_ASSUME_NONNULL_BEGIN

@interface QMChatVideoCell : QMChatBaseCell
@property (nonatomic, strong) SDAnimatedImageView *showImageView;
@property (nonatomic, copy) void(^playerVideoAction)(NSString *url, NSString *filePath);

@end

NS_ASSUME_NONNULL_END

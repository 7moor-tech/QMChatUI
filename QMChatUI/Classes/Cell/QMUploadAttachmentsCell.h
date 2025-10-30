//
//  QMUploadAttachmentsCell.h
//  IMSDK
//
//  Created by wt on 2025/8/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QMUploadAttachmentsCell : UITableViewCell

@property (nonatomic, copy) void(^clickBack)(void);

- (void)setModel:(NSDictionary *)model;

@end

NS_ASSUME_NONNULL_END

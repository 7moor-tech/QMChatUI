//
//  QMAttachmentsCell.h
//  IMSDK
//
//  Created by wt on 2025/8/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QMAttachmentsCell : UITableViewCell

@property (nonatomic, copy) void(^closeBack)(NSString *);

- (void)setModel:(NSDictionary *)model;

@end
NS_ASSUME_NONNULL_END

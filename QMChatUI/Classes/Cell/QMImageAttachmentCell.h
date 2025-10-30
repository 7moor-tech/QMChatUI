//
//  QMImageAttachmentCell.h
//  IMSDK
//
//  Created by wt on 2025/8/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QMImageAttachmentCell : UITableViewCell

- (void)setData:(NSArray *)imageArray;

@end

@interface QMLeaveImageCell : UICollectionViewCell

@property (nonatomic, copy) void(^selectAction)(NSString *);
@property (nonatomic, copy) NSString *urlStr;

@end

@interface QMLeftAlignedFlowLayout : UICollectionViewFlowLayout
 
@end 

NS_ASSUME_NONNULL_END

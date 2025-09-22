//
//  QMInsetLabel.h
//  IMSDK
//
//  Created by wt on 2025/8/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QMInsetLabel : UILabel

@property (nonatomic, assign) UIEdgeInsets textInsets; // 内边距属性
@property (nonatomic, copy) NSString *linkURL;
@property (nonatomic, assign) bool isLink;

@end

NS_ASSUME_NONNULL_END

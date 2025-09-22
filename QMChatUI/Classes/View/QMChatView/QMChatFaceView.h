//
//  QMChatFaceView.h
//  IMSDK
//
//  Created by lishuijiao on 2020/10/13.
//

#import <UIKit/UIKit.h>

@class QMChatEmoji;
NS_ASSUME_NONNULL_BEGIN

@protocol QMChatFaceDelegete <NSObject>

- (void)touchFaceEmoji:(QMChatEmoji *)emoji;

- (void)touchFaceDeleteBtn;

- (void)touchFaceSendBtn;

@end

@interface QMChatFaceView : UIView

@property (nonatomic, weak) id<QMChatFaceDelegete> delegate;

- (void)loadData;

- (void)setButtonEnble:(BOOL)enable;

@end

@interface QMChatFaceCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;

@end


NS_ASSUME_NONNULL_END

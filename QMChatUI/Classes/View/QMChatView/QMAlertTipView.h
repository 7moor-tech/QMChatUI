//
//  QMAlertTipView.h
//  IMSDK
//
//  Created by 焦林生 on 2022/5/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QMAlertTipView : UIView

@property (nonatomic, copy) void(^confirmBlock)(BOOL isConfirm);

@property (nonatomic, copy) NSString *tipString;
@property (nonatomic, copy) NSString *closeChat;

@end

NS_ASSUME_NONNULL_END

//
//  QMSwitchRobotView.h
//  IMSDK
//
//  Created by 焦林生 on 2023/3/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QMSwitchRobotView : UIView

@property (nonatomic, copy) void(^tapSwitchRobot)(NSString *robotStr,NSString *robotName);
@property (nonatomic, copy) void(^tapCancelBlock)(void);

@property (nonatomic, strong) NSArray *dataArray;

- (void)showView;

- (void)dismissView;

- (void)setDarkModeColor;

@end

@interface QMSwitchRobotCell: UICollectionViewCell

@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UILabel *titleLab;

- (void)setupData:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END

//
//  QMStarView.h
//  IMSDK
//
//  Created by 焦林生 on 2023/4/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^EvaluateViewDidChooseStarBlock)(NSInteger count);
@interface QMStarView : UIView

/*
 *@pramas  spacing 星星之间的间距
 ********  大小为：0～1，超过1则置为1
 ********  spacing = 0.1,则间隙为星星的宽度的0.1倍,默认为0.5(即不设置)
 */
@property (nonatomic, assign) CGFloat spacing;

/** 星级评分，如果不设置，默认为0颗星 */
@property (nonatomic, assign) NSUInteger starCount;

/*
 *@pramas  starCount 星星需要设置成的数量
 ********  大小为：1～5，超过5则置为5
 */
@property (nonatomic, assign) NSUInteger starTotalCount;

/*
 *@pramas  tapEnabled 关闭星星点击手势，关闭就不能点击
 */
@property (nonatomic, assign, getter=isTapEnabled) BOOL tapEnabled;

/*
 *@pramas  evaluateViewDidChooseStarBlock 点击评价之后回调的星星数量
 */
@property (nonatomic, copy) EvaluateViewDidChooseStarBlock evaluateViewChooseStarBlock;


@end

NS_ASSUME_NONNULL_END

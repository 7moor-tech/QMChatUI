//
//  QMStarEvaluationView.h
//  IMSDK
//
//  Created by 焦林生 on 2023/4/13.
//

#import <UIKit/UIKit.h>
#import <QMLineSDK/QMLineSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface QMStarEvaluationView : UIView

- (instancetype)initWithFrame:(CGRect)frame evaluation:(QMEvaluation *)evaluation;

@property (nonatomic, copy) void(^cancelSelect)(void);

@property (nonatomic, copy) void(^sendSelect)(NSString *evaluatType,NSString *optionName, NSString *optionValue, NSArray *radioValue, NSString *textViewValue);

@end

NS_ASSUME_NONNULL_END

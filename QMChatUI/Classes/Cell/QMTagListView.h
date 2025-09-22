//
//  QMTagListView.h
//  IMSDK
//
//  Created by 焦林生 on 2022/12/28.
//

#import <UIKit/UIKit.h>

@interface QMTagListView : UIView{
    CGRect previousFrame ;
    NSInteger totalHeight ;
    NSMutableArray*_tagArr;
    
}
/**
 * 整个view的背景色
 */
@property(nonatomic,retain) UIColor *QMbackgroundColor;
/**
 *  设置单一颜色
 */
@property(nonatomic) UIColor *signalTagColor;
/**
 *  回调统计选中tag
 */
@property(nonatomic,copy)void (^didselectItemBlock)(NSArray*arr);
/**
 *  回调高度
 */
@property(nonatomic,copy)void (^tagViewH)(NSInteger tagH);

/**
 *  是否可点击
 */
@property(nonatomic) BOOL canTouch;
/**

 *  限制点击个数
 *  0->不限制
 *  不设置此属性默认不限制
 */
@property(nonatomic) NSInteger canTouchNum;

/** 单选模式,该属性的优先级要高于canTouchNum */

@property(nonatomic) BOOL isSingleSelect;

@property (nonatomic, assign) NSInteger tagHeight;
/**
 *  标签文本赋值
 */
-(void)setTagWithTagArray:(NSArray *)arr selectTag:(NSString *)tagStr;
/**
 *  设置tag之间的距离
 *
 */
-(void)setMarginBetweenTagLabel:(CGFloat)Margin AndBottomMargin:(CGFloat)BottomMargin;

@end

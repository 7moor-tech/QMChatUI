//
//  QMChatInputView.h
//  IMSDK
//
//  Created by lishuijiao on 2020/10/13.
//

#import <UIKit/UIKit.h>
#import "QMChatMoreView.h"
#import "QMChatFaceView.h"
#import "QMRecordIndicatorView.h"
//@class QMChatMoreView;
//@class QMChatFaceView;
//@class QMRecordIndicatorView;

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    QMInputViewModeVoice = 100,
    QMInputViewModeRecordCancel,
    QMInputViewModeRecordBegin,
    QMInputViewModeRecordEnd,
    QMInputViewModeRecordExit,
    QMInputViewModeRecordEnter,
    QMInputViewModeFace,
    QMInputViewModeAdd,
} QMInputViewMode;

@protocol QMInputeViewDelegate <NSObject>

- (void)moreViewSelectAcitonIndex:(QMChatMoreMode)index;

- (void)sendTextViewText:(NSString *)text;
- (void)sendAudio:(NSString *)audioName duration:(NSString *)duration;

@end

@interface QMChatInputView : UIView

@property (nonatomic, weak) id <QMInputeViewDelegate> delegate;
@property (nonatomic, strong)UITextView *inputView; // 输入栏
@property (nonatomic, strong)UIButton *recordBtn; // 录音按钮

@property (nonatomic, strong)UIView *coverView; // 限制出入蒙版
@property (nonatomic, strong)UIView *backView; //输入栏和表情底部view
@property (nonatomic, strong)UILabel *hintText; //默认文案


@property (nonatomic, strong) QMRecordIndicatorView *recordeView; // 录音动画面板

@property (nonatomic, strong) QMChatMoreView *addView;
@property (nonatomic, strong) QMChatFaceView *emojiView;



- (void)setDarkModeColor;
// QMMoreViewDelegate / QMChatFaceDelegete
- (void)setChatInputDelegate:(id _Nullable)delegate;
/**
 录音按钮显示切换
 */
- (void)showRecordButton: (BOOL)show;

/**
 表情面板显示切换
 */
- (void)showEmotionView: (BOOL)show;


/**
 扩展面板显示切换
 */
- (void)showMoreView: (BOOL)show;

- (void)refreshInputView;

// 更改按钮状态
- (void)changeRecordButtonStatus:(BOOL)down;

@end

NS_ASSUME_NONNULL_END

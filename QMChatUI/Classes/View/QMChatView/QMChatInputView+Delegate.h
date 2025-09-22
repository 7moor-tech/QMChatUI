//
//  QMChatInputView+Delegate.h
//  IMSDK
//
//  Created by 焦林生 on 2023/2/15.
//

#import "QMChatInputView.h"
//#import "QMChatFaceView.h"
#import "QMAudioRecorder.h"

NS_ASSUME_NONNULL_BEGIN

@interface QMChatInputView (Delegate)<UIGestureRecognizerDelegate, QMChatFaceDelegete, QMMoreViewDelegate, QMAudioRecorderDelegate, AVAudioRecorderDelegate>

@end

NS_ASSUME_NONNULL_END

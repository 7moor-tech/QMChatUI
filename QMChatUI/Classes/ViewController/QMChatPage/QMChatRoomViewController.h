//
//  QMChatRoomViewController.h
//  IMSDK
//
//  Created by lishuijiao on 2020/9/28.
//

#import <UIKit/UIKit.h>
#import <QMLineSDK/QMLineSDK.h>

NS_ASSUME_NONNULL_BEGIN

@class QMChatMoreView;
@class QMChatFaceView;
@class QMRecordIndicatorView;
@class QMChatAssociationInputView;
@class QMChatInputView;

typedef enum : NSUInteger {
    QMDarkStyleDefault = 1, /**系统自定义*/
    QMDarkStyleOpen, /**打开暗黑模式*/
    QMDarkStyleClose, /**关闭暗黑模式*/
} QMDarkStyle;


@interface QMChatRoomViewController : UIViewController
/**消息列表*/
@property (nonatomic, strong) UITableView *chatTableView;
/**消息内容*/
@property (nonatomic, strong) NSArray *dataArray;
/**输入工具条*/
@property (nonatomic, strong) QMChatInputView *chatInputView;
/**表情面板*/
@property (nonatomic, strong) QMChatFaceView *faceView;
/**扩展面板*/
@property (nonatomic, strong) QMChatMoreView *addView;
/**录音动画面板*/
@property (nonatomic, strong) QMRecordIndicatorView *recordeView;
/**xbot联想输入面板*/
@property (nonatomic, strong) QMChatAssociationInputView *associationView;
/**蒙版*/
@property (nonatomic, strong) UIView *coverView;
/**技能组ID*/
@property (nonatomic, copy) NSString *peerId;
/**日程id*/
@property (nonatomic, copy) NSString *scheduleId;
/**流程id*/
@property (nonatomic, copy) NSString *processId;
/**入口节点中访客选择的流转节点id*/
@property (nonatomic, copy) NSString *currentNodeId;
/**入口节点中_id*/
@property (nonatomic, copy) NSString *entranceId;
/**用户头像 url*/
@property (nonatomic, copy) NSString *avaterStr;
/**是否开启日程管理*/
@property (nonatomic, assign) BOOL isOpenSchedule;
/**是否开启暗黑模式*/
@property (nonatomic, assign) QMDarkStyle darkStyle;
/**是否开启聊天*/
@property (nonatomic, assign)BOOL isSpeak;
/**键盘位置*/
@property (nonatomic, assign) CGRect keyBoardFrame;
//保存键盘弹出前tableview的contentOffset,方便我们在键盘收起时将tableview进行还原程原先的位置
@property (assign, nonatomic) CGPoint lastContentOffset;
// 访客userName
@property (nonatomic, copy) NSString *userName;

/**客服状态**/
@property (nonatomic, assign) QMKFStatus KFStatus;

@property (nonatomic,copy) NSString *fromUrl;

/**开启访客无响应 定时断开会话*/
- (void)createNSTimer;
- (void)removeTimer;
- (void)hideKeyboard;
//切换机器人
- (void)switchRobot:(NSString *)robotId;

- (void)createEvaluationView:(BOOL)isPop andGetServerTime:(BOOL)GetSer andEvaluatId:(NSString *)evaluatId andFrom:(NSString *)from;



@end

NS_ASSUME_NONNULL_END

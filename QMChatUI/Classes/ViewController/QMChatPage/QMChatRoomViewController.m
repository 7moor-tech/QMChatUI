//
//  QMChatRoomViewController.m
//  IMSDK
//
//  Created by lishuijiao on 2020/9/28.
//

#import "QMChatRoomViewController.h"
#import "QMChatGuestBookViewController.h"
#import "QMFileManagerController.h"
#import "QMQuestionViewController.h"
#import <Photos/Photos.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <QMBaseLib/QMBaseLib.h>
#import "QMChatRoomViewController+TableView.h"
#import "QMChatRoomViewController+ChatMessage.h"

//view
#import "QMChatTitleView.h"
#import "QMChatInputView.h"
#import "QMChatMoreView.h"
#import "QMChatFaceView.h"
#import "QMRecordIndicatorView.h"
#import "QMChatBottomListView.h"
#import "QMChatAssociationInputView.h"
#import "QMChatFormView.h"
#import "QMLogistsMoreView.h"
#import "SJVoiceTransform.h"
#import "QMAudioPlayer.h"
#import "QMAudioRecorder.h"
#import "QMAlertTipView.h"
#import "MJRefresh.h"
#import "QMHeader.h"
#import "QMProfileManager.h"
#import "QMDragView.h"
#import "QMSwitchRobotView.h"
#import "QMChatBaseCell.h"
#import "QMStarEvaluationView.h"
//#import <JJException/JJException.h>
//#import <QMMeet/QMMeet.h>
#import <sys/utsname.h>

@interface QMChatRoomViewController () <UITextViewDelegate,QMInputeViewDelegate> {
    CGFloat _navHeight;
    long dateTime;
    int _dataNum;
    BOOL isShowEvaluate; //满意度评价按钮
    BOOL alreadEvaluate; //是否已经评价过(机器人和人工共用一个)
    BOOL isShowAssociatsInput; //是否开启联想输入
    BOOL isShowAssociatsWithAgent; //人工状态下是否开启联想输入
}

@property (nonatomic, strong) NSTimer *backStatus;
/**标题*/
@property (nonatomic, strong) QMChatTitleView *titleView;
/**转人工*/
@property (nonatomic, strong) UIButton *manualButotn;
/**注销*/
@property (nonatomic, strong) UIButton *logoutButton;
/**日程管理*/
@property (nonatomic, copy) NSDictionary *scheduleDic;
/**人工满意度*/
@property (nonatomic, strong) QMEvaluation *evaluation;
/**机器人满意度*/
@property (nonatomic, strong) QMEvaluation *xbotEvaluation;
/**xbot底部推荐*/
@property (nonatomic, strong) QMChatBottomListView *bottomView;
/**评价**/
@property (nonatomic, strong) QMStarEvaluationView *evaluationView;
/**切换业务*/
@property (nonatomic, strong) QMDragView *dragView;
/**服务器时间*/
@property (nonatomic, copy) NSString *serviceTime;
/**遮罩*/
@property (nonatomic, strong) UIView *tapCoverView;
/**当前坐席*/
@property (nonatomic, strong) QMAgent *currentAgent;
/**线程锁*/
@property (nonatomic, strong) NSRecursiveLock *dataLock;
/**排队人数*/
@property (nonatomic, copy) NSString *queueNum;
/**坐席状态*/
@property (nonatomic, copy) NSString *titleViewText;
/**智能机器人id*/
@property (nonatomic, copy) NSString *intelligentRobot;
/**评价携带字段*/
@property (nonatomic, copy) NSString *evaluateOperation;
/**beginNewChat返回的chatID*/
@property (nonatomic, copy) NSString *beginChatID;
/**xbot联想问题*/
@property (nonatomic, strong) NSArray *questions;
/**xbot机器人cateId*/
@property (nonatomic, strong) NSArray *cateIdArr;
@property (nonatomic, assign) int closeTime;

@end

@implementation QMChatRoomViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNewReload:) name:CHATMSG_RELOAD object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(robotCustom) name:ROBOT_SERVICE object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customOffline) name:CUSTOMSRV_OFFLINE object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customClaim) name:CUSTOMSRV_CLAIM object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customVIP) name:CUSTOMSRV_VIP object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customFinish:) name:CUSTOMSRV_FINISH object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customQueue:) name:CUSTOMSRV_QUEUENUM object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customAgentMessage:) name:CUSTOMSRV_AGENT object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customInvestigate:) name:CUSTOMSRV_INVESTIGATE object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customLeavemsg:) name:CUSTOMSRV_LEAVEMSG object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCustomStatus) name:CUSTOMSRV_IMPORTING object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cbangeDrowMessageStatus:) name:CUSTOMSRV_DRAWMESSAGE object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customSatisfaction:) name:CUSTOMSRV_SATISFACTION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customAssociatsInput:) name:CUSTOMSRV_ASSOCIATSINPUT object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshVoiceMessage:) name:CUSTOMSRV_VOICETEXT object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(socketReConnect) name:CUSTOMSRV_SOCKETFAIL object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMessageReadStatus:) name:CUSTOM_MESSAGERELOAD_STATUS object:nil];
        //锁定会话关闭定时器
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createNSTimer) name:CUSTOMSRV_CHAT_CREATETIMER object:nil];
        //断开前提示语
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(breakTips) name:CUSTOMSRV_CHAT_BREAKTIPS object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(breakTimerAction) name:CUSTOMSRV_CHAT_BREAKTIMER object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didResignActiveNotif) name:UIApplicationWillResignActiveNotification object:nil];
    }
    return self;
}

//- (void)viewDidAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
//    
//    QMLog(@"%@", self->alreadEvaluate);
//    
//}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationController.interactivePopGestureRecognizer.delaysTouchesBegan = NO;
    
    [self changeUserInfaceStyle];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customVideoInvite:) name:CUSTOMSRV_VIDEO_INVITE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customVideoCancel:) name:CUSTOMSRV_VIDEO_CANCEL object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadImageAction:) name:@"qm_downImageCompleted" object:nil];
    
    [self getConfig];
    
    [self OpenDarkStyle:self.darkStyle];
    
    self.keyBoardFrame = CGRectZero;
    
    [QMActivityView startAnimating];
    
    [QMPushManager share].isOpenRead = [QMConnect sdkWhetherToOpenReadAndUnread];
    
    [self createUI];
    
    [self createCoverView];
    
    //卡片信息
    //    [self insertCardInfoMessage];
    //newcardinfo卡片信息
    [self insertNewCardInfoMessage];
    
    [self getInvestigateData];
    
    if (_dataNum == 0) {
        _dataNum = 10;
    }
    dateTime = 0;
    self.queueNum = @"0";
    [QMConnect changeVoiceTextShowoOrNot:@"0" message:@"all"];
    
    [self getData];
    
    [self consumeUnReadMessage];
    
    [self scrollToEnd];
    
//    QMLoginManager.shared.currentEvaluateRound = 0;
    //    [JJException registerExceptionHandle:self];
}

#pragma mark - Exception Delegate
//- (void)handleCrashException:(NSString*)exceptionMessage extraInfo:(NSDictionary*)info{
//    NSMutableDictionary *tempDict = [NSMutableDictionary dictionary];
//    tempDict[@"exception"] = exceptionMessage;
//    [QMZhugeManager trackNetWorking:tempDict];
//}

- (void)dealloc {
    [QMConnect changeAllCardMessageHidden];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if (@available(iOS 13.0, *)) {
        UIUserInterfaceStyle style = [UITraitCollection currentTraitCollection].userInterfaceStyle;
        [QMPushManager share].isStyle = style == UIUserInterfaceStyleDark;
        [self OpenDarkStyle:self.darkStyle];
    }
}

- (void)OpenDarkStyle:(QMDarkStyle)style {
    
    if (style == QMDarkStyleOpen) {
        [QMPushManager share].isStyle = YES;
    } else if (style == QMDarkStyleClose) {
        [QMPushManager share].isStyle = NO;
    } else {
        [self changeUserInfaceStyle];
    }
}

- (void)changeUserInfaceStyle {
    
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
        appearance.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_Nav_Bg_Dark : QMColor_Nav_Bg_Light];
        self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
        self.navigationController.navigationBar.standardAppearance = appearance;
    }
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_Nav_Bg_Dark : QMColor_Nav_Bg_Light];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_ECECEC_BG : QMColor_News_Custom];
    self.view.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_Main_Bg_Dark : QMColor_F6F6F6_BG];
    self.chatTableView.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_Main_Bg_Dark : QMColor_Main_Bg_Light];
    UIColor *commonColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_1E1E1E_BG : QMColor_F6F6F6_BG];
    //    self.chatInputView.backgroundColor = commonColor;
    self.addView.backgroundColor = commonColor;
    self.faceView.backgroundColor = commonColor;
    
    [self.titleView setDarkModeColor];
    [self.chatInputView setDarkModeColor];
    [self.bottomView setDarkModeColor];
    [self.chatTableView reloadData];
}

#pragma mark -------- setupMainUI ----------
- (void)createUI {
    if (@available(iOS 11.0, *)){
        [self.chatTableView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    }
    
    CGRect StatusRect = [[UIApplication sharedApplication] statusBarFrame];
    CGRect NavRect = self.navigationController.navigationBar.frame;
    _navHeight = StatusRect.size.height + NavRect.size.height;
    
    // 坐席信息提示
    _titleView = [[QMChatTitleView alloc] initWithFrame: CGRectMake(0, 0, 150, 40)];
    _titleView.nameLabel.text = QMUILocalizableString(title.people);
    _titleView.stateInfoLabel.text = @"";
    //    QMUILocalizableString(title.connection);
    _titleView.intrinsicContentSize = CGSizeMake(150, 40);
    self.navigationItem.titleView = _titleView;
    
    [self.view addSubview:self.chatTableView];
    [self.view addSubview:self.chatInputView];
    
    CGFloat offy = 0.0;
    if (QM_IS_iPHONEX) {
        offy = 14.0;
    }
    [self.chatInputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-offy);
        make.height.mas_equalTo(kInputViewHeight);
    }];
    
    //xbot底部推荐
    self.bottomView = [[QMChatBottomListView alloc] initWithFrame:CGRectZero];
    self.bottomView.hidden = YES;
    [self.view addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.chatInputView.mas_top).priority(666);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(52);
    }];
    
    [self.chatTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view);
        make.bottom.equalTo(self.bottomView.mas_top);
    }];
    
    [self.view addSubview:self.dragView];
    
    __weak QMChatRoomViewController * myChatView = self;
    MJRefreshNormalHeader *mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [myChatView refresh];
    }];
    [mj_header.lastUpdatedTimeLabel setHidden:true];
    self.chatTableView.mj_header = mj_header;
    
    // 转人工
    self.manualButotn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.manualButotn.frame = CGRectMake(0, 0, 60, 30);
    self.manualButotn.titleLabel.font = [UIFont fontWithName:QM_PingFangSC_Reg size:16];
    [self.manualButotn setTitle: QMUILocalizableString(button.topeople) forState:UIControlStateNormal];
    [self.manualButotn addTarget:self action:@selector(customClick:) forControlEvents:UIControlEventTouchUpInside];
    self.manualButotn.hidden = YES;
    
    // 注销
    self.logoutButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.logoutButton.frame = CGRectMake(0, 0, 50, 30);
    self.logoutButton.titleLabel.font = [UIFont fontWithName:QM_PingFangSC_Reg size:16];
    [self.logoutButton setTitle:QMUILocalizableString(button.logout) forState:UIControlStateNormal];
    [self.logoutButton addTarget:self action:@selector(logoutAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.logoutButton];
}

- (void)createCoverView {
    self.coverView = [[UIView alloc] init];
    self.coverView.frame = CGRectMake(0, 0, QM_kScreenWidth, QM_kScreenHeight);
    self.coverView.backgroundColor = [UIColor colorWithHexString:QMColor_151515_text alpha:0.3];
    [self.view addSubview:self.coverView];
}

#pragma mark ----- 获取数据(数据模型已存储本地) -----
// 获取消息数据
- (void)getData {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.dataArray = [QMConnect getDataFromDatabase:self->_dataNum];
        
        NSMutableArray *mutableArray = [self.dataArray mutableCopy];
        
        //在这里需要在过滤一下数据,如果配置的
        
        [mutableArray enumerateObjectsUsingBlock:^(CustomMessage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if([obj.messageType isEqualToString:@"cardInfo_New"]){
                NSData *jsonData = [obj.cardInfo_New dataUsingEncoding:NSUTF8StringEncoding];
                
                NSError *err;
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
                if(err) {
                    return;
                }
                
                NSString *autoCardSend = dic[@"autoCardSend"];//是否自动发送
                if([@"true" isEqualToString: autoCardSend]){
                    *stop = YES;
                    if (*stop) {
                        [mutableArray removeObject:obj];
                    }
                }
            }
            
            
        }];
        
        
        self.dataArray =  [NSArray arrayWithArray:mutableArray];
        
        if( QMLoginManager.shared.isEvaluate == YES) {
            QMLoginManager.shared.currentEvaluateRound = 0;
        }
    
        [self.chatTableView reloadData];
        
        //如果最后一个消息是左侧并且不是机器人或者系统的，就重新计时,不是的话就停止
        CustomMessage *msg = self.dataArray.firstObject;
        if(msg!=NULL){
//            QMLog(@"%@", msg.message);
            if(![msg.fromType isEqualToString:@"0"]){
                if(![msg.device containsString:@"local"]){
                    if (![msg.userType isEqualToString:@"system"] && ![msg.isRobot isEqualToString:@"1"]) {
                            [self createNSTimer];
                    }else {
                        [self removeTimer];
                    }
                }
                
            }
        }
    });
    
}

// 下拉刷新
- (void)refresh {
    if (_dataNum>self.dataArray.count) {
        [self.chatTableView.mj_header endRefreshing];
        return;
    }
    _dataNum = _dataNum+10;
    
    [self getData];
    
    [self.chatTableView.mj_header endRefreshing];
}

// 刷新TableView
-(void)reloadTableView {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self scrollToEnd];
    });
}

// 滑动到底部
- (void)scrollToEnd {
    if (self.dataArray.count>0) {
        NSInteger count = [self.chatTableView numberOfRowsInSection:0];
        if (count > 1) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:count-1 inSection:0];
            [_chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
    }
}

// 获取后台配置信息 、 满意度调查 、回复超时时间
- (void)getInvestigateData {
    [QMConnect newSDKGetInvestigate:^(QMEvaluation * _Nonnull evaluation) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.evaluation = evaluation;
            QMPushManager.share.evaluationNum = self.evaluation.evaluats.count;
        });
    } failureBlock:^(NSString *reason){
        
    }];
}

- (void)loadImageAction:(NSNotification *)notif {
    NSString *messageId = (NSString *)notif.object;
    if (self.dataArray.count > 0) {
        [self.dataArray enumerateObjectsUsingBlock:^(CustomMessage *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj._id isEqualToString:messageId]) {
                *stop = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.dataArray.count - idx - 1 inSection:0];
                    [self.chatTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                });
            }
        }];
    }
}

#pragma mark ------- 创建会话 --------
- (void)beginNewChat:(BOOL)otherAgent {
    
//    NSString * deviceMode = UIDevice.currentDevice.model;
    NSString * systemVersion = UIDevice.currentDevice.systemVersion;
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString * deviceMode = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    NSString * navigator = [NSString stringWithFormat:@"iOS%@|%@",systemVersion,deviceMode];
    NSDictionary *param = @{@"customField":@{@"扩展信息key":@"扩展信息value",@"user_labels":@{@"vip":@"true",@"city":@"beijing"}},@"agent":@"0000",@"navigator":navigator,@"fromUrl":self.fromUrl};
    
    //@"user_labels":@{@"vip":@"true",@"city":@"beijing"}},@"agent":@"0000"};
//    QMLog(@"%@", param);
    @weakify(self)
    if (self.isOpenSchedule) {
        [QMConnect sdkBeginNewChatSessionSchedule:self.scheduleId processId:self.processId currentNodeId:self.currentNodeId entranceId:self.entranceId params:param successBlock:^(BOOL remark, NSString *chatID) {
            @strongify(self)
            dispatch_async(dispatch_get_main_queue(), ^{
                self->_beginChatID = chatID;
                QMLoginManager.shared.chatId = chatID;
                if (otherAgent) {
                    [self acceptOtherAgentChatStatus:remark];
                }else {
                    [self changeChatStatus:remark];
                }
                
                [self autoSendNewCard];//自动发送卡片
            });
        } failBlock:^(NSString *failure) {
            [self popVC];
            QMLog(@"开始会话失败");
        }];
    }else {
        [QMConnect sdkBeginNewChatSession:self.peerId params:param successBlock:^(BOOL remark, NSString *chatID) {
            @strongify(self)
            dispatch_async(dispatch_get_main_queue(), ^{
                self->_beginChatID = chatID;
                QMLoginManager.shared.chatId = chatID;
                if (otherAgent) {
                    [self acceptOtherAgentChatStatus:remark];
                }else {
                    [self changeChatStatus:remark];
                }
                [self autoSendNewCard];//自动发送卡片
            });
        } failBlock:^(NSString *failure) {
            [self popVC];
            QMLog(@"开始会话失败");
        }];
    }
}

- (void)changeChatStatus:(BOOL)remark {
    // 是否启动了评价功能
    QMLog(@"%ld", (long)self.KFStatus);
    if (self.KFStatus == QMKFStatusRobot) {
        if ([QMConnect manualButtonStatus]) {
            self.manualButotn.hidden = NO;
        } else {
            self.manualButotn.hidden = YES;
        }
    }else{
        self.manualButotn.hidden = YES;
    }
    
    [QMActivityView stopAnimating];
    [self.coverView removeFromSuperview];
    
    NSArray *bottomArr = [QMConnect xbotBottomList:@""];
    
    if (bottomArr.count > 0) {
        self.bottomView.hidden = NO;
        [self.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.chatInputView.mas_top);
            make.left.right.equalTo(self.view);
            make.height.mas_equalTo(52);
        }];
        [self.chatTableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self.view);
            make.bottom.equalTo(self.bottomView.mas_top);
        }];
        [self.bottomView showData:bottomArr];
        __weak QMChatRoomViewController *weakSelf = self;
        self.bottomView.tapSendText = ^(NSString * text) {
            [weakSelf sendText:text];
        };
    }
    else{
        self.bottomView.hidden = YES;
        [self.chatTableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.chatInputView.mas_top);
        }];
    }
}

- (void)acceptOtherAgentChatStatus:(BOOL)remark {
    if (remark == NO) {
        QMLoginManager.shared.isShowEvaluateBtn = NO;
    }else {
        QMLoginManager.shared.isShowEvaluateBtn = YES;
    }
    [QMActivityView stopAnimating];
    [self.coverView removeFromSuperview];
    [self changeBottomViewFrame];
}

#pragma mark ------socket重连-------
- (void)socketReConnect {
    [self consumeUnReadMessage];
    [QMConnect reConnectSocket];
}

#pragma mark --消费未读消息
- (void)consumeUnReadMessage {
    NSArray *arr = [QMConnect sdkGetAgentMessageWithIsRead];
    [QMConnect sdkDealImMsgWithMessageID:arr];
}

#pragma mark -------- 音视频 -------
- (void)customVideoCancel:(NSNotification *)notification {
    //    [self stopPlaying];
    //    [self.answerView removeFromSuperview];
}

// 发起视频
- (void)takeVideoBtnAction {
    //    [self endEditChatInput];
    if (self.KFStatus == QMKFStatusRobot) {
        [QMRemind showMessage:@"请先转人工后，再发起视频"];
    } else {
        
        //        BOOL audioEnabled = NO;
        AVAuthorizationStatus audioAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
        if (audioAuthStatus == AVAuthorizationStatusAuthorized || audioAuthStatus == AVAuthorizationStatusNotDetermined) {
            //            audioEnabled = YES;
        }
        
        UIAlertController *sheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *video = [UIAlertAction actionWithTitle:@"视频通话" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self showMeetView:@"video_Invite" roomId:@"" password:@""];
            
            
        }];
        
        UIAlertAction *voice = [UIAlertAction actionWithTitle:@"语音通话" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self showMeetView:@"voice_Invite" roomId:@"" password:@""];
            
        }];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [sheet addAction:video];
        [sheet addAction:voice];
        [sheet addAction:cancel];
        [self presentViewController:sheet animated:YES completion:nil];
        
    }
}

- (void)showMeetView:(NSString *)type roomId:(NSString *)roomId password:(NSString *)password {
    __weak typeof(self)wSelf = self;
    void(^closeAction)(void) = ^ {
        [wSelf createNSTimer];
    };
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:self.currentAgent.name forKey:@"other_name"];
    [param setValue:self.currentAgent.icon_url forKey:@"other_icon_url"];
    
    [param setValue:self.userName ? : @"访客" forKey:@"my_name"];
    
    [param setValue:type forKey:@"type"];
    if (roomId.length > 0) {
        [param setValue:roomId forKey:@"roomId"];
    }
    if (password.length > 0) {
        [param setValue:password forKey:@"password"];
    }
    
    Class callClass = NSClassFromString(@"QMCallingManager");
    
    SEL selecter = NSSelectorFromString(@"getCallWaitViewControllerInfo:close:");
    if ([callClass respondsToSelector:selecter]) {
        IMP imp = [callClass methodForSelector:selecter];
        UIViewController *(*func)(id, SEL, NSDictionary *, void(^)(void)) = (void *)imp;
        
        UIViewController *waitVC = func(callClass, selecter, param, closeAction);
        if ([waitVC isKindOfClass:[UIViewController class]]) {
            [self removeTimer];
            waitVC.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:waitVC animated:YES completion:nil];
        }
        
    }
}

// 视频被邀请
- (void)customVideoInvite:(NSNotification *)nofification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideKeyboard];
        NSString *nofi = (NSString *)nofification.object;
        NSArray *arr = [nofi componentsSeparatedByString:@"@"];
        
        if (arr.count > 3) {
            NSString *roomId = arr[1];
            NSString *pwd = arr[2];
            NSString *type = arr.lastObject;
            NSString *room_type = @"voice";
            if ([type containsString:@"video"]) {
                room_type = @"video";
            }
            [self showMeetView:room_type roomId:roomId password:pwd];
            
        }
    });
    
}

#pragma mark --------- 转人工事件 ---------
// 转人工客服
- (void)customClick:(UIButton *)button {
    @weakify(self)
    [QMConnect sdkConvertManual:@"14" successBlock:^{
        @strongify(self)
        QMLog(@"转人工客服成功--14");
        [self createNSTimer];
        [self changeBottomViewFrame];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.chatInputView showMoreView:NO];
        });
            
    } failBlock:^(NSString *reason){
        @strongify(self)
        QMLog(@"转人工客服失败");
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!self.isOpenSchedule) {
                [self showGuestBookViewController];
            }
        });
    }];
    
    button.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        button.enabled = YES;
    });
}

// 更改xbot底部推荐的状态
- (void)changeBottomViewFrame {
    dispatch_async(dispatch_get_main_queue(), ^{
        self->isShowAssociatsInput = NO;
        self.bottomView.hidden = YES;
        self.dragView.hidden = YES;
        [self.chatTableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.chatInputView.mas_top);
        }];
    });
}

#pragma mark ------- logoutAction 注销事件 --------
- (void)logoutAction {
    Class callClass = NSClassFromString(@"QMCallingManager");
    SEL shared = NSSelectorFromString(@"shared");
    id class = ((id(*)(id, SEL))objc_msgSend)(callClass, shared);
    SEL getisCalling = NSSelectorFromString(@"isCalling");
    BOOL isCalling = ((BOOL(*)(id, SEL))objc_msgSend)(class, getisCalling);
    
    if (isCalling) {
        [self.view RockAlertTipTitle:@"提醒" message:@"正在通话中，离开此页面会挂断通话，您确定要离开吗？" cancelTitle:@"取消" confirmTitle:@"确定" cancelBlock:^{
        } confirmBlock:^{
            SEL selecter = NSSelectorFromString(@"closeCallAction");
            if ([class respondsToSelector:selecter]) {
                IMP imp = [class methodForSelector:selecter];
                void (*func)(id, SEL) = (void *)imp;
                func(class, selecter);
            }
            [self logout];
        }];
    } else {
        [self logout];
    }
}

- (void)logout {
    [self zhugeIoAction:@"注销"];
    if (!alreadEvaluate && self.KFStatus == QMKFStatusClaim && isShowEvaluate && !self.evaluation.CSRCustomerLeavePush && self.evaluation.evaluats.count > 0) {
        if (QMLoginManager.shared.isEvaluateRound == YES) {
            if (QMLoginManager.shared.currentEvaluateRound + 1 > QMLoginManager.shared.evaluateRound) {
                [self createEvaluationView:YES andGetServerTime:NO andEvaluatId:_beginChatID andFrom:@"in"];
            }else {
                [self popVC];
            }
        }else {
            [self createEvaluationView:YES andGetServerTime:NO andEvaluatId:_beginChatID andFrom:@"in"];
        }
    }
    else{
        
        if (self.queueNum.integerValue > 0) {
            
            QMAlertTipView *alertView = [[QMAlertTipView alloc] initWithFrame:CGRectMake(0, 0, QM_kScreenWidth, kScreenAllHeight)];
            if ([QMConnect queueKeepStatus]) {
                alertView.tipString = @"离开后，请及时返回查看排队进展，以免错过人工服务";
            }
            else {
                alertView.tipString = @"离开后，将退出当前排队，再次进入需要重新排队，请确认是否退出";
            }
            alertView.confirmBlock = ^(BOOL isConfirm) {
                [self popVC];
            };
            [[UIApplication sharedApplication].keyWindow addSubview:alertView];
        }
        else {
            [self popVC];
        }
    }
}

#pragma mark ------ NSNotification --------
- (void)getNewReload:(NSNotification *)sender {
    
    [self consumeUnReadMessage];
    
    [self getData];
    [self reloadTableView];
    
    if (_isSpeak && isShowEvaluate && self.KFStatus == QMKFStatusRobot && !alreadEvaluate) {
        QMLoginManager.shared.isShowEvaluateBtn = YES;
    }
    
    if ([QMConnect customerAccessAfterMessage]) {
        if (_isSpeak) {
            [self showEvaluateButton];
        }
    }else {
        [self showEvaluateButton];
    }
}

- (void)showEvaluateButton {
    if (self.KFStatus == QMKFStatusClaim && !alreadEvaluate) {
        [QMConnect customerServiceIsSpeek:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self isShowEvaluateBtn:YES];
                QMLoginManager.shared.isEvaluate = NO;
            });
        } failBlock:^(NSString *reason){
//            QMLog(@"---%@",reason);
            if ([reason isEqualToString:@"已经评价过了，不能重复评价"]) {
                QMLoginManager.shared.isEvaluate = YES ;
                QMLoginManager.shared.currentEvaluateRound = 0;
                self->alreadEvaluate = YES;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self isShowEvaluateBtn:NO];
            });
        }];
    }
}

- (void)isShowEvaluateBtn:(BOOL)speek {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (speek && !self.evaluation.CSRCustomerPush && self.evaluation.evaluats.count > 0) {
            QMLoginManager.shared.isShowEvaluateBtn = YES;
            self->isShowEvaluate = YES;
        }
        else {
            QMLoginManager.shared.isShowEvaluateBtn = NO;
            self->isShowEvaluate = NO;
        }
    });
}

- (void)updateMessageReadStatus:(NSNotification *)notif {
    
    NSArray *cells = self.chatTableView.visibleCells;
    for (QMChatBaseCell *cell in cells) {
        if ([cell.message.status isEqualToString:@"0"] &&
            [QMPushManager share].isOpenRead) {
            cell.message.isRead = @"1";
            [cell setMessageIsRead:@"1"];
        }
    }
}

#pragma mark ----- notification ------
- (void)robotCustom {
    QMLog(@"机器人客服");
    [QMActivityView stopAnimating];
    [self.coverView removeFromSuperview];
    _titleView.stateInfoLabel.text = @"";
    //            QMUILocalizableString(title.now_robit);
    if ([QMConnect manualButtonStatus]) {
        self.manualButotn.hidden = NO;
    } else {
        self.manualButotn.hidden = YES;
    }
    self.KFStatus = QMKFStatusRobot;
    QMLoginManager *uiModel = QMLoginManager.shared;
    uiModel.isRobot = true;
    QMLoginManager.shared.KFStatus = QMKFStatusRobot;
    QMLoginManager.shared.isShowEvaluateBtn = NO;
    QMLoginManager.shared.isEvaluate = NO;
    if (QMLoginManager.shared.isOpenSwitchRobot) {
        [self setupSwitchRobotView];
    }
    
    //    [self autoSendNewCard];//自动发送卡片
    
}

- (void)customClaim {
    QMLog(@"客服在线");
    [self removeQueueTipView];
    _titleView.stateInfoLabel.text = @"";
    //            QMUILocalizableString(title.people_now);
    self.manualButotn.hidden = YES;
    self.KFStatus = QMKFStatusClaim;
    QMLoginManager *uiModel = QMLoginManager.shared;
    uiModel.isRobot = false;
    QMLoginManager.shared.KFStatus = QMKFStatusClaim;
    QMLoginManager.shared.isEvaluate = NO;
    
    [QMConnect customerServiceIsSpeek:^{
        dispatch_async(dispatch_get_main_queue(), ^{
//            [self isShowEvaluateBtn:YES];
//            QMLoginManager.shared.isEvaluate = NO;
        });
    } failBlock:^(NSString *reason){
//        QMLog(@"---%@",reason);
        if ([reason isEqualToString:@"已经评价过了，不能重复评价"]) {
            QMLoginManager.shared.isEvaluate = YES ;
        }
//        dispatch_async(dispatch_get_main_queue(), ^{
////            [self isShowEvaluateBtn:NO];
//        });
    }];
    
    [self.chatInputView.coverView setHidden:YES];
    [self createNSTimer];
    [self changeBottomViewFrame];
    
    //    [self autoSendNewCard];//自动发送卡片
    
    
}


- (void)autoSendNewCard {
    //检查数据库中是否有这个卡片类型的数据 自动发送
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *array = [QMConnect queryMessageWithContentType:@"cardInfo_New"];
        
        for (id element in array) {
            //            NSLog(@"%@", element);
            CustomMessage *msgElement = (CustomMessage *)element;
            
            NSData *jsonData = [msgElement.cardInfo_New dataUsingEncoding:NSUTF8StringEncoding];
            
            NSError *err;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
            if(err) {
                return;
            }
            
            
            NSString *cardIdByuser = dic[@"CardID"];//客户自定义的一个id 用于记录发没发过，如果为空直接发送
            
            NSString *autoCardSend = dic[@"autoCardSend"];//是否自动发送
            
            if([@"true" isEqualToString: autoCardSend]){
                
                NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                
                NSString *isSend = [userDefault stringForKey:cardIdByuser];
                
                if(cardIdByuser.length==0){
                    [QMConnect sendMsgCardInfo:dic successBlock:^{
                        QMLog(@"发送商品信息成功");
                    } failBlock:^(NSString *reason){
                        QMLog(@"发送失败");
                    }];
                }else{
                    if(![@"true" isEqualToString: isSend]){
                        [QMConnect sendMsgCardInfo:dic successBlock:^{
                            [userDefault setValue:@"true" forKey:cardIdByuser];//保存自定义的一个id  定义为“true”
                            QMLog(@"发送商品信息成功");
                        } failBlock:^(NSString *reason){
                            QMLog(@"发送失败");
                        }];
                    }
                }
                
            }
            
        }
    });
}


- (void)customOffline {
    QMLog(@"客服离线");
    self.manualButotn.hidden = NO;
    self.KFStatus = QMKFStatusOffline;
    _titleView.stateInfoLabel.text = QMUILocalizableString(title.people_isline);
    if (!self.isOpenSchedule) {
        [self showGuestBookViewController];
    }
}

// 离线推送 （坐席在后台结束会话，返回上一界面）
- (void)customFinish:(NSNotification *)notification {
    QMLog(@"客服结束会话");
    _titleView.stateInfoLabel.text = QMUILocalizableString(title.people_isleave);
    [self.chatInputView.inputView endEditing:YES];
    self.chatInputView.coverView.hidden = NO;
    self.associationView.hidden = YES ;
    self.KFStatus = QMKFStatusFinish;
    [self removeTimer];
}

#pragma mark --切换机器人
- (void)setupSwitchRobotView {
    self.dragView.hidden = NO;
    @weakify(self)
    self.dragView.clickDragViewBlock = ^(QMDragView * _Nonnull dragView) {
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            //            self.dragView.hidden = YES;
            if ([self.chatInputView.inputView isFirstResponder]) {
                [self.chatInputView.inputView resignFirstResponder];
            }
            QMSwitchRobotView *robotView = [[QMSwitchRobotView alloc] initWithFrame:CGRectZero];
            robotView.tag = 1001;
            NSArray *robotList = QMLoginManager.shared.robotList;
            robotView.dataArray = robotList;
            robotView.tapCancelBlock = ^{
                //                self.dragView.hidden = NO;
            };
            robotView.tapSwitchRobot = ^(NSString * _Nonnull robotStr, NSString * _Nonnull robotName) {
                [self switchRobot:robotStr];
            };
            [robotView showView];
        });
    };
}

- (void)switchRobot:(NSString *)robotId {
    
    [QMConnect clickSwitchRobot:QMLoginManager.shared.robotId transferToBot:robotId completion:^(NSArray *questionList) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //            self.dragView.hidden = NO;
            self->alreadEvaluate = NO;
            if (questionList.count > 0) {
                self.bottomView.hidden = NO;
                [self.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.bottom.equalTo(self.chatInputView.mas_top);
                    make.left.right.equalTo(self.view);
                    make.height.mas_equalTo(52);
                }];
                [self.chatTableView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.top.right.equalTo(self.view);
                    make.bottom.equalTo(self.bottomView.mas_top);
                }];
                [self.bottomView showData:questionList];
            } else {
                self.bottomView.hidden = YES;
                [self.chatTableView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.bottom.equalTo(self.chatInputView.mas_top);
                }];
            }
            [self.chatTableView reloadData];
        });
    } failure:^(NSString *reason) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [QMRemind showMessage:QMUILocalizableString(switch_failed)];
        });
    }];
}

#pragma mark --排队人数
- (void)customQueue:(NSNotification *)notification {
    QMLog(@"排队人数 %@、%@", notification.object,self.queueNum);
    self.manualButotn.hidden = YES;
    self.KFStatus = QMKFStatusQueue;
    self.dragView.hidden = YES;
    NSArray *array =  [QMConnect sdkQueueMessage];
    if (self.queueNum.integerValue == 0) {
        [self createNSTimer];
        self.queueNum = [NSString stringWithFormat:@"%@",notification.object];
        if (self.queueNum.integerValue > 0) {
            QMLoginManager.shared.KFStatus = QMKFStatusQueue;
        }
        UIView *topNoticeView = [UIView new];
        topNoticeView.hidden = NO;
        topNoticeView.tag = 666;
        [self.view addSubview:topNoticeView];
        [self.view insertSubview:topNoticeView aboveSubview:self.chatTableView];
        topNoticeView.backgroundColor = [UIColor colorWithHexString:@"#D6D6D6"];
        
        UILabel *tipLab = [UILabel new];
        tipLab.font = [UIFont fontWithName:QM_PingFangSC_Reg size:15];
        tipLab.numberOfLines = 0;
        tipLab.tag = 777;
        tipLab.textColor = [UIColor colorWithHexString:@"#333333"];
        [topNoticeView addSubview:tipLab];
        
        if (array.count > 1) {
            NSString *title = array[0];
            NSString *alp = array[1];
            NSString *replacedStr = [title stringByReplacingOccurrencesOfString:alp withString:[NSString stringWithFormat:@"%@",notification.object]];
            tipLab.text = replacedStr;
        } else {
            tipLab.text = [NSString stringWithFormat:@"%@: %@",QMUILocalizableString(title.line_up), notification.object];
        }
        CGFloat textHeight = [QMLabelText calculateTextHeight:tipLab.text fontName:QM_PingFangSC_Med fontSize:16 maxWidth:QM_kScreenWidth]+15;
        
        [topNoticeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.top.equalTo(self.view).offset(1);
            make.height.mas_equalTo(textHeight);
        }];
        
        [tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(topNoticeView.mas_left).offset(12);
            make.centerY.equalTo(topNoticeView);
            make.right.mas_equalTo(-12);
            make.height.mas_equalTo(textHeight);
        }];
        
        [self.chatTableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(topNoticeView.mas_bottom);
            make.left.right.equalTo(self.view);
            make.bottom.equalTo(self.chatInputView.mas_top);
        }];
    }
    else {
        UILabel *tempLabel = [self.view viewWithTag:777];
        if (array.count > 1) {
            NSString *title = array[0];
            NSString *alp = array[1];
            NSString *replacedStr = [title stringByReplacingOccurrencesOfString:alp withString:[NSString stringWithFormat:@"%@",notification.object]];
            tempLabel.text = replacedStr;
        } else {
            tempLabel.text = [NSString stringWithFormat:@"%@: %@",QMUILocalizableString(title.line_up), notification.object];
        }
    }
}

- (void)removeQueueTipView{
    self.queueNum = @"";
    UIView *topNoticeView = [self.view viewWithTag:666];
    if (topNoticeView) {
        [topNoticeView removeFromSuperview];
        [self.chatTableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self.view);
            make.bottom.equalTo(self.chatInputView.mas_top);
        }];
        [self reloadTableView];
    }
}

// 坐席信息 (坐席工号、坐席名称、坐席头像) 可能为空字符串需要判断
- (void)customAgentMessage:(NSNotification *)notification {
    QMAgent *agent = notification.object;
    NSString *string;
    
    if ([agent.type isEqualToString:@"robot"]) {
        string = [NSString stringWithFormat:@"%@", agent.name];
    } else {
        //        string = [NSString stringWithFormat:@"%@(%@)", agent.name, agent.exten];
        string = agent.name;
        [self removeQueueTipView];
    }
    string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    _titleView.nameLabel.text = [NSString stringWithFormat:@"%@",string];
    
    self.currentAgent = agent;
}

// 满意度推送
- (void)customInvestigate:(NSNotification *)notification {
    NSArray *array = notification.object;
    NSString *evaluateChatId = @"";
    if (array.count > 1) {
        _evaluateOperation = array[0];
        evaluateChatId = array[1];
    }else if (array.count == 1) {
        _evaluateOperation = array[0];
    }
    QMLog(@"满意度通知");
    [self createEvaluationView:NO andGetServerTime:YES andEvaluatId:evaluateChatId andFrom:@"out"];
//    if (QMLoginManager.shared.isEvaluateRound == YES) {
//        if (QMLoginManager.shared.currentEvaluateRound + 1 > QMLoginManager.shared.evaluateRound) {
//            [self createEvaluationView:NO andGetServerTime:YES andEvaluatId:evaluateChatId andFrom:@"out"];
//        }
//    }else {
//        [self createEvaluationView:NO andGetServerTime:YES andEvaluatId:evaluateChatId andFrom:@"out"];
//    }
}

// 专属坐席不在线通知 调用接受其他坐席服务接口成功后调用 beginSession
- (void)customVIP {
    [self.view RockAlertTipTitle:QMUILocalizableString(title.schedule_notonline) message:@"" cancelTitle:QMUILocalizableString(button.cancel) confirmTitle:QMUILocalizableString(title.transferAgent) cancelBlock:^{
    } confirmBlock:^{
        @weakify(self)
        [QMConnect sdkAcceptOtherAgentWithPeer:self.peerId successBlock:^{
            @strongify(self)
            [self beginNewChat:YES];
        } failBlock:^(NSString *reason){
            [QMRemind showMessage:QMUILocalizableString(title.schedule_faile)];
        }];
    }];
}

#pragma mark -- // 日程管理的留言
- (void)customLeavemsg: (NSNotification*)notification {
    NSArray *array = notification.object;
    NSString *str = array[0];
    [QMConnect sdkGetWebchatScheduleConfig:^(NSDictionary * _Nonnull scheduleDic) {
        dispatch_async(dispatch_get_main_queue(), ^{
            for (NSDictionary*dic in scheduleDic[@"leavemsgNodes"]) {
                if ([str isEqualToString:dic[@"_id"]]){
                    NSMutableArray *fieldArray = [NSMutableArray array];
                    for (id field in dic[@"leavemsgFields"]) {
                        if ([field[@"enable"] boolValue] == YES) {
                            [fieldArray addObject:field];
                        }
                    }
                    [self zhugeIoAction:@"进入日程管理留言"];
                    QMChatGuestBookViewController *guestBookVC = [[QMChatGuestBookViewController alloc] init];
                    guestBookVC.peerId = array[1];
                    guestBookVC.contactFields = fieldArray;
                    guestBookVC.headerTitle = dic[@"title"];
                    guestBookVC.leaveMsg = dic[@"contentTip"];
                    guestBookVC.isScheduleLeave = true;
                    [self removeTimer];
                    [self.navigationController pushViewController:guestBookVC animated:YES];
                }
            }
        });
    } failBlock:^(NSString *reason){
        QMLog(@"日程管理进入留言失败");
    }];
}

// 坐席正在输入
- (void)changeCustomStatus {
    
    if (self.KFStatus == QMKFStatusClaim) {
        _titleView.stateInfoLabel.text = QMUILocalizableString(title.other_writing);
    }
    
    self.closeTime = 5;
    if (self.backStatus == nil || self.backStatus.isValid == NO) {
        @weakify(self)
        self.backStatus = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
            @strongify(self)
            self.closeTime -= 1;
            if (self.closeTime <= 0) {
                [timer invalidate];
                self.titleView.stateInfoLabel.text = @"";
            }
        }];
    }
    
}

// 撤回消息
- (void)cbangeDrowMessageStatus:(NSNotification*)notification {
    NSString *messageId = notification.object;
    [QMConnect changeDrawMessageStatus:messageId];
    [self getData];
    [self reloadTableView];
}

// 小陌机器人是否开启满意度评价
- (void)customSatisfaction:(NSNotification *)notification {
    NSArray *arr = notification.object;
    
    if (arr[1]) {
        _intelligentRobot = arr[1];
    }
    
    if ([arr[0] isEqualToString:@"true"]) {
        isShowEvaluate = true;
        if (_isSpeak) {
            QMLoginManager.shared.isShowEvaluateBtn = YES;
        }
    }
}

// xbot机器人开启联想输入
- (void)customAssociatsInput:(NSNotification *)notification {
    NSArray *arr = notification.object;
    NSString *channel = arr[4];
    if ([channel isEqualToString:@"agent"]) {
        isShowAssociatsWithAgent = YES;
    }
    _cateIdArr = arr[1];
    isShowAssociatsInput = arr[0];
    _intelligentRobot = arr[2];
}

//更新已读未读状态
- (void)refreshVoiceMessage:(NSNotification *)notification {
    NSArray *array = notification.object;
    NSString *messageId = array[0];
    NSString *attText = array[1];
    
    if (attText.length > 0) {
        [QMRemind showMessage:attText showTime:5 andPosition:QM_kScreenHeight/2 - 20];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSInteger row = 0;
        NSArray *messageModel = [QMConnect getOneDataFromDatabase:messageId];
        CustomMessage *oneModel = [[CustomMessage alloc] init];
        if (messageModel.count == 1) {
            oneModel = messageModel[0];
        }
        for (CustomMessage *item in self.dataArray) {
            if ([messageId isEqualToString:item._id]) {
                row = [self.dataArray indexOfObject:item];
                if (oneModel.fileName.length > 0) {
                    item.fileName = oneModel.fileName;
                }
            }
        }
        row = self.dataArray.count - row - 1;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        
        [self.chatTableView reloadRowsAtIndexPaths:@[indexPath]withRowAnimation:UITableViewRowAnimationNone];
    });
    
}

#pragma mark -------键盘监听-------
- (void)keyboardFrameChange:(NSNotification *)notification {
    
    QMChatFormView *formView = (QMChatFormView *)[[UIApplication sharedApplication].keyWindow viewWithTag:88];
    QMStarEvaluationView *starView = (QMStarEvaluationView *)[[UIApplication sharedApplication].keyWindow viewWithTag:89];
    
    
    
    
    if (formView || starView) {
        return;
    }
    
    
    
    
    NSDictionary *userInfo = notification.userInfo;
    NSValue * value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect newFrame = [value CGRectValue];
    
    if (ceil(newFrame.origin.y) == [UIScreen mainScreen].bounds.size.height) {
        
        CGPoint point = self.chatTableView.contentOffset;
        [self.chatTableView setContentOffset:point];
        CGFloat offy = 0.0;
        if (QM_IS_iPHONEX) {
            offy = 14.0;
        }
        [self.chatInputView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).offset(-offy);
        }];
        
    } else {
        
        [self.chatInputView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).offset(-newFrame.size.height);
        }];
        
        if (self.keyBoardFrame.origin.y != newFrame.origin.y) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self scrollToEnd];
            });
        }
    }
    self.keyBoardFrame = newFrame;
    self.associationView.frame = CGRectMake(0, CGRectGetMinY(self.chatInputView.frame)-_questions.count*50, QM_kScreenWidth, _questions.count*50);
}

- (void)keyboardWillShow:(NSNotification *)notification {
    QMChatFormView *formView = (QMChatFormView *)[[UIApplication sharedApplication].keyWindow viewWithTag:88];
    if (formView) {
        //如果window view是表单view，处理高度
        NSDictionary *userInfo = notification.userInfo;
        CGRect keyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        
        CGFloat keyboardHeight = keyboardFrame.size.height;
        //        CGFloat offset = 20; // 输入框或视图距离键盘的偏移量
        CGFloat offset = 0; // 输入框或视图距离键盘的偏移量
        
        // 计算输入框或视图需要上移的距离
        CGFloat moveHeight = keyboardHeight + offset;
        
        // 将输入框或视图向上移动
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = self.view.frame;
            frame.origin.y = -moveHeight + 35;
            formView.frame = frame;
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    QMChatFormView *formView = (QMChatFormView *)[[UIApplication sharedApplication].keyWindow viewWithTag:88];
    if(formView){
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = self.view.frame;
            frame.origin.y = 0;
            formView.frame = frame;
        }];
    }
}
#pragma mark - hideKeyboard
- (void)hideKeyboard {
    [self.chatTableView endEditing:YES];
    

    if ([self.chatInputView.inputView isFirstResponder]) {
        [self.chatInputView.inputView resignFirstResponder];
        self.chatInputView.inputView.inputView = nil;
        [self.chatInputView showMoreView:NO];
    }
    
    
    
}

#pragma mark ------ 留言提示 -------
- (void)showGuestBookViewController {
    
    if ([QMConnect allowedLeaveMessage]) {
        NSString *msg = [QMConnect clientLeavemsgTitle];
        if ([msg isEqualToString:@""]) {
            msg = [QMConnect leaveMessageTitle];
        }
//        NSString *msg = [QMConnect leaveMessageTitle];
        if ([msg isEqualToString:@""]) {
            msg = QMUILocalizableString(title.messageprompts);
        }
        [self.view RockAlertTipTitle:@"" message:msg cancelTitle:QMUILocalizableString(button.signOut) confirmTitle:QMUILocalizableString(button.leaveMessage) cancelBlock:^{
            [self logoutAction];
        } confirmBlock:^{
            [self zhugeIoAction:@"进入技能组留言"];
            QMChatGuestBookViewController *guestBookVC = [[QMChatGuestBookViewController alloc] init];
            guestBookVC.peerId = self.peerId;
            [self removeTimer];
            [self.navigationController pushViewController:guestBookVC animated:YES];
        }];
    }else {
       NSString *msg = [QMConnect leaveMessageAlert];
        if ([msg isEqualToString:@""]) {
            msg = QMUILocalizableString(title.messageprompts);
        }
        UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"" message: msg preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:QMUILocalizableString(title.iknow) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertView addAction:cancel];
        [self presentViewController:alertView animated:YES completion:nil];
    }
}

#pragma mark ------ 满意度评价 -------
// 满意度view from - 主动传 in --- 坐席推送的评价传out
- (void)createEvaluationView:(BOOL)isPop andGetServerTime:(BOOL)GetSer andEvaluatId:(NSString *)evaluatId andFrom:(NSString *)from {
    [self zhugeIoAction:@"评价框弹出"];
    
    if (self.evaluation.evaluats.count == 0) {
        [QMRemind showMessage:QMUILocalizableString(title.evaluation_remind)];
        if (isPop) {
            [self popVC];
        }
        return;
    }
    __weak typeof(self) weakSelf = self;
    
    [self.chatInputView showMoreView:NO];
    self.chatInputView.inputView.inputView = nil;
    [self.chatInputView.inputView endEditing:YES];
    
    self.evaluationView = [[QMStarEvaluationView alloc] initWithFrame:CGRectMake(0, 0, QM_kScreenWidth, kScreenAllHeight-kStatusBarAndNavHeight) evaluation:self.KFStatus == QMKFStatusRobot ? self.xbotEvaluation : self.evaluation];
    self.evaluationView.tag = 89;
    [self.view addSubview:self.evaluationView];
    
    @weakify(self)
    self.evaluationView.cancelSelect = ^{
        @strongify(self)
        [self.evaluationView removeFromSuperview];
        self->_evaluateOperation = @"";
        
        if (GetSer) {
            /// 获取时效参数
            [QMConnect sdkGetServerTime:^(NSString *timestamp) {
                QMLog(@"timestamp %@",timestamp);
                self.serviceTime = timestamp;
            } failureBlock:nil];
        }

        NSMutableDictionary *dic = @{@"text"    : @"",
                                     @"id"      : evaluatId,
                                     @"status"  : @"0",
                                     @"timeout" : self.evaluation.timeout
        }.mutableCopy;
        if (self.evaluation.CSRAging) {//是否开启满意度超时
            [QMConnect sdkGetServerTime:^(NSString *timestamp) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    QMLog(@"timestamp %@",timestamp);
                    if (evaluatId.length > 0 && ![from isEqualToString:@"send"]) {
                        [dic setValue:timestamp forKey:@"timestamp"];
                        [self sendEvaluateMessage:dic];
                    }
                });
            } failureBlock:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [dic setValue:@"" forKey:@"timestamp"];
                    if (evaluatId.length > 0 && ![from isEqualToString:@"send"]) {
                        [self sendEvaluateMessage:dic];
                    }
                });
            }];
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [dic setValue:@"" forKey:@"timestamp"];
                if (evaluatId.length > 0 && ![from isEqualToString:@"send"]) {
                    [self sendEvaluateMessage:dic];
                }
            });
        }

        if (isPop) {
            [self popVC];
        }
    };
    
    if ([from isEqualToString:@"send"]) {
        from = @"out";
    }
    self.evaluationView.sendSelect = ^(NSString *evaluatType,NSString *optionName, NSString *optionValue, NSArray *radioValue, NSString *textViewValue) {
        @strongify(self)
        [self.evaluationView removeFromSuperview];
        __strong typeof(weakSelf)sSelf = weakSelf;
        [QMConnect sdkNewSubmitInvestigate: self.KFStatus == QMKFStatusRobot ? @"xbotEvaluat" : evaluatType name:optionName value:optionValue radioValue:radioValue remark:textViewValue way:from operation:self->_evaluateOperation sessionId:evaluatId successBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [QMActivityView stopAnimating];
                NSString *evalatStr = self.KFStatus == QMKFStatusRobot ? weakSelf.xbotEvaluation.thank : weakSelf.evaluation.thank;
                [QMRemind showMessage:evalatStr ?: QMUILocalizableString(button.chat_thank)];
                self->alreadEvaluate = YES;
                [self isShowEvaluateBtn:NO];
                QMLoginManager.shared.isEvaluate = YES;
                NSString *nameStr = [@"用户已评价:" stringByAppendingFormat:@"%@ ",optionName];
                NSString *radioStr = @"";
                if (radioValue.count > 0) {
                    radioStr = [radioValue componentsJoinedByString:@","];
                    radioStr = [@"标签:" stringByAppendingFormat:@"%@ ", radioStr];
                }
                NSString *textViewStr = @"";
                if (textViewValue.length > 0) {
                    textViewStr = [@"详细信息:" stringByAppendingFormat:@"%@ ", textViewValue];
                }
                NSString *messageStr = [NSString stringWithFormat:@"%@%@%@",nameStr, radioStr, textViewStr];
                for (CustomMessage *msg in weakSelf.dataArray) {
                    if ([msg.messageType isEqualToString:@"evaluate"]) {
                        msg.evaluateStatus = @"1";
                        [QMConnect sdkUpdateEvaluateStatusWithEvaluateId:msg.evaluateId.length > 0 ? msg.evaluateId : @""];
                    }
                }
//                [QMConnect sdkUpdateEvaluateStatusWithEvaluateId:evaluatId.length > 0 ? evaluatId : @""];
                NSDictionary *dic = @{@"text"      : messageStr,
                                      @"id"        : @"",
                                      @"status"    : @"2",
                                      @"timestamp" : @"",
                                      @"timeout"   : @""
                };
                [self sendEvaluateMessage:dic];
            });
        } failBlock:^(NSString *reason){
            QMLog(@"评价失败");
            [QMActivityView stopAnimating];
            [sSelf isShowEvaluateBtn:YES];
        }];
                
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableDictionary *dic = @{@"text"    : @"",
                                         @"id"      : evaluatId,
                                         @"status"  : @"0",
                                         @"timeout" : self.evaluation.timeout
            }.mutableCopy;
            [dic setValue:@"" forKey:@"timestamp"];
            if (evaluatId.length > 0 && ![from isEqualToString:@"send"]) {
                [self sendEvaluateMessage:dic];
            }
        });
        
        if (isPop) {
            [sSelf popVC];
        }
    };
}

- (void)sendEvaluateMessage:(NSDictionary *)dic {
    
    [QMConnect sdkSendEvaluateMessage:dic];
}

- (void)pushSatisfaction:(NSString *)faction robotId:(NSString *)robotId {
    NSString *robotType = [QMConnect sdkRobotType];
    if ([robotType isEqualToString:@"xbot"]) {
        [QMConnect sdkSubmitXbotRobotSatisfaction:faction successBlock:^{
            QMLog(@"评价成功");
            dispatch_async(dispatch_get_main_queue(), ^{
                [QMRemind showMessage:QMUILocalizableString(title.robot_evaluation_ok)];
                self->alreadEvaluate = YES;
                [self hiddenEvaluationButton];
            });
        } failBlock:^(NSString *reason){
            QMLog(@"评价失败");
            dispatch_async(dispatch_get_main_queue(), ^{
                [QMRemind showMessage:QMUILocalizableString(title.robot_evaluation_fail)];
            });
        }];
    }else if ([robotType isEqualToString:@"7mbot_ai"]) {
        [QMConnect sdkSubmitIntelligentRobotSatisfaction:robotId satisfaction:faction successBlock:^{
            QMLog(@"评价成功");
            dispatch_async(dispatch_get_main_queue(), ^{
                [QMRemind showMessage:QMUILocalizableString(title.robot_evaluation_ok)];
                self->alreadEvaluate = YES;
                [self hiddenEvaluationButton];
            });
        } failBlock:^(NSString *reason){
            QMLog(@"评价失败");
            dispatch_async(dispatch_get_main_queue(), ^{
                [QMRemind showMessage:QMUILocalizableString(title.robot_evaluation_fail)];
            });
        }];
    }else {
        [QMConnect sdkSubmitXbotRobotSatisfaction:faction successBlock:^{
            QMLog(@"评价成功");
            dispatch_async(dispatch_get_main_queue(), ^{
                [QMRemind showMessage:QMUILocalizableString(title.robot_evaluation_ok)];
                self->alreadEvaluate = YES;
                [self hiddenEvaluationButton];
            });
        } failBlock:^(NSString *reason){
            QMLog(@"评价失败");
            dispatch_async(dispatch_get_main_queue(), ^{
                [QMRemind showMessage:QMUILocalizableString(title.robot_evaluation_fail)];
            });
        }];
    }
}

- (void)hiddenEvaluationButton {
    QMLoginManager.shared.isShowEvaluateBtn = NO;
}

- (void)popVC {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.KFStatus == QMKFStatusClaim &&[QMLoginManager.shared.visitorFinishSessionCharge  isEqual: @"1"]){
            [QMConnect sdkfinishSessionByVisitorSuccessBlock:^{
                QMLog(@"访客主动关闭会话成功");
            } failBlock:^{
                QMLog(@"访客主动关闭会话失败");
            }];
        }
        [self remeveAllfunc];
        [self.navigationController popViewControllerAnimated:YES];
    });
}

- (void)remeveAllfunc {
    _isSpeak = NO;
    alreadEvaluate = NO;
    [[QMAudioPlayer sharedInstance] stopAudioPlayer];
    [QMConnect logout];
    [self removeTimer];
    if (self.chatInputView.recordeView) {
        [QMAudioRecorder.sharedInstance cancelAudioRecord];
    }
}

#pragma mark ------ 开启访客无响应 定时断开会话 ------
- (void)createNSTimer{
//     [QMConnect createNoresponseTimer];//锁定会话关闭定时器
}
//移除定时器
- (void)removeTimer {
//    [QMConnect removeNoresponseTimer];//锁定会话关闭定时器
}
//锁定会话新增
-(void)breakTips{
    
    [QMConnect showBreakTips];
    
}
//断开会话
- (void)breakTimerAction{

    [self removeTimer];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.chatInputView.inputView endEditing:YES];
        self.manualButotn.hidden = YES;
        self.chatInputView.coverView.hidden = NO;
        self->_titleView.stateInfoLabel.text = QMUILocalizableString(title.people_isleave);
//        [QMConnect sdkClientChatClose:self->_beginChatID];//锁定会话注释
        [self closeChatView];
    });
    
}

- (void)closeChatView {
//    QMSwitchRobotView *robotView = [[UIApplication sharedApplication].keyWindow viewWithTag:1001];
//    if (robotView) {
//        [robotView dismissView];
//    }
    
    QMAlertTipView *alertView = [[QMAlertTipView alloc] initWithFrame:CGRectMake(0, 0, QM_kScreenWidth, kScreenAllHeight)];
    alertView.tag = 102;
    alertView.tipString = [QMConnect breakChatTipContent].length>0 ? [QMConnect breakChatTipContent] :QMUILocalizableString(systemTipContent);
    alertView.closeChat = QMUILocalizableString(close session);
    alertView.confirmBlock = ^(BOOL isConfirm) {
        [self logout];
    };
    QMAlertTipView *alertV = [[UIApplication sharedApplication].keyWindow viewWithTag:102];
    if (!alertV) {
        [[UIApplication sharedApplication].keyWindow addSubview:alertView];
    }
}

#pragma mark ------- 继续咨询 ------
- (void)tapAction {
    self.tapCoverView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.tapCoverView.backgroundColor = [UIColor colorWithHexString:QMColor_000000_text alpha:0.3];
    [self.view addSubview:self.tapCoverView];

    UIView *tapView = [[UIView alloc] init];
    tapView.frame = CGRectMake(0, QM_kScreenHeight - kStatusBarAndNavHeight - 190, QM_kScreenWidth, 190);
    tapView.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_News_Agent_Dark : QMColor_News_Agent_Light];
    [self.tapCoverView addSubview:tapView];

    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, QM_kScreenWidth, 40)];
    headerLabel.text = @"提示";
    headerLabel.font = QMFont_Medium(14);
    headerLabel.textColor = [UIColor colorWithHexString:isDarkStyle ? @"#959595" : QMColor_333333_text];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_News_Agent_Dark : @"#F5F5F5"];
    [tapView addSubview:headerLabel];

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 60, QM_kScreenWidth-30, 40)];
    titleLabel.text = QMUILocalizableString(title.chatFinish_reopen);
    titleLabel.font = QMFont_Medium(14);
    titleLabel.textColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_D5D5D5_text : QMColor_151515_text];
    titleLabel.numberOfLines = 0;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    [tapView addSubview:titleLabel];

    UIButton *beginBtn = [[UIButton alloc] init];
    beginBtn.frame = CGRectMake((QM_kScreenWidth - 235)/2, 115, 110, 40);
    beginBtn.titleLabel.font = [UIFont fontWithName:QM_PingFangSC_Reg size:15];
    [beginBtn setTitle:QMUILocalizableString(title.chatBegin) forState:UIControlStateNormal];
    [beginBtn setTitleColor:[UIColor colorWithHexString:QMColor_FFFFFF_text] forState:UIControlStateNormal];
    [beginBtn setBackgroundColor:[UIColor colorWithHexString:QMColor_News_Custom]];
    beginBtn.layer.masksToBounds = YES;
    beginBtn.layer.cornerRadius = 5;
    [beginBtn addTarget:self action:@selector(beginAction) forControlEvents:UIControlEventTouchUpInside];
    [tapView addSubview:beginBtn];

    UIButton *outBtn = [[UIButton alloc] init];
    outBtn.frame = CGRectMake(QM_kScreenWidth/2 + 7.5, 115, 110, 40);
    outBtn.titleLabel.font = [UIFont fontWithName:QM_PingFangSC_Reg size:15];
    [outBtn setTitle:QMUILocalizableString(button.signOut) forState:UIControlStateNormal];
    [outBtn setTitleColor:[UIColor colorWithHexString:isDarkStyle ? QMColor_D5D5D5_text : QMColor_FFFFFF_text] forState:UIControlStateNormal];
    [outBtn setBackgroundColor:[UIColor colorWithHexString:isDarkStyle ? QMColor_3D3D3D_text : QMColor_News_Custom]];
    outBtn.layer.masksToBounds = YES;
    outBtn.layer.cornerRadius = 5;
    [outBtn addTarget:self action:@selector(outAction) forControlEvents:UIControlEventTouchUpInside];
    [tapView addSubview:outBtn];
    if (QMLoginManager.shared.isNetworkError == YES) {
        titleLabel.text = QMUILocalizableString(title.chatFail_reason);
        titleLabel.textAlignment = NSTextAlignmentLeft;
        beginBtn.hidden = YES;
        outBtn.frame = CGRectMake(QM_kScreenWidth/2 - 55, 115, 110, 40);
        [outBtn setTitle:QMUILocalizableString(button.reenter) forState:UIControlStateNormal];
    }
    
    UIButton *cancelBtn = [[UIButton alloc] init];
    cancelBtn.frame = CGRectMake(QM_kScreenWidth - 26, 10, 20, 20);
    cancelBtn.titleLabel.font = [UIFont fontWithName:QM_PingFangSC_Reg size:15];
    [cancelBtn setTitle:@"X" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor colorWithHexString:isDarkStyle ? QMColor_D5D5D5_text : QMColor_666666_text] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [tapView addSubview:cancelBtn];
}

- (void)beginAction {
    [QMActivityView startAnimating];
    [self createCoverView];
    [self.tapCoverView removeFromSuperview];
    [self.chatInputView.coverView setHidden:YES];
    [self getConfig];
}

- (void)outAction {
    [self.tapCoverView removeFromSuperview];
    [self.chatInputView.coverView setHidden:YES];
    [self logoutAction];
}

- (void)cancelAction {
    [self.tapCoverView removeFromSuperview];
    
}

#pragma mark --全局配置
- (void)getConfig {
    @weakify(self)
    [QMConnect sdkGetWebchatScheduleConfig:^(NSDictionary * _Nonnull scheduleDic) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self)
            if ([QMConnect allowRobot]) {
                self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.manualButotn];
            }
            [self.chatInputView refreshInputView];
            self.scheduleDic = scheduleDic;
            if ([self.scheduleDic[@"scheduleEnable"] intValue] == 1) {
                QMLog(@"日程管理");
                [self starSchedule];
            }else{
                QMLog(@"技能组");
                [self getPeers];
            }
        });
    } failBlock:^(NSString *reason){
        [self getPeers];
    }];
}

- (void)getPeers {
    
    [QMConnect sdkGetPeers:^(NSArray * _Nonnull peerArray) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *peers = peerArray;
            if (peers.count == 1 && peers.count != 0) {
                [self setPropertyValue:[peers.firstObject objectForKey:@"id"] processType:@"" entranceId:@""];
            }else {
                [self showPeersWithAlert:peers messageStr:QMUILocalizableString(title.type)];
            }
        });
    } failureBlock:^(NSString *reason){
        [QMActivityView stopAnimating];
    }];
}

- (void)starSchedule {
    
    if ([self.scheduleDic[@"scheduleId"] isEqual: @""] || [self.scheduleDic[@"processId"] isEqual: @""] || [self.scheduleDic objectForKey:@"entranceNode"] == nil || [self.scheduleDic objectForKey:@"leavemsgNodes"] == nil) {
        [QMRemind showMessage:QMUILocalizableString(title.sorryconfigurationiswrong)];
        [QMActivityView stopAnimating];
    }else{
        NSDictionary *entranceNode = self.scheduleDic[@"entranceNode"];
        NSArray *entrances = entranceNode[@"entrances"];
        if (entrances.count == 1 && entrances.count != 0) {
            [self setPropertyValue:[entrances.firstObject objectForKey:@"processTo"] processType:[entrances.firstObject objectForKey:@"processType"] entranceId:[entrances.firstObject objectForKey:@"_id"]];
        }else{
            [self showPeersWithAlert:entrances messageStr:QMUILocalizableString(title.schedule_type)];
        }
    }
}

- (void)showPeersWithAlert: (NSArray *)peers messageStr: (NSString *)message {
    [QMActivityView stopAnimating];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:QMUILocalizableString(button.cancel) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self.chatInputView.coverView setHidden:NO];
        [self popVC];
    }];
    [alertController addAction:cancelAction];
    for (NSDictionary *index in peers) {
        UIAlertAction *surelAction = [UIAlertAction actionWithTitle:[index objectForKey:@"name"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if ([self.scheduleDic[@"scheduleEnable"] integerValue] == 1) {
                [self setPropertyValue:[index objectForKey:@"processTo"] processType:[index objectForKey:@"processType"] entranceId:[index objectForKey:@"_id"]];
            }else{
                [self setPropertyValue:[index objectForKey:@"id"] processType:@"" entranceId:@""];
            }
        }];
        [alertController addAction:surelAction];
    }
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)setPropertyValue:(NSString *)peerId processType:(NSString *)processType entranceId:(NSString *)entranceId {
    self.peerId = peerId;
    //创建文件夹
    [[QMProfileManager sharedInstance] loadProfile:self.peerId password:@"moor"];
    [QMActivityView stopAnimating];
    if ([self.scheduleDic[@"scheduleEnable"] intValue] == 1) {
        self.isOpenSchedule = YES;
        self.scheduleId = self.scheduleDic[@"scheduleId"];
        self.processId = self.scheduleDic[@"processId"];
        self.currentNodeId = peerId;
        self.entranceId = entranceId;
    }
    
    CGFloat addViewHeight = QM_IS_iPHONEX ? 144 : 110;
    addViewHeight = [QMConnect sdkVideoRights] ? (addViewHeight + 96) : addViewHeight;
    // 扩展面板
    self.addView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, QM_kScreenWidth, addViewHeight);

    [self beginNewChat:NO];
}

#pragma mark ----- MoreView Action ------
- (void)moreViewSelectAcitonIndex:(QMChatMoreMode)index {
    switch (index) {
        case QMChatMoreModePicture:
            [self.chatInputView showMoreView:NO];
            [self takePicBtnAction];
            break;
        case QMChatMoreModeCamera:
            [self.chatInputView showMoreView:NO];
            [self photoBtnAction];
            break;
        case QMChatMoreModeFile:
            [self.chatInputView showMoreView:NO];
            [self takeFileBtnAction];
            break;
        case QMChatMoreModeQuestion:
            [self openQuestionView];
            break;
        case QMChatMoreModeVideo:
            [self takeVideoBtnAction];
            break;
        case QMChatMoreModeEvaluate:
            self.chatInputView.inputView.inputView = nil;
            [self.chatInputView.inputView endEditing:YES];
            [self evaluateBtnAction];
            break;
        
        default:
            break;
    }
}
- (void)photoBtnAction {
    [self takePicture];
}

//从相册获取图片
- (void)takePicBtnAction {
    [self selectFile:QMSelectTypePhoto];
}

// 获取文件
- (void)takeFileBtnAction {
    [self selectFile:QMSelectTypeFile];
}

// 满意度评价
- (void)evaluateBtnAction {
    
    if (self.KFStatus == QMKFStatusRobot) {
        
        if (alreadEvaluate) {
            return;
        }
        [QMConnect SDKGetXbotInvestigate:_intelligentRobot success:^(QMEvaluation *_Nonnull evaluation) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.xbotEvaluation = evaluation;
                [self createEvaluationView:NO andGetServerTime:NO andEvaluatId:@"" andFrom:@"in"];
            });
        } failureBlock:^(NSString *reason) {
            
        }];
        
        
//        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:QMUILocalizableString(title.robot_evaluation) message:nil preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction * resolvedAction = [UIAlertAction actionWithTitle:QMUILocalizableString(button.solved_ok) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            [self pushSatisfaction:@"true" robotId:self.intelligentRobot];
//        }];
//        [alertController addAction:resolvedAction];
//
//        UIAlertAction * unsolvedAction = [UIAlertAction actionWithTitle:QMUILocalizableString(button.solved_fail) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            [self pushSatisfaction:@"false" robotId:self.intelligentRobot];
//        }];
//        [alertController addAction:unsolvedAction];
//
//        UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:QMUILocalizableString(button.cancel) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//
//        }];
//        [alertController addAction:cancelAction];
//        [self presentViewController:alertController animated:YES completion:nil];
        
    }else {
        
        if (self.evaluation.CSRAging && self.serviceTime.length > 0 && self.evaluation.timeout.length > 0) {
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setValue:self.serviceTime forKey:@"timestamp"];
            [params setValue:self.evaluation.timeout forKey:@"timeout"];
            [QMConnect sdkCheckImCsrTimeoutParams:params success:^{
                [self createEvaluationView:NO andGetServerTime:NO andEvaluatId:@"" andFrom:@"in"];
            } failureBlock:^{
                [QMRemind showMessage:QMUILocalizableString(title.evaluation_timeout) showTime:5 andPosition:QM_kScreenHeight/2 - 10];
            }];
        } else {
            [self createEvaluationView:NO andGetServerTime:NO andEvaluatId:@"" andFrom:@"in"];
        }
    }
}

// 常见问题
- (void)openQuestionView {
    QMQuestionViewController *vc = [QMQuestionViewController new];
    __weak typeof(self)wSelf = self;
    vc.backQuestion = ^(QMQuestionModel * model) {
        [wSelf insertModeltoIMDB:model];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)insertModeltoIMDB:(QMQuestionModel *)model {
    [QMConnect createAndInsertMessageToDBWithMessageType:@"Text" filePath:nil content:model.title metaData:nil];
}

#pragma mark - UITextViewDelegate && xbot联想输入
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqual:@"\n"]) {
        if (![self.chatInputView.inputView.text isEqualToString:@""]) {
            NSString *text = [_chatInputView.inputView.textStorage getRichString];
            [self sendText:text];
            self.chatInputView.inputView.text = @"";
            self.associationView.hidden = YES;
            
            return NO;
        }
        return NO;
    }
    return  YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length > 0) {
        if (self.KFStatus == QMKFStatusClaim) {
            isShowAssociatsInput = isShowAssociatsWithAgent;
            if ([QMConnect sdkGetIsInputMonitor]) {
                long nowTime = [NSString getTimeStamp:[NSDate date]];
                if ((dateTime == 0) || (nowTime - dateTime > 0.5)) {
                    dateTime = nowTime;
                    [QMConnect sdkInputMonitor:textView.text successBlock:^{
                    } failBlock:^{
                    }];
                }
            }
        }
        if (isShowAssociatsInput) {
            long nowTime = [NSString getTimeStamp:[NSDate date]];
            
//            if ((dateTime == 0) || (nowTime - dateTime > 0.5)) {
                dateTime = nowTime;
                NSString *robotType = [QMConnect sdkRobotType];
                robotType = [robotType isEqual: @""] ? @"xbot" : robotType;
                [QMConnect sdkSubmitXbotRobotAssociationInput:textView.text cateIds:_cateIdArr robotId:_intelligentRobot robotType:robotType successBlock:^(NSArray *questions){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (questions.count > 0 && textView.text.length > 0) {
                            self->_questions = questions;
                                [self createQuestionView:questions andInputText:textView.text];
                        }else {
                            self->_questions = @[];
                            self.associationView.hidden = YES;
                        }
                    });
                } failBlock:^(NSString *reason){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.associationView.hidden = YES;
                    });
                }];
//            }
        }else {
            self.associationView.hidden = YES;
        }
    }else {
        self.associationView.hidden = YES;
    }
}

//xbot联想输入view
- (void)createQuestionView:(NSArray *)questions andInputText:(NSString *)text {
    __weak typeof(self) weakSelf = self;

    if (!self.associationView) {
        self.associationView = [[QMChatAssociationInputView alloc] init];
        [self.view addSubview:self.associationView];
    }
    self.associationView.hidden = NO;
    self.associationView.frame = CGRectMake(0, CGRectGetMinY(self.chatInputView.frame)-questions.count*50, QM_kScreenWidth, questions.count*50);
    [self.associationView showData:questions andInputText:text];
    self.associationView.questionsSelect = ^(NSString *question) {
        [weakSelf sendText:question];
        weakSelf.chatInputView.inputView.text = @"";
        weakSelf.associationView.hidden = YES;
    };
}

- (void)sendAudio:(NSString *)audioName duration:(NSString *)duration {
    [self sendAudioMessage:audioName duration:duration];
}

- (void)sendTextViewText:(NSString *)text {
    [self sendText:text];
}

- (void)didBecomeActive {
    [self zhugeIoAction:@"恢复前台"];
}

- (void)didEnterBackground {
    [self zhugeIoAction:@"进入后台"];
}

//挂起状态取消录音
- (void)didResignActiveNotif {
    [[QMAudioRecorder sharedInstance] cancelAudioRecord];
}

- (void)zhugeIoAction:(NSString *)actionName {
    [QMZhugeManager trackEvent:actionName];
}

- (UITableView *)chatTableView {
    if (!_chatTableView) {
        _chatTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, QM_kScreenWidth, QM_kScreenHeight-kInputViewHeight-_navHeight) style:UITableViewStylePlain];
        _chatTableView.delegate = self;
        _chatTableView.dataSource = self;
        _chatTableView.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_Main_Bg_Dark : QMColor_Main_Bg_Light];
        _chatTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _chatTableView.rowHeight = UITableViewAutomaticDimension;
        _chatTableView.estimatedRowHeight = 80;
        _chatTableView.decelerationRate = UIScrollViewDecelerationRateNormal;
        
        UITapGestureRecognizer * gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
        [_chatTableView addGestureRecognizer:gestureRecognizer];
        gestureRecognizer.cancelsTouchesInView = NO;
    }
    return _chatTableView;
}

- (QMChatInputView *)chatInputView {
    if (!_chatInputView) {
        _chatInputView = [[QMChatInputView alloc] initWithFrame:CGRectMake(0, QM_kScreenHeight-kInputViewHeight-_navHeight, QM_kScreenWidth, kInputViewHeight)];
        _chatInputView.delegate = self;
        _chatInputView.inputView.delegate = self;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [_chatInputView.coverView addGestureRecognizer:tapGesture];
        [_chatInputView.coverView setHidden:YES];
    }
    return _chatInputView;
}

- (QMDragView *)dragView {
    if (!_dragView) {
        _dragView = [[QMDragView alloc] initWithFrame:CGRectMake(QM_kScreenWidth-110, 100, 110, 40)];
        _dragView.freeRect = CGRectMake(0, 0, QM_kScreenWidth, QM_kScreenHeight-kStatusBarAndNavHeight-kInputViewHeight);
        _dragView.backgroundColor = [UIColor whiteColor];
        [_dragView.button setImage:[UIImage imageNamed:QMChatUIImagePath(@"QM_SwitchBtn_Icon")] forState:UIControlStateNormal];
        [_dragView.button setTitle:@"切换业务" forState:UIControlStateNormal];
        _dragView.hidden = YES;
        [_dragView QM_ClipCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft radius:20 border:1 color:[UIColor colorWithHexString:QMColor_Main_Bg_Light]];
        _dragView.isKeepBounds = YES;
    }
    return _dragView;
}

- (NSArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSArray alloc] init];
    }
    return _dataArray;
}

@end

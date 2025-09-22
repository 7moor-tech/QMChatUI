//
//  QMChatRobotReplyCell.m
//  IMSDK
//
//  Created by 焦林生 on 2021/12/17.
//

#import "QMChatRobotReplyCell.h"
#import "QMHeader.h"
#import "QMTagListView.h"
#import "QMConfigTool.h"
#import "QMChatShowImageViewController.h"
@interface QMChatRobotReplyCell ()<UITextViewDelegate>

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIButton *CopyButton;
@property (nonatomic, strong) UIButton *scanButton;
@property (nonatomic, copy) NSString *wxNumber;
@property (nonatomic, copy) NSString *qr_codeUrl;
@property (nonatomic, strong) UIButton *helpBtn;
@property (nonatomic, strong) UIButton *noHelpBtn;
@property (nonatomic, strong) UILabel *lineLabel;
@property (nonatomic, strong) UILabel *describeLbl;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *fingerUp;
@property (nonatomic, copy) NSString *fingerDown;
@property (nonatomic, strong) UIView *answerBgView;
@property (nonatomic, strong) QMTagListView *tagView;
@property (nonatomic, strong) UIView *segView;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UIView *segViewTwo;
@property (nonatomic, strong) UIButton *commitBtn;
@property (nonatomic, copy) NSString *tagStr;

@end

@implementation QMChatRobotReplyCell

- (void)createUI {
    [super createUI];
    
    self.answerBgView = [UIView new];
    self.answerBgView.QMCornerRadius = 10;
    [self.contentView addSubview:self.answerBgView];
    
    [self.contentLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.chatBackgroundView).offset(2.5).priority(999);
        make.left.equalTo(self.chatBackgroundView).offset(QMFixWidth(8));
        make.right.equalTo(self.chatBackgroundView).offset(-QMFixWidth(8));
        make.height.mas_greaterThanOrEqualTo(QMFixWidth(40)).priorityHigh();
    }];
    
    [self.answerBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentLab.mas_bottom).priority(999);
        make.left.equalTo(self.chatBackgroundView);
        make.right.equalTo(self.chatBackgroundView);
        make.bottom.equalTo(self.chatBackgroundView).priority(999);
    }];
    
    self.backView = [[UIView alloc] init];
    self.backView.hidden = YES;
    [self.contentView addSubview:self.backView];
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.chatBackgroundView);
        make.top.equalTo(self.answerBgView.mas_bottom);
        make.height.mas_equalTo(35);
    }];
    
    self.CopyButton = [[UIButton alloc] init];
    [self.CopyButton setTitleColor:[UIColor colorWithHexString:QMColor_News_Custom] forState:UIControlStateNormal];
    self.CopyButton.backgroundColor = [UIColor whiteColor];
    self.CopyButton.hidden = YES;
    self.CopyButton.QMCornerRadius = 15;
    [self.CopyButton QMBorderWidth:0.7 color:[UIColor colorWithHexString:QMColor_News_Custom]];
    self.CopyButton.titleLabel.font = QMFONT(14);
    [self.CopyButton addTarget:self action:@selector(copyButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.backView addSubview:self.CopyButton];
    [self.CopyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.backView.mas_left);
        make.top.equalTo(self.backView.mas_top).offset(5);
        make.size.mas_equalTo(CGSizeMake(80, 30));
    }];
    
    self.scanButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.scanButton setTitleColor:[UIColor colorWithHexString:QMColor_News_Custom] forState:UIControlStateNormal];
    self.scanButton.hidden = YES;
    self.scanButton.backgroundColor = [UIColor whiteColor];
    self.scanButton.QMCornerRadius = 15;
    [self.scanButton QMBorderWidth:0.7 color:[UIColor colorWithHexString:QMColor_News_Custom]];
    self.scanButton.titleLabel.font = QMFONT(14);
    [self.scanButton addTarget:self action:@selector(scanButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.backView addSubview:self.scanButton];
    [self.scanButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.CopyButton.mas_right).offset(10);
        make.centerY.equalTo(self.CopyButton);
        make.size.mas_equalTo(CGSizeMake(80, 30));
    }];
    
    self.helpBtn = [[UIButton alloc] init];
    [self.helpBtn setBackgroundImage:[UIImage imageNamed:QMChatUIImagePath(@"qm_useful_nor")] forState:UIControlStateNormal];
    [self.helpBtn setBackgroundImage:[UIImage imageNamed:QMChatUIImagePath(@"qm_useful_sel")] forState:UIControlStateSelected];
    [self.helpBtn setTitle:@"有帮助" forState:UIControlStateNormal];
    [self.helpBtn setTitleColor:[UIColor colorWithHexString:QMColor_News_Custom] forState:UIControlStateNormal];
    [self.helpBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    self.helpBtn.titleLabel.font = QMFont_Medium(13);
    [self.helpBtn addTarget:self action:@selector(helpBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.answerBgView addSubview:self.helpBtn];
    [self.helpBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.answerBgView.mas_right).offset(-169);
        make.top.equalTo(self.answerBgView.mas_top);
        make.size.mas_equalTo(CGSizeMake(80, 35));
    }];
    
    self.noHelpBtn = [[UIButton alloc] init];
    [self.noHelpBtn setBackgroundImage:[UIImage imageNamed:QMChatUIImagePath(@"qm_useless_nor")] forState:UIControlStateNormal];
    [self.noHelpBtn setBackgroundImage:[UIImage imageNamed:QMChatUIImagePath(@"qm_useless_sel")] forState:UIControlStateSelected];
    [self.noHelpBtn setTitle:@"无帮助" forState:UIControlStateNormal];
    [self.noHelpBtn setTitleColor:[UIColor colorWithHexString:@"#F8624F"] forState:UIControlStateNormal];
    [self.noHelpBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    self.noHelpBtn.titleLabel.font = QMFont_Medium(13);
    [self.noHelpBtn addTarget:self action:@selector(noHelpBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.answerBgView addSubview:self.noHelpBtn];
    [self.noHelpBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.answerBgView.mas_right).offset(-95);
        make.top.equalTo(self.answerBgView.mas_top);
        make.size.mas_equalTo(CGSizeMake(80, 35));
    }];
    
    self.lineLabel = [[UILabel alloc] init];
    self.lineLabel.backgroundColor = [UIColor colorWithHexString:@"#F5F5F5"];
    [self.answerBgView addSubview:_lineLabel];
    [self.lineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.answerBgView);
        make.top.equalTo(self.helpBtn.mas_bottom).offset(5);
        make.height.mas_equalTo(0.6);
    }];
    
    self.tagView = [[QMTagListView alloc] initWithFrame:CGRectMake(0, self.contentLab.frame.origin.y +48, QMChatTextMaxWidth, 0)];
    /**允许点击 */
    self.tagView.canTouch=YES;
    /**可以控制允许点击的标签数 */
    //    self.tagView.canTouchNum=5;
    self.tagView.signalTagColor=[UIColor whiteColor];
    [self.answerBgView addSubview:self.tagView];
    [self.tagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.answerBgView);
        make.top.equalTo(self.lineLabel.mas_bottom).offset(3);
        make.height.mas_equalTo(100);
    }];
    
    self.segView = [[UIView alloc] init];
    self.segView.backgroundColor = [UIColor colorWithHexString:@"#DCDCDC"];
    [self.answerBgView addSubview:self.segView];
    [self.segView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.answerBgView);
        make.top.equalTo(self.tagView.mas_bottom).offset(5);
        make.height.mas_equalTo(0.8);
    }];
    
    self.textView = [[UITextView alloc] init];
    self.textView.delegate = self;
    self.textView.backgroundColor = [UIColor whiteColor];
    self.textView.font = [UIFont fontWithName:QM_PingFangSC_Reg size:14];
    [self.answerBgView addSubview:self.textView];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(5);
        make.right.mas_equalTo(-5);
        make.top.equalTo(self.segView.mas_bottom).offset(2);
        make.height.mas_equalTo(60);
    }];
    
    self.tipLabel = [[UILabel alloc] init];
    self.tipLabel.textColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_666666_text : QMColor_999999_text];
    self.tipLabel.font = [UIFont fontWithName:QM_PingFangSC_Reg size:14];
    self.tipLabel.numberOfLines = 2;
    [self.answerBgView addSubview:self.tipLabel];
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(5);
        make.right.mas_equalTo(-5);
        make.top.equalTo(self.textView.mas_top).offset(8);
    }];
    
    self.segViewTwo = [[UIView alloc] init];
    self.segViewTwo.backgroundColor = [UIColor colorWithHexString:@"#DCDCDC"];
    [self.answerBgView addSubview:self.segViewTwo];
    [self.segViewTwo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.answerBgView);
        make.top.equalTo(self.textView.mas_bottom);
        make.height.mas_equalTo(0.8);
    }];
    
    self.commitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.commitBtn setTitle:QMUILocalizableString(submit) forState:UIControlStateNormal];
    self.commitBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [self.commitBtn setTitleColor:[UIColor colorWithHexString:QMColor_News_Custom] forState:UIControlStateNormal];
    [self.commitBtn addTarget:self action:@selector(commitAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.answerBgView addSubview:self.commitBtn];
    [self.commitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.segViewTwo.mas_bottom);
        make.centerX.equalTo(self.answerBgView);
        make.size.mas_equalTo(CGSizeMake(QMChatTextMaxWidth, 40));
    }];
    
    self.describeLbl = [[UILabel alloc] init];
    self.describeLbl.font = QMFont_Medium(13);
    self.describeLbl.textColor = [UIColor grayColor];
    self.describeLbl.backgroundColor = [UIColor clearColor];
    self.describeLbl.textAlignment = NSTextAlignmentLeft;
    self.describeLbl.numberOfLines = 0;
    [self.answerBgView addSubview:self.describeLbl];
    [self.describeLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.commitBtn.mas_bottom);
        make.left.equalTo(self.answerBgView).offset(5);
        make.right.equalTo(self.answerBgView).offset(-5);
        make.bottom.equalTo(self.answerBgView).offset(-5).priority(999);
    }];
}

- (void)setData:(CustomMessage *)message avater:(NSString *)avater {
    [super setData:message avater:avater];
    
    if ([message.contactPushed isEqualToString:@"1"]) {
        self.backView.hidden = NO;
        [self.chatBackgroundView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kChatLeftAndRightWidth);
            make.right.equalTo(self.contentView).offset(-kChatLeftAndRightWidth);
            make.top.equalTo(self.timeLabel.mas_bottom).offset(kChatTopMargin).priority(999);
            make.bottom.equalTo(self.contentView).offset(-(kChatBottomMargin+35));
            make.height.mas_greaterThanOrEqualTo(QMChatTextMinHeight);
        }];
        [self setContactButtonStatus];
    } else {
        self.backView.hidden = YES;
        [self.chatBackgroundView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kChatLeftAndRightWidth);
            make.right.equalTo(self.contentView).offset(-kChatLeftAndRightWidth);
            make.top.equalTo(self.timeLabel.mas_bottom).offset(kChatTopMargin).priority(999);
            make.bottom.equalTo(self.contentView).offset(-kChatBottomMargin);
            make.height.mas_greaterThanOrEqualTo(QMChatTextMinHeight);
        }];
    }
    
    self.fingerUp = message.fingerUp.length > 0 ? message.fingerUp : QMUILocalizableString(title.thanks_yes);
    self.fingerDown = message.fingerDown.length > 0 ? message.fingerDown : QMUILocalizableString(title.thanks_no);
    self.tagStr = @"";
    self.textView.text = @"";
    
    if (message.isUseful) {
        [self setupStatus:message.isUseful];
    }
    else {
        [self setupStatus:@"none"];
    }
    
}

- (void)setContactButtonStatus {
    NSDictionary *dict = QMLoginManager.shared.pushContactInfo;
    if (QMLoginManager.shared.enable_copy == 1) {
        self.CopyButton.hidden = NO;
        self.wxNumber = [NSString stringWithFormat:@"%@",dict[@"number"]];
        [self.CopyButton setTitle:dict[@"copy_prompt"] forState:UIControlStateNormal];
       CGFloat textW = [QMLabelText calculateTextWidth:dict[@"copy_prompt"] fontName:QM_PingFangSC_Reg fontSize:14 maxHeight:25];
        if (textW > 70) {
            [self.CopyButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.chatBackgroundView.mas_left);
                make.top.equalTo(self.backView.mas_top).offset(5);
                make.size.mas_equalTo(CGSizeMake(textW+10, 30));
            }];
        }
    }
    if (QMLoginManager.shared.enable_scan == 1) {
        self.scanButton.hidden = NO;
        self.qr_codeUrl = dict[@"qr_code"];
        [self.scanButton setTitle:dict[@"scan_prompt"] forState:UIControlStateNormal];
        CGFloat textW = [QMLabelText calculateTextWidth:dict[@"scan_prompt"] fontName:QM_PingFangSC_Reg fontSize:14 maxHeight:25];
        CGFloat buttonW = 1.0f;
        if (textW > 70) {
            buttonW = textW + 10;
        } else {
            buttonW = 80;
        }
        if (QMLoginManager.shared.enable_copy == 1) {
            [self.scanButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.CopyButton.mas_right).offset(10);
                make.centerY.equalTo(self.CopyButton);
                make.size.mas_equalTo(CGSizeMake(buttonW, 30));
            }];
        } else {
            [self.scanButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.chatBackgroundView.mas_left);
                make.top.equalTo(self.backView.mas_top).offset(5);
                make.size.mas_equalTo(CGSizeMake(buttonW, 30));
            }];
        }
    }
}

- (void)setupStatus:(NSString *)status {
    if ([status isEqualToString:@"useful"] ||
        [status isEqualToString:@"useless"]) {
        self.helpBtn.userInteractionEnabled = NO;
        self.noHelpBtn.userInteractionEnabled = NO;
        [self.lineLabel setHidden:NO];
        [self.describeLbl setHidden:NO];
        
        [self.answerBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentLab.mas_bottom).priority(999);
            make.left.equalTo(self.chatBackgroundView);
            make.right.equalTo(self.chatBackgroundView);
            make.bottom.equalTo(self.chatBackgroundView);
            make.height.mas_equalTo(75).priorityHigh();
        }];
        if ([status isEqualToString:@"useful"]) {
            
            [self.noHelpBtn setSelected:NO];
            [self.helpBtn setSelected:YES];
            self.describeLbl.text = self.fingerUp;
            [self hiddenTagAndTextView];
        }
        else {
            [self.noHelpBtn setSelected:YES];
            [self.helpBtn setSelected:NO];
            self.describeLbl.text = self.fingerDown;
            if ([self.message.isSubmitReason isEqualToString:@"submit"]) {
                [self setTagUI];
            } else {
                [self hiddenTagAndTextView];
            }
        }
    }
    else {
        [self.describeLbl setHidden:YES];
        if (self.message.isShowTag == YES) {
            [self setTagUI];
        }
        else {
            [self.lineLabel setHidden:YES];
            self.helpBtn.userInteractionEnabled = YES;
            self.noHelpBtn.userInteractionEnabled = YES;
            [self.noHelpBtn setSelected:NO];
            [self.helpBtn setSelected:NO];
            [self hiddenTagAndTextView];
            [self.answerBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.contentLab.mas_bottom).priority(999);
                make.left.equalTo(self.chatBackgroundView);
                make.right.equalTo(self.chatBackgroundView);
                make.bottom.equalTo(self.chatBackgroundView);
                make.height.mas_equalTo(50).priorityHigh();
            }];
        }
    }
}

- (void)hiddenTagAndTextView {
    self.segView.hidden = YES;
    self.segViewTwo.hidden = YES;
    self.tagView.hidden = YES;
    self.commitBtn.hidden = YES;
    self.tipLabel.hidden = YES;
    [self.tagView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0.01);
    }];
    [self.textView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0.01);
    }];
    [self.commitBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0.01);
    }];
}

- (void)copyButtonAction:(UIButton *)action {
    
    UIPasteboard *pasteBoard =  [UIPasteboard generalPasteboard];
    pasteBoard.string = self.wxNumber;
    
    [QMRemind showMessage:@"复制成功"];
    
    [QMConnect clickPushContact:self.CopyButton.titleLabel.text contactStatus:@"1"];
}

- (void)scanButtonAction:(UIButton *)action {

    [self tapRecognizerAction];
    
    [QMConnect clickPushContact:self.scanButton.titleLabel.text contactStatus:@"2"];
}

- (void)tapRecognizerAction {
    QMChatShowImageViewController *showPicVC = [[QMChatShowImageViewController alloc] init];
    showPicVC.imageUrl = self.qr_codeUrl;
    showPicVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:showPicVC animated:true completion:nil];
}

- (void)setTagUI {
    self.commitBtn.hidden = NO;
    self.lineLabel.hidden= NO;
    if ([self.message.isSubmitReason isEqualToString:@"submit"]) {
        [self.commitBtn setTitle:@"已提交" forState:UIControlStateNormal];
        CGFloat answerH = 0;
        self.describeLbl.hidden = NO;
        self.tipLabel.hidden = YES;
        self.commitBtn.enabled = NO;
        [self.commitBtn setTitleColor:QM_RGB(159, 199, 242) forState:UIControlStateNormal];
        if (self.message.tagStr.length > 0) {
            self.tagView.hidden = NO;
            self.segView.hidden = NO;
            NSArray *tagArr = [QMConfigTool getTagList];
            self.tagView.canTouch = NO;
            [self.tagView setTagWithTagArray:tagArr selectTag:self.message.tagStr];
            [self.tagView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(self.tagView.tagHeight);
            }];
            answerH = 115+self.tagView.tagHeight;
        }
        
        if (self.message.remark.length > 0) {
            self.textView.hidden = NO;
            self.segViewTwo.hidden = NO;
            self.textView.text = self.message.remark;
            self.textView.editable = NO;
            if (self.message.tagStr.length > 0) {
                self.tagView.hidden = NO;
                answerH = 175+self.tagView.tagHeight;
            }
            else {
                self.tagView.hidden = YES;
                [self.tagView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(1);
                }];
                answerH = 175;
            }
            [self.textView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(60);
            }];
        } else {
            [self.segViewTwo mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(0.01);
            }];
            [self.textView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(1);
            }];
        }
        [self.commitBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(40);
        }];
        [self.answerBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentLab.mas_bottom).priority(999);
            make.left.equalTo(self.chatBackgroundView);
            make.right.equalTo(self.chatBackgroundView);
            make.bottom.equalTo(self.chatBackgroundView).priority(999);
            make.height.mas_equalTo(answerH);
        }];
    }
    else {
        CGFloat answerH = 0;
        self.commitBtn.enabled = YES;
        [self.commitBtn setTitle:QMUILocalizableString(submit) forState:UIControlStateNormal];
        [self.commitBtn setTitleColor:[UIColor colorWithHexString:QMColor_News_Custom] forState:UIControlStateNormal];
        if ([QMConfigTool isOpenTaglist]) {
            self.tagView.hidden = NO;
            self.segView.hidden = NO;
            NSArray *tagArr = [QMConfigTool getTagList];
            /**控制是否是单选模式 */
            if ([QMConfigTool isMultiple]) {
                self.tagView.isSingleSelect = NO;
            } else {
                self.tagView.isSingleSelect = YES;
            }
            self.tagView.canTouch = YES;
            @weakify(self)
            [self.tagView setDidselectItemBlock:^(NSArray *arr) {
                @strongify(self)
                self.tagStr = [arr componentsJoinedByString:@"##"];
            }];
            [self.tagView setTagWithTagArray:tagArr selectTag:@""];
            [self.tagView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(self.tagView.tagHeight);
            }];
            answerH = 100+self.tagView.tagHeight;
        }
        if ([QMConfigTool isOpenTipContent]) {
            self.textView.editable = YES;
            self.textView.hidden = NO;
            self.segViewTwo.hidden = NO;
            self.tipLabel.hidden = NO;
            self.textView.text = @"";
            self.tipLabel.text = [QMConfigTool getRemarks].length > 0 ? [QMConfigTool getRemarks] : @"";
            [self.segViewTwo mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(0.8);
            }];
            if ([QMConfigTool isOpenTaglist]) {
                answerH = 160+self.tagView.tagHeight;
            } else {
                [self.tagView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(1);
                }];
                answerH = 160;
            }
            [self.textView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(60);
            }];
        }
        else {
            [self.segViewTwo mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(0.01);
            }];
            [self.textView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(1);
            }];
        }
        [self.commitBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(40);
        }];
        [self.answerBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentLab.mas_bottom).priority(999);
            make.left.equalTo(self.chatBackgroundView);
            make.right.equalTo(self.chatBackgroundView);
            make.bottom.equalTo(self.chatBackgroundView).priority(999);
            make.height.mas_equalTo(answerH);
        }];
    }
}

#pragma mark 机器人答案反馈点击事件
- (void)helpBtnAction: (UIButton *)sender {
    if (QMLoginManager.shared.KFStatus != QMKFStatusRobot) {
        return;
    }
    self.didBtnAction(YES, @"", @"");
    [self setupStatus:@"useful"];
}

- (void)noHelpBtnAction: (UIButton *)sender {
    if (QMLoginManager.shared.KFStatus != QMKFStatusRobot) {
        return;
    }
    if ([QMConfigTool isOpenTaglist] ||
        [QMConfigTool isOpenTipContent]) {
        self.message.isShowTag = YES;
        [self setupStatus:@"none"];
        if (self.needReloadCell) {
            self.needReloadCell(self.message);
        }
    }
    else {
        self.didBtnAction(NO, @"", @"");
        [self setupStatus:@"useless"];
    }
    
}

- (void)commitAction:(UIButton *)sender {
    self.didBtnAction(NO, self.tagStr, self.textView.text);
}

#pragma mark - textViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.tipLabel.text = @"";
    self.tipLabel.hidden = YES;
    
    CGRect frame = [textView convertRect:textView.frame toView:nil];
    if (self.contentStartEditBlock) {
        self.contentStartEditBlock(frame);
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@""]) {
        self.tipLabel.text = [QMConfigTool getRemarks].length > 0 ? [QMConfigTool getRemarks] : @"";
        self.tipLabel.hidden = NO;
    }
}

@end

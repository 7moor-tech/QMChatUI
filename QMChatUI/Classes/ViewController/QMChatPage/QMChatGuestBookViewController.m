//
//  QMChatGuestBookViewController.m
//  IMSDK
//
//  Created by lishuijiao on 2020/9/29.
//

#import "QMChatGuestBookViewController.h"
#import "QMLeaveMessageCell.h"
#import "QMUploadAttachmentsCell.h"
#import "QMAttachmentsCell.h"
#import "QMHeader.h"
#import <QMLineSDK/QMLineSDK.h>
#import "QMFileManagerController.h"
#import "Masonry.h"

@interface QMChatGuestBookViewController () <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>

@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, strong) UIView *titleView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UITextView *textView;

@property (nonatomic ,strong) UILabel *textLabel;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, copy) NSArray *oldFields;
@property (nonatomic, strong) NSMutableArray *uploadAttachments;

@property (nonatomic, strong) NSMutableDictionary *condition;

@property (nonatomic, copy) NSString *leaveMsgString;

@property (nonatomic, assign) BOOL isSucceed;

@property (nonatomic, strong) UIView *fileView;

@property (nonatomic, strong) UIView *sendView;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *sizeLabel;

@property (nonatomic, strong) UIView *progressView;

@property (nonatomic, strong) UIView *progressCView;


@end

@implementation QMChatGuestBookViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self changeUserInfaceStyle];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChange:) name:UIKeyboardWillChangeFrameNotification object:nil];

    self.title = QMUILocalizableString(title.messageBoard);
    
    [self.navigationController.navigationBar setTranslucent:NO];
    self.view.userInteractionEnabled = true;
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [self.view addGestureRecognizer:tapGesture];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setTitle:QMUILocalizableString(button.back) forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor colorWithHexString:QMColor_News_Custom] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backToRootVC) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = buttonItem;
    self.uploadAttachments = [NSMutableArray array];
    [self createUI];
    [self setData];
    
    [self OpenDarkStyle:self.darkStyle];
}

- (void)dealloc {
    
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
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_Nav_Bg_Dark : QMColor_Nav_Bg_Light];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_ECECEC_BG: QMColor_News_Custom];

    self.view.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_Main_Bg_Dark : QMColor_Main_Bg_Light];
    self.titleView.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_News_Agent_Dark : @"#E4EDF6"];
    self.titleLabel.textColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_D4D4D4_text : QMColor_News_Custom];
    self.textView.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_News_Agent_Dark : QMColor_FFFFFF_text];
    self.textLabel.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_News_Agent_Dark : QMColor_FFFFFF_text];
    self.tableView.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_Main_Bg_Dark : QMColor_F6F6F6_BG];
    [self.tableView reloadData];
}

- (void)createUI {
    
    if (!self.isScheduleLeave) {
        NSString *title = [QMConnect leaveMessageTitle];
        self.headerTitle = title.length > 0 ? title : QMUILocalizableString(title.messageHeader);
    }
    NSString *titleString = self.headerTitle;
    CGFloat titleHeight = [QMLabelText calculateTextHeight:titleString fontName:QM_PingFangSC_Reg fontSize:14 maxWidth:QM_kScreenWidth - 70];
    CGFloat labelHeight = titleHeight > 25 ? titleHeight : 25;
    
    self.headerView = [[UIView alloc] init];
    self.headerView.frame = CGRectMake(0, 64, QM_kScreenWidth, 45+labelHeight+40+100);
    self.headerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.headerView];

    self.titleView = [[UIView alloc] init];
    self.titleView.frame = CGRectMake(15, 15, QM_kScreenWidth - 30, labelHeight + 40);
    self.titleView.layer.masksToBounds = YES;
    self.titleView.layer.cornerRadius = 7;
    [self.headerView addSubview:self.titleView];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.frame = CGRectMake(20.5, 18, CGRectGetWidth(self.titleView.frame) - 41, labelHeight);
    self.titleLabel.text = titleString;
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.font = [UIFont fontWithName:QM_PingFangSC_Reg size:14];
    [self.titleView addSubview:self.titleLabel];
    
    self.textView = [[UITextView alloc] init];
    self.textView.frame = CGRectMake(15, CGRectGetMaxY(self.titleView.frame) + 15, QM_kScreenWidth - 30, 100);
    self.textView.delegate = self;
    self.textView.layer.masksToBounds = YES;
    self.textView.layer.cornerRadius = 8;
    self.textView.font = [UIFont fontWithName:QM_PingFangSC_Reg size:14];
    [self.headerView addSubview:self.textView];
    
    self.textLabel = [[UILabel alloc] init];
    CGFloat textHeight = [QMLabelText calculateTextHeight:self.leaveMsg ?: QMUILocalizableString(title.pleaseLeave) fontName:QM_PingFangSC_Reg fontSize:14 maxWidth:CGRectGetWidth(self.textView.frame) - 10];
    self.textLabel.frame = CGRectMake(10, -1, CGRectGetWidth(self.textView.frame) - 10, textHeight > 90 ? 90 : textHeight+10);
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.textColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_666666_text : QMColor_999999_text];
    self.textLabel.font = [UIFont fontWithName:QM_PingFangSC_Reg size:14];
    self.textLabel.numberOfLines = 0;
    [self.textView addSubview:self.textLabel];

    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, QM_kScreenWidth, 100)];
    bottomView.backgroundColor = [UIColor clearColor];
    
    UIButton *submitBtn = [[UIButton alloc] init];
    submitBtn.frame = CGRectMake(20, 25, QM_kScreenWidth - 40, 50);
    submitBtn.titleLabel.font = QMFont_Medium(18);
    submitBtn.layer.masksToBounds = YES;
    submitBtn.layer.cornerRadius = 5;
    [submitBtn setTitle:QMUILocalizableString(title.leaving) forState:UIControlStateNormal];
    [submitBtn setTitleColor:[UIColor colorWithHexString:QMColor_FFFFFF_text] forState:UIControlStateNormal];
    [submitBtn setBackgroundColor:[UIColor colorWithHexString:QMColor_News_Custom]];
    [submitBtn addTarget:self action:@selector(submitAction:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:submitBtn];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, QM_kScreenWidth, QM_kScreenHeight-64) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.tableFooterView = bottomView;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.tableView registerClass:[QMLeaveMessageCell self] forCellReuseIdentifier:NSStringFromClass(QMLeaveMessageCell.self)];
    [self.tableView registerClass:[QMUploadAttachmentsCell self] forCellReuseIdentifier:NSStringFromClass(QMUploadAttachmentsCell.self)];
    [self.tableView registerClass:[QMAttachmentsCell self] forCellReuseIdentifier:NSStringFromClass(QMAttachmentsCell.self)];
    [self.view addSubview:self.tableView];
    
    [self.fileView addSubview:self.sendView];
    [self.sendView addSubview:self.nameLabel];
    [self.sendView addSubview:self.sizeLabel];
    [self.sendView addSubview:self.progressView];
    
    [self.sendView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.fileView).offset(QM_kScreenHeight/2-50);
        make.left.equalTo(self.fileView).offset(50);
        make.right.equalTo(self.fileView).offset(-50);
        make.height.mas_equalTo(100);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.sendView).offset(10);
        make.left.equalTo(self.sendView).offset(10);
        make.height.mas_equalTo(30);
    }];
    
    [self.sizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.sendView).offset(10);
        make.left.equalTo(self.nameLabel.mas_right).offset(15);
        make.right.equalTo(self.sendView).offset(-10);
        make.height.mas_equalTo(30);
    }];
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.mas_bottom).offset(20);
        make.left.equalTo(self.sendView).offset(10);
        make.right.equalTo(self.sendView).offset(-10);
        make.height.mas_equalTo(10);
    }];
    
    [self.progressView addSubview:self.progressCView];

    
    [self.progressCView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self.progressView);
        make.height.mas_equalTo(10);
        make.width.mas_equalTo(0);
    }];
}

- (void)setData {
    if (!self.isScheduleLeave) {
        self.leaveMsg = [QMConnect leaveMessagePlaceholder];
        self.contactFields = [QMConnect leaveMessageContactInformation].mutableCopy;
        self.isLeavemsgAnnexAble = [QMConnect leavemsgAnnexAble];
    }
    if (self.leaveMsg.length > 0) {
        self.textLabel.text = self.leaveMsg;
    } else {
        self.textLabel.text = QMUILocalizableString(title.pleaseLeave);
    }
    self.oldFields = self.contactFields;

    [self.tableView reloadData];
}

- (void)backToRootVC {
    [QMConnect logout];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)tapAction {
    [self.textView resignFirstResponder];
}

- (NSString *)urlEncoded:(NSString *)urlStr {
    // 对 URL 百分号编码
    CFStringRef encodedString = CFURLCreateStringByAddingPercentEscapes(
        NULL,
        (__bridge CFStringRef)urlStr,
        NULL,
        CFSTR("&?#"),
        kCFStringEncodingUTF8
    );
    NSString *escapedURL = (__bridge_transfer NSString *)encodedString;
     
    return escapedURL;
}

- (void)submitAction:(UIButton *)button {
    if (_isSucceed) {
        [QMRemind showMessage:QMUILocalizableString(title.isBeginLeave)];
        return;
    }
    NSMutableArray *leavemsgAnnexList = [NSMutableArray array];
    if (self.isLeavemsgAnnexAble) {
        for (NSDictionary *dict in self.uploadAttachments) {
            [leavemsgAnnexList addObject:@{@"agentUrl":[self urlEncoded:dict[@"agentUrl"]], @"visitorUrl":[self urlEncoded:dict[@"visitorUrl"]]}];
        }
    }

    if ([self verifyRequired] && self.textView.text.length) {
        _isSucceed = YES;
        NSString *leaveString = [NSString stringWithFormat:@"留言\n%@ : %@\n%@",@"内容",self.textView.text, _leaveMsgString];
        
        __weak QMChatGuestBookViewController *weakSelf = self;
        [QMConnect sdkSubmitLeaveMessageWithInformation:self.peerId information:_condition leavemsgFields:self.oldFields leavemsgAnnexList:[leavemsgAnnexList copy] message:self.textView.text successBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [QMConnect insertLeaveMsg:leaveString leavemsgAnnexList:[weakSelf.uploadAttachments copy]];
                [QMRemind showMessage:QMUILocalizableString(title.messageSuccess)];
                weakSelf.isSucceed = NO;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf backToRootVC];
                });
            });
        } failBlock:^(NSString *reason){
            dispatch_async(dispatch_get_main_queue(), ^{
                [QMRemind showMessage:QMUILocalizableString(title.messageFailure)];
                weakSelf.isSucceed = NO;
            });
        }];
    }

}

- (BOOL)verifyRequired {
    _condition = [NSMutableDictionary dictionary];
    NSString *leaveString = @"";
    if (self.textView.text == nil || self.textView.text.length == 0) {
        [QMRemind showMessage:@"请填写留言内容"];
        return NO;
    }
    for (NSDictionary *dic in self.contactFields) {
        BOOL required = [[dic objectForKey:@"required"] boolValue];
        NSString *name = dic[@"name"];
        NSString *value = dic[@"value"];
        if (value.length) {
            leaveString = [leaveString stringByAppendingFormat:@"%@ : %@\n", name, value];
        }
        if (required) {
            if (value.length) {
                [_condition setValue:value forKey:dic[@"_id"]];
            }else {
                NSString *msg = [name stringByAppendingString:@"为必填项"];
                [QMRemind showMessage:msg];
                return NO;
            }
        }else {
            if (value.length) {
                [_condition setValue:value forKey:dic[@"_id"]];
            }
        }
    }
    _leaveMsgString = leaveString;
    return YES;
}

#pragma mark - Push Notification
// 键盘通知
- (void)keyboardFrameChange: (NSNotification *)notification {
    NSDictionary * userInfo =  notification.userInfo;
    NSValue * value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect newFrame = [value CGRectValue];
    if (ceil(newFrame.origin.y) == [UIScreen mainScreen].bounds.size.height) {
        [UIView animateWithDuration:0.3 animations:^{
            self.tableView.frame = CGRectMake(0, 0, QM_kScreenWidth, QM_kScreenHeight-64);
        }];
    }else {
        [UIView animateWithDuration:0.3 animations:^{
            self.tableView.frame = CGRectMake(0, 0, QM_kScreenWidth, [UIScreen mainScreen].bounds.size.height-64-newFrame.size.height);
        }];
    }
}

#pragma mark - textViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.textLabel.text = @"";
    self.textLabel.hidden = YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@""]) {
        self.textLabel.text = (self.leaveMsg.length>0) ?self.leaveMsg: QMUILocalizableString(title.pleaseLeave);
        self.textLabel.hidden = NO;
    }
}

#pragma mark - tableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.contactFields.count + (self.isLeavemsgAnnexAble ? 1 : 0);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isLeavemsgAnnexAble) {
        if (section + 1 > self.contactFields.count) {
            return self.uploadAttachments.count + 1;
        }
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.isLeavemsgAnnexAble && (indexPath.section + 1 > self.contactFields.count)) {
        if (indexPath.row == 0) {
            QMUploadAttachmentsCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(QMUploadAttachmentsCell.self) forIndexPath:indexPath];
            cell.model = [NSMutableDictionary dictionary];
            @weakify(self)
            cell.clickBack = ^{
                @strongify(self)
                [self uploadAttachmentsAction];
            };
            return cell;
        }
        QMAttachmentsCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(QMAttachmentsCell.self) forIndexPath:indexPath];
        NSMutableDictionary *dic = self.uploadAttachments[indexPath.row-1];
        cell.model = dic;
        @weakify(self)
        cell.closeBack = ^(NSString * _Nonnull idStr) {
            @strongify(self)
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", idStr];
            NSArray *filtered = [self.uploadAttachments filteredArrayUsingPredicate:predicate];
            [self.uploadAttachments removeObjectsInArray:filtered];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
        };
        return cell;
    }else {
        QMLeaveMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(QMLeaveMessageCell.self) forIndexPath:indexPath];
        NSMutableDictionary *dic = self.contactFields[indexPath.section];
        cell.model = dic;
        @weakify(self)
        cell.backValue = ^(NSString * _Nonnull value) {
            @strongify(self)
            [dic setValue:value forKey:@"value"];
            [self.contactFields.mutableCopy replaceObjectAtIndex:indexPath.section withObject:dic];
        };
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_Main_Bg_Dark : QMColor_F6F6F6_BG];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isLeavemsgAnnexAble && (indexPath.section + 1 > self.contactFields.count)) {
        return 70;
    }
    return 55;
}

- (void)uploadAttachmentsAction {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (status) {
                case PHAuthorizationStatusAuthorized: {
                    QMFileManagerController *fileVC = [[QMFileManagerController alloc] init];
                    @weakify(self)
                    fileVC.callBackBlock = ^(NSString *name, NSString *size, NSString *path) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            @strongify(self)
                            [self sendFileMessageWithName:name AndSize:size AndPath:path];
                        });
                    };
                    [self.navigationController pushViewController:fileVC animated:true];
                }
                    break;
                case PHAuthorizationStatusDenied: {
                    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:QMUILocalizableString(title.prompt) message: QMUILocalizableString(title.photoAuthority) preferredStyle: UIAlertControllerStyleAlert];
                    
                    UIAlertAction *action = [UIAlertAction actionWithTitle:QMUILocalizableString(button.set) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        if (UIApplicationOpenSettingsURLString != NULL) {
                            NSURL *URL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                            [[UIApplication sharedApplication] openURL:URL options:@{} completionHandler:nil];
                        }
                    }];
                    
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:QMUILocalizableString(button.cancel) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        
                    }];
                    [alertController addAction:action];
                    [alertController addAction:cancelAction];
                    [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:alertController animated:YES completion:nil];
                }
                    break;
                case PHAuthorizationStatusRestricted:
                    NSLog(@"相册访问受限!");
                    break;
                default:
                    break;
            }
        });
    }];
}

// 发送文件
- (void)sendFileMessageWithName:(NSString *)fileName AndSize:(NSString *)fileSize AndPath:(NSString *)filePath {
    if ([fileSize containsString:@"MB"]) {
        NSInteger num = [[fileSize stringByReplacingOccurrencesOfString:@"MB" withString:@""] integerValue];
        if (num > 200) {
            [QMRemind showMessage:@"上传文件太大，超过200M"];
            return;
        }
    }
    //新增文件上传黑白名单限制
    NSRange range = [fileName rangeOfString:@"." options:NSBackwardsSearch];
    if (range.length > 0) {
        NSString *result = [fileName substringFromIndex:range.location].lowercaseString;
        if ([QMLoginManager.shared.globalUploadBlackList containsString:result]) {
            [QMRemind showMessage:QMUILocalizableString(fileTost1)];
            return;
        }
        if (QMLoginManager.shared.isUploadWhite == YES && ![QMLoginManager.shared.uploadWhiteList containsString:result]) {
            [QMRemind showMessage:QMUILocalizableString(fileTost2)];
            return;
        }
    }
   
    @weakify(self)
    NSDictionary *fileDic = @{
        @"fileName" : fileName,
        @"fileSize" : fileSize,
        @"filePath" : filePath
    };
    
    //  在添加前先移除可能存在的旧视图
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.fileView removeFromSuperview];
    });
    
    [QMConnect sdkSendLeavemsgAnnexFile:fileDic progress:^(float progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self)
            self.nameLabel.text = fileDic[@"fileName"];
            self.sizeLabel.text = fileDic[@"fileSize"];
            if (!self.fileView.superview) {
                [[UIApplication sharedApplication].keyWindow addSubview:self.fileView];
                [self.fileView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo([UIApplication sharedApplication].keyWindow);
                }];
            }
            [self setProgress:progress];
        });
    } success:^(NSArray *array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self)
            if (self.fileView.superview) {
                [self.fileView removeFromSuperview];
            }
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            dict[@"fileName"] = fileName;
            dict[@"fileSize"] = fileSize;
            dict[@"filePath"] = filePath;
            dict[@"agentUrl"] = [NSString stringWithFormat:@"%@?fileName=%@?fileSize=%@",array.firstObject, fileName,fileSize];
            dict[@"visitorUrl"] = array.lastObject;
            NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
            dict[@"id"] = [NSString stringWithFormat:@"%.0f", timestamp];
            [self.uploadAttachments addObject:dict];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:self.contactFields.count] withRowAnimation:UITableViewRowAnimationFade];
        });
    } failBlock:^(NSString *reaseon) {
        @strongify(self)
        NSLog(@"reaseon===%@", reaseon);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.fileView.superview) {
                [self.fileView removeFromSuperview];
            }
        });
    }];
}

- (void)setProgress: (float)progress {
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat pWidth = CGRectGetWidth(self.progressView.frame) * progress;
        [self.progressCView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(pWidth);
        }];
    });
}

- (UIView *)fileView {
    if (!_fileView) {
        _fileView = [[UIView alloc] init];
        _fileView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    }
    return _fileView;
}

- (UIView *)sendView {
    if (!_sendView) {
        _sendView = [[UIView alloc] init];
        _sendView.backgroundColor = UIColor.whiteColor;
    }
    return _sendView;
}

- (UIView *)progressView {
    if (!_progressView) {
        _progressView = [[UIView alloc] init];
        _progressView.backgroundColor = UIColor.clearColor;
        _progressView.layer.borderWidth = 1;
        _progressView.layer.borderColor = [UIColor colorWithHexString:QMColor_News_Custom].CGColor;
    }
    return _progressView;
}

- (UIView *)progressCView {
    if (!_progressCView) {
        _progressCView = [[UIView alloc] init];
        _progressCView.backgroundColor = [UIColor colorWithHexString:QMColor_News_Custom];
    }
    return _progressCView;
}


- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = [UIColor colorWithHexString:QMColor_666666_text];
        _nameLabel.font = [UIFont fontWithName:QM_PingFangSC_Reg size:13];
    }
    return _nameLabel;
}

- (UILabel *)sizeLabel {
    if (!_sizeLabel) {
        _sizeLabel = [[UILabel alloc] init];
        _sizeLabel.textColor = [UIColor colorWithHexString:QMColor_666666_text];
        _sizeLabel.font = [UIFont fontWithName:QM_PingFangSC_Reg size:13];
        [_sizeLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _sizeLabel;
}

@end


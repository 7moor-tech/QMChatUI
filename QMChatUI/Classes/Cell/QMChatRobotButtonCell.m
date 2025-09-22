//
//  QMChatRobotButtonCell.m
//  IMSDK
//
//  Created by 焦林生 on 2023/3/17.
//

#import "QMChatRobotButtonCell.h"
#import "QMHeader.h"
#import "QMChatShowImageViewController.h"

@interface QMChatRobotButtonCell ()

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIButton *CopyButton;
@property (nonatomic, strong) UIButton *scanButton;
@property (nonatomic, copy) NSString *wxNumber;
@property (nonatomic, copy) NSString *qr_codeUrl;

@end

@implementation QMChatRobotButtonCell

- (void)createUI {
    [super createUI];

    self.backView = [UIView new];
    [self.contentView addSubview:self.backView];
    
    self.contentLab.backgroundColor = [UIColor whiteColor];
    [self.contentLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.chatBackgroundView).priority(999);
        make.left.equalTo(self.chatBackgroundView);
        make.right.equalTo(self.chatBackgroundView);
        make.height.mas_greaterThanOrEqualTo(40).priorityHigh();
    }];
    
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentLab.mas_bottom).priority(999);
        make.left.equalTo(self.chatBackgroundView);
        make.right.equalTo(self.chatBackgroundView);
        make.height.mas_equalTo(35);
        make.bottom.equalTo(self.chatBackgroundView).priority(999);
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
        make.left.mas_equalTo(self.contentLab.mas_left);
        make.top.equalTo(self.contentLab.mas_bottom).offset(5);
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
}

- (void)setData:(CustomMessage *)message avater:(NSString *)avater {
    [super setData:message avater:avater];
    
    self.chatBackgroundView.backgroundColor = [UIColor clearColor];
    
    NSDictionary *dict = QMLoginManager.shared.pushContactInfo;
    if (QMLoginManager.shared.enable_copy == 1) {
        self.CopyButton.hidden = NO;
        self.wxNumber = [NSString stringWithFormat:@"%@",dict[@"number"]];
        [self.CopyButton setTitle:dict[@"copy_prompt"] forState:UIControlStateNormal];
       CGFloat textW = [QMLabelText calculateTextWidth:dict[@"copy_prompt"] fontName:QM_PingFangSC_Reg fontSize:14 maxHeight:25];
        if (textW > 70) {
            [self.CopyButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.chatBackgroundView.mas_left);
                make.top.equalTo(self.contentLab.mas_bottom).offset(5);
                make.size.mas_equalTo(CGSizeMake(textW+10, 30));
            }];
        }
    }
    if (QMLoginManager.shared.enable_scan == 1) {
        self.scanButton.hidden = NO;
        self.qr_codeUrl = dict[@"qr_code"];
        [self.scanButton setTitle:dict[@"scan_prompt"] forState:UIControlStateNormal];
        CGFloat textW = [QMLabelText calculateTextWidth:dict[@"scan_prompt"] fontName:QM_PingFangSC_Reg fontSize:14 maxHeight:25];
         if (textW > 70) {
             [self.scanButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                 make.left.mas_equalTo(self.CopyButton.mas_right).offset(10);
                 make.centerY.equalTo(self.CopyButton);
                 make.size.mas_equalTo(CGSizeMake(textW+10, 30));
             }];
         }
    }
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

@end

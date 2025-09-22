//
//  QMChatFormCell.m
//  IMSDK
//
//  Created by lishuijiao on 2021/1/8.
//

#import "QMChatFormCell.h"
#import "QMChatFormView.h"
#import "QMHeader.h"
@interface QMChatFormCell ()
@property (nonatomic, strong) UIView *aiShowView;
@property (nonatomic, strong) UILabel *aiLabel;

@end

@implementation QMChatFormCell {
    UILabel *_promptLabel;
    
    UIButton *_nameButton;
    
    QMChatFormView *_formView;
    
    NSArray *_formInfoArr;
    
    NSDictionary *_dataDic;
    
    NSString *_title;
    
    NSString *_note;
}

- (void)createUI {
    [super createUI];
    
    _promptLabel = [[UILabel alloc] init];
    _promptLabel.font = [UIFont fontWithName:QM_PingFangSC_Reg size:16];
    _promptLabel.numberOfLines = 0;
    [self.chatBackgroundView addSubview:_promptLabel];
    
    _nameButton = [[UIButton alloc] init];
    _nameButton.titleLabel.font = [UIFont fontWithName:QM_PingFangSC_Reg size:15];
    [_nameButton setTitleColor:[UIColor colorWithHexString:isDarkStyle ? QMColor_ECECEC_BG : QMColor_News_Custom] forState:UIControlStateNormal];
    [_nameButton addTarget:self action:@selector(nameAction) forControlEvents:UIControlEventTouchUpInside];
    [self.chatBackgroundView addSubview:_nameButton];
}

- (void)setData:(CustomMessage *)message avater:(NSString *)avater {
    self.message = message;
    [super setData:message avater:avater];
    
    _promptLabel.textColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_D5D5D5_text : QMColor_151515_text];
    
    if ([message.fromType isEqualToString:@"1"]) {
        NSData *jsonData = [message.xbotForm dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
        if(err) {
            return;
        }
        
        _formInfoArr = [[NSArray alloc] init];
        if (dic.count) {
            _dataDic = dic;
            NSString *formPrompt = dic[@"formPrompt"];
            NSString *formName = dic[@"formName"];
            NSString *formNotes = dic[@"formNotes"];
            _title = formName;
            _note = formNotes;
            _formInfoArr = dic[@"formInfo"];
            CGSize promptSize = [QMLabelText calculateText:formPrompt fontName:QM_PingFangSC_Reg fontSize:16 maxWidth:QM_kScreenWidth - 58*2 - 30 maxHeight:2000];
            CGSize nameSize = [QMLabelText calculateText:formName fontName:QM_PingFangSC_Reg fontSize:16 maxWidth:QM_kScreenWidth - 58*2 - 30 maxHeight:2000];
            
            _promptLabel.text = formPrompt;
            [_nameButton setTitle:formName forState:UIControlStateNormal];
            if ([message.xbotFirst isEqualToString:@"2"]) {
                _promptLabel.frame = CGRectMake(15, 15, promptSize.width, promptSize.height);
                _nameButton.frame = CGRectZero;
//                self.chatBackgroundView.frame = CGRectMake(58, CGRectGetMaxY(self.timeLabel.frame) + 25, promptSize.width + 30 , promptSize.height + 30);
                [self.chatBackgroundView mas_updateConstraints:^(MASConstraintMaker *make) {
                    
                    make.width.mas_equalTo(promptSize.width + 30);
                    make.height.mas_equalTo(promptSize.height + 30);
                }];
            }else {
                _promptLabel.frame = CGRectMake(15, 15, promptSize.width, promptSize.height);
                _nameButton.frame = CGRectMake(15, 15+promptSize.height+20, nameSize.width, nameSize.height);
//                self.chatBackgroundView.frame = CGRectMake(58, CGRectGetMaxY(self.timeLabel.frame) + 25, (promptSize.width - nameSize.width) > 0 ? promptSize.width + 30 : nameSize.width + 30, promptSize.height + 20 + nameSize.height + 30);
                [self.chatBackgroundView mas_updateConstraints:^(MASConstraintMaker *make) {
                    
                    make.width.mas_equalTo((promptSize.width - nameSize.width) > 0 ? promptSize.width + 30 : nameSize.width + 30);
                    make.height.mas_equalTo(promptSize.height + 20 + nameSize.height + 30);
                }];
            }
            
            if ([message.xbotFirst isEqualToString:@"1"]) {
                if (self.didBtnAction) {
                    self.didBtnAction(YES, @"", @"");
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self nameAction];
                    [QMConnect sdkUpdateFormStatus:@"0" withMessageID:message._id];
                    [[NSNotificationCenter defaultCenter] postNotificationName:CHATMSG_RELOAD object:nil];
                    
                });
            }
        }
        
        if(self.message.agentTipsSwitch == YES){
            [self.chatBackgroundView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.contentView.mas_bottom).offset(-50).priority(999);
            }];
            
            [self.contentView addSubview:self.aiShowView];
            
            [self.aiShowView mas_remakeConstraints:^(MASConstraintMaker *make) {
                
                make.top.equalTo(self.chatBackgroundView.mas_bottom).offset(-4);
                make.left.equalTo(self.chatBackgroundView).offset(0);
                make.width.equalTo(self.chatBackgroundView);
                make.height.mas_equalTo(40);
                
            }];
            [self.aiLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                
                make.top.mas_equalTo(14);
                make.left.equalTo(self.aiShowView).offset(40);
                make.right.equalTo(self.aiShowView).offset(5);
                make.height.mas_equalTo(15);
                
            }];
            self.aiLabel.text = self.message.agentTipsContent;
        }else{
            [self.aiShowView removeFromSuperview];
        }
        
    }
}

- (UIView *)aiShowView{
    if (!_aiShowView){
        _aiShowView = [[UIView alloc]init];
        _aiShowView.backgroundColor = [UIColor colorWithHexString:@"#FAFAFA"];
        _aiShowView.QMCornerRadius = 8;
        _aiShowView.layer.maskedCorners = kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
        UIImageView* aiImage = [[UIImageView alloc] init];
        aiImage.backgroundColor = [UIColor clearColor];
        aiImage.contentMode = UIViewContentModeScaleAspectFill;
        aiImage.image = [UIImage imageNamed:QMChatUIImagePath(@"AI@2x")];
        aiImage.frame = CGRectMake(15, 14, 15, 15);
        [_aiShowView addSubview:aiImage];
        
        _aiLabel = [[UILabel alloc]init];
        _aiLabel.text = @"此消息由ai自动生成";
        _aiLabel.font = [UIFont systemFontOfSize:15];
        _aiLabel.textColor = [UIColor colorWithHexString:@"#9E9E9E"];
        _aiLabel.textAlignment = NSTextAlignmentLeft;
//        _aiLabel.numberOfLines = 0;
        [_aiShowView addSubview:_aiLabel];
        
    }
    
    return _aiShowView;
    
}


- (void)nameAction {
    
    if (_formView) {
        [_formView removeFromSuperview];
    }
//    eg1
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    _formView = [[QMChatFormView alloc] init];
    _formView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    UIViewController *vc = [self getCurrentVC];
    [vc.view addSubview:_formView];
    [_formView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(vc.view);
    }];
//    for (UIView* next = [self superview]; next; next = next.superview) {
//        UIResponder* nextResponder = [next nextResponder];
//        if ([nextResponder isKindOfClass:[QMChatRoomViewController class]]) {
//            QMChatRoomViewController *roomVC = (QMChatRoomViewController *)nextResponder;
//            [roomVC.view addSubview:_formView];
//            [_formView mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.edges.equalTo(roomVC.view);
//            }];
//        }
//    }
    @weakify(self)
    _formView.formViewBlock = ^(NSDictionary * _Nonnull dict) {
        @strongify(self)
        [QMConnect sdkUpdateFormStatus:@"2" withMessageID:self.message._id];
            
        [QMConnect sdkSubmitFormMessage:dict];
    };
    _formView.dataDic = _dataDic;
    _formView.title = _title;
    _formView.note = _note;
    _formView.messageId = self.message._id;
    [_formView setFormInfoArr:_formInfoArr];

}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

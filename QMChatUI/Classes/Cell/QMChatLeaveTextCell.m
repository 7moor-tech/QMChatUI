//
//  QMChatLeaveTextCell.m
//  IMSDK
//
//  Created by wt on 2025/8/28.
//

#import "QMChatLeaveTextCell.h"
#import "MLEmojiLabel.h"
#import "QMHeader.h"
#import <Masonry/Masonry.h>
#import <QMLineSDK/QMLineSDK.h>

@interface QMChatLeaveTextCell() <MLEmojiLabelDelegate>

@end

@implementation QMChatLeaveTextCell{
    
    MLEmojiLabel *_textLabel;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self createUI];
    }
    return self;
}

- (void)createUI {
    _textLabel = [MLEmojiLabel new];
    _textLabel.numberOfLines = 0;
    _textLabel.font = [UIFont fontWithName:QM_PingFangSC_Reg size:16];
    _textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _textLabel.delegate = self;
    _textLabel.disableEmoji = NO;
    _textLabel.disableThreeCommon = YES;
    _textLabel.isNeedAtAndPoundSign = YES;
    _textLabel.customEmojiRegex = @"\\:[^\\:]+\\:";
    _textLabel.customEmojiPlistName = @"expressionImage.plist";
    _textLabel.customEmojiBundleName = @"QMEmoticon.bundle";
    [self.contentView addSubview:_textLabel];
    
    [_textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(5);
        make.bottom.equalTo(self.contentView).offset(-5);
        make.left.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-6);
        make.width.mas_greaterThanOrEqualTo(20);
        make.height.mas_greaterThanOrEqualTo(40);
    }];
}

- (void)setData:(CustomMessage *)message {
    if ([message.fromType isEqualToString:@"0"]) {
        _textLabel.textColor = [UIColor colorWithHexString:QMColor_FFFFFF_text];
    }
    else {
        _textLabel.textColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_D4D4D4_text : QMColor_151515_text];
    }
    _textLabel.text = message.message;
    
}

- (void)mlEmojiLabel:(MLEmojiLabel *)emojiLabel didSelectLink:(NSString *)link withType:(MLEmojiLabelLinkType)type {
    if (type == MLEmojiLabelLinkTypePhoneNumber) {
        if (link && self.tapNumberAction) {
            self.tapNumberAction(link);
        }
    }else {
        if (link && self.tapNetAddress) {
            self.tapNetAddress(link);
        }
    }
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

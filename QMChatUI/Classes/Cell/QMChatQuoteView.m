//
//  QMChatQuoteView.m
//  IMSDK
//
//  Created by ZCZ on 2023/7/28.
//

#import "QMChatQuoteView.h"
#import "MLEmojiLabel.h"
#import "QMHeader.h"
#import <Masonry/Masonry.h>
@interface QMChatQuoteView ()

@property (nonatomic, strong) UIView *backView;

@property (nonatomic, strong) UILabel *headerLab;
@property (nonatomic, strong) MLEmojiLabel *contentLab;


@end

@implementation QMChatQuoteView

- (instancetype)init {
    if (self = [super init]) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.backView = [UIView new];
    [self addSubview:self.backView];
    self.layer.cornerRadius = 4;
    self.clipsToBounds = YES;
    [self.backView addSubview:self.headerLab];
    [self.backView addSubview:self.contentLab];
    
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(4);
        make.top.right.bottom.equalTo(self);
    }];
    
    [self.headerLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(4);
        make.left.equalTo(self.backView).offset(6);
        make.right.equalTo(self.backView).offset(-6);
        make.height.mas_equalTo([UIFont boldSystemFontOfSize:14].lineHeight);
    }];

    [self.contentLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.headerLab);
        make.top.equalTo(self.headerLab.mas_bottom).offset(4);
        make.bottom.equalTo(self.backView).offset(-4);
    }];
    
}

- (void)setBackColor:(BOOL)isLeft {
    if (isLeft) {
        self.backgroundColor = [UIColor colorWithHexString:QMColor_D4D4D4_text];
        self.backView.backgroundColor = [UIColor colorWithHexString:QMColor_ECECEC_BG];
    } else {
        self.backgroundColor = [UIColor colorWithHexString:@"#BCD0FC"];
        self.backView.backgroundColor = [UIColor colorWithHexString:@"#C5D8FF"];
    }
}

- (void)setData:(NSString *)content {
    if (content.length == 0) {
        self.headerLab.text = @"";
    } else {
        self.headerLab.text = @"回复:";
    }
    self.contentLab.text = [content stringByRemovingPercentEncoding];
}

- (UILabel *)headerLab {
    if (!_headerLab) {
        _headerLab = [UILabel new];
        _headerLab.text = @"回复:";
        _headerLab.font = [UIFont boldSystemFontOfSize:14];
    }
    return _headerLab;
}

- (MLEmojiLabel *)contentLab {
    if (!_contentLab) {
        _contentLab = [MLEmojiLabel new];
        _contentLab.numberOfLines = 0;
        _contentLab.font = [UIFont fontWithName:QM_PingFangSC_Reg size:14];
        _contentLab.lineBreakMode = NSLineBreakByTruncatingTail;
//        _contentLab.delegate = self;
        _contentLab.disableEmoji = NO;
        _contentLab.disableThreeCommon = NO;
        _contentLab.isNeedAtAndPoundSign = YES;
        _contentLab.customEmojiRegex = @"\\:[^\\:]+\\:";
        _contentLab.customEmojiPlistName = @"expressionImage.plist";
        _contentLab.customEmojiBundleName = @"QMEmoticon.bundle";
    }
    return _contentLab;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

//
//  QMAlertTipView.m
//  IMSDK
//
//  Created by 焦林生 on 2022/5/17.
//

#import "QMAlertTipView.h"
#import "QMHeader.h"
#import "Masonry.h"

@interface QMAlertTipView ()

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *configButton;
@property (nonatomic, strong) UILabel *titleLabel;

@end
@implementation QMAlertTipView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
    self.backgroundColor = [UIColor colorWithHexString:QMColor_000000_text alpha:0.4];
    
    UIView *backView = [[UIView alloc] init];
    self.backView = backView;
    backView.backgroundColor = [UIColor whiteColor];
    backView.QMCornerRadius = 10;
    [self addSubview:backView];
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(QM_kScreenWidth-QMFixWidth(64), 160));
    }];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = QMFont_Medium(15);
    self.titleLabel.textColor = [UIColor colorWithHexString:QMColor_151515_text];
    self.titleLabel.numberOfLines = 0;
    [backView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(25);
        make.centerX.equalTo(self);
        make.left.mas_equalTo(QMFixWidth(30));
        make.right.mas_equalTo(-QMFixWidth(30));
    }];
    
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor colorWithHexString:QMColor_666666_text] forState:UIControlStateNormal];
    self.cancelButton.QMCornerRadius = 5;
    self.cancelButton.layer.borderColor = [UIColor colorWithHexString:@"#E4E4E4"].CGColor;
    self.cancelButton.layer.borderWidth = 0.5;
    [self.cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:self.cancelButton];
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(QMFixWidth(37));
        make.bottom.mas_equalTo(-25);
        make.size.mas_equalTo(CGSizeMake(QMFixWidth(110), 40));
    }];
    
    self.configButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.configButton setTitle:@"确定" forState:UIControlStateNormal];
    self.configButton.backgroundColor = [UIColor colorWithHexString:QMColor_News_Custom];
    [self.configButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.configButton.QMCornerRadius = 5;
    [self.configButton addTarget:self action:@selector(sureButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:self.configButton];
    [self.configButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-QMFixWidth(37));
        make.centerY.equalTo(self.cancelButton);
        make.size.mas_equalTo(CGSizeMake(QMFixWidth(110), 40));
    }];
}

- (void)setTipString:(NSString *)tipString {
    self.titleLabel.text = tipString;
    CGFloat textHeight = [QMLabelText calculateTextHeight:tipString fontName:QM_PingFangSC_Med fontSize:15 maxWidth:QM_kScreenWidth-120];
    if (textHeight > 70) {
        [self.backView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(105+textHeight);
        }];
    }
}

- (void)setCloseChat:(NSString *)closeChat {
    [self.configButton setTitle:closeChat forState:UIControlStateNormal];
    self.configButton.titleLabel.font = [UIFont systemFontOfSize:15];
    self.cancelButton.hidden = YES;
    [self.configButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.backView);
        make.bottom.mas_equalTo(-25);
        make.size.mas_equalTo(CGSizeMake(QMFixWidth(110), 40));
    }];
}

- (void)cancelButtonAction:(UIButton *)action {
    [self removeFromSuperview];
}

- (void)sureButtonAction:(UIButton *)action {
    if (self.confirmBlock) {
        self.confirmBlock(YES);
    }
    [self removeFromSuperview];
}

@end

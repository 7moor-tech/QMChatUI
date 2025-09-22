//
//  QMWXCardCell.m
//  IMSDK
//
//  Created by 焦林生 on 2022/12/12.
//

#import "QMWXCardCell.h"
#import "QMHeader.h"
@interface QMWXCardCell ()

@property (nonatomic, strong) UILabel *CardTitleLab;
@property (nonatomic, strong) UIImageView *CardImage;

@end

@implementation QMWXCardCell

- (void)createUI {
    
    [super createUI];
    self.chatBackgroundView.backgroundColor = [UIColor clearColor];
    
    UIView *backView = [[UIView alloc] init];
    backView.backgroundColor = isDarkStyle ? [UIColor blackColor]: [UIColor whiteColor];
    [self.chatBackgroundView addSubview:backView];
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.chatBackgroundView);
        make.left.equalTo(self.chatBackgroundView).offset(8);
        make.right.equalTo(self.chatBackgroundView).offset(-8);
        make.bottom.equalTo(self.chatBackgroundView.mas_bottom).offset(-8);
        make.width.mas_equalTo(220);
        make.height.mas_greaterThanOrEqualTo(220).priorityHigh();
    }];
    
    self.CardTitleLab = [[UILabel alloc] init];
    self.CardTitleLab.font = [UIFont fontWithName:QM_PingFangSC_Reg size:14];
    self.CardTitleLab.numberOfLines = 0;
    [backView addSubview:self.CardTitleLab];
    [self.CardTitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(backView).offset(10);
        make.right.equalTo(backView).offset(-10);
        make.top.equalTo(backView).offset(10);
    }];
    
    self.CardImage = [[UIImageView alloc] init];
    [backView addSubview:self.CardImage];
    [self.CardImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.top.equalTo(self.CardTitleLab.mas_bottom).offset(8);
        make.height.mas_equalTo(180);
    }];
    
    UIView *segView = [[UIView alloc] init];
    segView.backgroundColor = isDarkStyle ? [UIColor whiteColor] : [UIColor colorWithHexString:QMColor_999999_text];
    [backView addSubview:segView];
    [segView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.top.equalTo(self.CardImage.mas_bottom).offset(10);
        make.height.mas_equalTo(0.8);
    }];
    
    UIImageView *wxImage = [[UIImageView alloc] init];
    wxImage.image = [UIImage imageNamed:QMChatUIImagePath(@"chat_wxCard")];
    [backView addSubview:wxImage];
    [wxImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.top.equalTo(segView.mas_bottom).offset(15);
        make.size.mas_equalTo(CGSizeMake(10, 10));
    }];
    
    UILabel *wxTitle = [[UILabel alloc] init];
    wxTitle.text = @"微信小程序";
    wxTitle.font = [UIFont fontWithName:QM_PingFangSC_Reg size:14];
    wxTitle.textColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_FFFFFF_text : QMColor_666666_text];
    [backView addSubview:wxTitle];
    [wxTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wxImage.mas_right).offset(2);
        make.centerY.equalTo(wxImage);
        make.bottom.equalTo(backView.mas_bottom);
    }];
}

- (void)setData:(CustomMessage *)message avater:(NSString *)avater {
    [super setData:message avater:avater];
    
    self.CardTitleLab.textColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_FFFFFF_text : QMColor_666666_text];
    self.CardTitleLab.text = @"jfksdjfsdjl";
    [self.CardImage sd_setImageWithURL:[NSURL URLWithString:message.cardImage] placeholderImage:[UIImage imageNamed:QMChatUIImagePath(@"chat_image_placeholder")]];
}

@end

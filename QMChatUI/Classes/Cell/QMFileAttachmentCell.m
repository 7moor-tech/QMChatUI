//
//  QMFileAttachmentCell.m
//  IMSDK
//
//  Created by wt on 2025/8/28.
//

#import "QMFileAttachmentCell.h"
#import "QMHeader.h"
#import <Masonry/Masonry.h>
#import <QMLineSDK/QMLineSDK.h>

@interface QMFileAttachmentCell()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation QMFileAttachmentCell

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
    self.containerView = [[UIView alloc] init];
    self.containerView.layer.cornerRadius = 6;
    self.containerView.layer.borderColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_D5D5D5_text : @"#E8E8E8"].CGColor;
    self.containerView.layer.borderWidth = 1;
    [self.containerView setUserInteractionEnabled:true];

    self.iconImageView = [[UIImageView alloc] init];
    
    self.nameLabel = [[UILabel alloc] init];
    [self.nameLabel setFont: [UIFont fontWithName:QM_PingFangSC_Reg size:14]];
    [self.nameLabel setTextColor: [UIColor colorWithHexString:isDarkStyle ? QMColor_D4D4D4_text : QMColor_FFFFFF_text]];
    self.nameLabel.numberOfLines = 1;
    
    [self.contentView addSubview: self.containerView];
    [self.containerView addSubview: self.iconImageView];
    [self.containerView addSubview:self.nameLabel];
    
    [self.containerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(4);
        make.left.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-6);
        make.bottom.equalTo(self.contentView).offset(-4);
        make.height.mas_equalTo(44);
    }];
    [self.iconImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.containerView).offset(10);
        make.centerY.equalTo(self.containerView);
        make.size.mas_equalTo(CGSizeMake(24, 24));
    }];
    [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImageView.mas_right).offset(8);
        make.right.equalTo(self.containerView).offset(-10);
        make.top.bottom.right.equalTo(self.containerView);
    }];
}

- (void)setData:(NSDictionary *)fileDict {
    NSString *fileName = fileDict[@"fileName"];
    [self.nameLabel setText:fileName];
    self.iconImageView.image = [UIImage imageNamed:[self matchImageWithFileNameExtension:fileName.pathExtension.lowercaseString]];
}

- (NSString *)matchImageWithFileNameExtension:(NSString *)fileName {
    NSString * str;
    if ([fileName isEqualToString:@"doc"]||[fileName isEqualToString:@"docx"]) {
        str = @"doc";
    }else if ([fileName isEqualToString:@"xlsx"]||[fileName isEqualToString:@"xls"]) {
        str = @"xls";
    }else if ([fileName isEqualToString:@"ppt"]||[fileName isEqualToString:@"pptx"]) {
        str = @"pptx";
    }else if ([fileName isEqualToString:@"pdf"]) {
        str = @"pdf";
    }else if ([fileName isEqualToString:@"mp3"]) {
        str = @"mp3";
    }else if ([fileName isEqualToString:@"mov"]||[fileName isEqualToString:@"mp4"]) {
        str = @"mov";
    }else if ([fileName isEqualToString:@"png"]||[fileName isEqualToString:@"jpg"]||[fileName isEqualToString:@"bmp"]||[fileName isEqualToString:@"jpeg"]) {
        str = @"png";
    }else {
        str = @"other";
    }
    NSString *iconName = [NSString stringWithFormat:@"qm_file_%@", str];
    return QMChatUIImagePath(iconName);
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

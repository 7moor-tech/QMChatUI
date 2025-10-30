//
//  QMAttachmentsCell.m
//  IMSDK
//
//  Created by wt on 2025/6/27.
//

#import "QMAttachmentsCell.h"
#import "QMHeader.h"

@implementation QMAttachmentsCell{
    UIView *_backView;
    UIImageView *_fileImageView;
    UILabel *_textLabel;
    UIButton *_closeBtn;
    NSString *_id;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_Main_Bg_Dark : QMColor_F6F6F6_BG];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self createUI];
    }
    return self;
}

- (void)createUI {
    _backView = [[UIView alloc] init];
    _backView.frame = CGRectMake(15, 0, QM_kScreenWidth - 30, 55);
    _backView.backgroundColor = [UIColor colorWithHexString:QMColor_FFFFFF_text];
    _backView.layer.masksToBounds = YES;
    _backView.layer.cornerRadius = 10;
    _backView.layer.borderColor = [UIColor colorWithHexString:QMColor_FFFFFF_text].CGColor;
    _backView.layer.borderWidth = 1;
    [_backView setUserInteractionEnabled:YES];
    [self.contentView addSubview:_backView];
    
    _fileImageView = [[UIImageView alloc] init];
    _fileImageView.frame = CGRectMake(12, 10, 35, 35);
    _fileImageView.backgroundColor = [UIColor whiteColor];
    [_backView addSubview:_fileImageView];
    
    _textLabel = [[UILabel alloc] init];
    [_textLabel setFont:[UIFont systemFontOfSize:14]];
    _textLabel.frame = CGRectMake(52, 10, QM_kScreenWidth-119-5, 35);
    _textLabel.textColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_666666_text : QMColor_151515_text];
    [_backView addSubview:_textLabel];
    
    _closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(QM_kScreenWidth-30-28, 18, 19, 19)];
    [_closeBtn setImage:[UIImage imageNamed:QMChatUIImagePath(@"closeTip")] forState:UIControlStateNormal];
    [_closeBtn addTarget:self action:@selector(closeEvent:) forControlEvents:UIControlEventTouchUpInside];
    [_backView addSubview:_closeBtn];
}

- (void)setModel:(NSDictionary *)model {
    _id = model[@"id"];
    NSString *fileName = model[@"fileName"];
    
    if ([fileName.pathExtension.lowercaseString isEqualToString:@"doc"]||[fileName.pathExtension.lowercaseString isEqualToString:@"docx"]) {
        _fileImageView.image = [UIImage imageNamed:QMChatUIImagePath(@"qm_file_doc")];
    }else if ([fileName.pathExtension.lowercaseString isEqualToString:@"xlsx"]||[fileName.pathExtension.lowercaseString isEqualToString:@"xls"]) {
        _fileImageView.image = [UIImage imageNamed:QMChatUIImagePath(@"qm_file_xls")];
    }else if ([fileName.pathExtension.lowercaseString isEqualToString:@"ppt"]||[fileName.pathExtension.lowercaseString isEqualToString:@"pptx"]) {
        _fileImageView.image = [UIImage imageNamed:QMChatUIImagePath(@"qm_file_pptx")];
    }else if ([fileName.pathExtension.lowercaseString isEqualToString:@"pdf"]) {
        _fileImageView.image = [UIImage imageNamed:QMChatUIImagePath(@"qm_file_pdf")];
    }else if ([fileName.pathExtension.lowercaseString isEqualToString:@"mp3"]) {
        _fileImageView.image = [UIImage imageNamed:QMChatUIImagePath(@"qm_file_mp3")];
    }else if ([fileName.pathExtension.lowercaseString isEqualToString:@"mov"]||[fileName.pathExtension.lowercaseString isEqualToString:@"mp4"]) {
        _fileImageView.image = [UIImage imageNamed:QMChatUIImagePath(@"qm_file_mov")];
    }else if ([fileName.pathExtension.lowercaseString isEqualToString:@"png"]||[fileName.pathExtension.lowercaseString isEqualToString:@"jpg"]||[fileName.pathExtension.lowercaseString isEqualToString:@"bmp"]||[fileName.pathExtension.lowercaseString isEqualToString:@"jpeg"]) {
//        _fileImageView.image = [UIImage imageNamed:QMChatUIImagePath(@"qm_file_png")];
        NSString * filePath = [NSString stringWithFormat:@"%@/%@/%@",NSHomeDirectory(),@"Documents",fileName];
        _fileImageView.image = [UIImage imageWithContentsOfFile:filePath];
    }else {
        _fileImageView.image = [UIImage imageNamed:QMChatUIImagePath(@"qm_file_other")];
    }
    
    _textLabel.text = fileName;
    
    self.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_Main_Bg_Dark : QMColor_F6F6F6_BG];
    _backView.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_News_Agent_Dark : QMColor_FFFFFF_text];
    _textLabel.textColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_666666_text : QMColor_151515_text];
}

- (void)closeEvent:(UIButton *)button {
    if (self.closeBack) {
        self.closeBack(_id);
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

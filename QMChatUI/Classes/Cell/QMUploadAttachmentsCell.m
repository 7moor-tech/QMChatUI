//
//  QMUploadAttachmentsCell.m
//  IMSDK
//
//  Created by wt on 2025/6/27.
//

#import "QMUploadAttachmentsCell.h"
#import "QMHeader.h"

@implementation QMUploadAttachmentsCell {
    UIImageView *_fileImageView;
    UITextField *_textField;
    UIView *_backView;
    UIButton *_clickBtn;
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
    _backView.layer.borderColor = [UIColor colorWithHexString:QMColor_D5D5D5_text].CGColor;
    [self.contentView addSubview:_backView];
    
    _clickBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _clickBtn.frame = CGRectMake(0, 0, QM_kScreenWidth - 30, 55);
    [_clickBtn setImage:[UIImage imageNamed:QMUIComponentImagePath(@"QMGuestBookForm_upload")] forState:UIControlStateNormal];
    NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:@"上传附件（单个附件不超过200M）"];
    [attributedTitle addAttributes:@{
            NSFontAttributeName: [UIFont systemFontOfSize:14],
            NSForegroundColorAttributeName: [UIColor colorWithHexString:isDarkStyle ? QMColor_666666_text : QMColor_151515_text]
    } range:NSMakeRange(0, 4)];
    
    [attributedTitle addAttributes:@{
            NSFontAttributeName: [UIFont systemFontOfSize:12],
            NSForegroundColorAttributeName: [UIColor colorWithHexString:isDarkStyle ? QMColor_666666_text : @"9e9e9e"]
    } range:NSMakeRange(4, [attributedTitle length]-4)];
    
    [_clickBtn setAttributedTitle:attributedTitle forState:UIControlStateNormal];
    // 设置内容整体居中
    _clickBtn.contentHorizontalAlignment  = UIControlContentHorizontalAlignmentCenter; // 水平居中
    _clickBtn.contentVerticalAlignment  = UIControlContentVerticalAlignmentCenter;// 垂直居中
    [_clickBtn setTitleColor:[UIColor colorWithHexString:isDarkStyle ? QMColor_666666_text : QMColor_151515_text] forState:UIControlStateNormal];
    [_clickBtn addTarget:self action:@selector(clickEvent:) forControlEvents:UIControlEventTouchUpInside];
    [_backView addSubview:_clickBtn];
    
    
//    _fileImageView = [[UIImageView alloc] init];
//    _fileImageView.frame = CGRectMake(20, 10, 18, 18);
//    _fileImageView.backgroundColor = [UIColor whiteColor];
//    _fileImageView.image = [UIImage imageNamed:@"QMForm_upload"];
//    [_backView addSubview:_fileImageView];
//
//    _textField = [[UITextField alloc] init];
//    _textField.frame = CGRectMake(20, 0, CGRectGetWidth(_backView.frame) - 40, 48);
//    _textField.layer.masksToBounds = YES;
//    _textField.layer.cornerRadius = 8;
//    _textField.font = [UIFont fontWithName:QM_PingFangSC_Reg size:14];
//    _textField.textColor = [UIColor colorWithHexString:@"#151515"];
//    _textField.backgroundColor = [UIColor clearColor];
//    [_backView addSubview:_textField];
//    [_textField addTarget:self action:@selector(change:) forControlEvents:UIControlEventEditingChanged];
}

- (void)setModel:(NSDictionary *)model {
//    NSString *value = model[@"value"];
//    if (value.length > 0) {
//        _textField.text = model[@"value"];
//    }
//    NSString *name = model[@"name"];
//    _textField.placeholder = name.length > 0 ? name : @"";
    self.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_Main_Bg_Dark : QMColor_F6F6F6_BG];
    _backView.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_News_Agent_Dark : QMColor_FFFFFF_text];
    _textField.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_News_Agent_Dark : QMColor_FFFFFF_text];
    _textField.textColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_666666_text : QMColor_151515_text];
    NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:@"上传附件（单个附件不超过200M）"];
    [attributedTitle addAttributes:@{
            NSFontAttributeName: [UIFont systemFontOfSize:14],
            NSForegroundColorAttributeName: [UIColor colorWithHexString:isDarkStyle ? QMColor_666666_text : QMColor_151515_text]
    } range:NSMakeRange(0, 4)];
    
    [attributedTitle addAttributes:@{
            NSFontAttributeName: [UIFont systemFontOfSize:12],
            NSForegroundColorAttributeName: [UIColor colorWithHexString:isDarkStyle ? QMColor_666666_text : @"9e9e9e"]
    } range:NSMakeRange(4, [attributedTitle length]-4)];
    
    [_clickBtn setAttributedTitle:attributedTitle forState:UIControlStateNormal];
}

- (void)clickEvent:(UIButton *)button {
    self.clickBack();
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

//
//  QMChatNewCardCell.m
//  IMSDK
//
//  Created by lishuijiao on 2020/cardLeftMargin/29.
//

#import "QMChatNewCardCell.h"
#import "QMChatShowRichTextController.h"
#import "QMHeader.h"

#define newcardTitleFont 15.0f
#define newcardSubFont 13.0f
#define newcardDesFont 12.0f
#define cardLeftMargin 10
#define cardTopMargin 5
#define cardTextHeight 15
#define cardViewWith QM_kScreenWidth - kChatLeftAndRightWidth*2
@implementation QMChatNewCardCell {
    NSDictionary *_cardDic;
    
    NSString *_messageId;
    
    UIView *_newCardView;
    
    UILabel *_titleLabel;
    
    UILabel *_descriptionLabel;
        
    UIImageView *_imageView;
    
    UILabel *_attrOne;
    
    UILabel *_attrTwo;
    
    UILabel *_price;

    UILabel *_otherOne;
    
    UILabel *_otherTwo;

    UILabel *_otherThree;
    UIView *_segView;
    UIButton *_buttonOne;
    UIButton *_buttonTwo;
}

- (void)createUI {
    [super createUI];
    
    _newCardView = [[UIView alloc] init];
    _newCardView.QMCornerRadius = 8;
    [self.contentView addSubview:_newCardView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [_newCardView addGestureRecognizer:tap];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont systemFontOfSize:newcardTitleFont];
    _titleLabel.numberOfLines = 2;
    [_newCardView addSubview:_titleLabel];
    
    _descriptionLabel = [[UILabel alloc] init];
    _descriptionLabel.numberOfLines = 0;
    _descriptionLabel.font = [UIFont systemFontOfSize:newcardSubFont];
    [_newCardView addSubview:_descriptionLabel];
        
    _imageView = [[UIImageView alloc] init];
    _imageView.QMCornerRadius = 4;
    _imageView.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
    [_newCardView addSubview:_imageView];
    
    _attrOne = [[UILabel alloc] init];
    _attrOne.font = [UIFont systemFontOfSize:newcardSubFont];
    [_newCardView addSubview:_attrOne];

    _attrTwo = [[UILabel alloc] init];
    _attrTwo.font = [UIFont systemFontOfSize:newcardDesFont];
    [_newCardView addSubview:_attrTwo];

    _price = [[UILabel alloc] init];
    _price.font = [UIFont systemFontOfSize:newcardDesFont];
    [_newCardView addSubview:_price];
    
    _segView = [[UIView alloc] init];
    _segView.backgroundColor = [UIColor colorWithHexString:@"#E6E6E6"];
    [_newCardView addSubview:_segView];

    _otherOne = [[UILabel alloc] init];
    _otherOne.font = [UIFont systemFontOfSize:newcardDesFont];
    [_newCardView addSubview:_otherOne];

    _otherTwo = [[UILabel alloc] init];
    _otherTwo.font = [UIFont systemFontOfSize:newcardDesFont];
    [_newCardView addSubview:_otherTwo];

    _otherThree = [[UILabel alloc] init];
    _otherThree.font = [UIFont systemFontOfSize:newcardDesFont];
    [_newCardView addSubview:_otherThree];

    _buttonOne = [UIButton buttonWithType:UIButtonTypeCustom];
    _buttonOne.tag = 99;
    _buttonOne.hidden = YES;
    [_buttonOne setBackgroundColor:[UIColor colorWithHexString:QMColor_News_Custom]];
    [_buttonOne setTitleColor:[UIColor colorWithHexString:QMColor_FFFFFF_text] forState:UIControlStateNormal];
    _buttonOne.titleLabel.font = [UIFont systemFontOfSize:newcardDesFont];
    _buttonOne.QMCornerRadius = 4;
    [_buttonOne addTarget:self action:@selector(sendAction:) forControlEvents:UIControlEventTouchUpInside];
    [_newCardView addSubview:_buttonOne];
    
    _buttonTwo = [UIButton buttonWithType:UIButtonTypeCustom];
    _buttonTwo.tag = 100;
    _buttonTwo.hidden = YES;
    [_buttonTwo setBackgroundColor:[UIColor colorWithHexString:QMColor_FFFFFF_text]];
    [_buttonTwo setTitleColor:[UIColor colorWithHexString:QMColor_333333_text] forState:UIControlStateNormal];
    _buttonTwo.titleLabel.font = [UIFont systemFontOfSize:newcardDesFont];
    _buttonTwo.QMCornerRadius = 4;
    _buttonTwo.layer.borderColor = [UIColor colorWithHexString:@"#E6E6E6"].CGColor;
    _buttonTwo.layer.borderWidth = 0.5;
    [_buttonTwo addTarget:self action:@selector(sendAction:) forControlEvents:UIControlEventTouchUpInside];
    [_newCardView addSubview:_buttonTwo];
}

- (void)setData:(CustomMessage *)message avater:(NSString *)avater {
    self.message = message;
    _messageId = message._id;
    [super setData:message avater:avater];
    self.readStatus.hidden = YES;
    _titleLabel.textColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_FFFFFF_text : QMColor_000000_text];
    _descriptionLabel.textColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_999999_text : QMColor_666666_text];
//    _attrOne.textColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_999999_text : QMColor_999999_text];
//    _attrTwo.textColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_999999_text : QMColor_666666_text];
    _price.textColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_999999_text : @"#FF5C5C"];
    _otherOne.textColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_999999_text : QMColor_999999_text];
    _otherTwo.textColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_999999_text : QMColor_999999_text];
    _otherThree.textColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_999999_text : QMColor_999999_text];
    
    NSData *jsonData = [message.cardMessage_New dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err) {
        return;
    }

    _cardDic = dic;
    
    _imageView.hidden = NO;
    _imageView.frame = CGRectMake(cardLeftMargin, cardLeftMargin, 72, 72);
    NSString *imgUrl = dic[@"img"];
    if (imgUrl) {
        imgUrl = [imgUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        [_imageView sd_setImageWithURL:[NSURL URLWithString:imgUrl]];
    }

    NSString *otherTitleOne = dic[@"other_title_one"];
    NSString *otherTitleTwo = dic[@"other_title_two"];
    NSString *otherTitleThree = dic[@"other_title_three"];
    NSMutableArray *tagArray = dic[@"tags"];

    for (NSDictionary *dict in tagArray) {
        if ([dict[@"showRange"] isEqualToString:@"seats"]) {
            [tagArray removeObject:dict];
        }
    }
    
    CGFloat textWith = cardViewWith-cardLeftMargin*2;
    CGFloat titleWith = cardViewWith-90;
    CGFloat titleLeftMargin = CGRectGetMaxX(_imageView.frame)+5;
    if (otherTitleOne.length > 0 ||
        otherTitleTwo.length > 0 ||
        otherTitleThree.length > 0 ||
        tagArray.count > 0) {
        _segView.frame = CGRectMake(cardLeftMargin, CGRectGetMaxY(_imageView.frame) + cardLeftMargin, textWith, 0.5);
        _segView.hidden = NO;
    } else {
        _segView.frame = CGRectMake(cardLeftMargin, CGRectGetMaxY(_imageView.frame), textWith, 0);
        _segView.hidden = YES;
    }
    
    if (otherTitleOne.length > 0) {
        _otherOne.text = otherTitleOne;
        _otherOne.frame = CGRectMake(cardLeftMargin, CGRectGetMaxY(_segView.frame) + cardTopMargin, textWith, cardTextHeight);
    }else {
        _otherOne.frame = CGRectMake(cardLeftMargin, CGRectGetMaxY(_segView.frame), textWith, 0);
    }
    if (otherTitleTwo.length > 0) {
        _otherTwo.text = otherTitleTwo;
        _otherTwo.frame = CGRectMake(cardLeftMargin, CGRectGetMaxY(_otherOne.frame) + cardTopMargin, textWith, cardTextHeight);
    }else {
        _otherTwo.frame = CGRectMake(cardLeftMargin, CGRectGetMaxY(_otherOne.frame), textWith, 0);
    }
    if (otherTitleThree.length > 0) {
        _otherThree.text = otherTitleThree;
        _otherThree.frame = CGRectMake(cardLeftMargin, CGRectGetMaxY(_otherTwo.frame) + cardTopMargin, textWith, cardTextHeight);
    }else {
        _otherThree.frame = CGRectMake(cardLeftMargin, CGRectGetMaxY(_otherTwo.frame), textWith, 0);
    }
    
    NSString *price = dic[@"price"];
    NSString *attrOne = dic[@"attr_one"][@"content"];
    NSString *attrTwo = dic[@"attr_two"][@"content"];
    NSString *attrOneColor = dic[@"attr_one"][@"color"];
    NSString *attrTwoColor = dic[@"attr_two"][@"color"];
    NSString *itemType = dic[@"item_type"];
    _titleLabel.text = dic[@"title"];
    NSString *sub_Title = dic[@"sub_title"];
    if (itemType.length > 0) {
        _buttonOne.hidden = YES;
        _buttonTwo.hidden = YES;
        _titleLabel.numberOfLines = 1;
        _titleLabel.frame = CGRectMake(titleLeftMargin, cardLeftMargin, [UIScreen mainScreen].bounds.size.width - 225 - 60, 18);

        if (price.length > 0) {
            _price.text = price;
            _price.textAlignment = NSTextAlignmentRight;
            _price.frame = CGRectMake(CGRectGetMaxX(_titleLabel.frame), cardLeftMargin, 90, 18);
        }else {
            _price.text = @"";
        }

        if (sub_Title.length > 0) {
            _descriptionLabel.text = sub_Title;
            _descriptionLabel.frame = CGRectMake(titleLeftMargin, CGRectGetMaxY(_titleLabel.frame) + 5, [UIScreen mainScreen].bounds.size.width - 225 - 40, 18);
        }else {
            _descriptionLabel.text = @"";
            _descriptionLabel.frame = CGRectMake(titleLeftMargin, CGRectGetMaxY(_titleLabel.frame) + 5, [UIScreen mainScreen].bounds.size.width - 225 - 40, 18);
        }

        if (attrOne.length > 0) {
            _attrOne.text = attrOne;
            _attrOne.textAlignment = NSTextAlignmentRight;
            _attrOne.frame = CGRectMake(CGRectGetMaxX(_descriptionLabel.frame), CGRectGetMaxY(_titleLabel.frame) + 5, 40, 18);
            NSString *color = dic[@"attr_one"][@"color"];
            if (color.length > 0) {
                _attrOne.textColor = [UIColor colorWithHexString:color];
            }
        }else {
            _attrOne.text = @"";
        }

        NSString *otherTitleOne = dic[@"other_title_one"];
        if (otherTitleOne.length > 0) {
            _otherOne.text = otherTitleOne;
            _otherOne.frame = CGRectMake(titleLeftMargin, CGRectGetMaxY(_descriptionLabel.frame) + 5, [UIScreen mainScreen].bounds.size.width - 225 - 50, 16);
        }else {
            _otherOne.frame = CGRectMake(titleLeftMargin, CGRectGetMaxY(_imageView.frame) + cardLeftMargin, [UIScreen mainScreen].bounds.size.width - 225 - 50, 16);
        }

        if (attrTwo.length > 0) {
            _attrTwo.text = attrTwo;
            _attrTwo.textAlignment = NSTextAlignmentRight;
            _attrTwo.frame = CGRectMake(CGRectGetMaxX(_otherOne.frame), CGRectGetMaxY(_descriptionLabel.frame) + 5, 50, 16);
            NSString *color = dic[@"attr_two"][@"color"];
            if (color.length > 0) {
                _attrTwo.textColor = [UIColor colorWithHexString:color];
            }
        }else {
            _attrTwo.text = @"";
        }

        _newCardView.frame = CGRectMake(kChatLeftAndRightWidth, CGRectGetMaxY(self.timeLabel.frame)+25, QM_kScreenWidth - kChatLeftAndRightWidth * 2, 100);
        self.chatBackgroundView.frame = CGRectMake(kChatLeftAndRightWidth, CGRectGetMaxY(self.timeLabel.frame)+25, QM_kScreenWidth - kChatLeftAndRightWidth * 2, 100);
    }
    else {
        BOOL isTwoLine = NO;
        BOOL isThreeLine = NO;
        
        CGFloat strHeight = [QMLabelText calculateTextHeight:dic[@"title"] fontName:QM_PingFangSC_Reg fontSize:newcardTitleFont maxWidth:titleWith];
        
        if (strHeight > 25) {
            _titleLabel.numberOfLines = 2;
            _titleLabel.frame = CGRectMake(titleLeftMargin, cardTopMargin, titleWith,36);
        } else {
            _titleLabel.numberOfLines = 1;
            _titleLabel.frame = CGRectMake(titleLeftMargin, 8, titleWith, 25);
        }
        if (price.length > 0 || attrTwo.length > 0) {
            isThreeLine = YES;
        }
        
        if (attrOne.length > 0) {
            isTwoLine = YES;
            _attrOne.text = attrOne;
            _attrOne.textAlignment = NSTextAlignmentLeft;
        }else {
            _attrOne.text = @"";
        }
        _attrOne.frame = CGRectMake(cardViewWith - 30, CGRectGetMaxY(_titleLabel.frame) + cardTopMargin, 30, cardTextHeight);
        _attrOne.textColor = [UIColor colorWithHexString:attrOneColor.length ? attrOneColor : QMColor_999999_text];
        
        if (sub_Title.length > 0) {
            _descriptionLabel.text = sub_Title;
        }else {
            _descriptionLabel.text = @"";
        }
        CGFloat subStrHeight = [QMLabelText calculateTextHeight:sub_Title fontName:QM_PingFangSC_Reg fontSize:newcardSubFont maxWidth:titleWith - 20];
        if (isThreeLine && isTwoLine) {
            _descriptionLabel.numberOfLines = 1;
            _descriptionLabel.frame = CGRectMake(titleLeftMargin, CGRectGetMaxY(_titleLabel.frame) + cardTopMargin, titleWith - 20, cardTextHeight);
        }else if (isTwoLine && !isThreeLine) {
            _descriptionLabel.numberOfLines = 2;
            _descriptionLabel.frame = CGRectMake(titleLeftMargin, CGRectGetMaxY(_titleLabel.frame) + cardTopMargin, titleWith - 20, subStrHeight > 30 ? 30 : subStrHeight);
        }else if (!isTwoLine && isThreeLine) {
            _descriptionLabel.numberOfLines = 1;
            _descriptionLabel.frame = CGRectMake(titleLeftMargin, CGRectGetMaxY(_titleLabel.frame) + cardTopMargin, titleWith, cardTextHeight);
        }else {
            subStrHeight = [QMLabelText calculateTextHeight:sub_Title fontName:QM_PingFangSC_Reg fontSize:newcardSubFont maxWidth:titleWith];
            _descriptionLabel.numberOfLines = 2;
            _descriptionLabel.frame = CGRectMake(titleLeftMargin, CGRectGetMaxY(_titleLabel.frame) + cardTopMargin, titleWith, subStrHeight > 30 ? 30 : subStrHeight);
        }
        
        if (price.length > 0) {
            _price.text = price;
            _price.frame = CGRectMake(titleLeftMargin, CGRectGetMaxY(_descriptionLabel.frame) + cardLeftMargin, 100, cardTextHeight);
        }else {
            _price.text = @"";
            _price.frame = CGRectZero;
        }

        if (attrTwo.length > 0) {
            _attrTwo.text = attrTwo;
            _attrTwo.textAlignment = NSTextAlignmentLeft;
        }else {
            _attrTwo.text = @"";
        }
        _attrTwo.frame = CGRectMake(cardViewWith - 50, CGRectGetMaxY(_descriptionLabel.frame) + cardLeftMargin, 50, cardTextHeight);
        if (isDarkStyle) {
            _attrTwo.textColor = [UIColor colorWithHexString:QMColor_999999_text];
        } else {
            _attrTwo.textColor = [UIColor colorWithHexString:attrTwoColor.length ? attrTwoColor : QMColor_666666_text];
        }
        
        if (tagArray.count > 0) {
            if (tagArray.count == 1) {
                _buttonOne.hidden = NO;
                _buttonTwo.hidden = YES;
                NSString *labelOne = tagArray.firstObject[@"label"];
                CGFloat buttonW = (textWith-10)/2;
                [_buttonOne setTitle:labelOne forState:UIControlStateNormal];
                if ((labelOne.length > 4)) {
                    _buttonOne.frame = CGRectMake(cardLeftMargin, CGRectGetMaxY(_otherThree.frame) + cardTopMargin, textWith, 30);
                }
                else {
                    _buttonOne.frame = CGRectMake(buttonW+20, CGRectGetMaxY(_otherThree.frame) + 8, buttonW, 30);
                }
                self.chatBackgroundView.frame = CGRectMake(kChatLeftAndRightWidth, CGRectGetMaxY(self.timeLabel.frame)+25, cardViewWith,CGRectGetMaxY(_buttonOne.frame) + cardLeftMargin);
                _newCardView.frame = CGRectMake(kChatLeftAndRightWidth, CGRectGetMaxY(self.timeLabel.frame)+25, cardViewWith, CGRectGetMaxY(_buttonOne.frame) + cardLeftMargin);
            } else {
                _buttonOne.hidden = NO;
                _buttonTwo.hidden = NO;
                
                NSString *labelOne = tagArray.firstObject[@"label"];
                NSString *labelTwo = tagArray.lastObject[@"label"];
                CGFloat buttonW = (textWith-10)/2;
                [_buttonOne setTitle:labelOne forState:UIControlStateNormal];
                [_buttonTwo setTitle:labelTwo forState:UIControlStateNormal];
                if ((labelOne.length > 4) ||
                    (labelTwo.length > 4)) {
                    _buttonOne.frame = CGRectMake(cardLeftMargin, CGRectGetMaxY(_otherThree.frame) + cardTopMargin, textWith, 30);
                    _buttonTwo.frame = CGRectMake(cardLeftMargin, CGRectGetMaxY(_buttonOne.frame) + 8, textWith, 30);
                }
                else {
                   
                    _buttonOne.frame = CGRectMake(cardLeftMargin, CGRectGetMaxY(_otherThree.frame) + 8, buttonW, 30);
                    _buttonTwo.frame = CGRectMake(buttonW+20, CGRectGetMaxY(_otherThree.frame) + 8, buttonW, 30);
                }
                self.chatBackgroundView.frame = CGRectMake(kChatLeftAndRightWidth, CGRectGetMaxY(self.timeLabel.frame)+25, cardViewWith,CGRectGetMaxY(_buttonTwo.frame) + cardLeftMargin);
                _newCardView.frame = CGRectMake(kChatLeftAndRightWidth, CGRectGetMaxY(self.timeLabel.frame)+25, cardViewWith, CGRectGetMaxY(_buttonTwo.frame) + cardLeftMargin);
            }
        }
        else {
            _buttonOne.hidden = YES;
            _buttonTwo.hidden = YES;
            self.chatBackgroundView.frame = CGRectMake(kChatLeftAndRightWidth, CGRectGetMaxY(self.timeLabel.frame)+25, cardViewWith,  CGRectGetMaxY(_otherThree.frame) + cardLeftMargin);
            _newCardView.frame = CGRectMake(kChatLeftAndRightWidth, CGRectGetMaxY(self.timeLabel.frame)+25, cardViewWith,  CGRectGetMaxY(_otherThree.frame) + cardLeftMargin);
        }
        self.message.height = [NSString stringWithFormat:@"%f",CGRectGetMaxY(_newCardView.frame)+cardLeftMargin];
    }

    _newCardView.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_News_Agent_Dark : QMColor_News_Agent_Light];
    self.chatBackgroundView.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_News_Agent_Dark : QMColor_News_Agent_Light];
}

- (void)tapAction:(UITapGestureRecognizer *)gestureRecognizer {
    [self jumpLinkPage:_cardDic[@"target"]];
}

- (void)sendAction:(UIButton *)action
{
    NSArray *tagArray = _cardDic[@"tags"];
    if (action.tag == 99) {
        [self jumpLinkPage:tagArray.firstObject[@"url"]];
    } else {
        [self jumpLinkPage:tagArray.lastObject[@"url"]];
    }
}

- (void)jumpLinkPage:(NSString *)link {
    QMChatShowRichTextController * showWebVC = [[QMChatShowRichTextController alloc] init];
    if (link.length > 0) {
        if (![link hasPrefix:@"http"]) {
            link = [NSString stringWithFormat:@"http://%@",link];
        }
        showWebVC.urlStr = link;
        showWebVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:showWebVC animated:true completion:nil];
    }else {
//        showWebVC.urlStr = _cardDic[@"target"];
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

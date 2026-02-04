//
//  QMChatRobotCell.m
//  IMSDK
//
//  Created by 焦林生 on 2021/12/9.
//

#import "QMChatRobotCell.h"
#import "QMChatShowImageViewController.h"
#import "QMHeader.h"
#import "QMChatQuoteView.h"
#import "QMTableContainerView.h"
#import <CommonCrypto/CommonDigest.h>

@interface QMChatRobotCell ()<UITextViewDelegate>
@property (nonatomic, strong) QMChatQuoteView *quoteView;
@property (nonatomic, strong) UIView *aiShowView;
@property (nonatomic, strong) UILabel *aiLabel;
// 存储当前显示的表格视图
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, QMTableContainerView *> *currentTables;

@end
@implementation QMChatRobotCell

- (void)createUI {
    [super createUI];
    
    [self.chatBackgroundView addSubview:self.contentLab];
    [self.chatBackgroundView addSubview:self.quoteView];
    [self.quoteView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.chatBackgroundView).offset(2.5).priority(999);
        make.left.equalTo(self.chatBackgroundView).offset(8);
        make.right.equalTo(self.chatBackgroundView).offset(-8);
    }];
    
    [self.contentLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.quoteView.mas_bottom).offset(2.5);
        make.left.equalTo(self.chatBackgroundView).offset(QMFixWidth(8));
        make.right.equalTo(self.chatBackgroundView).offset(-QMFixWidth(8));
        make.bottom.equalTo(self.chatBackgroundView).offset(-1).priorityHigh();
        make.height.mas_greaterThanOrEqualTo(QMFixWidth(40)).priorityHigh();
    }];
    
    _currentTables = [NSMutableDictionary dictionary];
}

- (void)setData:(CustomMessage *)message avater:(NSString *)avater {
    [super setData:message avater:avater];
    self.message = message;
    
    // 移除旧的表格视图
    [self.currentTables.allValues enumerateObjectsUsingBlock:^(QMTableContainerView * _Nonnull table, NSUInteger idx, BOOL * _Nonnull stop) {
        [table removeFromSuperview];
    }];
    [self.currentTables removeAllObjects];
    
    self.contentLab.text = message.message;
    if (message.attrAttachmentReplaced == 1) {
        [self handleImage:message];
    }
    
    if (message.isQuoteMsg) {
        [self.quoteView setData:message.quoteContent.content];
        
        self.contentLab.text = [message.sendContent stringByRemovingPercentEncoding];
        [self updateQuoteView];
        [self.quoteView setBackColor:[message.fromType isEqualToString:@"1"]];

    } else {
        // 防止复用-回复布局
        [self.quoteView setData:@""];
        
        if (message.contentAttr && message.contentAttr.length > 0) {
            self.contentLab.attributedText = message.contentAttr;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self processTextAttachmentForMessage:message];
            });
        }
        [self updateQuoteView];

    }
    
    if (isDarkStyle) {
        self.contentLab.textColor = [UIColor colorWithHexString:QMColor_FFFFFF_text];
    }
}

- (void)processTextAttachmentForMessage:(CustomMessage *)message {
    if (!message.contentAttr) return;
    
    [self.currentTables.allValues enumerateObjectsUsingBlock:^(QMTableContainerView * _Nonnull table, NSUInteger idx, BOOL * _Nonnull stop) {
        [table removeFromSuperview];
    }];
    [self.currentTables removeAllObjects];
    
    [message.contentAttr enumerateAttribute:NSAttachmentAttributeName
                                   inRange:NSMakeRange(0, message.contentAttr.length)
                                   options:0
                                usingBlock:^(id value, NSRange range, BOOL *stop) {
        if ([value isKindOfClass:[QMTableTextAttachment class]]) {
            QMTableTextAttachment *tableAttachment = (QMTableTextAttachment *)value;
            
            // 检查表格是否已显示
//            if (self.currentTables[@(tableAttachment.tableIndex)]) {
//                return;
//            }
            
            // 计算实际位置（此时布局已完成）
            CGRect rect = [self.contentLab.layoutManager boundingRectForGlyphRange:range inTextContainer:self.contentLab.textContainer];
            rect.origin.y += QMFixHeight(8);
            // 创建表格容器
            QMTableContainerView *tableContainer = [[QMTableContainerView alloc] initWithFrame:rect];
            [tableContainer setupTableView:tableAttachment];
            
            // 存储并添加视图
            self.currentTables[@(tableAttachment.tableIndex)] = tableContainer;
            [self.contentLab addSubview:tableContainer];
        }
    }];
}

- (void)updateQuoteView {
    if (self.message.isQuoteMsg) {
        [self.quoteView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.chatBackgroundView).offset(4).priority(999);
            make.left.equalTo(self.chatBackgroundView).offset(8);
            make.right.equalTo(self.chatBackgroundView).offset(-8);
        }];
        
        [self.contentLab mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.quoteView.mas_bottom).offset(2.5);
            make.left.equalTo(self.chatBackgroundView).offset(QMFixWidth(8));
            make.right.equalTo(self.chatBackgroundView).offset(-QMFixWidth(8));
            make.bottom.equalTo(self.chatBackgroundView).offset(-1).priorityHigh();
            make.height.mas_greaterThanOrEqualTo(QMFixWidth(40)).priorityHigh();
        }];
    } else {
        [self.quoteView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.chatBackgroundView).offset(0).priority(999);
            make.height.mas_equalTo(0);
        }];
        
        [self.contentLab mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.chatBackgroundView).offset(6).priority(999);
            make.left.equalTo(self.chatBackgroundView).offset(QMFixWidth(8));
            make.right.equalTo(self.chatBackgroundView).offset(-QMFixWidth(8));
            make.bottom.equalTo(self.chatBackgroundView).offset(-1).priorityHigh();
            make.height.mas_greaterThanOrEqualTo(QMFixWidth(40)).priorityHigh();
        }];
        
        if(self.message.agentTipsSwitch == YES){
            [self.chatBackgroundView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.contentView).offset(-50).priority(999);
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

- (void)handleImage:(CustomMessage *)model {
    
    // 处理html替换成原本图片-原图片过大加载过慢
    __block BOOL needReload = NO;
    __block BOOL replacedAll = YES;
    
    [model.contentAttr enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, model.contentAttr.length) options:NSAttributedStringEnumerationReverse usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        
        if ([value isKindOfClass:[QMChatFileTextAttachment class]]) {
            QMChatFileTextAttachment *attach = (QMChatFileTextAttachment *)value;
            
            if (([attach.type isEqualToString:@"image"] ||
                 [attach.type isEqualToString:@"video"]) && (attach.need_replaceImage == YES)) {
                NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
                path = [path stringByAppendingPathComponent:[self MD5:attach.url]];
                
                if ([[NSFileManager defaultManager] fileExistsAtPath:path] == true) {
                    NSData *data = [[NSData alloc] initWithContentsOfFile:path options:NSDataReadingMappedAlways error:nil];
                    if (data.length > 0) {
                        UIImage *image = [[UIImage alloc] initWithData:data];
                        attach.image = image;
                        attach.need_replaceImage = NO;
                        needReload = YES;
                    }
                } else {
                    replacedAll = NO;
                }
            }
        }
    }];
    
    if (replacedAll) {
        model.attrAttachmentReplaced = 2;
    }
    
    if (needReload) {
        self.contentLab.attributedText = model.contentAttr;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self processTextAttachmentForMessage:model];
        });
        if (self.needReloadCell) {
            self.needReloadCell(model);
        }
    }
}

- (NSString *)MD5:(NSString *)string{
    
    const char* input = [string UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input, (CC_LONG)strlen(input), result);
    
    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [digest appendFormat:@"%02x", result[i]];
    }
    
    return digest;
}

- (QMChatTextView *)contentLab {
    if (!_contentLab) {
        _contentLab = [[QMChatTextView alloc] init];
        _contentLab.font = [UIFont systemFontOfSize:16];
        _contentLab.textAlignment = NSTextAlignmentLeft;
        _contentLab.textColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_FFFFFF_text : QMColor_151515_text];
        _contentLab.backgroundColor = [UIColor clearColor];
        _contentLab.QMCornerRadius = 10;
        _contentLab.delegate = self;
    }
    return _contentLab;
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

#pragma mark -------textViewDelegate-----
- (BOOL)handelTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRang {
    if ([textAttachment isKindOfClass:[QMChatFileTextAttachment class]]) {
        QMChatFileTextAttachment *attach = (QMChatFileTextAttachment *)textAttachment;
        if ([attach.type isEqualToString:@"image"]) {
            QMChatShowImageViewController * showPicVC = [[QMChatShowImageViewController alloc] init];
            showPicVC.modalPresentationStyle = UIModalPresentationFullScreen;
                NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
                path = [path stringByAppendingPathComponent:attach.url.lastPathComponent];
                if ([[NSFileManager defaultManager] fileExistsAtPath:path] == true) {
                    NSData *data = [[NSData alloc] initWithContentsOfFile:path options:NSDataReadingMappedAlways error:nil];
                    if (data.length > 0) {
                        UIImage *image = [[UIImage alloc] initWithData:data];
                        showPicVC.image = image;
                    }
                }
            
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:showPicVC animated:true completion:nil];
        } else {
            self.tapNetAddress(attach.url);
        }
        return false;
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction API_AVAILABLE(ios(10.0)) {
    return [self handelTextAttachment:textAttachment inRange:characterRange];
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction {
    
    if ([URL.absoluteString hasPrefix:@"http"]) {
        NSString *text = [URL.absoluteString stringByRemovingPercentEncoding];
        if ([text hasPrefix:@"http://7moor_param="]) {
            text = [text stringByReplacingOccurrencesOfString:@"http://7moor_param=" withString:@""];
            NSArray *items = [text componentsSeparatedByString:@"qm_actiontype"];
            if (items.count > 1) {
                NSString *actionType = items.firstObject;
                NSString *value = [items.lastObject stringByReplacingOccurrencesOfString:@"/" withString:@""];
                NSString *txtStr = [[NSUserDefaults standardUserDefaults] objectForKey:value];
                if ([actionType isEqualToString:@"robottransferagent"] ||
                    [actionType isEqualToString:@"transferagent"]) {
                    // 转人工
                    self.tapArtificialAction(value);
                } else if ([actionType isEqualToString:@"xbottransferrobot"]) {
                    //切换机器人
                    self.switchRobotAction(value);
                }
                else {
                    //自定义消息
                    self.tapSendMessage(txtStr, @"");
                }
            } else {
                self.tapArtificialAction(@"");
            }
        } else {
            self.tapNetAddress(text);
        }
    } else {

        NSString *text = URL.absoluteString;
        if ([text hasPrefix:@"tel:"]) {
            if ([text containsString:@"tel://"] == NO) {
                text = [text stringByReplacingOccurrencesOfString:@"tel:" withString:@"tel://"];
            }
            NSURL *url = [NSURL URLWithString:text];
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
        else {
            text =  [text stringByRemovingPercentEncoding];
            
            NSString *tempString = [text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            NSArray *array = [tempString componentsSeparatedByString:@"："];
            if (array.count > 1) {
                self.tapSendMessage(array[1], array[0]);
            }
        }
    }
    return false;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    // 移除所有表格视图
    [self.currentTables.allValues enumerateObjectsUsingBlock:^(QMTableContainerView * _Nonnull table, NSUInteger idx, BOOL * _Nonnull stop) {
        [table removeFromSuperview];
    }];
    [self.currentTables removeAllObjects];
    
    _contentLab.text = nil;
    _contentLab.attributedText = nil;
}

- (QMChatQuoteView *)quoteView {
    if (!_quoteView) {
        _quoteView = [QMChatQuoteView new];
    }
    return _quoteView;
}

@end

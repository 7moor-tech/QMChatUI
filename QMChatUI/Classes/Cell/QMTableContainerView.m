//
//  QMTableContainerView.m
//  QMLineSDK
//
//  Created by wt on 2025/7/31.
//  Copyright © 2025 haochongfeng. All rights reserved.
//

#import "QMTableContainerView.h"
#import "QMInsetLabel.h"

@interface QMTableContainerView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *horizontalScrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) QMTableTextAttachment *textAttachment;

@end

@implementation QMTableContainerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
//    self.layer.borderWidth = 0.5;
//    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    // 创建水平滚动视图
    _horizontalScrollView = [[UIScrollView alloc] init];
    _horizontalScrollView.showsHorizontalScrollIndicator = YES;
    _horizontalScrollView.delegate = self;
    _horizontalScrollView.bounces = NO;
    [self addSubview:_horizontalScrollView];
    
    // 创建内容视图
    _contentView = [[UIView alloc] init];
    [_horizontalScrollView addSubview:_contentView];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    _horizontalScrollView.frame = self.bounds;
    [self updateContentSize];
}

- (void)setupTableView:(QMTableTextAttachment *)attachment {
    self.textAttachment = attachment;
    if (!self.textAttachment.tableData || self.textAttachment.tableData.count == 0) return;
    
    // 清除旧视图
    for (UIView *subview in _contentView.subviews) {
        [subview removeFromSuperview];
    }

    // 创建表格内容
    [self createTableContent];
    
    // 更新内容大小
    [self updateContentSize];
}

- (void)updateContentSize {
    // 设置滚动视图内容大小
    _horizontalScrollView.contentSize = CGSizeMake(self.textAttachment.rect.size.width, self.textAttachment.rect.size.height);
    _contentView.frame = CGRectMake(0, 0, self.textAttachment.rect.size.width, self.textAttachment.rect.size.height);
}

- (void)createTableContent {
    CGFloat yOffset = 0;
    
    for (int row = 0; row < self.textAttachment.tableData.count; row++) {
        NSArray *rowData = self.textAttachment.tableData[row];
        CGFloat xOffset = 0;
        CGFloat rowHeight = [self.textAttachment.rowHeights[row] floatValue];
        for (int col = 0; col < self.textAttachment.columnWidths.count; col++) {
            CGFloat width = [self.textAttachment.columnWidths[col] floatValue];
            
            // 创建单元格
            QMInsetLabel *cellLabel = [[QMInsetLabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, width, rowHeight)];
            cellLabel.textInsets = UIEdgeInsetsMake(0, 4, 0, 0);
            cellLabel.font = [UIFont systemFontOfSize:16.0];
            cellLabel.textColor = [UIColor darkTextColor];
            cellLabel.textAlignment = NSTextAlignmentLeft;
            cellLabel.numberOfLines = 0;
            cellLabel.lineBreakMode  = NSLineBreakByWordWrapping;
            
            // 设置文本
            if (col < rowData.count) {
                if ([rowData[col] isKindOfClass:[NSString class]]) {
                    cellLabel.text = rowData[col];
                }else {
                    NSDictionary *dict = rowData[col];
                    NSString *text = dict[@"text"];
                    NSString *link = dict[@"link"];
                    cellLabel.linkURL = link;
                    cellLabel.isLink = dict[@"isLink"];
                    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text
                            attributes:@{
                                NSFontAttributeName: [UIFont systemFontOfSize:16],
                                NSForegroundColorAttributeName: [UIColor blueColor]
                            }];
                    
                    [attributedText addAttribute:NSLinkAttributeName value:[NSURL URLWithString:link] range:NSMakeRange(0, text.length)];
                    [attributedText addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(0, text.length)];
                    
                    cellLabel.attributedText = attributedText;
                    if (dict[@"isLink"]) {
                        cellLabel.userInteractionEnabled = YES;
                        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
                        [cellLabel addGestureRecognizer:tap];
                    }
                }
            }
            
            // 第一行加粗
            if (row == 0) {
                cellLabel.font = [UIFont boldSystemFontOfSize:16.0];
            }
            
            // 添加边框
            cellLabel.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:1.0].CGColor;
            cellLabel.layer.borderWidth = 0.5;

            [_contentView addSubview:cellLabel];
            
            xOffset += width;
        }
        
        yOffset += rowHeight;
    }
}

// 2. 在手势回调中计算点击位置
- (void)handleTap:(UITapGestureRecognizer *)gesture {
    QMInsetLabel *label = (QMInsetLabel *)gesture.view;
    NSURL *url = [NSURL URLWithString:label.linkURL];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
}

@end

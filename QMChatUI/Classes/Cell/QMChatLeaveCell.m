//
//  QMChatLeaveCell.m
//  IMSDK
//
//  Created by wt on 2025/7/18.
//

#import "QMChatLeaveCell.h"
#import "MLEmojiLabel.h"
#import "QMHeader.h"
#import <SDWebImage/SDWebImage.h>
#import "QMChatShowImageViewController.h"
#import "QMChatLeaveTextCell.h"
#import "QMImageAttachmentCell.h"
#import "QMFileAttachmentCell.h"
#import "QMProfileManager.h"

static CGFloat itemSize(void) {
    // 计算每个图片项的尺寸（每行4个，间距8）
    return floorf((QMChatTextMaxWidth  - 26 - 16) / 4);
}

@interface QMChatLeaveCell() <MLEmojiLabelDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSMutableArray *imageArr;
@property (nonatomic, copy) NSMutableArray *fileArr;

@end

@implementation QMChatLeaveCell

- (void)createUI {
    [super createUI];
    
    [self.chatBackgroundView addSubview:self.tableView];

    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.chatBackgroundView).offset(2.5).priority(999);
        make.left.equalTo(self.chatBackgroundView).offset(8);
        make.width.mas_greaterThanOrEqualTo(20);
        make.right.equalTo(self.chatBackgroundView).offset(-2);
        make.height.mas_equalTo(40);
        make.bottom.equalTo(self.chatBackgroundView).offset(-2.5);
    }];
    
    UILongPressGestureRecognizer * longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressTapGesture:)];
    [self.tableView addGestureRecognizer:longPressGesture];
}

- (void)setData:(CustomMessage *)message avater:(NSString *)avater {
    [super setData:message avater:avater];
    self.message = message;
    
    NSData *jsonData = [message.fileContent dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSArray *commonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err) {
        return;
    }
    [self.imageArr removeAllObjects];
    [self.fileArr removeAllObjects];
    CGFloat maxFileNameWidth = 0;
    if (commonArray.count) {
        for (NSDictionary *item in commonArray) {
            NSString *fileNameStr = item[@"fileName"];
            NSString *fileName = fileNameStr.pathExtension.lowercaseString;
            if ([fileName isEqualToString:@"png"]||[fileName isEqualToString:@"jpg"]||[fileName isEqualToString:@"bmp"]||[fileName isEqualToString:@"jpeg"]) {
                [self.imageArr addObject:item];
            }else {
                [self.fileArr addObject:item];
                CGSize size = [fileNameStr sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:QM_PingFangSC_Reg size:14]}];
                if (size.width > maxFileNameWidth) {
                    maxFileNameWidth = size.width;
                }
            }
        }
    }
    
    CGFloat imageRow = self.imageArr.count/4+(self.imageArr.count%4 > 0 ? 1 : 0);
    CGFloat imageHeight = imageRow * itemSize() + (imageRow > 1 ? (imageRow-1)*8 : 0) + (self.imageArr.count > 0 ? 8 : 0);
    CGFloat imageWidth = self.imageArr.count > 3 ? QMChatTextMaxWidth : (self.imageArr.count*itemSize()+self.imageArr.count*8);
    
    CGFloat fileHeight = self.fileArr.count * 52;
    
    CGFloat titleHeight = 50;

    CGSize testSize = [QMLabelText calculateText:self.message.message fontName:QM_PingFangSC_Reg fontSize:16 maxWidth:QMChatTextMaxWidth maxHeight:CGFLOAT_MAX];
                                                 
    if (titleHeight < (testSize.height + 10)) {
        titleHeight = ceil(testSize.height) + 10;
    }
    
    CGFloat totalHeight = imageHeight + fileHeight + titleHeight;
    
    totalHeight = (totalHeight > 300) ? 300 : totalHeight;
    maxFileNameWidth += 44;
    CGFloat totalWidth = MIN(MAX(MAX(imageWidth, ceil(testSize.width+6)), maxFileNameWidth), QMChatTextMaxWidth);
    
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.chatBackgroundView).offset(2.5).priority(999);
        make.left.equalTo(self.chatBackgroundView).offset(8);
        make.width.mas_greaterThanOrEqualTo(totalWidth);
        make.right.equalTo(self.chatBackgroundView).offset(-2);
        make.height.mas_equalTo(totalHeight);
        make.bottom.equalTo(self.chatBackgroundView).offset(-2.5);
    }];
    
    [self.tableView reloadData];
}

#pragma --mark tableview----
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1 + self.fileArr.count + (self.imageArr.count > 0 ? 1 : 0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        QMChatLeaveTextCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(QMChatLeaveTextCell.self) forIndexPath:indexPath];
        [cell setData:self.message];
        cell.tapNetAddress = self.tapNetAddress;
        cell.tapNumberAction = self.tapNumberAction;
        return cell;
    }else if (indexPath.row == 1 && self.imageArr.count > 0) {
        QMImageAttachmentCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(QMImageAttachmentCell.self) forIndexPath:indexPath];
        [cell setData:self.imageArr];
        return cell;
    }
    QMFileAttachmentCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(QMFileAttachmentCell.self) forIndexPath:indexPath];
    NSInteger index = indexPath.row-1;
    if (self.imageArr.count > 0) {
        index -= 1;
    }
    if (index >= 0 && self.fileArr.count > index) {
        [cell setData:self.fileArr[index]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    });
   
    NSInteger didSelectIndex = indexPath.row-1;
    if (self.imageArr.count > 0) {
        didSelectIndex -= 1;
    }
    
    if (self.showFileBlock) {
        CustomMessage *customMessage = [[CustomMessage alloc] init];
        if (self.fileArr.count > didSelectIndex) {
            NSDictionary *dict = self.fileArr[didSelectIndex];
            customMessage.fileName = dict[@"fileName"];
            customMessage.remoteFilePath = dict[@"agentUrl"];
            customMessage.fileSize = dict[@"fileSize"];
            NSString *localPath = [[QMProfileManager sharedInstance] checkFileExtension: customMessage.fileName];
            customMessage.localFilePath = localPath;
            self.showFileBlock(customMessage);
        }
    }
}

- (void)longPressTapGesture:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self becomeFirstResponder];
        CGPoint point = [sender locationInView:self.chatBackgroundView];
        
        UIMenuController *menu = [UIMenuController sharedMenuController];
        UIMenuItem *copyMenu = [[UIMenuItem alloc] initWithTitle:QMUILocalizableString(button.copy)  action:@selector(copyMenu:)];
        UIMenuItem *removeMenu = [[UIMenuItem alloc] initWithTitle:QMUILocalizableString(button.delete) action:@selector(removeMenu:)];
        if ([self.message.fromType isEqualToString:@"0"]) {
            [menu setMenuItems:[NSArray arrayWithObjects:copyMenu,removeMenu, nil]];
        }
        else {
            [menu setMenuItems:[NSArray arrayWithObjects:copyMenu, nil]];
        }
        
        CGRect frame = CGRectMake(point.x - 25, point.y, 50, 20);
        if (@available(iOS 13, *)) {
            [menu showMenuFromView:self rect:self.chatBackgroundView.frame];
        } else {
            [menu setTargetRect:frame inView:self];
            [menu setMenuVisible:YES];
        }
    }
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(copyMenu:) || action == @selector(removeMenu:)) {
        return YES;
    }else {
        return  NO;
    }
}

- (void)copyMenu:(id)sender {
    // 复制文本消息
    UIPasteboard *pasteBoard =  [UIPasteboard generalPasteboard];
    pasteBoard.string = self.message.message;
}

- (void)removeMenu:(id)sender {
    // 删除文本消息
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:QMUILocalizableString(title.prompt) message:QMUILocalizableString(title.statement) preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:QMUILocalizableString(button.cancel) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

    }];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:QMUILocalizableString(button.sure) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [QMConnect removeDataFromDataBase:self.message._id];
        [[NSNotificationCenter defaultCenter] postNotificationName:CHATMSG_RELOAD object:nil];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:sureAction];

    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}

- (NSMutableArray *)imageArr {
    if (!_imageArr) {
        _imageArr = [NSMutableArray array];
    }
    return _imageArr;
}

- (NSMutableArray *)fileArr {
    if (!_fileArr) {
        _fileArr = [NSMutableArray array];
    }
    return _fileArr;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.bounces = NO;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[QMChatLeaveTextCell self] forCellReuseIdentifier:NSStringFromClass(QMChatLeaveTextCell.self)];
        [_tableView registerClass:[QMImageAttachmentCell self] forCellReuseIdentifier:NSStringFromClass(QMImageAttachmentCell.self)];
        [_tableView registerClass:[QMFileAttachmentCell self] forCellReuseIdentifier:NSStringFromClass(QMFileAttachmentCell.self)];
//        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    return _tableView;
}

@end


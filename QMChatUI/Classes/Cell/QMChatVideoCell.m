//
//  QMChatVideoCell.m
//  IMSDK
//
//  Created by ZCZ on 2022/10/17.
//

#import "QMChatVideoCell.h"
#import "QMHeader.h"
#import "QMProfileManager.h"
@interface QMChatVideoCell ()
@property (nonatomic, strong) UIButton *pleyerBtn;
@property (nonatomic, strong) UIProgressView *progressView;
@end

@implementation QMChatVideoCell

- (void)createUI {
    [super createUI];
    
    [self.chatBackgroundView addSubview:self.showImageView];
    [self.showImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.chatBackgroundView);
        make.width.height.mas_equalTo(200).priorityHigh();
    }];
    
    [self.showImageView addSubview:self.pleyerBtn];
    [self.pleyerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.showImageView);
    }];
    [self.chatBackgroundView addSubview:self.progressView];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.chatBackgroundView);
        make.height.mas_equalTo(3);
    }];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    [self.showImageView addGestureRecognizer:longPress];
}

- (void)setData:(CustomMessage *)message avater:(NSString *)avater
{
    [super setData:message avater:avater];
    self.chatBackgroundView.backgroundColor = [UIColor clearColor];
    
    NSString *urlString = message.message;
    if ([urlString.stringByRemovingPercentEncoding isEqualToString:urlString]) {
        urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    }
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@/%@",NSHomeDirectory(),@"Documents",urlString.lastPathComponent];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
//        self.showImageView.image = [UIImage imageWithContentsOfFile:filePath];
        [self setNetImageWithURL:filePath isFilePath:YES];
    } else {
        [self setNetImageWithURL:urlString isFilePath:NO];
    }
}

- (void)setNetImageWithURL:(NSString *)urlString isFilePath:(BOOL)isFilePath {
  
    UIImage *image = [[SDImageCache sharedImageCache] imageFromCacheForKey:urlString];

    if (image) {
        self.showImageView.image = image;
        [self upShowImageViewFrame:image.size needUpdateCell:NO];
    }
    else {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSURL *url = [NSURL URLWithString:urlString ? : @"" ];
            if (isFilePath) {
                url = [NSURL fileURLWithPath:urlString ? : @""];
            }
            AVURLAsset *asset1 = [[AVURLAsset alloc] initWithURL:url options:nil];
            AVAssetImageGenerator *generate1 = [[AVAssetImageGenerator alloc] initWithAsset:asset1];
            generate1.appliesPreferredTrackTransform = YES;
            NSError *err = NULL;
            CMTime time = CMTimeMake(1, 2);
            CGImageRef oneRef = [generate1 copyCGImageAtTime:time actualTime:NULL error:&err];
            UIImage *one = [[UIImage alloc] initWithCGImage:oneRef];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.showImageView.image = one;
                [self upShowImageViewFrame:one.size needUpdateCell:YES];
            });
        });

    }
}

- (void)upShowImageViewFrame:(CGSize)imageSize needUpdateCell:(BOOL)update {
    if (imageSize.height == 0 || imageSize.width == 0) {
        return;
    }
    
    CGFloat width = 0.0;
    CGFloat height = 0.0;
    if (imageSize.width > imageSize.height) {
        width = imageSize.width > 200 ? 200 : imageSize.width;
        height = width*imageSize.height/imageSize.width;
    } else {
        height = imageSize.height > 200 ? 200 : imageSize.height;
        width = height*imageSize.width/imageSize.height;
    }
    
    [self.showImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height).priorityHigh();
        make.width.mas_equalTo(width).priorityHigh();
    }];
    
    if (update && self.needReloadCell) {
        self.needReloadCell(self.message);
    }

}

- (void)tapRecognizerAction {
    NSString *realFilePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:self.message.fileName];
    NSString *urlString = self.message.remoteFilePath;
    

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:realFilePath]) {
        realFilePath = @"";
    }
    if ([urlString.stringByRemovingPercentEncoding isEqualToString:urlString]) {
        urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    }
    if (self.playerVideoAction) {
        self.playerVideoAction(urlString, realFilePath);
    }

}

- (SDAnimatedImageView *)showImageView {
    if (!_showImageView) {
        _showImageView = [[SDAnimatedImageView alloc] init];
        _showImageView.contentMode = UIViewContentModeScaleAspectFill;
        _showImageView.userInteractionEnabled = YES;
        _showImageView.image = [UIImage imageNamed:QMChatUIImagePath(@"chat_image_placeholder")];
    }
    return  _showImageView;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] init];
        _progressView.tintColor = [UIColor grayColor];
        _progressView.progressTintColor = UIColor.greenColor;
        [_progressView setHidden:YES];
    }
    return _progressView;
}

- (void)longPressAction:(UILongPressGestureRecognizer *)press {
    if (press.state == UIGestureRecognizerStateBegan) {
        [self becomeFirstResponder];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        UIMenuItem *removeMenu = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(removeMenu:)];
        UIMenuItem *downMenu = [[UIMenuItem alloc] initWithTitle:@"下载" action:@selector(downloadMenu:)];
        [menu setMenuItems:[NSArray arrayWithObjects:removeMenu, downMenu, nil]];
        [menu setTargetRect:self.showImageView.frame inView:self.showImageView];
        [menu setMenuVisible:YES animated:YES];
        
        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
        if ([window isKeyWindow] == NO) {
            [window becomeKeyWindow];
            [window makeKeyAndVisible];
        }
    }
}

- (UIButton *)pleyerBtn {
    if (!_pleyerBtn) {
        _pleyerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_pleyerBtn setImage:[UIImage imageNamed:QMChatUIImagePath(@"chat_video_player")] forState:UIControlStateNormal];
        _pleyerBtn.contentMode = UIViewContentModeScaleAspectFit;
        [_pleyerBtn addTarget:self action:@selector(tapRecognizerAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pleyerBtn;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(removeMenu:) || action == @selector(downloadMenu:)) {
        return YES;
    }else {
        return  NO;
    }
}

- (void)setProgress:(CGFloat)progress messageId:(NSString *)messageId {
    if ([messageId isEqualToString:self.message._id]){
        NSLog(@"progress = %0.2f",progress);
        [self.progressView setHidden:(progress >= 1.0 || progress == 0.0)];
        self.progressView.progress = progress;
    }
}

- (void)downloadMenu:(id)sender {
    NSString *localPath = [[QMProfileManager sharedInstance] checkFileExtension: self.message.fileName];
    __weak typeof (self) weakSelf = self;
    NSString *messageId = self.message._id;
    [QMConnect downloadFileWithMessage:self.message localFilePath:localPath progressHander:^(float progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf setProgress:progress messageId:messageId];
        });
    } successBlock:^{
        // 图片或视频存储至相册
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf setProgress:1 messageId:messageId];

            NSString *rootPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
            NSString *localFilePath = [rootPath stringByAppendingPathComponent:localPath];
            UISaveVideoAtPathToSavedPhotosAlbum(localFilePath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        });
    } failBlock:^(NSString * _Nonnull error) {
//        [weakSelf setProgress:1];
        [weakSelf setProgress:1 messageId:messageId];

    }];
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo: (void *)contextInfo {

}

- (void)removeMenu:(id)sender {
    
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



@end

//
//  QMFileDownloadViewController.m
//  IMSDK
//
//  Created by wt on 2025/8/14.
//

#import "QMFileDownloadViewController.h"
#import <QMLineSDK/QMLineSDK.h>
#import <WebKit/WebKit.h>
#import "QMHeader.h"
#import "QMFileModel.h"
#import "QMProfileManager.h"
#import "QMChatShowRichTextController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface QMFileDownloadViewController ()<UIScrollViewDelegate,WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIImageView *typeImageView;
@property (nonatomic, strong) UILabel *fileNameLabel;
@property (nonatomic, strong) UIButton *onlineShowButton;
@property (nonatomic, strong) UIButton *downloadButton;
@property (nonatomic, strong) UILabel *percentLabel;
@property (nonatomic, strong) UIView *progressView;
@property (nonatomic, strong) UIView *trackView;
@property (nonatomic, strong) CustomMessage *customMessage;

@end

@implementation QMFileDownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];

    [self.view addSubview:self.typeImageView];
    [self.view addSubview:self.fileNameLabel];
    [self.view addSubview:self.onlineShowButton];
    [self.view addSubview:self.downloadButton];
    [self.view addSubview:self.percentLabel];
    [self.view addSubview:self.progressView];
    [self.progressView addSubview:self.trackView];
    
    [self getLocalFile];
}

- (void)loadData:(CustomMessage *)message {
    self.customMessage = message;
    if (message.fileName == nil || message.fileName.length == 0) {
        return;
    }
    
    self.title = message.fileName;
    [self setTypeImage:message.fileName];
    CGRect rect = [message.fileName boundingRectWithSize:CGSizeMake(QM_kScreenWidth-80, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:self.fileNameLabel.font}
                                                 context:nil];
    self.fileNameLabel.text = message.fileName;
    self.fileNameLabel.frame = CGRectMake(40, CGRectGetMaxY(self.typeImageView.frame)+15, QM_kScreenWidth-80, rect.size.height);
}

- (void)setTypeImage:(NSString *)fileName {
    NSString *fileType = fileName.pathExtension.lowercaseString;
    if ([fileType isEqualToString:@"doc"]||[fileType isEqualToString:@"docx"]) {
        self.typeImageView.image = [UIImage imageNamed:QMChatUIImagePath(@"qm_file_doc")];
    }else if ([fileType isEqualToString:@"xlsx"]||[fileType isEqualToString:@"xls"]) {
        self.typeImageView.image = [UIImage imageNamed:QMChatUIImagePath(@"qm_file_xls")];
    }else if ([fileType isEqualToString:@"ppt"]||[fileType isEqualToString:@"pptx"]) {
        self.typeImageView.image = [UIImage imageNamed:QMChatUIImagePath(@"qm_file_pptx")];
    }else if ([fileType isEqualToString:@"pdf"]) {
        self.typeImageView.image = [UIImage imageNamed:QMChatUIImagePath(@"qm_file_pdf")];
    }else if ([fileType isEqualToString:@"mp3"]) {
        self.typeImageView.image = [UIImage imageNamed:QMChatUIImagePath(@"qm_file_mp3")];
    }else if ([fileType isEqualToString:@"mov"]||[fileType isEqualToString:@"mp4"]) {
        self.typeImageView.image = [UIImage imageNamed:QMChatUIImagePath(@"qm_file_mov")];
    }else if ([fileType isEqualToString:@"png"]||[fileType isEqualToString:@"jpg"]||[fileType isEqualToString:@"bmp"]||[fileType isEqualToString:@"jpeg"]) {
        self.typeImageView.image = [UIImage imageNamed:QMChatUIImagePath(@"qm_file_png")];
    }else {
        self.typeImageView.image = [UIImage imageNamed:QMChatUIImagePath(@"qm_file_other")];
    }
}

- (void)onlineShowFile {
    NSString *fileName = self.customMessage.fileName.pathExtension.lowercaseString;
    if ([fileName isEqualToString:@"mov"]||[fileName isEqualToString:@"mp4"]||[fileName isEqualToString:@"m4v"]) { // 视频消息
        NSString *realFilePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:self.customMessage.fileName];
        NSString *urlString = self.customMessage.remoteFilePath;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:realFilePath]) {
            realFilePath = @"";
        }
        if ([urlString.stringByRemovingPercentEncoding isEqualToString:urlString]) {
            urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
        }
        NSURL *url = nil;
        if (realFilePath.length > 0) {
            url = [NSURL fileURLWithPath:realFilePath];
        } else if (urlString) {
            url = [NSURL URLWithString:urlString];
        }
        if (url) {
            //步骤2：创建AVPlayer
            AVPlayer *avPlayer = [[AVPlayer alloc] initWithURL:url];
            avPlayer.shouldGroupAccessibilityChildren = YES;
            //步骤3：使用AVPlayer创建AVPlayerViewController，并跳转播放界面
            AVPlayerViewController *avPlayerVC =[[AVPlayerViewController alloc] init];
            avPlayerVC.player = avPlayer;
            avPlayerVC.allowsPictureInPicturePlayback = YES;
            [avPlayerVC.player play];
            [self presentViewController:avPlayerVC animated:YES completion:nil];
        }
    }else {
        // 打开本地文件
        QMChatShowRichTextController *showFile = [[QMChatShowRichTextController alloc] init];
        showFile.modalPresentationStyle = UIModalPresentationFullScreen;
        if (self.customMessage.localFilePath && [self.customMessage.localFilePath length] > 0) {
            showFile.urlStr = self.customMessage.localFilePath;
        }else {
            showFile.urlStr = self.customMessage.remoteFilePath;
        }
        UIViewController *vc = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        [vc presentViewController:showFile animated:YES completion:nil];
    }
}

-(void)getLocalFile {
    NSString *localPath = [[QMProfileManager sharedInstance] checkFileExtension: self.customMessage.fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
        self.customMessage.localFilePath = localPath;
    }
}

- (void)downloadFile {
    [self.onlineShowButton setHidden:true];
    [self.downloadButton setHidden:true];
    [self.progressView setHidden:false];
    [self.trackView setHidden:false];
    [self.percentLabel setHidden:false];

    NSString *localPath = [[QMProfileManager sharedInstance] checkFileExtension: self.customMessage.fileName];
    __weak QMFileDownloadViewController *weakSelf = self;
    [QMConnect downloadLeaveFileWithMessage:self.customMessage localFilePath:localPath progressHander:^(NSProgress *downProgress) {
        float complete = (float)downProgress.completedUnitCount;
        float total = (float)downProgress.totalUnitCount;
        float percent = complete/total;
        NSString *readyValue = total > 1024*1024 ? [NSString stringWithFormat:@"%0.1f MB", complete/1024/1024] : [NSString stringWithFormat:@"%0.1f KB", complete/1024];
        NSString *totalValue = total > 1024*1024 ? [NSString stringWithFormat:@"%0.1f MB", total/1024/1024] : [NSString stringWithFormat:@"%0.1f KB", total/1024];
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.percentLabel.text = [NSString stringWithFormat:@"(%@/%@)",readyValue, totalValue];
            [weakSelf setProgress:percent];
        });
    } successBlock:^{
        // 图片或视频存储至相册
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf setProgress:1];
            
            [weakSelf.progressView setHidden:true];
            [weakSelf.trackView setHidden:true];
            [weakSelf.percentLabel setHidden:true];
            
            [weakSelf onlineShowFile];
//                //下载文件路径
//                NSString *rootPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
//                NSString *localFilePath = [rootPath stringByAppendingPathComponent:localPath];
        });
    } failBlock:^(NSString * _Nonnull error) {
        [weakSelf setProgress:1];
        
        [weakSelf.onlineShowButton setHidden:false];
        [weakSelf.downloadButton setHidden:false];
        [weakSelf.progressView setHidden:true];
        [weakSelf.trackView setHidden:true];
        [weakSelf.percentLabel setHidden:true];
    }];
}

- (void)setProgress:(float)percent {
    CGFloat trackWidth = (QM_kScreenWidth - 80) * percent;
    self.trackView.frame = CGRectMake(0, 0, trackWidth, 2);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if (navigationAction.targetFrame == nil) {
        [webView loadRequest:navigationAction.request];
    }
        
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
//    [QMActivityView startAnimating];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
//    [QMActivityView stopAnimating];
}

- (void)backAction:(UIButton *)button {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (WKWebView *)webView {
    if (!_webView) {
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, kStatusBarAndNavHeight, QM_kScreenWidth, [UIScreen mainScreen].bounds.size.height - kStatusBarAndNavHeight) configuration:[[WKWebViewConfiguration alloc] init]];
        _webView.navigationDelegate = self;
    }
    return _webView;
}

- (UIImageView *)typeImageView {
    if (!_typeImageView) {
        _typeImageView = [[UIImageView alloc] initWithFrame:CGRectMake((QM_kScreenWidth-75)*0.5, 80, 75, 75)];
    }
    return _typeImageView;
}

- (UILabel *)fileNameLabel {
    if (!_fileNameLabel) {
        _fileNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, CGRectGetMaxY(self.typeImageView.frame)+15, QM_kScreenWidth-80, 30)];
        _fileNameLabel.textAlignment = NSTextAlignmentCenter;
        _fileNameLabel.font = [UIFont fontWithName:QM_PingFangSC_Reg size:18];
        _fileNameLabel.numberOfLines = 0;
    }
    return _fileNameLabel;
}

- (UIButton *)onlineShowButton {
    if (!_onlineShowButton) {
        _onlineShowButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _onlineShowButton.frame = CGRectMake(70, CGRectGetMaxY(self.fileNameLabel.frame)+60, QM_kScreenWidth-140, 30);
        [_onlineShowButton setTitle:@"在线预览" forState:UIControlStateNormal];
        [_onlineShowButton setTitleColor:[UIColor colorWithHexString:QMColor_News_Custom] forState:UIControlStateNormal];
        _onlineShowButton.titleLabel.font = [UIFont fontWithName:QM_PingFangSC_Reg size:16];
        [_onlineShowButton addTarget:self action:@selector(onlineShowFile) forControlEvents:UIControlEventTouchUpInside];
    }
    return _onlineShowButton;
}

- (UILabel *)percentLabel {
    if (!_percentLabel) {
        _percentLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, CGRectGetMaxY(self.fileNameLabel.frame)+60, QM_kScreenWidth-140, 30)];
        _percentLabel.textAlignment = NSTextAlignmentCenter;
        _percentLabel.font = [UIFont fontWithName:QM_PingFangSC_Reg size:16];
        [_percentLabel setHidden:true];
    }
    return _percentLabel;
}

- (UIButton *)downloadButton {
    if (!_downloadButton) {
        _downloadButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _downloadButton.frame = CGRectMake(70, CGRectGetMaxY(self.onlineShowButton.frame)+20, QM_kScreenWidth-140, 40);
        [_downloadButton setTitle:@"下载" forState:UIControlStateNormal];
        _downloadButton.backgroundColor = [UIColor colorWithHexString:QMColor_News_Custom];
        [_downloadButton setTitleColor:[UIColor colorWithHexString:isDarkStyle ? QMColor_D4D4D4_text : QMColor_FFFFFF_text] forState:UIControlStateNormal];
        _downloadButton.titleLabel.font = [UIFont fontWithName:QM_PingFangSC_Reg size:16];
        [_downloadButton addTarget:self action:@selector(downloadFile) forControlEvents:UIControlEventTouchUpInside];
        _downloadButton.layer.cornerRadius = 4;
        _downloadButton.layer.masksToBounds = true;
        
    }
    return _downloadButton;
}

- (UIView *)progressView {
    if (!_progressView) {
        _progressView = [[UIView alloc] initWithFrame:CGRectMake(40, CGRectGetMaxY(self.onlineShowButton.frame)+40, QM_kScreenWidth-80, 2)];
        _progressView.backgroundColor = [UIColor colorWithHexString:QMColor_Main_Bg_Light];
        _progressView.layer.cornerRadius = 1;
        _progressView.layer.masksToBounds = true;
        [_progressView setHidden:true];
    }
    return _progressView;
}

- (UIView *)trackView {
    if (!_trackView) {
        _trackView = [[UIView alloc] initWithFrame:CGRectZero];
        _trackView.backgroundColor = [UIColor colorWithHexString:QMColor_News_Custom];
        _trackView.layer.cornerRadius = 1;
        _trackView.layer.masksToBounds = true;
        [_trackView setHidden:true];
    }
    return _trackView;
}

@end

//
//  QMChatFaceView.m
//  IMSDK
//
//  Created by lishuijiao on 2020/10/13.
//

#import "QMChatFaceView.h"
#import "QMHeader.h"
#import <Masonry/Masonry.h>
#import "QMChatEmoji.h"

@interface QMChatFaceView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) NSArray *dataArray;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UIView *coverView;

@property (nonatomic, strong) UIButton *deleteBtn;

@property (nonatomic, strong) UIButton *sendBtn;

@end

@implementation QMChatFaceView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.collectionView];
        [self addSubview:self.coverView];
        [self.coverView addSubview:self.sendBtn];
        [self.coverView addSubview:self.deleteBtn];
        
        [self layoutViews];
        [self loadData];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(inputViewDidChange:) name:@"QM__inputViewDidChange" object:nil];
    }
    return self;
}

- (void)layoutViews {
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    CGFloat itemWidth = QM_kScreenWidth/8;
    CGFloat btnWidth = 50;
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.equalTo(self);
        make.width.mas_equalTo(itemWidth * 3);
        make.height.mas_equalTo(QM_IS_iPHONEX ? itemWidth + 34 : itemWidth);
    }];
    
    [self.deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.coverView).offset(itemWidth/2);
        make.top.equalTo(self.coverView).offset(8);
        make.width.mas_equalTo(btnWidth);
        make.height.mas_equalTo(35);
    }];
    
    [self.sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.coverView).offset(-10);
        make.height.top.width.equalTo(self.deleteBtn);
    }];
}

- (void)loadData {
    if (self.dataArray == 0) {
        
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"QMEmoticon" ofType:@"bundle"];
        NSString *fileName = [QMTUIBundle(QMChatUIBundle) pathForResource:@"expressionImage" ofType:@"plist"];
        NSDictionary *plistDict = [NSDictionary dictionaryWithContentsOfFile:fileName];
        NSMutableArray *items = [NSMutableArray array];
        for (int i = 0; i<[[plistDict allKeys] count]; i++)
        {
            QMChatEmoji *item = [QMChatEmoji new];
            NSString *imageStr = [NSString stringWithFormat:@"emoji_%d",i+1];
            NSString *imagePath = [NSString stringWithFormat:@"%@/%@", bundlePath,imageStr];
            item.image = [UIImage imageWithContentsOfFile:imagePath];
            NSString *image = [NSString stringWithFormat:@"emoji_%d.png",i+1];
            for (int j = 0; j<[[plistDict allKeys] count]; j++)
            {
                if ([[plistDict objectForKey:[[plistDict allKeys] objectAtIndex:j]]
                     isEqualToString:image])
                {
                    item.name = [[plistDict allKeys] objectAtIndex:j];
                }
            }
            [items addObject:item];
        }
        self.dataArray = items;
        [self.collectionView reloadData];
    }
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowlayout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat itemWidth = QM_kScreenWidth/8;
        flowlayout.itemSize = CGSizeMake(itemWidth, itemWidth);
        CGFloat space = 0;
        flowlayout.minimumLineSpacing = space;
        flowlayout.minimumInteritemSpacing = space;
        flowlayout.sectionInset = UIEdgeInsetsMake(0, 0, itemWidth - 10, 0);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowlayout];
        _collectionView.backgroundColor = QM_RGB(238, 238, 238);
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[QMChatFaceCell class] forCellWithReuseIdentifier:NSStringFromClass([QMChatFaceCell self])];
    }
    return _collectionView;
}

- (UIView *)coverView {
    if (!_coverView) {
        _coverView = [[UIView alloc] init];
        _coverView.backgroundColor = QM_RGBA(238, 238, 238, 0.8);
        _coverView.layer.cornerRadius = 1.5;
        _coverView.clipsToBounds = YES;
    }
    return _coverView;
}

- (void)setButtonEnble:(BOOL)enable {
    self.deleteBtn.enabled = enable;
    self.sendBtn.enabled = enable;
}

- (void)inputViewDidChange:(NSNotification *)notif {
    NSString *text = (NSString *)notif.object;
    if ([text isKindOfClass:[NSString class]]) {
        if (text.length > 0) {
            self.deleteBtn.enabled = YES;
            self.sendBtn.enabled = YES;
        } else {
            self.deleteBtn.enabled = NO;
            self.sendBtn.enabled = NO;
        }
    }
}

- (UIButton *)sendBtn {
    if (!_sendBtn) {
        _sendBtn = [[UIButton alloc] init];
        [_sendBtn setTitle:QMUILocalizableString(button.send) forState:UIControlStateNormal];
        [_sendBtn setBackgroundImage:[UIImage imageFromColor:[UIColor colorWithHexString:QMColor_News_Custom]] forState:UIControlStateNormal];
        [_sendBtn setBackgroundImage:[UIImage imageFromColor:UIColor.whiteColor] forState:UIControlStateDisabled];
        [_sendBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_sendBtn setTitleColor:QM_RGB(153, 153, 153) forState:UIControlStateDisabled];
        _sendBtn.titleLabel.font = [UIFont fontWithName:QM_PingFangSC_Reg size:14];
        _sendBtn.layer.cornerRadius = 5;
        _sendBtn.clipsToBounds = YES;
        [_sendBtn addTarget:self action:@selector(sendAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendBtn;
}

- (UIButton *)deleteBtn {
    if (!_deleteBtn) {
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteBtn setImage:[UIImage imageNamed:QMChatUIImagePath(@"face_delete")] forState:UIControlStateNormal];
        [_deleteBtn setImage:[UIImage imageNamed:QMChatUIImagePath(@"face_delete_disable")] forState:UIControlStateDisabled];
        [_deleteBtn setBackgroundImage:[UIImage imageFromColor:UIColor.whiteColor] forState:UIControlStateNormal];
        [_deleteBtn setBackgroundImage:[UIImage imageFromColor:UIColor.whiteColor] forState:UIControlStateDisabled];

        _deleteBtn.layer.cornerRadius = 5;
        _deleteBtn.clipsToBounds = YES;
        [_deleteBtn addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteBtn;
}

- (void)sendAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(touchFaceSendBtn)]) {
        [self.delegate touchFaceSendBtn];
    }
}

- (void)deleteAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(touchFaceDeleteBtn)]) {
        [self.delegate touchFaceDeleteBtn];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QMChatFaceCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([QMChatFaceCell class]) forIndexPath:indexPath];
//    cell.backgroundColor = [UIColor orangeColor];
//    cell.layer.borderWidth = 2;
    QMChatEmoji *emoji = self.dataArray[indexPath.row];
    cell.imageView.image = emoji.image;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(touchFaceEmoji:)]) {
        QMChatEmoji *emoji = self.dataArray[indexPath.row];

        [self.delegate touchFaceEmoji:emoji];
    }
}

@end

@implementation QMChatFaceCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(self.contentView).offset(10);
            make.right.bottom.equalTo(self.contentView).offset(-10);
            
        }];
    }
    return self;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleToFill;
    }
    return _imageView;
}

@end


//
//  QMImageAttachmentCell.m
//  IMSDK
//
//  Created by wt on 2025/8/28.
//

#import "QMImageAttachmentCell.h"
#import "QMHeader.h"
#import <Masonry/Masonry.h>
#import <QMLineSDK/QMLineSDK.h>
#import <SDWebImage/SDWebImage.h>
#import "QMChatShowImageViewController.h"

static CGFloat itemSize(void) {
    // 计算每个图片项的尺寸（每行4个，间距8）
    return floorf((QMChatTextMaxWidth  - 26 - 16) / 4);
}

@interface QMImageAttachmentCell()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *imageCollectionView;
@property (nonatomic, copy) NSArray *imageArr;

@end

@implementation QMImageAttachmentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.imageArr = [NSArray array];
        [self createUI];
    }
    return self;
}

- (void)createUI {
    [self.contentView addSubview:self.imageCollectionView];
    [self.imageCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.contentView);
        make.width.mas_greaterThanOrEqualTo(0);
        make.height.mas_equalTo(0);
    }];
}

- (void)setData:(NSArray *)imageArray {
    self.imageArr = imageArray;
    
    CGFloat imageRow = self.imageArr.count/4+(self.imageArr.count%4 > 0 ? 1 : 0);
    CGFloat imageHeight = imageRow * itemSize() + (imageRow > 1 ? (imageRow-1)*8 : 0) + (self.imageArr.count > 0 ? 8 : 0);
    CGFloat imageWidth = self.imageArr.count > 3 ? QMChatTextMaxWidth : (self.imageArr.count*itemSize()+self.imageArr.count*8);
    
    [self.imageCollectionView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.contentView);
        make.width.mas_greaterThanOrEqualTo(imageWidth);
        make.height.mas_equalTo(imageHeight);
    }];
    
    [self.imageCollectionView setHidden:self.imageArr.count == 0];
    
    [self.imageCollectionView reloadData];
    [self.imageCollectionView layoutIfNeeded];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageArr.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QMLeaveImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(QMLeaveImageCell.class) forIndexPath:indexPath];
    cell.urlStr = self.imageArr[indexPath.row][@"agentUrl"];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
}

- (UICollectionView *)imageCollectionView {
    if (!_imageCollectionView) {
        QMLeftAlignedFlowLayout *layout = [[QMLeftAlignedFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.minimumLineSpacing = 8;
        layout.minimumInteritemSpacing = 8;
        layout.sectionInset = UIEdgeInsetsZero;
        layout.itemSize = CGSizeMake(itemSize(), itemSize());
        _imageCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _imageCollectionView.showsHorizontalScrollIndicator = NO;
        _imageCollectionView.showsVerticalScrollIndicator = NO;
        _imageCollectionView.backgroundColor = [UIColor clearColor];
        [_imageCollectionView setScrollEnabled:NO];
        _imageCollectionView.delegate = self;
        _imageCollectionView.dataSource = self;
        _imageCollectionView.contentInset = UIEdgeInsetsZero;
        [_imageCollectionView registerClass:QMLeaveImageCell.class forCellWithReuseIdentifier:NSStringFromClass(QMLeaveImageCell.class)];
    }
    return _imageCollectionView;
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


@interface QMLeaveImageCell()

@property (nonatomic, strong) SDAnimatedImageView *showImageView;

@end


@implementation QMLeaveImageCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.showImageView];
        [self.showImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
    }
    return self;
}

- (void)tapRecognizerAction {
    QMChatShowImageViewController * showPicVC = [[QMChatShowImageViewController alloc] init];
    showPicVC.imageUrl = self.urlStr;
    showPicVC.image = self.showImageView.image;
    showPicVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:showPicVC animated:true completion:nil];
}

- (void)setUrlStr:(NSString *)urlStr {
    _urlStr = urlStr;
    if ([urlStr.stringByRemovingPercentEncoding isEqualToString:urlStr]) {
        urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    }
    NSURL *url = [NSURL URLWithString:urlStr ? : @"" ];
    [self.showImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:QMChatUIImagePath(@"chat_image_placeholder")]];
}

- (SDAnimatedImageView *)showImageView {
    if (!_showImageView) {
        _showImageView = [[SDAnimatedImageView alloc] init];
        _showImageView.contentMode = UIViewContentModeScaleAspectFill;
        _showImageView.userInteractionEnabled = YES;
        _showImageView.clipsToBounds = YES;
        [_showImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognizerAction)]];
    }
    return  _showImageView;
}

@end


@interface QMLeftAlignedFlowLayout()
 
@end

@implementation QMLeftAlignedFlowLayout

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    // 1. 获取父类布局属性并复制（避免缓存冲突）
    NSArray *originalAttributes = [super layoutAttributesForElementsInRect:rect];
    NSMutableArray *attributes = [[NSMutableArray alloc] initWithArray:originalAttributes copyItems:YES]; // [[2, 5]]
    
    // 2. 初始化变量
    CGFloat leftMargin = self.sectionInset.left; // 起始左间距
    CGFloat currentY = -1; // 当前行Y坐标标记
    
    // 3. 遍历所有属性
    for (UICollectionViewLayoutAttributes *attribute in attributes) {
        // 仅处理Cell类型（排除Supplementary Views）
        if (attribute.representedElementCategory != UICollectionElementCategoryCell) continue; // [[6]]
        
        // 4. 检测换行：Y坐标变化时重置左间距
        if (CGRectGetMinY(attribute.frame) != currentY) {
            leftMargin = self.sectionInset.left; // [[5, 6, 13]]
            currentY = CGRectGetMinY(attribute.frame);
        }
        
        // 5. 修改Cell的X坐标
        CGRect frame = attribute.frame;
        frame.origin.x = leftMargin;
        attribute.frame = frame;
        
        // 6. 更新左间距（当前Cell宽度 + 间距）
        leftMargin += CGRectGetWidth(frame) + self.minimumInteritemSpacing; // [[5, 6, 13]]
    }
    return attributes;
}

@end

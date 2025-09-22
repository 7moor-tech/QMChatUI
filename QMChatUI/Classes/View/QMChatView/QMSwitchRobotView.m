//
//  QMSwitchRobotView.m
//  IMSDK
//
//  Created by 焦林生 on 2023/3/10.
//

#import "QMSwitchRobotView.h"
#import "QMHeader.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <Masonry/Masonry.h>
#import <QMLineSDK/QMLineSDK.h>

@interface QMSwitchRobotView ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) CGFloat titleHeight;

@end

@implementation QMSwitchRobotView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        self.frame = CGRectMake(0, 0, QM_kScreenWidth, kScreenAllHeight);
        [self setupView];
    }
    return  self;
}


- (void)setDarkModeColor {
//    _collectionView.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_Main_Bg_Dark : QMColor_Main_Bg_Light];
//    [_collectionView reloadData];
}

- (void)setupView {
    
    self.titleHeight = [QMLabelText calculateTextHeight:QMLoginManager.shared.switchRobotTip fontName:QM_PingFangSC_Med fontSize:15 maxWidth:QM_kScreenWidth-85];
    self.bottomView = [[UIView alloc]initWithFrame:(CGRect){10,CGRectGetHeight(self.frame),QM_kScreenWidth-20,130+self.titleHeight}];;
    self.bottomView.backgroundColor = [UIColor whiteColor];
    self.bottomView.QMCornerRadius = 8;
    [self addSubview:self.bottomView];
    
    UILabel *titleTip = [[UILabel alloc] init];
    titleTip.text = QMLoginManager.shared.switchRobotTip;
    titleTip.textColor = [UIColor blackColor];
    titleTip.numberOfLines = 0;
    titleTip.font = QMFont_Medium(15);
    [self.bottomView addSubview:titleTip];
    [titleTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-45);
        make.top.mas_equalTo(14);
    }];
    
    UIButton *cancelBtn = [[UIButton alloc] init];
    cancelBtn.titleLabel.font = [UIFont fontWithName:QM_PingFangSC_Reg size:16];
    [cancelBtn setImage:[UIImage imageNamed:QMChatUIImagePath(@"qm_common_cancel")] forState:UIControlStateNormal];
//    [cancelBtn setTitle:@"X" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor colorWithHexString:isDarkStyle ? QMColor_D5D5D5_text : QMColor_666666_text] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:cancelBtn];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(15);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    
    UIView *segView = [[UIView alloc] init];
    segView.backgroundColor = [UIColor colorWithHexString:@"#E8E8E8"];
    [self.bottomView addSubview:segView];
    [segView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleTip.mas_bottom).offset(12);
        make.centerX.equalTo(self.bottomView);
        make.size.mas_equalTo(CGSizeMake(QM_kScreenWidth-40, 1));
    }];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 2;
    layout.minimumInteritemSpacing = 2;
//    layout.sectionInset = UIEdgeInsetsMake(8, 10, 8, 10);
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor colorWithHexString: QMColor_Nav_Bg_Light];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.collectionView registerClass:[QMSwitchRobotCell class] forCellWithReuseIdentifier:NSStringFromClass([QMSwitchRobotCell class])];
    [self.bottomView addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.top.equalTo(segView.mas_bottom).offset(14);
        make.size.mas_equalTo(CGSizeMake(QM_kScreenWidth-40, 70));
    }];
}

- (void)setDataArray:(NSArray *)dataArray {
    _dataArray = dataArray;
    [self.collectionView reloadData];
}

- (void)cancelAction:(UIButton *)action{
    if (self.tapCancelBlock) {
        self.tapCancelBlock();
    }
    [self dismissView];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.tapCancelBlock) {
        self.tapCancelBlock();
    }
    [self dismissView];
}

- (void)showView {
    
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [[UIApplication sharedApplication].keyWindow addSubview:self.bottomView];

    self.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        self.bottomView.transform = CGAffineTransformMakeTranslation(0, -(kSafeArea+130+self.titleHeight));
        self.alpha = 0.5;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dismissView{
    [UIView animateWithDuration:0.3 animations:^{
        self.bottomView.transform = CGAffineTransformIdentity;
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [self.bottomView removeFromSuperview];
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QMSwitchRobotCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([QMSwitchRobotCell class]) forIndexPath:indexPath];
    [cell setupData:self.dataArray[indexPath.row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *tempDict = self.dataArray[indexPath.item];
    if (self.tapSwitchRobot) {
        self.tapSwitchRobot(tempDict[@"switchRobotId"],tempDict[@"switchRobotName"]);
    }
    [self dismissView];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    return CGSizeMake(82, 70);
}

@end

@implementation QMSwitchRobotCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
    }
    return self;
}

- (void)createUI {
    
    self.imgView = [[UIImageView alloc] init];
    self.imgView.QMCornerRadius = 24;
    [self.contentView addSubview:self.imgView];
    
    self.titleLab = [[UILabel alloc] init];
    self.titleLab.textColor = [UIColor colorWithHexString:QMColor_666666_text];
    self.titleLab.font = [UIFont systemFontOfSize:14];
    self.titleLab.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.titleLab];
    
    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView);
        make.centerX.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(48, 48));
    }];
    
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.contentView);
        make.height.mas_equalTo(20);
    }];
}

- (void)setupData:(NSDictionary *)dict {
    NSString *url = [dict[@"switchRobotImg"] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self.imgView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:QMChatUIImagePath(@"qm_default_robot")]];
    self.titleLab.text = dict[@"switchRobotName"];
}


@end

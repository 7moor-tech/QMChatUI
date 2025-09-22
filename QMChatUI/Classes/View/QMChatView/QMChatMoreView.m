//
//  QMChatMoreView.m
//  IMSDK
//
//  Created by lishuijiao on 2020/10/13.
//

#import "QMChatMoreView.h"
#import "QMHeader.h"
#import <QMLineSDK/QMLineSDK.h>
#import <Masonry/Masonry.h>

#define moreBtnWidht 60

@interface QMChatMoreView () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *rootView;
@property (nonatomic, strong) NSMutableArray <QMChatMoreModel *>*dataArray;
@end

@implementation QMChatMoreView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

        [self layoutViews];
    }
    return self;
}

- (QMChatMoreModel *)getChatMoreItem:(QMChatMoreMode)mode {
    QMChatMoreModel *model = [QMChatMoreModel new];
    model.mode = mode;
    
    switch (mode) {
        case QMChatMoreModePicture:
            model.image_name = @"ToolBar_Picture";
            model.name = QMUILocalizableString(button.chat_img);
            break;
        case QMChatMoreModeCamera:
            model.image_name = @"QM_ToolBar_Camera";
            model.name = QMUILocalizableString(button.chat_camera);
            break;
        case QMChatMoreModeFile:
            model.image_name = @"QM_ToolBar_File";
            model.name = QMUILocalizableString(button.chat_file);
            break;
        case QMChatMoreModeQuestion:
            model.image_name = @"QM_ToolBar_Question";
            model.name = QMUILocalizableString(button.chat_question);
            break;
        case QMChatMoreModeEvaluate:
            model.image_name = @"QM_ToolBar_Evaluate";
            model.name = QMUILocalizableString(button.chat_evaluate);
            break;
        case QMChatMoreModeVideo:
            model.image_name = @"QM_ToolBar_Video";
            model.name = QMUILocalizableString(button.chat_video);
            break;

        default:
            break;
    }
    return model;
}

- (void)layoutViews {

    self.dataArray = [NSMutableArray array];

    QMLoginManager *uiModel = QMLoginManager.shared;

    if (uiModel.isRobot == true) {
        if (uiModel.isShowCameraByRobotBtn == YES ) {
            QMChatMoreModel *pictModel = [self getChatMoreItem:QMChatMoreModeCamera];
            [self.dataArray addObject:pictModel];
        }
        if (uiModel.isShowPictureByRobotBtn == YES) {
            QMChatMoreModel *pictModel = [self getChatMoreItem:QMChatMoreModePicture];
            [self.dataArray addObject:pictModel];
        }
        if (uiModel.isShowFileByRobotBtn == YES) {
            QMChatMoreModel *pictModel = [self getChatMoreItem:QMChatMoreModeFile];
            [self.dataArray addObject:pictModel];
        }
        
        if (uiModel.isShowQuestionByRobotBtn == YES) {
            QMChatMoreModel *pictModel = [self getChatMoreItem:QMChatMoreModeQuestion];
            [self.dataArray addObject:pictModel];
        }
        
        if (uiModel.isShowEvaluateBtn == YES && QMLoginManager.shared.isEvaluate == NO) {
            QMChatMoreModel *pictModel = [self getChatMoreItem:QMChatMoreModeEvaluate];
            [self.dataArray addObject:pictModel];
        }
        
    }else{
        
        
        
        if (self.dataArray.count == 0) {
            
            if (uiModel.isShowCameraBtn == YES) {
                QMChatMoreModel *pictModel = [self getChatMoreItem:QMChatMoreModeCamera];
                [self.dataArray addObject:pictModel];
            }
            
            if (uiModel.isShowPictureBtn == YES) {
                QMChatMoreModel *pictModel = [self getChatMoreItem:QMChatMoreModePicture];
                [self.dataArray addObject:pictModel];
            }
            
            if (uiModel.isShowFileBtn == YES) {
                QMChatMoreModel *pictModel = [self getChatMoreItem:QMChatMoreModeFile];
                [self.dataArray addObject:pictModel];
            }
            
            if (uiModel.isShowQuestionBtn == YES) {
                QMChatMoreModel *pictModel = [self getChatMoreItem:QMChatMoreModeQuestion];
                [self.dataArray addObject:pictModel];
            }
            
            if ([QMConnect sdkVideoRights] == YES) {
                QMChatMoreModel *pictModel = [self getChatMoreItem:QMChatMoreModeVideo];
                [self.dataArray addObject:pictModel];
            }
            
            if (QMLoginManager.shared.isEvaluate == NO) {
                
                if (uiModel.isEvaluateRound == YES && uiModel.isRobot == false) {
                    if (uiModel.currentEvaluateRound + 1 > uiModel.evaluateRound) {
                        QMChatMoreModel *pictModel = [self getChatMoreItem:QMChatMoreModeEvaluate];
                        [self.dataArray addObject:pictModel];
                    }
                    
                }
                
//                if (uiModel.isShowEvaluateBtn == YES && uiModel.isRobot == true) {
//                    QMChatMoreModel *pictModel = [self getChatMoreItem:QMChatMoreModeEvaluate];
//                    [self.dataArray addObject:pictModel];
//                }
            }
            
        }
    }
            
    UICollectionViewFlowLayout *flowlayout = [UICollectionViewFlowLayout new];
    flowlayout.itemSize = CGSizeMake(60, 60 + 12 + 12);
    flowlayout.sectionInset = UIEdgeInsetsMake(15, 30, 15, 30);
    flowlayout.minimumLineSpacing = 14;
    flowlayout.minimumInteritemSpacing = 24;
    self.rootView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowlayout];
    self.rootView.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_1E1E1E_BG : QMColor_F6F6F6_BG];
    [self.rootView registerClass:UICollectionViewCell.class forCellWithReuseIdentifier:@"cell_id"];
    self.rootView.dataSource = self;
    self.rootView.delegate = self;
    [self addSubview:self.rootView];

}

- (void)refreshMoreBtn {
    [self layoutViews];
    [self.rootView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell_id" forIndexPath:indexPath];
    UILabel *lab = (UILabel *)[cell.contentView viewWithTag:200];
    UIImageView *image = (UIImageView *)[cell.contentView viewWithTag:199];
    if (!image) {
        image = [UIImageView new];
        image.contentMode = UIViewContentModeScaleAspectFit;
        image.tag = 199;
        [cell.contentView addSubview:image];
        [image mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(cell.contentView);
            make.height.width.mas_equalTo(60);
            make.centerX.equalTo(cell.contentView);
        }];
    }
    
    if (!lab) {
        lab = [UILabel new];
        lab.tag = 200;
        lab.textColor = QM_RGB(109, 109, 109);
        lab.font = [UIFont fontWithName:QM_PingFangSC_Reg size:12];
        lab.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:lab];
        [lab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(cell.contentView);
            make.top.equalTo(image.mas_bottom).offset(10);
        }];
    }
    
    QMChatMoreModel *model = self.dataArray[indexPath.row];
    lab.text = model.name;
    image.image = [UIImage imageNamed:QMChatUIImagePath(model.image_name)];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    QMChatMoreModel *model = self.dataArray[indexPath.row];
    if ([self.delegate respondsToSelector:@selector(moreViewSelectAcitonIndex:)]) {
        [self.delegate moreViewSelectAcitonIndex:model.mode];
    }
}


@end

@implementation QMChatMoreModel



@end

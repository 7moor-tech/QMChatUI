//
//  QMPickedPhotoViewController.m
//  IMSDK-OC
//
//  Created by HCF on 16/8/11.
//  Copyright © 2016年 HCF. All rights reserved.
//

#import "QMPickedPhotoViewController.h"
#import "QMHeader.h"
#import "QMFileCollectionCell.h"
#import <Photos/Photos.h>
#import "QMFileTabbarView.h"
#import "UIScrollView+EmptyData.h"

@interface QMPickedPhotoViewController ()<UICollectionViewDelegate, UICollectionViewDataSource> {
    UICollectionView *_collectionView;
    PHFetchResult *_photoAssets;
    PHCachingImageManager *_cacheManager;
    
    QMFileTabbarView *_tabbarView;
    CGFloat _navHeight;
}

@property (nonatomic, strong) NSMutableSet *pickedImageSet;

@end

@implementation QMPickedPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    CGRect StatusRect = [[UIApplication sharedApplication] statusBarFrame];
    CGRect NavRect = self.navigationController.navigationBar.frame;
    _navHeight = StatusRect.size.height + NavRect.size.height;

    _cacheManager = [[PHCachingImageManager alloc] init];
    self.pickedImageSet = [[NSMutableSet alloc] init];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake((QM_kScreenWidth-6)/3, (QM_kScreenWidth-6)/3);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.sectionInset = UIEdgeInsetsMake(0, 1, 0, 1);
    layout.minimumLineSpacing = 2.0;
    layout.minimumInteritemSpacing = 1.0;
    layout.headerReferenceSize = CGSizeMake(0, 0);

    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, QM_kScreenWidth, QM_kScreenHeight-_navHeight-44) collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [self.view addSubview:_collectionView];
    [_collectionView registerClass:[QMFileCollectionCell self] forCellWithReuseIdentifier:NSStringFromClass(QMFileCollectionCell.self)];

    _tabbarView = [[QMFileTabbarView alloc] init];
    _tabbarView.frame = CGRectMake(0, QM_kScreenHeight-44-_navHeight, QM_kScreenWidth, 44);
    [self.view addSubview:_tabbarView];
    
    __weak QMPickedPhotoViewController *strongSelf = self;
    _tabbarView.selectAction = ^{
        Class chatRoomClass = NSClassFromString(@"QMChatRoomViewController");
        Class ChatGuestBookClass = NSClassFromString(@"QMChatGuestBookViewController");
        UIViewController *targetVC1 = nil;
        UIViewController *targetVC2 = nil;
        for (UIViewController *vc in strongSelf.navigationController.viewControllers) {
            if ([vc isKindOfClass:chatRoomClass]) {
                targetVC1 = vc;
            }
            if ([vc isKindOfClass:ChatGuestBookClass]) {
                targetVC2 = vc;
            }
        }
        
        if (targetVC2) {
            [strongSelf.navigationController popToViewController:targetVC2 animated:YES];
        } else if (targetVC1) {
            [strongSelf.navigationController popToViewController:targetVC1 animated:YES];
        } else {
            [strongSelf.navigationController popViewControllerAnimated:YES];
        }
        for (PHAsset *asset in strongSelf.pickedImageSet) {
            [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                NSString *photoPath = [[info objectForKey:@"PHImageFileURLKey"] absoluteString];
                NSArray *array = [photoPath componentsSeparatedByString:@"/"];
                
                NSString *name = array.lastObject;
                if (!name && name.length == 0) {
                    NSString *uuid = [[[NSUUID UUID] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
                    name = [NSString stringWithFormat:@"%@%@",uuid,dataUTI];
                }
                
                NSString *fileSize = [imageData length]<1024*1024 ? [NSString stringWithFormat:@"%d KB", (int)([imageData length]/1024.0)] : [NSString stringWithFormat:@"%d MB", (int)([imageData length]/1024.0/1024)];
                
                NSString * filePath = [NSString stringWithFormat:@"%@/%@", NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0], name];
                // 写入sendVideo文件夹
                [imageData writeToFile:filePath atomically:YES];
                if (strongSelf.callBackBlock) {
                    strongSelf.callBackBlock(name, fileSize, name);
                }
            }];
        }
        
//        for (UIViewController *viewController in strongSelf.navigationController.viewControllers) {
//            if ([viewController isKindOfClass:chatRoomClass]) {
//                [strongSelf.navigationController popToViewController:viewController animated:true];
//
//                for (PHAsset *asset in strongSelf.pickedImageSet) {
//
//
////                        if (@available(iOS 13, *)) {
////                            [[PHImageManager defaultManager] requestImageDataAndOrientationForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, CGImagePropertyOrientation orientation, NSDictionary * _Nullable info) {
////
////                                NSString *photoPath = [[info objectForKey:@"PHImageFileURLKey"] absoluteString];
////                                NSArray *array = [photoPath componentsSeparatedByString:@"/"];
////                                NSString *name = array.lastObject;
////                                if (!name && name.length == 0) {
////                                    NSString *uuid = [[[NSUUID UUID] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
////                                    name = [NSString stringWithFormat:@"%@%@",uuid,dataUTI];
////                                }
////                                NSString *fileSize = [imageData length]<1024*1024 ? [NSString stringWithFormat:@"%d KB", (int)([imageData length]/1024.0)] : [NSString stringWithFormat:@"%d MB", (int)([imageData length]/1024.0/1024)];
////
////                                NSString * filePath = [NSString stringWithFormat:@"%@/%@", NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0], name];
////                                // 写入sendVideo文件夹
////                                [imageData writeToFile:filePath atomically:YES];
////
////                                [tagViewController sendFileMessageWithName:name AndSize:fileSize AndPath:name];
////                            }];
////                        } else {
//                            // Fallback on earlier versions
//
//                            [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
//                                NSString *photoPath = [[info objectForKey:@"PHImageFileURLKey"] absoluteString];
//                                NSArray *array = [photoPath componentsSeparatedByString:@"/"];
//
//                                NSString *name = array.lastObject;
//                                if (!name && name.length == 0) {
//                                    NSString *uuid = [[[NSUUID UUID] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
//                                    name = [NSString stringWithFormat:@"%@%@",uuid,dataUTI];
//                                }
//
//                                NSString *fileSize = [imageData length]<1024*1024 ? [NSString stringWithFormat:@"%d KB", (int)([imageData length]/1024.0)] : [NSString stringWithFormat:@"%d MB", (int)([imageData length]/1024.0/1024)];
//
//                                NSString * filePath = [NSString stringWithFormat:@"%@/%@", NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0], name];
//                                // 写入sendVideo文件夹
//                                [imageData writeToFile:filePath atomically:YES];
//                                if (strongSelf.callBackBlock) {
//                                    strongSelf.callBackBlock(name, fileSize, name);
//                                }
////                                if (strongSelf.isForm) {
////                                    if (strongSelf.callBackBlock) {
////                                        strongSelf.callBackBlock(name, fileSize, name);
////                                    }
////                                }else {
////                                    [tagViewController sendFileMessageWithName:name AndSize:fileSize AndPath:name];
////                                }
//                            }];
////                        }
//                }
//            }
//        }
    };
    
    dispatch_async(dispatch_get_main_queue(), ^{
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        
        self->_photoAssets = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];
        [self->_collectionView reloadData];
    });
}

- (void)dealloc {
    
}

#pragma mark - CollectionViewDelegate CollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSUInteger count = _photoAssets ? _photoAssets.count : 0;
    if (count == 0) {
//        [_collectionView showEmptyMessage:QMUILocalizableString(file.emptyTip1)];
        [_collectionView showEmptyMessage:@"没有检索到文件"];
    }else {
        [_collectionView hideEmptyMessage];
    }
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QMFileCollectionCell * cell = (QMFileCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(QMFileCollectionCell.self) forIndexPath:indexPath];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell isKindOfClass:[QMFileCollectionCell class]]) {
        QMFileCollectionCell *displayCell = (QMFileCollectionCell *)cell;
        displayCell.imageManager = _cacheManager;
        if (_photoAssets) {
            PHAsset * asset = _photoAssets[indexPath.item];
            displayCell.imageAsset = asset;
            displayCell.pickedItemImageView.hidden = ![self.pickedImageSet containsObject:asset];
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_photoAssets) {
        PHAsset *asset = _photoAssets[indexPath.item];
        if ([self.pickedImageSet containsObject:asset]) {
            [self.pickedImageSet removeObject:asset];
        }else {
            if (self.pickedImageSet.count>0) {
                return;
            }
            [self.pickedImageSet addObject:asset];
        }
        
        QMFileCollectionCell * cell = (QMFileCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
        cell.pickedItemImageView.hidden = ![self.pickedImageSet containsObject:asset];
    }
    
    if (self.pickedImageSet.count>0) {
        _tabbarView.doneButton.selected = YES;
    }else {
        _tabbarView.doneButton.selected = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

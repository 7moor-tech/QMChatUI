//
//  QMFileCollectionCell.m
//  IMSDK-OC
//
//  Created by HCF on 16/8/11.
//  Copyright © 2016年 HCF. All rights reserved.
//

#import "QMFileCollectionCell.h"
#import "QMHeader.h"

@interface QMFileCollectionCell () {
    UIImageView *_photoImageView;
}

@end

@implementation QMFileCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
    }
    return self;
}

- (void)createUI {
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    _photoImageView = [[UIImageView alloc] init];
    _photoImageView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    [self.contentView addSubview:_photoImageView];
    
    self.pickedItemImageView = [[UIImageView alloc] init];
    self.pickedItemImageView.frame = CGRectMake(self.bounds.size.width-35, 5, 25, 25);
    self.pickedItemImageView.image = [UIImage imageNamed:QMUIComponentImagePath(@"ic_checkbox_pressed")];
    [self.contentView addSubview:self.pickedItemImageView];
    
}

- (void)setImageAsset:(PHAsset *)imageAsset {
    if (imageAsset) {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.synchronous = YES;
        options.version = PHImageRequestOptionsVersionCurrent;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.resizeMode = PHImageRequestOptionsResizeModeExact;
        options.networkAccessAllowed = YES;
        
        [self.imageManager requestImageForAsset:imageAsset targetSize:CGSizeMake(120, 120) contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            self->_photoImageView.image = result;
        }];
    }
}

@end

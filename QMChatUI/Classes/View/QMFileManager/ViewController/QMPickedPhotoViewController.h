//
//  QMPickedPhotoViewController.h
//  IMSDK-OC
//
//  Created by HCF on 16/8/11.
//  Copyright © 2016年 HCF. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^FileCallBackBlock)(NSString *name, NSString * size, NSString * path);

@interface QMPickedPhotoViewController : UIViewController

@property (nonatomic, copy)FileCallBackBlock callBackBlock;

@property (nonatomic, assign)BOOL isForm;

@end

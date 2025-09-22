//
//  QMPickedOtherViewController.h
//  IMSDK-OC
//
//  Created by HCF on 16/8/10.
//  Copyright © 2016年 HCF. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^FileCallBackBlock)(NSString *name, NSString * size, NSString *path);

@interface QMPickedOtherViewController : UIViewController

@property (nonatomic, copy) FileCallBackBlock callBackBlock;

@property (nonatomic, assign)BOOL isForm;


@end

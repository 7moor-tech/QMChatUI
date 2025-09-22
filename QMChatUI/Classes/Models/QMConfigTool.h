//
//  QMConfigTool.h
//  IMSDK
//
//  Created by 焦林生 on 2023/1/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QMConfigTool : NSObject

+ (NSArray *)getTagList;

+ (NSString *)getRemarks;

+ (BOOL)isMultiple;

+ (BOOL)isOpenTaglist;

+ (BOOL)isOpenTipContent;

+ (id)getBeginSessionConfigValue:(NSString *)key;

@end

NS_ASSUME_NONNULL_END

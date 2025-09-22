//
//  QMConfigTool.m
//  IMSDK
//
//  Created by 焦林生 on 2023/1/13.
//

#import "QMConfigTool.h"

@implementation QMConfigTool
//标签
+ (NSArray *)getTagList {
    id tagArr = [QMConfigTool getBeginSessionConfigValue:@"taglist"];
    if ([tagArr isKindOfClass:[NSArray class]]) {
        return tagArr;
    } else {
        return nil;
    }
}
//点踩自定义原因
+ (NSString *)getRemarks {
    id remark = [QMConfigTool getBeginSessionConfigValue:@"remarks"];
    if ([remark isKindOfClass:[NSString class]]) {
        return remark;
    } else {
        return @"";
    }
}
//是否多选
+ (BOOL)isMultiple {
    id choice = [QMConfigTool getBeginSessionConfigValue:@"enable_multiple_choice"];
    if ([choice isKindOfClass:[NSString class]]) {
        if ([choice isEqualToString:@"1"]) {
            return true;
        }else {
            return false;
        }
    }else if ([choice isKindOfClass:[NSNumber class]]) {
        if ([choice isEqualToNumber:[NSNumber numberWithInt:1]]) {
            return true;
        }else {
            return false;
        }
    }else {
        if ([choice boolValue] == YES) {
            return true;
        }else if ([choice boolValue] == NO){
            return false;
        }else {
            return true;
        }
    }
}
//点踩标签是否开启
+ (BOOL)isOpenTaglist {
    id isopen = [QMConfigTool getBeginSessionConfigValue:@"enable_taglist"];
    if ([isopen isKindOfClass:[NSString class]]) {
        if ([isopen isEqualToString:@"1"]) {
            return true;
        }else {
            return false;
        }
    }else if ([isopen isKindOfClass:[NSNumber class]]) {
        if ([isopen isEqualToNumber:[NSNumber numberWithInt:1]]) {
            return true;
        }else {
            return false;
        }
    }else {
        if ([isopen boolValue] == YES) {
            return true;
        }else if ([isopen boolValue] == NO){
            return false;
        }else {
            return true;
        }
    }
}
//自定义原因是否开启
+ (BOOL)isOpenTipContent {
    id isopen = [QMConfigTool getBeginSessionConfigValue:@"enable_remarks"];
    if ([isopen isKindOfClass:[NSString class]]) {
        if ([isopen isEqualToString:@"1"]) {
            return true;
        }else {
            return false;
        }
    }else if ([isopen isKindOfClass:[NSNumber class]]) {
        if ([isopen isEqualToNumber:[NSNumber numberWithInt:1]]) {
            return true;
        }else {
            return false;
        }
    }else {
        if ([isopen boolValue] == YES) {
            return true;
        }else if ([isopen boolValue] == NO){
            return false;
        }else {
            return true;
        }
    }
}

# pragma maek --
+ (id)getBeginSessionConfigValue:(NSString *)key {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *doc = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    if (![fileManager fileExistsAtPath:[doc stringByAppendingPathComponent:@"chatSession.plist"]]) {
        return nil;
    }
    
    NSDictionary *configs = [NSDictionary dictionaryWithContentsOfFile:[doc stringByAppendingPathComponent:@"chatSession.plist"]];
    
    if (!configs) {
        return nil;
    }
    
    return [configs objectForKey:key];
}

@end

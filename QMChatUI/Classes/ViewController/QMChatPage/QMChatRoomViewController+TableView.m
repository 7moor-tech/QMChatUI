//
//  QMChatRoomViewController+TableView.m
//  IMSDK
//
//  Created by 焦林生 on 2022/1/10.
//

#import "QMChatRoomViewController+TableView.h"
#import "QMChatRoomViewController+ChatMessage.h"
#import "QMLogistsMoreView.h"
#import "QMChatRobotCell.h"
#import "QMChatRobotFlowCell.h"
#import "QMChatTextCell.h"
#import "QMChatImageCell.h"
#import "QMChatVoiceCell.h"
#import "QMChatFileCell.h"
#import "QMChatNoteCell.h"
#import "QMChatCardCell.h"
#import "QMChatNewCardCell.h"
#import "QMChatRichTextCell.h"
#import "QMChatCallCell.h"
#import "QMChatCommonProblemCell.h"
#import "QMChatFormCell.h"
#import "QMWXCardCell.h"
#import "QMChatLogistcsInfoCell.h"
#import "QMChatRoomXbotCardCell.h"
#import "QMChatListCardCell.h"
#import "QMChatRobotReplyCell.h"
#import "QMTipMessageCell.h"
#import "QMHeader.h"
#import "QMChatVideoCell.h"
#import "QMChatRobotButtonCell.h"
#import "QMChatLeaveCell.h"
#import "QMFileDownloadViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
@implementation QMChatRoomViewController (TableView)

#pragma mark ------- tableViewDelegate ---------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomMessage * message = self.dataArray[self.dataArray.count-indexPath.row-1];
    NSString *identifier = @"";
    if ([message.messageType isEqualToString:@"text"]) {
        if ([message.isRobot isEqualToString:@"1"]) {
            if ([message.isRobot isEqualToString:@"1"] && ![message.questionId isEqualToString:@""]) {
                identifier = NSStringFromClass([QMChatRobotReplyCell class]);//带机器人评价
            } else {
                if ([message.contactPushed isEqualToString:@"1"]) {
                    identifier = NSStringFromClass([QMChatRobotButtonCell class]);//获取二维码
                } else {
                    identifier = NSStringFromClass([QMChatRobotCell class]);
                }
            }
            
        }else if ([message.isRobot isEqualToString:@"2"]) {
            if ([message.robotFlowsStyle isEqualToString:@"2"]) {
                identifier = NSStringFromClass([QMChatRobotCell class]);
            }else {
                identifier = NSStringFromClass([QMChatRobotFlowCell class]);
            }
        } else if (message.showHtml == YES) {
            identifier = NSStringFromClass([QMChatRobotCell class]);//机器人消息
        }
        else {
            identifier = NSStringFromClass([QMChatTextCell class]);//文本消息
        }
    }else if ([message.messageType isEqualToString:@"image"]) {
        identifier = NSStringFromClass([QMChatImageCell class]);//图片消息
    }else if ([message.messageType isEqualToString:@"voice"]) {
        identifier = NSStringFromClass([QMChatVoiceCell class]);//语音消息
    }else if ([message.messageType isEqualToString:@"file"]) {
        NSString *fileName = message.fileName.pathExtension.lowercaseString;
        if ([fileName isEqualToString:@"mov"]||[fileName isEqualToString:@"mp4"]||[fileName isEqualToString:@"m4v"]) {
            identifier = NSStringFromClass([QMChatVideoCell class]);//视频消息
        }else if ([fileName isEqualToString:@"png"]||[fileName isEqualToString:@"jpg"]||[fileName isEqualToString:@"bmp"]||[fileName isEqualToString:@"jpeg"]||[fileName isEqualToString:@"heic"]||[fileName isEqualToString:@"webp"]||[fileName isEqualToString:@"gif"]) {
            identifier = NSStringFromClass([QMChatImageCell class]);
        } else {
            identifier = NSStringFromClass([QMChatFileCell class]);//文件消息
        }
    }else if ([message.messageType isEqualToString:@"Leave"]) {
        identifier = NSStringFromClass([QMChatLeaveCell class]);//留言消息
    }else if ([message.messageType isEqualToString:@"card"]) {
        identifier = NSStringFromClass([QMChatCardCell class]);//普通卡片
    }else if ([message.messageType isEqualToString:@"cardInfo"]) {
        identifier = NSStringFromClass([QMChatRichTextCell class]);//消息卡片链接(富文本)
    }else if ([message.messageType isEqualToString:@"richText"]) {
        identifier = NSStringFromClass([QMChatRichTextCell class]);//知识库富文本
    }else if ([message.messageType isEqualToString:@"withdrawMessage"]) {
        identifier = NSStringFromClass([QMTipMessageCell class]);//撤回消息
    }else if ([message.messageType isEqualToString:@"cardInfo_New"]) {
        identifier = NSStringFromClass([QMChatCardCell class]); //带发送按钮的卡片
    }else if ([message.messageType isEqualToString:@"newCardInfo"]) {
        identifier = NSStringFromClass([QMChatNewCardCell class]);//卡片消息展示
    }else if ([message.messageType isEqualToString:@"video"]) {
        identifier = NSStringFromClass([QMChatCallCell class]);//视频消息
    }else if ([message.messageType isEqualToString:@"evaluate"]) {
        identifier = NSStringFromClass([QMChatNoteCell class]);//评价展示
    }else if ([message.messageType isEqualToString:@"NewPushQues"]) {
        identifier = NSStringFromClass([QMChatCommonProblemCell class]);//常见问题
    }else if ([message.messageType isEqualToString:@"xbotForm"]) {
        identifier = NSStringFromClass([QMChatFormCell class]);//表单消息
    }else if ([message.messageType isEqualToString:@"xbotFormSubmit"]) {
        identifier = NSStringFromClass([QMChatTextCell class]);
    }else if ([message.messageType isEqualToString:@"msgTask"]) {
        NSDictionary *dic = message.cardMsg_NewDict;
        if ([dic[@"resp_type"] intValue] == 1) {
            identifier = NSStringFromClass([QMChatLogistcsInfoCell class]);//物流消息
        } else {
            identifier = NSStringFromClass([QMChatRoomXbotCardCell class]);
        }
    }else if ([message.messageType isEqualToString:@"listCard"]) {
        identifier = NSStringFromClass([QMChatListCardCell class]);//流水布局的卡片消息
    }
    else{
        return UITableViewCell.new;
    }
    
//    QMLog(@"identifier = %@",identifier);
    
    QMChatBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [self createCellWithClassName:identifier cellModel:message indexPath:indexPath];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    if (indexPath.row>0) {
        CustomMessage * preMessage = self.dataArray[self.dataArray.count-indexPath.row];
        UInt64 disTime = message.createdTime.longLongValue - preMessage.createdTime.longLongValue;
        if (disTime<3*60*1000) {
            cell.timeLabel.hidden = YES;
        }else {
            cell.timeLabel.hidden = NO;
        }
    }else {
        cell.timeLabel.hidden = NO;
    }
    
    @weakify(self)
    if ([cell isKindOfClass:[QMChatLogistcsInfoCell class]]) {
        
        NSDictionary *dic = message.cardMsg_NewDict;
        NSDictionary *listDict = dic[@"data"];
        QMLogistcsInfoModel *model = [[QMLogistcsInfoModel alloc] initWithDictionary:listDict error:nil];

        QMChatLogistcsInfoCell *lcell = (QMChatLogistcsInfoCell *)cell;
        lcell.dataModel = model;
        QMLogistcsInfoModel *dataA = model;
        lcell.showMore = ^{
            @strongify(self)
            [self showMoreView:dataA];
        };
    }
    
    [cell setData:message avater:self.avaterStr];
    
    if ([cell isKindOfClass:[QMChatImageCell class]] ||
        [cell isKindOfClass: [QMChatRobotCell class]]) {
        cell.needReloadCell = ^(CustomMessage * _Nonnull model) {
            @strongify(self)
            [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                CustomMessage *item = obj;
                if ([item._id isEqualToString:model._id]) {
                    [self.chatTableView beginUpdates];
                    NSMutableArray *mutableArr = self.dataArray.mutableCopy;
                    [mutableArr replaceObjectAtIndex:idx withObject:model];
                    self.dataArray = mutableArr;
                    [self.chatTableView endUpdates];
                    
                    if (self.dataArray.count - 1 == indexPath.row) {
                        [self.chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];

                    }
                }
            }];
        };
        
        cell.contentStartEditBlock = ^(CGRect frameToView) {
            @strongify(self)
            
            //判断键盘弹出是否会遮挡当前编辑cell
            NSInteger offSet = frameToView.origin.y + frameToView.size.height - (self.view.frame.size.height - self.keyBoardFrame.size.height);
            
            if (offSet > 1) {
                offSet += self.lastContentOffset.y;
                [UIView animateWithDuration:0.4 animations:^{
                    self.chatTableView.contentOffset = CGPointMake(0, offSet);
                }];
            }
        };
    }
    
    if ([message.messageType isEqualToString:@"text"] || [message.messageType isEqualToString:@"Leave"]) {
        cell.tapNetAddress = ^(NSString *address) {
            if (![address hasPrefix:@"http"]) {
                address = [NSString stringWithFormat:@"http://%@", address];
            }

            NSString *str = [address stringByRemovingPercentEncoding];
            address = [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            NSURL *uRL = [NSURL URLWithString:address];
            [[UIApplication sharedApplication] openURL:uRL options:@{} completionHandler:nil];
        };
        
        cell.tapNumberAction = ^(NSString *number) {
            @strongify(self)
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"%@%@",number,QMUILocalizableString(title.mayBeNumber)] preferredStyle:UIAlertControllerStyleActionSheet];
            
            UIAlertAction *callAction = [UIAlertAction actionWithTitle:QMUILocalizableString(button.call) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSString *phone = [NSString stringWithFormat:@"tel://%@",number];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phone] options:@{} completionHandler:nil];
            }];
            
            UIAlertAction *copyAction = [UIAlertAction actionWithTitle:QMUILocalizableString(button.copy) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                // 复制文本消息
                UIPasteboard *pasteBoard =  [UIPasteboard generalPasteboard];
                pasteBoard.string = number;
            }];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:QMUILocalizableString(button.cancel) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }];
            
            [alertController addAction:callAction];
            [alertController addAction:copyAction];
            [alertController addAction:cancelAction];
            [self presentViewController:alertController animated:YES completion:nil];
        };
    }
    
    // 机器人消息可以选择问题代码 答案可以选择有帮助或无帮助
    if ([message.messageType isEqualToString:@"text"] && [message.isRobot isEqualToString:@"1"]) {
        cell.tapSendMessage = ^(NSString *text, NSString *num) {
            @strongify(self)
            if (message.robotFlowList.length) {
                NSMutableArray * arr = [QMLabelText dictionaryWithJsonString:message.robotFlowList];
                if (![num isEqualToString:@""]) {
                    int number = [num intValue] - 1;
                    NSString *mssg = arr[number][@"button"];
                    if ([mssg isEqualToString:text]) {
                        [self sendText:arr[number][@"text"]];
                    }else {
                        [self sendText:text];
                    }
                }else {
                    [self sendText:text];
                }
            }else {
                if (self.KFStatus == QMKFStatusRobot || self.KFStatus == QMKFStatusQueue) {
                    [self sendText:text];
                }
            }
        };

        cell.didBtnAction = ^(BOOL isUseful, NSString * _Nonnull tag, NSString * _Nonnull remark) {
            @strongify(self)
            if (!message.isUseful||
                [message.isUseful isEqualToString:@"none"]) {
                message.tagStr = tag;
                message.remark = remark;
                if ([message.robotType isEqualToString:@"xbot"]) {
                    [self sendXbotRobotFeedback:isUseful message:message];
                }else{
                    [self sendRobotFeedback:isUseful questionId:message.questionId messageId:message._id robotType:message.robotType robotId:message.robotId robotMsgId:message.robotMsgId];
                }
            }
        };
        
        cell.switchRobotAction = ^(NSString * _Nonnull robotId) {
            @strongify(self)
            if (self.KFStatus == QMKFStatusRobot) {
                [self switchRobot:robotId];
            } else {
                [QMRemind showMessage:QMUILocalizableString(not supported)];
            }
        };
        
        cell.tapArtificialAction = ^(NSString *number) {
            @strongify(self)
            if (self.KFStatus == QMKFStatusRobot) {
                [QMConnect sdkConvertManualWithPeerId:number convertType:@"13" successBlock:^{
    //                QMLog(@"转人工成功--13");
                    [self createNSTimer];
                } failBlock:^(NSString *reason){
                    QMLog(@"转人工失败");
                }];
            } else {
                [QMRemind showMessage:QMUILocalizableString(not supported)];
            }
            
        };
        
    }else if ([message.messageType isEqualToString:@"text"] && [message.isRobot isEqualToString:@"2"]) {
        cell.tapSendMessage = ^(NSString *text, NSString *num) {
            @strongify(self)
            if (self.KFStatus == QMKFStatusRobot) {
                if ([message.robotFlowType isEqualToString:@"button"]) {
                    NSMutableArray * arr = [QMLabelText dictionaryWithJsonString:message.robotFlowList];
                    if (![num isEqualToString:@""]) {
                        int number = [num intValue] - 1;
                        NSString *mssg = arr[number][@"button"];
                        if ([mssg isEqualToString:text]) {
                            [self sendText:arr[number][@"text"]];
                        }else {
                            [self sendText:text];
                        }
                    }else {
                        [self sendText:text];
                    }
                }else if ([message.robotFlowType isEqualToString:@"list"]) {
                    NSMutableArray * arr = [QMLabelText dictionaryWithJsonString:message.robotFlowList];
                    if (![num isEqualToString:@""]) {
                        int number = [num intValue] - 1;
                        NSString *mssg = arr[number][@"button"];
                        if ([mssg isEqualToString:text]) {
                            [self sendText:arr[number][@"text"]];
                        }else {
                            [self sendText:text];
                        }
                    }else {
                        [self sendText:text];
                    }
                }else {
                    [self sendText:text];
                }
            }
        };
        
        cell.tapFlowSelectAction = ^(NSArray * _Nonnull array, BOOL isSend) {
            @strongify(self)
            dispatch_async(dispatch_get_main_queue(), ^{
                if (isSend) {
                    NSString *text = @"";
                    for (NSDictionary *item in array) {
                        BOOL select = [item[@"select"] boolValue];
                        if (select) {
                            text = [text stringByAppendingFormat:@" 【%@】、",item[@"text"]];
                        }
                    }
                    text = [text substringToIndex:[text length] - 1];
                    [QMConnect sdkUpdateRobotFlowSend:@"1" withMessageID:message._id];
                    [self sendText:text];
                }else {
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:0 error:nil];
                    NSString *strJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    [QMConnect sdkUpdateRobotFlowList:strJson withMessageID:message._id];
                    [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        CustomMessage *item = obj;
                        if ([item._id isEqualToString:message._id]) {
                            item.robotFlowList = strJson;
                            NSMutableArray *mutableArr = self.dataArray.mutableCopy;
                            [mutableArr replaceObjectAtIndex:idx withObject:item];
                            self.dataArray = mutableArr;
                        }
                    }];
                }
            });
        };
        
    }else if ([message.messageType isEqualToString:@"evaluate"] && [message.evaluateStatus isEqualToString:@"0"]) {
        cell.noteSelected = ^(CustomMessage * _Nonnull message) {
            @strongify(self)
            [self createEvaluationView:NO andGetServerTime:NO andEvaluatId:message.evaluateId andFrom:@"send"];
        };
    }
    
    if ([message.messageType isEqualToString:@"NewPushQues"]) {
        cell.tapCommonAction = ^(NSInteger index) {
            @strongify(self)
            NSString *strIndex = [NSString stringWithFormat:@"%ld", index];
            [self.dataArray enumerateObjectsUsingBlock:^(CustomMessage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
               
                if ([obj._id isEqualToString:message._id]) {
                    *stop = YES;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.chatTableView beginUpdates];
                        obj.common_selected_index = strIndex;
                        [QMConnect sdkChangeCommonProblemIndex:strIndex withMessageID:message._id];
                        [self.chatTableView endUpdates];
                    });
                }
            }];
            
        };
        
        cell.tapSendMessage = ^(NSString * _Nonnull message, NSString * _Nonnull number) {
            @strongify(self)
            if (self.KFStatus == QMKFStatusRobot || self.KFStatus == QMKFStatusQueue) {
                [self sendText:message];
            }
        };
    }
    
    if ([message.messageType isEqualToString:@"xbotForm"]) {
        cell.didBtnAction = ^(BOOL isUseful, NSString * _Nonnull tag, NSString * _Nonnull remark) {
            @strongify(self)
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideKeyboard];
            });
        };
    }
    
    if ([message.messageType isEqualToString:@"listCard"]) {
        cell.tapListCardAction = ^(NSDictionary * _Nonnull listDic) {
            @strongify(self)
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *content = listDic[@"content"];
                if (content.length > 0) {
                    [self sendText:content];
                }
            });
        };
    }
    
    if ([cell isKindOfClass:[QMChatVideoCell class]]) {
        QMChatVideoCell *videoCell = (QMChatVideoCell *) cell;
        videoCell.playerVideoAction = ^(NSString * url, NSString *filePath) {
            @strongify(self)
            [self pushVideoPalyer:url filePath:filePath];
        };
    }
    
    if ([cell isKindOfClass:[QMChatLeaveCell class]]) {
        QMChatLeaveCell *leaveCell = (QMChatLeaveCell *) cell;
        leaveCell.showFileBlock = ^(CustomMessage * _Nonnull message) {
            @strongify(self)
            QMFileDownloadViewController *showFile = [[QMFileDownloadViewController alloc] init];
            [showFile loadData:message];
            [self.navigationController pushViewController:showFile animated:YES];
        };
    }
    
    return cell;
}

- (void)pushVideoPalyer:(NSString *)urlString filePath:(NSString *)filePath {
    
    [self.view endEditing:YES];
    NSURL *url = nil;
    if (filePath.length > 0) {
        url = [NSURL fileURLWithPath:filePath];
    } else if (urlString) {
        url = [NSURL URLWithString:urlString];
    }
    if (url) {
        //步骤2：创建AVPlayer
        AVPlayer *avPlayer = [[AVPlayer alloc] initWithURL:url];
        avPlayer.shouldGroupAccessibilityChildren = YES;
        //步骤3：使用AVPlayer创建AVPlayerViewController，并跳转播放界面
        AVPlayerViewController *avPlayerVC =[[AVPlayerViewController alloc] init];
        avPlayerVC.player = avPlayer;
        avPlayerVC.allowsPictureInPicturePlayback = YES;
        [avPlayerVC.player play];
        [self presentViewController:avPlayerVC animated:YES completion:nil];
    }
}

- (void)showMoreView:(QMLogistcsInfoModel *)model {
    QMLogistsMoreView *vc = [QMLogistsMoreView defualtView];
    [vc show:model];
}

static CGSize extracted(CustomMessage *message) {
    return [QMLabelText MLEmojiLabelText:message.message fontName:QM_PingFangSC_Reg fontSize:16 maxWidth:QMChatTextMaxWidth];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomMessage * message = self.dataArray[self.dataArray.count-indexPath.row-1];
    
    CGFloat height = 25;
    if (indexPath.row>0) {
        CustomMessage * preMessage = self.dataArray[self.dataArray.count-indexPath.row];
        UInt64 disTime = message.createdTime.longLongValue - preMessage.createdTime.longLongValue;
        if (disTime<3*60*1000) {
            height = 25;
        }else {
            height = 60;
        }
    }else {
        height = 60;
    }

    if ([message.messageType isEqualToString:@"text"]) {
        
         if ([message.isRobot isEqualToString:@"2"]) {
            NSMutableArray * arr = [QMLabelText dictionaryWithJsonString:message.robotFlowList];
            CGFloat titleHeight = [QMLabelText calcRobotHeight:message.robotFlowTip];
            CGFloat messageHeight = 0;
            
            BOOL flowSelect = [message.robotFlowSelect boolValue];
            BOOL flowSend = [message.robotFlowSend boolValue];
            CGFloat selectHeight = (flowSelect && !flowSend) ? 50 : 0;
            if ([message.robotFlowsStyle isEqualToString:@"1"]) {
                if (arr.count < 4) {
                    messageHeight = 25+titleHeight+30+arr.count*50;
                }else {
                    messageHeight = 265 + titleHeight;
                }
                height += messageHeight + 10 + selectHeight;
            }else if ([message.robotFlowsStyle isEqualToString:@"0"]) {
                if (arr.count < 7) {
                    if (arr.count%2 == 0) {
                        messageHeight = 25+titleHeight+30+ceil(arr.count/2)*50;
                    }else {
                        messageHeight = 25+titleHeight+30+ceil(arr.count/2+1)*50;
                    }
                }else {
                    messageHeight = 265 + titleHeight;
                }
                height += messageHeight + 10 + selectHeight;
            }else if ([message.robotFlowsStyle isEqualToString:@"2"]) {
                CGFloat robotHeight = [QMLabelText calcRobotHeight:message.message];
                height += robotHeight + 30;
            }else {
                if (arr.count < 7) {
                    if (arr.count%2 == 0) {
                        messageHeight = 25+titleHeight+30+ceil(arr.count/2)*50;
                    }else {
                        messageHeight = 25+titleHeight+30+ceil(arr.count/2+1)*50;
                    }
                }else {
                    messageHeight = 265 + titleHeight;
                }
                height += messageHeight + 10 + selectHeight;
            }
        }else {
            return UITableViewAutomaticDimension;
        }

         
    }else if ([message.messageType isEqualToString:@"Leave"]) {
        return UITableViewAutomaticDimension;

    }else if ([message.messageType isEqualToString:@"image"]) {
        return UITableViewAutomaticDimension;

    }else if ([message.messageType isEqualToString:@"voice"]) {
        NSString *voiceStatus = [QMConnect queryVoiceTextStatusWithmessageId:message._id];
        if ([voiceStatus isEqualToString:@"1"]) {
            if (message.fileName.length > 0) {
                CGSize textSize = extracted(message);
                height += textSize.height + 100;
            }
        }else {
            height += 45;
        }
            
    }else if ([message.messageType isEqualToString:@"file"]) {
//        height += 90;
        return UITableViewAutomaticDimension;
    }else if ([message.messageType isEqualToString:@"card"]) {
        height += 165;
    }else if ([message.messageType isEqualToString:@"cardInfo"]) {
        height += 80;
    }else if ([message.messageType isEqualToString:@"richText"]) {
        height += 120;
    }else if ([message.messageType isEqualToString:@"withdrawMessage"]) {
        return UITableViewAutomaticDimension;
//        height += 12;
    }else if ([message.messageType isEqualToString:@"cardInfo_New"]) {
        height += 110;
    }else if ([message.messageType isEqualToString:@"newCardInfo"]) {
        NSData *jsonData = [message.cardMessage_New dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
        if(err) {
            height += 0;
        }else {
            NSString *itemType = dic[@"item_type"];
            NSString *otherTitleOne = dic[@"other_title_one"];
            NSString *otherTitleTwo = dic[@"other_title_two"];
            NSString *otherTitleThree = dic[@"other_title_three"];
            NSArray *tags = dic[@"tags"];
            NSString *labelOne = tags.firstObject[@"label"];
            NSString *labelTwo = tags.lastObject[@"label"];
            CGFloat otherHeight = 0;
            if (otherTitleOne.length > 0) {
                otherHeight += 5 + 15;
            }
            if (otherTitleTwo.length > 0) {
                otherHeight += 5 + 15;
            }
            if (otherTitleThree.length > 0) {
                otherHeight += 5 + 15;
            }
            
            if (itemType.length > 0) {
                height += 100;
            }
            else {
                if (otherHeight > 0 ||
                    tags.count > 0) {
                    height += otherHeight + 12;
                }
                
                if (tags.count > 0) {
                    if (((labelOne.length > 4) ||
                        (labelTwo.length > 4)) &&
                        (tags.count != 1)) {
                        height += 100 + 73;
                    } else {
                        height += 100 + 33;
                    }
                } else {
                    height += 100;
                }
            }
        }
//        return message.height.integerValue;
    }else if ([message.messageType isEqualToString:@"video"]) {
        return UITableViewAutomaticDimension;
    }else if ([message.messageType isEqualToString:@"evaluate"]) {
        return UITableViewAutomaticDimension;
    }else if ([message.messageType isEqualToString:@"NewPushQues"]) {
        NSData *jsonData = [message.common_questions_group dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSArray *commonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
        if(err) {
            NSLog(@"json解析失败：%@",err);
            height += 0;
        }else {
            NSString *index = message.common_selected_index;
            NSMutableArray *listArray = [NSMutableArray array];

            if (commonArray.count) {
                for (NSDictionary *item in commonArray) {
                    NSArray *list = item[@"list"];
                    if (list.count) {
                        [listArray addObject:list];
                    }
                }
                
                NSMutableArray *itemArray = [NSMutableArray array];
                if (index.length) {
                    [itemArray addObjectsFromArray:listArray[[index integerValue]]];
                }else {
                    [itemArray addObjectsFromArray:listArray[0]];
                }

                CGFloat answerHeight = itemArray.count > 5 ? 5 * 45 + 40 : itemArray.count * 45;
                height += answerHeight+100;
            }else {
                height += 0;
            }
                        
        }
    }else if ([message.messageType isEqualToString:@"xbotForm"]) {
        NSData *jsonData = [message.xbotForm dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
        if(err) {
            return 0;
        }else {
            if (dic.count) {
                NSString *formPrompt = dic[@"formPrompt"];
                NSString *formName = dic[@"formName"];
                CGFloat promptHeight = [QMLabelText calculateTextHeight:formPrompt fontName:QM_PingFangSC_Reg fontSize:16 maxWidth:QM_kScreenWidth - kChatLeftAndRightWidth*2 - 30];
                CGFloat nameHeight = [QMLabelText calculateTextHeight:formName fontName:QM_PingFangSC_Reg fontSize:16 maxWidth:QM_kScreenWidth - kChatLeftAndRightWidth*2 - 30];
                height += promptHeight + 20 + nameHeight + 30;
                if(message.agentTipsSwitch == YES){
                    height += 50;
                }
            }else {
                return 0;
            }
        }
    }else if ([message.messageType isEqualToString:@"xbotFormSubmit"]) {
        CGSize textSize = [QMLabelText MLEmojiLabelText:@"提交成功!" fontName:QM_PingFangSC_Reg fontSize:16 maxWidth:QMChatTextMaxWidth];
        height += textSize.height + 30;
    }else if ([message.messageType isEqualToString:@"msgTask"]) {
        NSData *jsonData = [message.cardMessage_New dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
        NSDictionary *listDict = dic[@"data"];
        if ([dic[@"resp_type"] intValue] == 1) {
            QMLogistcsInfoModel *model = [[QMLogistcsInfoModel alloc] initWithDictionary:listDict error:nil];
            height += [QMChatLogistcsInfoCell getCellHeigt:model];
        } else {
            height += 5;
            if (message.cardType == QMMessageCardTypeNone) {
                if(err) {
                    height += 0;
                }else {
                    NSArray *cardList = listDict[@"shop_list"];
                    int shop_list_show = [dic[@"data"][@"shop_list_show"] intValue] ?: 5;

                    int shopNumber = 0;
                    int listNumber = 0;
                    
                    if (shop_list_show <= cardList.count) {
                        for (int i = 0; i < cardList.count; i++) {
                            if (listNumber == shop_list_show) {
                                break;;
                            }
                            NSDictionary *dic = cardList[i];
                            if ([dic[@"item_type"] isEqualToString:@"0"]) {
                                listNumber += 1;
                            }else if ([dic[@"item_type"] isEqualToString:@"1"]) {
                                shopNumber += 1;
                            }
                        }
                    }else {
                        for (NSDictionary *dic in cardList) {
                            if ([dic[@"item_type"] isEqualToString:@"0"]) {
                                listNumber += 1;
                            }else if ([dic[@"item_type"] isEqualToString:@"1"]) {
                                shopNumber += 1;
                            }
                        }
                    }
                    CGFloat cellHeight = 88*listNumber + 72*shopNumber;
                    height += cellHeight + 48;
                    if (cardList.count > 0) {
                        height += 40;
                    }
                }
            } else if (message.cardType == QMMessageCardTypeSeleced) {
                height += 81;
            } else {
                height += 44;
            }
        }
    }else if ([message.messageType isEqualToString:@"listCard"]) {
        height += 110;
    }
    else {
        return 0;
    }
       
    return height;
}

#pragma mark - 机器人评价Action
// xbot机器人帮助评价
- (void)sendXbotRobotFeedback:(BOOL)isUseful message:(CustomMessage *)message {
    @weakify(self)
    [QMConnect sdkSubmitXbotRobotFeedback:isUseful message:message successBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self)
            for (CustomMessage *mes in self.dataArray) {
                if ([mes._id isEqualToString:message._id]) {
                    mes.isUseful = isUseful == YES ? @"useful" : @"useless";
                    break;
                }
            }
            [self.chatTableView reloadData];
        });
    } failBlock:^(NSString *reason){
        
    }];
}

// 机器人帮助评价
- (void)sendRobotFeedback: (BOOL)isUseful questionId: (NSString *)questionId messageId: (NSString *)messageId robotType: (NSString *)robotType robotId: (NSString *)robotId robotMsgId: (NSString *)robotMsgId {
    @weakify(self)
    [QMConnect sdkSubmitRobotFeedback:isUseful questionId:questionId messageId:messageId robotType:robotType robotId:robotId robotMsgId:robotMsgId successBlock:^{
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            for (CustomMessage *message in self.dataArray) {
                if ([message._id isEqualToString:messageId]) {
                    message.isUseful = isUseful == YES ? @"useful" : @"useless";
                    break;
                }
            }
            [self.chatTableView reloadData];
        });
    } failBlock:^(NSString *reason){
        
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *row = [tableView cellForRowAtIndexPath:indexPath];
    UIView *backview = [[UIView alloc] initWithFrame:row.frame];
    backview.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_Main_Bg_Dark : QMColor_Main_Bg_Light];;
    row.selectedBackgroundView = backview;
}

- (QMChatBaseCell *)createCellWithClassName:(NSString *)className
                                      cellModel:(CustomMessage *)cellModel
                                      indexPath:(NSIndexPath *)indexPath {
    QMChatBaseCell * cell = nil;
    
    Class cellClass = NSClassFromString(className);
    
    cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:className];
    
    if (cell == nil) {
        cell = [[QMChatBaseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"QMChatBaseCell"];
    }
    
    return cell;
}

@end

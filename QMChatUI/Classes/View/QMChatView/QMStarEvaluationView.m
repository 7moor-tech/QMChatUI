//
//  QMStarEvaluationView.m
//  IMSDK
//
//  Created by 焦林生 on 2023/4/13.
//

#import "QMStarEvaluationView.h"
#import "QMHeader.h"
#import <Masonry/Masonry.h>
#import "QMTagListView.h"
#import "QMStarView.h"
#import "QMConfigTool.h"

@interface QMStarEvaluationView ()<UITextViewDelegate>

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UILabel *evaluationLabel;
@property (nonatomic, strong) QMStarView *starView;
@property (nonatomic, strong) UIView *likeView;
@property (nonatomic, strong) QMTagListView *tagView;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UILabel *placeholderlabel;
@property (nonatomic, strong) QMEvaluation *evaluation;//满意度
@property (nonatomic, strong) QMEvaluats *currentEvaluate;
@property (nonatomic, copy) NSArray *tagValue;
@property (nonatomic, copy) NSString *optionName;
@property (nonatomic, copy) NSString *optionValue;
@property (nonatomic, assign) NSInteger tempTag;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *submitButton;

@end
@implementation QMStarEvaluationView

- (instancetype)initWithFrame:(CGRect)frame evaluation:(QMEvaluation *)evaluation {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];

        [self setupView:evaluation];
    }
    return  self;
}

- (void)setupView:(QMEvaluation *)evaluation {
    self.evaluation = evaluation;
    
    CGFloat backW = QM_kScreenWidth-60;
//    CGFloat backH = 0.1f;
    self.backView = [[UIView alloc] initWithFrame:CGRectMake(30, 70, backW, 450)];
    self.backView.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_Main_Bg_Dark : QMColor_News_Agent_Light];
    self.backView.QMCornerRadius = 8;
    [self addSubview:self.backView];
    
    BOOL isShowTop = NO;
    self.topView = [[UIView alloc] initWithFrame:CGRectZero];
    self.topView.backgroundColor = [UIColor clearColor];
    [self.backView addSubview:self.topView];
    if (isShowTop) {
        
        self.topView.frame = CGRectMake(0, 0, backW, 120);
        UILabel *topLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, backW, 20)];
        topLabel.text = @"是否解决了您的问题";
        topLabel.font = [UIFont systemFontOfSize:14];
        topLabel.textAlignment = NSTextAlignmentCenter;
        [self.topView addSubview:topLabel];
        
        CGFloat buttonW = 80;
        UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        saveButton.frame = CGRectMake((backW-2*buttonW-25)/2, CGRectGetMaxY(topLabel.frame)+20, buttonW, 30);
        saveButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [saveButton setImage:[UIImage imageNamed:QMChatUIImagePath(@"QMLike_Icon")] forState:UIControlStateNormal];
        [saveButton setImage:[UIImage imageNamed:QMChatUIImagePath(@"QMLike_Select_Icon")] forState:UIControlStateSelected];
        [saveButton setTitle:@"已解决" forState:UIControlStateNormal];
        [saveButton setTitleColor:[UIColor colorWithHexString:isDarkStyle ? QMColor_D5D5D5_text : QMColor_999999_text] forState:UIControlStateNormal];
        [saveButton setTitleColor:[UIColor colorWithHexString:isDarkStyle ? QMColor_News_Agent_Light : QMColor_News_Custom] forState:UIControlStateSelected];
        [saveButton QM_ClipCorners:UIRectCornerAllCorners radius:15 border:1 color:[UIColor colorWithHexString:isDarkStyle ? QMColor_D5D5D5_text : @"#E8E8E8"]];
        [saveButton layoutButtonWithEdgeInsetsStyle:QMButtonEdgeInsetsStyleLeft imageTitleSpace:3];
        [saveButton addTarget:self action:@selector(clickSaveQuestionAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.topView addSubview:saveButton];
        
        UIButton *notSaveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        notSaveButton.frame = CGRectMake(CGRectGetMaxX(saveButton.frame)+25, CGRectGetMaxY(topLabel.frame)+20, buttonW, 30);
        notSaveButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [notSaveButton setImage:[UIImage imageNamed:QMChatUIImagePath(@"QMNotLike_Icon")] forState:UIControlStateNormal];
        [notSaveButton setImage:[UIImage imageNamed:QMChatUIImagePath(@"QMNotLike_Select_Icon")] forState:UIControlStateSelected];
        [notSaveButton setTitle:@"未解决" forState:UIControlStateNormal];
        [notSaveButton setTitleColor:[UIColor colorWithHexString:isDarkStyle ? QMColor_D5D5D5_text : QMColor_999999_text] forState:UIControlStateNormal];
        [notSaveButton setTitleColor:[UIColor colorWithHexString:isDarkStyle ? QMColor_News_Agent_Light : QMColor_News_Custom] forState:UIControlStateSelected];
        [notSaveButton QM_ClipCorners:UIRectCornerAllCorners radius:15 border:1 color:[UIColor colorWithHexString:isDarkStyle ? QMColor_D5D5D5_text : @"#E8E8E8"]];
        [notSaveButton layoutButtonWithEdgeInsetsStyle:QMButtonEdgeInsetsStyleLeft imageTitleSpace:3];
        [notSaveButton addTarget:self action:@selector(clickSaveQuestionAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.topView addSubview:notSaveButton];
        
        UIView *segView = [[UIView alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(saveButton.frame)+20, backW-32, 1)];
        segView.backgroundColor = [UIColor colorWithHexString:@"#E8E8E8"];
        [self.topView addSubview:segView];
    } else {
        self.topView.hidden = YES;
    }
    
    CGFloat titleHeight = [QMLabelText calculateTextHeight:evaluation.title fontName:QM_PingFangSC_Reg fontSize:14 maxWidth:backW-20];
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.topView.frame)+12, backW-20, titleHeight)];
    tipLabel.text = evaluation.title;
    tipLabel.font = [UIFont systemFontOfSize:14];
    tipLabel.numberOfLines = 0;
    tipLabel.textAlignment = NSTextAlignmentCenter;
    [self.backView addSubview:tipLabel];
    
    NSInteger listCount  = evaluation.evaluats.count;
    CGFloat starViewH = 0.1f;
    if ([evaluation.csrDetailType isEqualToString:@"star"] && listCount > 1) {
        self.tempTag = 100+evaluation.starInitValue-1;
        if (listCount > 2) {
            self.starView = [[QMStarView alloc] initWithFrame:CGRectMake(50, CGRectGetMaxY(tipLabel.frame)+10, self.backView.QM_width-100, 50)];
            self.starView.backgroundColor = [UIColor clearColor];
            
            self.starView.starCount = evaluation.starInitValue;
            self.starView.starTotalCount = listCount;
            @weakify(self)
            self.starView.evaluateViewChooseStarBlock = ^(NSInteger count) {
                @strongify(self)
                self.tempTag = count-1;
                self.evaluationLabel.text = evaluation.evaluats[self.tempTag].name;
                [self refreshEvaluationLabel:self.tempTag];
                [self setTagWithReason:evaluation backW:backW];
                QMLog(@"%ld颗星",count);
            };
            [self.backView addSubview:self.starView];

            self.evaluationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.starView.frame), backW, 20)];
            self.evaluationLabel.text = evaluation.evaluats[self.tempTag-100].name;
            self.evaluationLabel.textColor = [UIColor colorWithHexString:QMColor_999999_text];
            self.evaluationLabel.font = [UIFont systemFontOfSize:12];
            self.evaluationLabel.textAlignment = NSTextAlignmentCenter;
            [self.backView addSubview:self.evaluationLabel];
            starViewH = 80;
        }
        else if (listCount == 2){
            CGFloat buttonW = 80;
            UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
            saveButton.frame = CGRectMake((backW-2*buttonW-25)/2, CGRectGetMaxY(tipLabel.frame)+20, buttonW, 30);
            saveButton.titleLabel.font = [UIFont systemFontOfSize:14];
            [saveButton setImage:[UIImage imageNamed:QMChatUIImagePath(@"QMLike_Icon")] forState:UIControlStateNormal];
            [saveButton setImage:[UIImage imageNamed:QMChatUIImagePath(@"QMLike_Select_Icon")] forState:UIControlStateSelected];
            [saveButton setTitle:@"满意" forState:UIControlStateNormal];
            saveButton.tag = 200;
            [saveButton setTitleColor:[UIColor colorWithHexString:isDarkStyle ? QMColor_D5D5D5_text : QMColor_999999_text] forState:UIControlStateNormal];
            [saveButton setTitleColor:[UIColor colorWithHexString:isDarkStyle ? QMColor_News_Agent_Light : QMColor_News_Custom] forState:UIControlStateSelected];
            [saveButton QM_ClipCorners:UIRectCornerAllCorners radius:15 border:1 color:[UIColor colorWithHexString:isDarkStyle ? QMColor_D5D5D5_text : @"#E8E8E8"]];
            [saveButton layoutButtonWithEdgeInsetsStyle:QMButtonEdgeInsetsStyleLeft imageTitleSpace:3];
//            [saveButton addTarget:self action:@selector(clickSaveQuestionAction:) forControlEvents:UIControlEventTouchUpInside];
            [self.backView addSubview:saveButton];
            @weakify(self)
            [saveButton addActionHandler:^(NSInteger tag) {
                @strongify(self)
                for (int i = 200; i < 202; i++) {
                    UIButton *tempBtn = [self viewWithTag:i];
                    if (tempBtn.tag == tag) {
                        tempBtn.selected = YES;
                        [tempBtn QM_ClipCorners:UIRectCornerAllCorners radius:15 border:1 color:[UIColor colorWithHexString:isDarkStyle ? QMColor_D5D5D5_text : QMColor_News_Custom]];
                    }
                    else {
                        tempBtn.selected = NO;
                        [tempBtn QM_ClipCorners:UIRectCornerAllCorners radius:15 border:1 color:[UIColor colorWithHexString:isDarkStyle ? QMColor_D5D5D5_text : @"#E8E8E8"]];
                    }
                }
                [self refreshEvaluationLabel:tag-200];
                [self setTagWithReason:evaluation backW:backW];
            }];
            if (evaluation.starInitValue == 1) {
                saveButton.selected = YES;
                [saveButton QM_ClipCorners:UIRectCornerAllCorners radius:15 border:1 color:[UIColor colorWithHexString:isDarkStyle ? QMColor_D5D5D5_text : QMColor_News_Custom]];
            }
            
            UIButton *notSaveButton = [UIButton buttonWithType:UIButtonTypeCustom];
            notSaveButton.frame = CGRectMake(CGRectGetMaxX(saveButton.frame)+25, CGRectGetMaxY(tipLabel.frame)+20, buttonW, 30);
            notSaveButton.titleLabel.font = [UIFont systemFontOfSize:14];
            [notSaveButton setImage:[UIImage imageNamed:QMChatUIImagePath(@"QMNotLike_Icon")] forState:UIControlStateNormal];
            [notSaveButton setImage:[UIImage imageNamed:QMChatUIImagePath(@"QMNotLike_Select_Icon")] forState:UIControlStateSelected];
            [notSaveButton setTitle:@"不满意" forState:UIControlStateNormal];
            notSaveButton.tag = 201;
            [notSaveButton setTitleColor:[UIColor colorWithHexString:isDarkStyle ? QMColor_D5D5D5_text : QMColor_999999_text] forState:UIControlStateNormal];
            [notSaveButton setTitleColor:[UIColor colorWithHexString:isDarkStyle ? QMColor_News_Agent_Light : QMColor_News_Custom] forState:UIControlStateSelected];
    //        [notSaveButton setBackgroundColor:[UIColor colorWithHexString:@"#F8F8F8"] forState:UIControlStateNormal];
    //        [notSaveButton setBackgroundColor:[UIColor colorWithHexString:QMColor_News_Custom] forState:UIControlStateSelected];
            [notSaveButton QM_ClipCorners:UIRectCornerAllCorners radius:15 border:1 color:[UIColor colorWithHexString:isDarkStyle ? QMColor_D5D5D5_text : @"#E8E8E8"]];
            [notSaveButton layoutButtonWithEdgeInsetsStyle:QMButtonEdgeInsetsStyleLeft imageTitleSpace:3];
//            [notSaveButton addTarget:self action:@selector(clickSaveQuestionAction:) forControlEvents:UIControlEventTouchUpInside];
            [self.backView addSubview:notSaveButton];
            [notSaveButton addActionHandler:^(NSInteger tag) {
                @strongify(self)
                for (int i = 200; i < 202; i++) {
                    UIButton *tempBtn = [self viewWithTag:i];
                    if (tempBtn.tag == tag) {
                        tempBtn.selected = YES;
                        [tempBtn QM_ClipCorners:UIRectCornerAllCorners radius:15 border:1 color:[UIColor colorWithHexString:isDarkStyle ? QMColor_D5D5D5_text : QMColor_News_Custom]];
                    }
                    else {
                        tempBtn.selected = NO;
                        [tempBtn QM_ClipCorners:UIRectCornerAllCorners radius:15 border:1 color:[UIColor colorWithHexString:isDarkStyle ? QMColor_D5D5D5_text : @"#E8E8E8"]];
                    }
                }
                [self refreshEvaluationLabel:tag-200];
                [self setTagWithReason:evaluation backW:backW];
            }];
            if (evaluation.starInitValue == 2) {
                notSaveButton.selected = YES;
                [notSaveButton QM_ClipCorners:UIRectCornerAllCorners radius:15 border:1 color:[UIColor colorWithHexString:isDarkStyle ? QMColor_D5D5D5_text : QMColor_News_Custom]];
            }
            
            UIView *segView = [[UIView alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(saveButton.frame)+20, backW-32, 1)];
            segView.backgroundColor = [UIColor colorWithHexString:@"#F8F8F8"];
            [self.backView addSubview:segView];
            starViewH = 60;
        }
    }
    else {
        CGFloat originX = 15;
        CGFloat originY = CGRectGetMaxY(tipLabel.frame)+12;
        CGFloat maxWidth = QM_kScreenWidth - 110;
        CGFloat titleMargin = 20;
        CGFloat buttonMargin = 15;
        
        for (int i = 0; i < evaluation.evaluats.count; i++) {
            UIButton *button = [[UIButton alloc] init];
            QMEvaluats *model = evaluation.evaluats[i];
            [button setTitle:[NSString stringWithFormat:@" %@", model.name] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:QMChatUIImagePath(@"qm_evaluat_nor")] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:QMChatUIImagePath(@"qm_evaluat_sel")] forState:UIControlStateSelected];
            [button setTitleColor:[UIColor colorWithHexString:isDarkStyle ? QMColor_D5D5D5_text : QMColor_151515_text] forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:14];
            button.tag = 100+i;
            [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            button.titleLabel.lineBreakMode = 0;
            CGSize size = [QMLabelText calculateText:model.name fontName:QM_PingFangSC_Med fontSize:15 maxWidth:maxWidth-10 maxHeight:100];
            CGFloat btnHeight = 21;//size.height > 21 ? size.height : 21;
            button.frame = CGRectMake(originX + 10, originY, size.width + titleMargin + 10, btnHeight);
            originY += btnHeight + buttonMargin;
            [self.backView addSubview:button];
            
            if (model.isDefaultSelected) {
                self.tempTag = button.tag;
                button.selected = YES;
            } else {
                button.selected = NO;
            }
        }
        starViewH = (buttonMargin + 21)*evaluation.evaluats.count + 10;
    }
    
    self.tagView = [[QMTagListView alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(tipLabel.frame)+starViewH+10, backW-30, 0)];
    /**允许点击 */
    self.tagView.canTouch=YES;
    self.tagView.isSingleSelect=NO;
    self.tagView.signalTagColor = [UIColor clearColor];
    [self.backView addSubview:self.tagView];

    [self refreshEvaluationLabel:self.tempTag-100];
    @weakify(self)
    [self.tagView setDidselectItemBlock:^(NSArray *arr) {
        @strongify(self)
        self.tagValue = arr;
    }];
    [self setTagWithReason:evaluation backW:backW];
}

- (void)setTagWithReason:(QMEvaluation *)evaluation backW:(CGFloat)backW {
    [self.textView removeFromSuperview];
    self.textView = [[UITextView alloc] init];
    self.textView.frame = CGRectMake(15, self.tagView.QM_top+self.tagView.tagHeight+12, backW-30, 75);
    self.textView.font = [UIFont systemFontOfSize:14];
    self.textView.QMCornerRadius = 4;
    self.textView.layer.borderColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_D5D5D5_text : @"#E8E8E8"].CGColor;
    self.textView.layer.borderWidth = 1;
//    [self.textView QM_ClipCorners:UIRectCornerAllCorners radius:4 border:1 color:[UIColor colorWithHexString:isDarkStyle ? QMColor_D5D5D5_text : @"#E8E8E8"]];
    self.textView.delegate = self;
    [self.backView addSubview:self.textView];
    
    CGFloat textHeight = [QMLabelText calculateTextHeight:evaluation.satisfyComment fontName:QM_PingFangSC_Reg fontSize:13 maxWidth:backW-40];
    self.placeholderlabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, backW-40, textHeight)];
    self.placeholderlabel.font = [UIFont systemFontOfSize:13];
    self.placeholderlabel.numberOfLines = 0;
    self.placeholderlabel.textColor = [UIColor colorWithHexString:@"#E8E8E8"];
    self.placeholderlabel.text = evaluation.satisfyComment ;
    [self.textView addSubview:self.placeholderlabel];

    [self.cancelButton removeFromSuperview];
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelButton = cancelBtn;
    cancelBtn.frame = CGRectMake((backW-2*100-16)/2, CGRectGetMaxY(self.textView.frame)+20, 100, 32);
//    cancelBtn.tag = 777;
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setBackgroundColor:[UIColor colorWithHexString:@"#E8E8E8"] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.QMCornerRadius = 4;
    [self.backView addSubview:cancelBtn];

    [self.submitButton removeFromSuperview];
    UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.submitButton = submitBtn;
    submitBtn.frame = CGRectMake(CGRectGetMaxX(cancelBtn.frame)+16, CGRectGetMaxY(self.textView.frame)+20, 100, 32);
//    submitBtn.tag = 778;
    submitBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [submitBtn setTitle:@"提交评价" forState:UIControlStateNormal];
    [submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [submitBtn setBackgroundColor:[UIColor colorWithHexString:QMColor_News_Custom] forState:UIControlStateNormal];
    [submitBtn addTarget:self action:@selector(sendAction:) forControlEvents:UIControlEventTouchUpInside];
    submitBtn.QMCornerRadius = 4;
    [self.backView addSubview:submitBtn];
    
    self.backView.frame = CGRectMake(30, 70, backW, CGRectGetMaxY(cancelBtn.frame)+20);
}

- (void)buttonAction:(UIButton *)button {
    
    [self.textView resignFirstResponder];
    
    for (int i = 100; i < self.evaluation.evaluats.count+100; i++) {
        UIButton *tempBtn = [self viewWithTag:i];
        if (tempBtn.tag == button.tag) {
            tempBtn.selected = !button.selected;
        }
        else {
            tempBtn.selected = NO;
        }
    }
    
    [self refreshEvaluationLabel:button.tag-100];
    
}

- (void)refreshEvaluationLabel:(NSInteger)tag {
    if (tag < 0) {
        self.currentEvaluate = self.evaluation.evaluats.firstObject;
        [self.tagView setTagWithTagArray:self.currentEvaluate.reason selectTag:@""];
    }
    else {
        self.currentEvaluate = self.evaluation.evaluats[tag];
        [self.tagView setTagWithTagArray:self.currentEvaluate.reason selectTag:@""];
        self.optionValue = self.currentEvaluate.value;
        self.optionName = self.currentEvaluate.name;
    }
}

- (void)clickSaveQuestionAction:(UIButton *)action {
    
    for (int i = 200; i < 202; i++) {
        UIButton *tempBtn = [self viewWithTag:i];
        if (tempBtn.tag == action.tag) {
            tempBtn.selected = YES;
            [tempBtn QM_ClipCorners:UIRectCornerAllCorners radius:15 border:1 color:[UIColor colorWithHexString:isDarkStyle ? QMColor_D5D5D5_text : QMColor_News_Custom]];
        }
        else {
            tempBtn.selected = NO;
            [tempBtn QM_ClipCorners:UIRectCornerAllCorners radius:15 border:1 color:[UIColor colorWithHexString:isDarkStyle ? QMColor_D5D5D5_text : @"#E8E8E8"]];
        }
    }
    
    [self refreshEvaluationLabel:action.tag-200];
}

- (void)sendAction:(UIButton *)button {
    [self.textView resignFirstResponder];
//    if ([self.placeholderlabel.text isEqualToString:self.evaluation.satisfyComment]) {
//
//    }
    if (self.optionName.length > 0) {
//        if (self.tagValue.count == 0) {//self.currentEvaluate.labelRequired.boolValue &&
//            [QMRemind showMessage:QMUILocalizableString(title.evaluation_label)];
//            return;
//        }
        
        if (self.currentEvaluate.proposalRequired.boolValue && self.textView.text.length == 0) {
            [QMRemind showMessage:QMUILocalizableString(title.evaluation_reason)];
            return;
        }
//        [QMActivityView startAnimating];
        self.sendSelect(self.evaluation.csrDetailType,self.optionName, self.optionValue, self.tagValue, self.textView.text);
    }else{
        [QMRemind showMessage:QMUILocalizableString(title.evaluation_select)];
    }
}

- (void)cancelAction:(UIButton *)action{
    
//    [self dismissView];
    self.cancelSelect();
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.textView.isFirstResponder == YES) {
        [self.textView resignFirstResponder];
    }
}

- (void)showView {
    [[UIApplication sharedApplication].keyWindow addSubview:self];
}

- (void)dismissView{
    [self removeFromSuperview];
}

#pragma mark - textViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.placeholderlabel.text = @"";
}

- (void)textViewDidChange:(UITextView *)textView {
    NSString *str = textView.text;
    if (str.length > 120) {
        textView.text = [str substringToIndex:120];
//        [QMRemind showMessage:@"最大不超过 120 字"];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@""]) {
        self.placeholderlabel.text = self.evaluation.satisfyComment;
    }
}

@end

//
//  QMTagListView.m
//  IMSDK
//
//  Created by 焦林生 on 2022/12/28.
//

#import "QMTagListView.h"
#import "QMHeader.h"
#define HORIZONTAL_PADDING 5.0f
#define VERTICAL_PADDING   4.0f
#define LABEL_MARGIN       10.0f
#define BOTTOM_MARGIN      10.0f
#define KBtnTag            1000
#define R_G_B_16(rgbValue)\
\
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 \
alpha:1.0]
@interface QMTagListView(){
    
    CGFloat _KTagMargin;//左右tag之间的间距
    CGFloat _KBottomMargin;//上下tag之间的间距
    NSInteger _kSelectNum;//实际选中的标签数
    UIButton*_tempBtn;//临时保存对象
}
@end
@implementation QMTagListView
-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        _kSelectNum=0;
        totalHeight=0;
        self.frame=frame;
        _tagArr=[[NSMutableArray alloc]init];
        /**默认是多选模式 */
        self.isSingleSelect=NO;

    }
    return self;
    
}
-(void)setTagWithTagArray:(NSArray *)arr selectTag:(NSString *)tagStr{
    self.tagHeight = 0;
    previousFrame = CGRectZero;
    totalHeight = 0;
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    [_tagArr removeAllObjects];
    [_tagArr addObjectsFromArray:arr];
    [arr enumerateObjectsUsingBlock:^(NSString*str, NSUInteger idx, BOOL *stop) {
    
        UIButton*tagBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        tagBtn.frame=CGRectZero;
        
        if(_signalTagColor){
            //可以单一设置tag的颜色
            tagBtn.backgroundColor=_signalTagColor;
        }
        if(_canTouch){
            tagBtn.userInteractionEnabled=YES;
        }else{
            tagBtn.userInteractionEnabled=NO;
        }
        [tagBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [tagBtn setTitleColor:[UIColor colorWithHexString:QMColor_News_Custom] forState:UIControlStateSelected];
        tagBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [tagBtn addTarget:self action:@selector(tagBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [tagBtn setTitle:str forState:UIControlStateNormal];
        tagBtn.tag=KBtnTag+idx;
        tagBtn.layer.cornerRadius=13;
//        tagBtn.layer.borderColor=R_G_B_16(0x818181).CGColor;
//        tagBtn.layer.borderWidth=0.5;
        tagBtn.titleLabel.numberOfLines = 0;
        tagBtn.clipsToBounds=YES;
        NSDictionary *attrs = @{NSFontAttributeName : [UIFont systemFontOfSize:14]};
        CGSize Size_str=[str sizeWithAttributes:attrs];

        if (Size_str.width > 240) {
            Size_str.width = 240;
            Size_str.height = 35;
        } else {
            Size_str.width += HORIZONTAL_PADDING*3;
            Size_str.height += VERTICAL_PADDING*3;
        }
        
        CGRect newRect = CGRectZero;
        
        [tagBtn setBackgroundColor:[UIColor colorWithHexString:QMColor_F6F6F6_BG]  forState:UIControlStateNormal];
        [tagBtn setBackgroundColor:[UIColor colorWithHexString:@"#ECF5FF"] forState:UIControlStateHighlighted];
        [tagBtn setBackgroundColor:[UIColor colorWithHexString:@"#ECF5FF"] forState:UIControlStateSelected];
        
        if (tagStr.length > 0) {
            NSArray *tempArr = [tagStr componentsSeparatedByString:@"##"];
            for (NSString *tempStr in tempArr) {
                if ([tempStr isEqualToString:str]) {
                    tagBtn.selected = YES;
                }
            }
        }

        if(_KTagMargin&&_KBottomMargin){
            
            if (previousFrame.origin.x + previousFrame.size.width + Size_str.width + _KTagMargin > self.bounds.size.width) {
                
                newRect.origin = CGPointMake(10, previousFrame.origin.y + Size_str.height + _KBottomMargin);
                totalHeight +=Size_str.height + _KBottomMargin;
            }
            else {
                newRect.origin = CGPointMake(previousFrame.origin.x + previousFrame.size.width + _KTagMargin, previousFrame.origin.y);
                
            }
            [self setHight:self andHight:totalHeight+Size_str.height + _KBottomMargin];

            
        }else{
        if (previousFrame.origin.x + previousFrame.size.width + Size_str.width + LABEL_MARGIN > self.bounds.size.width) {
            
            if (Size_str.width == 240) {
                newRect.origin = CGPointMake(10, previousFrame.origin.y + Size_str.height);
                totalHeight +=Size_str.height;
            } else {
                newRect.origin = CGPointMake(10, previousFrame.origin.y + Size_str.height + BOTTOM_MARGIN);
                totalHeight +=Size_str.height + BOTTOM_MARGIN;
            }
            
        }
        else {
            newRect.origin = CGPointMake(previousFrame.origin.x + previousFrame.size.width + LABEL_MARGIN, previousFrame.origin.y);
            
        }
        [self setHight:self andHight:totalHeight+Size_str.height + BOTTOM_MARGIN];
        }
        newRect.size = Size_str;
        [tagBtn setFrame:newRect];
        previousFrame=tagBtn.frame;
        [self setHight:self andHight:totalHeight+Size_str.height + BOTTOM_MARGIN];
        [self addSubview:tagBtn];
        
        self.tagHeight = totalHeight+Size_str.height + BOTTOM_MARGIN;
    }];
    if(_QMbackgroundColor){
        
        self.backgroundColor=_QMbackgroundColor;
        
    }else{
        
        self.backgroundColor=[UIColor whiteColor];
        
    }
    

}
#pragma mark-改变控件高度
- (void)setHight:(UIView *)view andHight:(CGFloat)hight
{
    CGRect tempFrame = view.frame;
    tempFrame.size.height = hight;
    view.frame = tempFrame;
}
-(void)tagBtnClick:(UIButton*)button{
    if(_isSingleSelect){
        if(button.selected){
            
            button.selected=!button.selected;
            
        }else{
            
            _tempBtn.selected=NO;
//            _tempBtn.backgroundColor=[UIColor whiteColor];
             button.selected=YES;
            _tempBtn=button;
            
        }
        
    }else{
        
        button.selected=!button.selected;
    }
    
//    if(button.selected==YES){
//        button.backgroundColor=[UIColor colorWithHexString:QMColor_News_Custom];
//    }else if (button.selected==NO){
//        button.backgroundColor=[UIColor whiteColor];
//    }
    
    [self didSelectItems];
    
    
}
-(void)didSelectItems{

    NSMutableArray*arr=[[NSMutableArray alloc]init];
    
    for(UIView*view in self.subviews){

        if([view isKindOfClass:[UIButton class]]){

            UIButton*tempBtn=(UIButton*)view;
            tempBtn.enabled=YES;
            if (tempBtn.selected==YES) {
                [arr addObject:_tagArr[tempBtn.tag-KBtnTag]];
                _kSelectNum=arr.count;
            }
        }
    }
    if(_kSelectNum==self.canTouchNum){
        
        for(UIView*view in self.subviews){

            UIButton*tempBtn=(UIButton*)view;

             if (tempBtn.selected==YES) {
                 tempBtn.enabled=YES;
             }
             else{
                 tempBtn.enabled=NO;
                 
             }
        }
    }
    self.didselectItemBlock(arr);
    
    
}
-(void)setMarginBetweenTagLabel:(CGFloat)Margin AndBottomMargin:(CGFloat)BottomMargin{
    
    _KTagMargin=Margin;
    _KBottomMargin=BottomMargin;

}

@end

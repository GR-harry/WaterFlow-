//
//  WaterFlowLayout.h
//  WaterFlow瀑布流
//
//  Created by apple on 15/4/9.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WaterFlowLayout;
@protocol WaterFlowLayoutDelegate <NSObject>
/**
 *  返回该indexPath下的cell的高度，根据当前宽度width计算
 */
- (CGFloat)waterFlowLayout:(WaterFlowLayout *)waterFlowLayout heightForWidth:(CGFloat)width atIndexPath:(NSIndexPath *)indexPath;
@end

@interface WaterFlowLayout : UICollectionViewFlowLayout
@property (nonatomic, assign)CGFloat columnMargin; // 每列的间距
@property (nonatomic, assign)CGFloat rowMargin;    // 每行的间距
@property (nonatomic, assign)UIEdgeInsets edgeInsets; // 边框的间距
@property (nonatomic, assign)NSInteger columnCount;   // 列数

@property (nonatomic, assign)id<WaterFlowLayoutDelegate> delegate;
@end

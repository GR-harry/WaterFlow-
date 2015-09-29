//
//  WaterFlowLayout.m
//  WaterFlow瀑布流
//
//  Created by apple on 15/4/9.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "WaterFlowLayout.h"
#import "Shop.h"
#import "ShopCell.h"
@interface WaterFlowLayout ()
@property (nonatomic, strong)NSMutableArray *columnMaxYs;
/**
 *  存放所有cell的，Attributes属性
 */
@property (nonatomic, strong)NSMutableArray *attrisArray;
@end

@implementation WaterFlowLayout
- (NSMutableArray *)columnMaxYs
{
    if (!_columnMaxYs) {
        _columnMaxYs = [NSMutableArray array];
        for (int i = 0; i < self.columnCount; i++) {
            [_columnMaxYs addObject:@0];
        }
    }
    
    return _columnMaxYs;
}
- (NSMutableArray *)attrisArray
{
    if (!_attrisArray) {
        _attrisArray = [NSMutableArray array];
    }
    
    return _attrisArray;
}
- (instancetype)init
{
    if (self = [super init]) {
        self.columnMargin = 10;
        self.rowMargin = 10;
        self.edgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        self.columnCount = 3;
    }
    return self;
}
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}
- (CGSize)collectionViewContentSize
{
    NSInteger maxIndex = 0;
    for (int i = 0; i < self.columnCount; i++) {
        if ([self.columnMaxYs[i] floatValue] > [self.columnMaxYs[maxIndex] floatValue]) {
            maxIndex = i;
        }
    }
    return CGSizeMake(0, [self.columnMaxYs[maxIndex] floatValue] + self.edgeInsets.bottom);
}

/**
 *  每次计算Attributes之前，都调用一次该方法
 */
- (void)prepareLayout
{
    // 1. 重置各列的最大值数组
    [self.columnMaxYs removeAllObjects];
    for (int i = 0; i < self.columnCount; i++) {
        [self.columnMaxYs addObject:@(self.edgeInsets.top)];
    }
    
    // 2. 计算Attributes属性
    NSInteger count = [self.collectionView numberOfItemsInSection:0];
    for (int i = 0; i < count; i++) {
        UICollectionViewLayoutAttributes *attris = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        [self.attrisArray addObject:attris];
    }
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 1. 找到长度最短的列
    NSInteger minIndex = 0;
    for (int i = 0; i < self.columnCount; i++) {
        CGFloat currentY = [self.columnMaxYs[i] floatValue];
        if (currentY < [self.columnMaxYs[minIndex] floatValue]) {
            minIndex = i;
        }
    }
    
    // 2. 计算y值
    CGFloat y = [self.columnMaxYs[minIndex] floatValue] + self.rowMargin;
    
    // 3. 计算宽度
    CGFloat width = (self.collectionView.frame.size.width - self.edgeInsets.left - self.edgeInsets.right - (self.columnCount - 1) * self.columnMargin) / self.columnCount;
    
    // 4. 计算x值
    CGFloat x = self.edgeInsets.left + (width + self.columnMargin) * minIndex;
    
    // 5. 计算高度
    CGFloat height = [self.delegate waterFlowLayout:self heightForWidth:width atIndexPath:indexPath];
    
    // 6. 记录当前列y最大值
    self.columnMaxYs[minIndex] = @(y + height);
    
    UICollectionViewLayoutAttributes *attris = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attris.frame = CGRectMake(x, y, width, height);
    
    return attris;
}
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return self.attrisArray;
}
@end

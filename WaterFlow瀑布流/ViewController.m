//
//  ViewController.m
//  WaterFlow瀑布流
//
//  Created by apple on 15/4/9.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "ViewController.h"
#import "WaterFlowLayout.h"
#import "Shop.h"
#import "MJExtension.h"
#import "ShopCell.h"
#import "MJRefresh.h"
@interface ViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, WaterFlowLayoutDelegate>
@property (nonatomic, weak)UICollectionView *collectionView;
@property (nonatomic, strong)NSMutableArray *shops;
@end
static NSString *const Id = @"shop";
@implementation ViewController
- (NSMutableArray *)shops
{
    if (!_shops) {
        _shops = [NSMutableArray array];
    }
    
    return _shops;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 1. 初始化数据
    NSArray *shops = [Shop objectArrayWithFilename:@"1.plist"];
    [self.shops addObjectsFromArray:shops];
    
    // 2. 创建UICollectionView
    WaterFlowLayout *layout = [[WaterFlowLayout alloc] init];
    layout.delegate = self;
    layout.edgeInsets = UIEdgeInsetsMake(20, 10, 10, 10);
    layout.columnCount = 3;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.backgroundColor = [UIColor whiteColor];
    [collectionView registerNib:[UINib nibWithNibName:@"ShopCell" bundle:nil] forCellWithReuseIdentifier:Id];
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    
    // 3. 添加刷新
    [self.collectionView addFooterWithCallback:^{
        [self loadMoreShops];
    }];
    
    UILongPressGestureRecognizer *regconizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressReconizer:)];
    [collectionView addGestureRecognizer:regconizer];
}
- (void)loadMoreShops
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSArray *shops = [Shop objectArrayWithFilename:@"1.plist"];
        [self.shops addObjectsFromArray:shops];
        [self.collectionView reloadData];
        [self.collectionView footerEndRefreshing];
    });
}
#pragma mark - WaterFlowLayout
- (CGFloat)waterFlowLayout:(WaterFlowLayout *)waterFlowLayout heightForWidth:(CGFloat)width atIndexPath:(NSIndexPath *)indexPath
{
    Shop *shop = self.shops[indexPath.item];
    return shop.h / shop.w * width;
}
#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.shops.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ShopCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:Id forIndexPath:indexPath];
    cell.shop = self.shops[indexPath.item];
    return cell;
}

#pragma mark - GestureRecognizer
- (void)handleLongPressReconizer:(UILongPressGestureRecognizer *)recognizer
{
    static UIView *snapShot = nil;
    static NSIndexPath *sourceIndexPath = nil;
    
    CGPoint touchPoint = [recognizer locationInView:self.collectionView];
    NSIndexPath *currentIndexPath = [self.collectionView indexPathForItemAtPoint:touchPoint];
    
    if (!currentIndexPath) return;
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            // 1. 记录下当前的indexPath
            sourceIndexPath = currentIndexPath;
            
            // 2. 获取需要移动的cell，并且截图
            ShopCell *movedCell = (ShopCell *)[self.collectionView cellForItemAtIndexPath:currentIndexPath];
            snapShot = [self snapShotInView:movedCell];
            [self.collectionView addSubview:snapShot];
            
            // 3. 动画显示截图，和隐藏cell
            [UIView animateWithDuration:0.25 animations:^{
                snapShot.alpha = 0.8;
                snapShot.transform = CGAffineTransformMakeScale(1.05, 1.05);
                movedCell.alpha = 0;
                snapShot.center = touchPoint;
            } completion:^(BOOL finished) {
                movedCell.hidden = YES;
            }];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            // 1. 移动截图
            snapShot.center = touchPoint;
            
            // 2. 交换数据 和 移动cell
            if (![currentIndexPath isEqual:sourceIndexPath])
            {
                [self.shops exchangeObjectAtIndex:currentIndexPath.item withObjectAtIndex:sourceIndexPath.item];
                [self.collectionView moveItemAtIndexPath:sourceIndexPath toIndexPath:currentIndexPath];
                sourceIndexPath = currentIndexPath;
            }
            
        }
            break;
        default:
        {
            ShopCell *movedCell = (ShopCell *)[self.collectionView cellForItemAtIndexPath:currentIndexPath];
            
            // 复原截图，显示出cell
            [UIView animateWithDuration:0.25 animations:^{
                snapShot.center = movedCell.center;
                snapShot.alpha = 0;
                snapShot.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                movedCell.hidden = NO;
                movedCell.alpha = 1.0f;
                [snapShot removeFromSuperview];
            }];
        }
            break;
    }
}
- (UIView *)snapShotInView:(UIView *)inputView
{
    UIView *snapShotView = [inputView snapshotViewAfterScreenUpdates:NO];
    snapShotView.layer.shadowOffset = CGSizeMake(- 5, 5);
    snapShotView.layer.shadowOpacity = 0.4;
    snapShotView.alpha = 0.0f;
    snapShotView.frame = inputView.frame;
    return snapShotView;
}
@end

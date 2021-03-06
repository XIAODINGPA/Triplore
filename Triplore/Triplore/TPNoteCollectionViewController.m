//
//  TPNoteCollectionViewController.m
//  Triplore
//
//  Created by 宋 奎熹 on 2017/5/25.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "TPNoteCollectionViewController.h"
#import "TPNoteCollectionViewCell.h"
#import "TPNoteViewController.h"
#import "TPNote.h"
#import "TPNoteManager.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "TPRefreshHeader.h"

@interface TPNoteCollectionViewController () <UIViewControllerPreviewingDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@end

@implementation TPNoteCollectionViewController{
    NSArray *noteArr;
}

static NSString * const reuseIdentifier = @"TPNoteCollectionViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    self.collectionView.backgroundColor = TPBackgroundColor;
    
    self.collectionView.emptyDataSetSource = self;
    self.collectionView.emptyDataSetDelegate = self;

    UINib *nib = [UINib nibWithNibName:@"TPNoteCollectionViewCell" bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:reuseIdentifier];
    
    TPRefreshHeader *header = [TPRefreshHeader headerWithRefreshingTarget:self
                                                         refreshingAction:@selector(loadNotes)];
    self.collectionView.mj_header = header;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadNotes)
                                                 name:@"load_notes"
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"load_notes" object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [self.tabBarController.tabBar setHidden:NO];
    [self loadNotes];
}

- (void)loadNotes{
    noteArr = [NSMutableArray arrayWithArray:[TPNoteManager fetchAllNotes]];
    [self.collectionView.mj_header endRefreshing];
    [self.collectionView reloadData];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return noteArr.count;
}

- (TPNoteCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TPNoteCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.note = noteArr[indexPath.row];
    
    //注册3D Touch
    if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        [self registerForPreviewingWithDelegate:self sourceView:cell];
    }
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    TPNoteViewController *noteVC = [[TPNoteViewController alloc] init];
    
    TPNote *note = (TPNote *)noteArr[indexPath.row];
    [noteVC setNote:note];
    [noteVC setNoteMode:TPOldNote];
    
    [self.parentNavigationController pushViewController:noteVC animated:YES];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat width = (CGRectGetWidth(self.view.frame) - 30) / 2;
    return CGSizeMake(width, width/16*9 + 82);
}

//每一个分组的上左下右间距
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(10, 10, 0, 10);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 10;
}

#pragma mark - UIViewControllerPreviewingDelegate

- (UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location{
    
    if ([self.presentedViewController isKindOfClass:[TPNoteViewController class]]){
        return nil;
    }
    
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:(TPNoteCollectionViewCell* )[previewingContext sourceView]];
    
    TPNoteViewController *noteVC = [[TPNoteViewController alloc] init];
    TPNote *note = (TPNote *)noteArr[indexPath.row];
    [noteVC setNote:note];
    [noteVC setNoteMode:TPOldNote];
    noteVC.preferredContentSize = CGSizeMake(0.0f, 525.0f);
    
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, 70);
    previewingContext.sourceRect = rect;
    
    return noteVC;
}

- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    [self.navigationController pushViewController:viewControllerToCommit animated:YES];
}

#pragma mark - DZNEmptyTableViewDelegate

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView{
    NSString *text = @"没有笔记";
    
    NSDictionary *attributes = @{
                                 NSForegroundColorAttributeName: TPColor,
                                 NSFontAttributeName:[UIFont fontWithName:@"PingFangSC-Medium" size:20.0]
                                 };
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView{
    return YES;
}

@end

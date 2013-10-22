//
//  TestGalleryViewController.m
//  TestGallery
//
//  Created by Avner Barr on 10/22/13.
//  Copyright (c) 2013 Avner Barr. All rights reserved.
//

#import "TestGalleryViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
@interface SimpleImageViewCell : UICollectionViewCell

@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UILabel *label;
@property (nonatomic,strong) UILabel *alabel;

@end

@implementation SimpleImageViewCell

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.imageView];
        self.label = [[UILabel alloc] initWithFrame:self.imageView.bounds];
        self.label.numberOfLines = 0;
        self.label.textColor = [UIColor whiteColor];
        [self.imageView addSubview:self.label];
        self.label.backgroundColor = [UIColor clearColor];
        self.alabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.imageView.bounds.size.width, 50)];
        [self.alabel setTextColor:[UIColor redColor]];
        [self.imageView addSubview:self.alabel];
        self.alabel.text = @"This cell was allocated";
    }
    return self;
}

-(void)prepareForReuse
{
    self.imageView.image = nil;
    self.label.text = nil;
    self.alabel.text = @"This cell was reused";
}

@end
@interface TestGalleryViewController () <UICollectionViewDataSource>
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) ALAssetsLibrary *library;
@property (nonatomic,strong) NSMutableArray *assets;
@end

@implementation TestGalleryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    CGSize s = self.view.frame.size;
    
    flowLayout.itemSize =  s;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;




    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:flowLayout];
    self.collectionView.pagingEnabled = YES;
    [self.collectionView registerClass:[SimpleImageViewCell class] forCellWithReuseIdentifier:@"cell"];
    self.collectionView.dataSource= self;
    [self.view addSubview:self.collectionView];
    self.library = [[ALAssetsLibrary alloc] init];
	// Do any additional setup after loading the view, typically from a nib.
    self.assets = [[NSMutableArray alloc] init];
    [self.library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group != nil)
        {
            [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
                if (asset != nil)
                {
                    [self.assets addObject:asset];
                }
            }];
        } else
        {
            [self.collectionView reloadData];
        }
        
    } failureBlock:^(NSError *error) {
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{

}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assets.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    double totalTime = 0;
    NSTimeInterval cellCreate = [NSDate timeIntervalSinceReferenceDate];
    SimpleImageViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    NSTimeInterval cellduration = [NSDate timeIntervalSinceReferenceDate] - cellCreate;
    NSString *loadTime = [NSString stringWithFormat:@"Cell Dequeue Time = %f",cellduration];
    
    totalTime += cellduration;

    ALAsset *asset = [self.assets objectAtIndex:indexPath.row];

    
    NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    NSTimeInterval duration = [NSDate timeIntervalSinceReferenceDate] - start;
    loadTime = [NSString stringWithFormat:@"%@\nalassetRepresentation loadTime %f +",loadTime,duration];
    
    totalTime += duration;
    
    start = [NSDate timeIntervalSinceReferenceDate];
    CGImageRef ref = [rep fullResolutionImage];
    duration = [NSDate timeIntervalSinceReferenceDate] - start;
    loadTime = [NSString stringWithFormat:@"%@\nCGImageCreateTime %f +",loadTime,duration];
    
    totalTime += duration;
    
    start = [NSDate timeIntervalSinceReferenceDate];
    UIImage *im = [UIImage imageWithCGImage:ref scale:rep.scale orientation:rep.orientation];
    duration = [NSDate timeIntervalSinceReferenceDate] - start;
    loadTime = [NSString stringWithFormat:@"%@\nUIImage Create time %f",loadTime,duration];

    totalTime += duration;
    
    
    loadTime = [NSString stringWithFormat:@"%@\n\n\nTotal Create time %f",loadTime,totalTime];
    cell.imageView.image = im;
    cell.label.text = loadTime  ;
    return cell;
}

@end



//
//  CollectionViewController.m
//  APFT Commander
//
//  Created by Phillip Dieppa on 12/1/14.
//  Copyright (c) 2014 Phillip Dieppa. All rights reserved.
//

#import "PADCollectionViewController.h"
#import "PADCalc.h"

@interface PADCollectionViewController ()

@end

@implementation PADCollectionViewController
static BOOL logging = YES;
static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
    [self setTitle:@"APFT Commander"];
    
#pragma mark -
    // FIXME: Remove Test
    NSNumber *age = [NSNumber numberWithInt:23];
    NSString *sex  = [NSString stringWithFormat:@"Male"];
    NSNumber *pushup = [PADCalc getPU:@"55" soldierAge:age soldierSex:sex];
    NSNumber *situp = [PADCalc getSU:@"72" soldierAge:age soldierSex:sex];
    NSNumber *run = [PADCalc getRun:@"1100" soldierAge:age soldierSex:sex];
    NSNumber *score = [PADCalc compileScore:run scorePU:pushup scoreSU:situp soldierSex:sex];
    logging ? NSLog(@"%s:line:%d PU:%i SU:%i RUN:%i Score: %i", __func__, __LINE__,[pushup intValue], [situp intValue], [run intValue], [score intValue]) : nil;
#pragma mark -
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.menuChoices.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PADCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MenuCell" forIndexPath:indexPath];
    
    // Get the dictionary reference.
    NSDictionary *ref = [self.menuChoices objectAtIndex:indexPath.row];
    // Configure the cell
    cell.imageView.image = [UIImage imageNamed:[ref valueForKey:@"image"]];
    //cell.imageView.backgroundColor = [UIColor blackColor];
    cell.title.text = [ref valueForKey:@"title"];
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

// Uncomment this method to specify if the specified item is selected
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *ref = [self.menuChoices objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:[ref objectForKey:@"viewController"] sender:nil];
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}
/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/
#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize retval = CGSizeMake(100, 75);
    retval.height += 50; retval.width += 0; return retval;
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(20, 20, 20, 20);
}
-(NSArray *)menuChoices {
    if (!_menuChoices) {
        NSString *menuPlist = [[NSBundle mainBundle] pathForResource:@"MenuChoices(original)" ofType:@"plist"];
        //NSString *menuPlist = [[NSBundle mainBundle] pathForResource:@"MenuChoices" ofType:@"plist"];
        
        _menuChoices = [NSArray arrayWithContentsOfFile:menuPlist];
        return _menuChoices;
    } else {
        return _menuChoices;
    }
}


@end

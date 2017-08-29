//
//  CollectionViewController.h
//  APFT Commander
//
//  Created by Phillip Dieppa on 12/1/14.
//  Copyright (c) 2014 Phillip Dieppa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PADCollectionViewCell.h"

@interface PADCollectionViewController : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, retain) NSArray *menuChoices;

@end

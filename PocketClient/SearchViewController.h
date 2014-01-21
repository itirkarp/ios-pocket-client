//
//  SearchViewController.h
//  Ass11CustomApplication
//
//  Created by swin on 20/11/13.
//  Copyright (c) 2013 PM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController : UIViewController
- (IBAction)search:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *keywordsTextField;
@property (retain) NSMutableArray *searchedArticles;
@property(retain) UIView *overlayView;
@property(retain) UIActivityIndicatorView *activityIndicator;
@end

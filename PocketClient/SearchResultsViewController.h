//
//  SearchResultsViewController.h
//  Ass11CustomApplication
//
//  Created by swin on 23/11/13.
//  Copyright (c) 2013 PM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchResultsViewController : UITableViewController

- (void)prepareTableView:(NSArray *)searchedArticles;
@property (retain) NSArray *searchedArticles;

@end

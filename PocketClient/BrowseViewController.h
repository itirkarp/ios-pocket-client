//
//  BrowseViewController.h
//  Ass11CustomApplication
//
//  Created by swin on 20/11/13.
//  Copyright (c) 2013 PM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PocketAPI.h"

@interface BrowseViewController : UITableViewController

- (IBAction)logout:(id)sender;

@property(retain) UIView *overlayView;
@property(retain) UIActivityIndicatorView *activityIndicator;
@property(retain) NSArray *articles;
@property(retain) NSString *consumerKey;
@property (retain) PocketAPI *pocketAPI;

@end

//
//  BrowseDetailViewController.h
//  Ass11CustomApplication
//
//  Created by swin on 20/11/13.
//  Copyright (c) 2013 PM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Article.h"
#import <MessageUI/MessageUI.h> 

@interface BrowseDetailViewController : UIViewController<MFMailComposeViewControllerDelegate>

- (void)prepareDetailView:(Article *) article;
@property (weak, nonatomic) IBOutlet UITextView *headingTextView;

@property (weak, nonatomic) IBOutlet UITextView *bodyTextView;
- (IBAction)favouriteButton:(id)sender;
@property(retain) UIView *overlayView;
@property(retain) UIActivityIndicatorView *activityIndicator;
@property (retain) Article *article;
@property (retain) NSString *heading;
- (IBAction)share:(id)sender;
@property (retain) NSString *body;

@end

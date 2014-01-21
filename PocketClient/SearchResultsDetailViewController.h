//
//  SearchResultsDetailViewController.h
//  Ass11CustomApplication
//
//  Created by swin on 23/11/13.
//  Copyright (c) 2013 PM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Article.h"
#import <MessageUI/MessageUI.h> 

@interface SearchResultsDetailViewController : UIViewController<MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextView *bodyTextView;

@property (weak, nonatomic) IBOutlet UITextView *headingTextView;
- (void)prepareDetailView:(Article *)article;
@property (retain) Article *article;
- (IBAction)share:(id)sender;

@end

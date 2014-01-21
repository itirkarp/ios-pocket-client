//
//  FavoritesDetailViewController.m
//  Ass11CustomApplication
//
//  Created by swin on 20/11/13.
//  Copyright (c) 2013 PM. All rights reserved.
//

#import "FavoritesDetailViewController.h"
#import "Article.h"

@interface FavoritesDetailViewController ()

@end

@implementation FavoritesDetailViewController

@synthesize bodyTextView;
@synthesize article;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.bodyTextView.text = self.article.body;
    self.headingTextView.text = self.article.heading;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareDetailView:(Article*)articleDetail {
    self.article = articleDetail;
}

- (IBAction)share:(id)sender {
    // Email Subject
    NSString *emailTitle = self.headingTextView.text;
    // Email Content
    NSString *messageBody = self.bodyTextView.text;
    // To address
   
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end

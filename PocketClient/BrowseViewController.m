//
//  BrowseViewController.m
//  Ass11CustomApplication
//
//  Created by swin on 20/11/13.
//  Copyright (c) 2013 PM. All rights reserved.
//

#import "BrowseViewController.h"
#import "PocketAPI.h"
#import "Article.h"
#import "BrowseDetailViewController.h"


@interface BrowseViewController ()
@property (strong, nonatomic) UIViewController *initialViewController;
@end

@implementation BrowseViewController

@synthesize activityIndicator;
@synthesize overlayView;
@synthesize articles;
@synthesize consumerKey;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults) {
        NSString *username = [standardUserDefaults objectForKey:@"username"];
        if ([username length] != 0) {

        }
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Article"];
    self.articles = [[[self managedObjectContext] executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [refresh addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.articles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    Article *article = [self.articles objectAtIndex:indexPath.row];
    cell.textLabel.text = article.heading;
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (IBAction)refresh:(id)sender {
}

- (void)createArticle:(NSManagedObjectContext *)context itemId:(NSString *)itemId
          articleJSON:(NSDictionary *)articleJSON {
    NSManagedObject *article = [NSEntityDescription insertNewObjectForEntityForName:@"Article"
                                            inManagedObjectContext:context];
    [article setValue:itemId forKey:@"itemId"];
    NSString *body = [articleJSON objectForKey:@"excerpt"];
    [article setValue:body forKey:@"body"];
    [article setValue:[articleJSON objectForKey:@"resolved_title"] forKey:@"heading"];
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    [article setValue:[f numberFromString:[articleJSON objectForKey:@"favorite"]] forKey:@"favorite"];
    
    NSError *saveError = nil;
    if (![context save:&saveError]) {
        NSLog(@"Error saving article: %@ %@", saveError, [saveError localizedDescription]);
    }
}

- (void)handleGetResponse:(NSDictionary *)response {
    NSManagedObjectContext *context = [self managedObjectContext];
    [self deleteAllArticles:context];
    NSDictionary *list =  [response objectForKey:@"list"];

    for (NSString *itemId in list) {
        NSDictionary *articleJSON = [list objectForKey:itemId];
        if ([[articleJSON objectForKey:@"status"] isEqual: @"0"]) {
            [self createArticle:context itemId:itemId articleJSON:articleJSON];
        }
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Article"];
    self.articles = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    [self.tableView reloadData];
}

- (void)fetchAllArticles {
    NSDictionary *arguments = @{@"state" : @"all", @"since" : @"974874207"};
    [[PocketAPI sharedAPI] callAPIMethod:@"get"
                          withHTTPMethod:PocketAPIHTTPMethodPOST
                               arguments:arguments
                                 handler: ^(PocketAPI *api, NSString *apiMethod,NSDictionary *response, NSError *error){
                                     if ([response count] == 0) {
                                         UIAlertView *message = [[UIAlertView alloc] initWithTitle:@""
                                                                                           message:@"Could not refresh. Please try again later."
                                                                                          delegate:nil
                                                                                 cancelButtonTitle:@"OK"
                                                                                 otherButtonTitles:nil];
                                         [message show];
                                     } else {
                                         [self handleGetResponse:response];
                                     }
                                     [self.refreshControl endRefreshing];
                                 }];
}


- (IBAction)logout:(id)sender {
    [[PocketAPI sharedAPI] logout];
    [self deleteAllArticles:[self managedObjectContext]];
    [self.tableView reloadData];
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@""
                                                      message:@"You are now logged out."
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [message show];
}

- (IBAction)login:(id)sender {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pocketLoginStarted:)
                                                 name:PocketAPILoginStartedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pocketLoginFinished:)
                                                 name:PocketAPILoginFinishedNotification
                                               object:nil];
    [[PocketAPI sharedAPI] loginWithHandler: ^(PocketAPI *API, NSError *error){
        NSString *messageString = nil;
        if (error != nil)
        {
            messageString = @"There was an error logging you in, please try again.";
        }
        else
        {
            messageString = [NSString stringWithFormat:@"%@%@%@",@"Hi ",[API username],@"! You are now logged in."];
            [self fetchAllArticles];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:[API username] forKey:@"username"];
            [defaults synchronize];
        }
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@""
                                                          message:messageString
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
    }];
}

-(void)pocketLoginStarted:(NSNotification *)notification{
    self.overlayView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.overlayView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicator.center = self.overlayView.center;
    [self.overlayView addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
    [[UIApplication sharedApplication].keyWindow addSubview:self.overlayView];
}

-(void)pocketLoginFinished:(NSNotification *)notification{
    [self.activityIndicator removeFromSuperview];
    [self.overlayView removeFromSuperview];
}

- (void)deleteAllArticles:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Article"];
    NSArray *allArticles = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    for (NSManagedObject *managedObject in allArticles) {
        [context deleteObject:managedObject];
    }
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Error deleting articles: %@ %@", error, [error localizedDescription]);
    }
    self.articles = nil;
}

-(NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    Article *article = [self.articles objectAtIndex:indexPath.row];
    [[segue destinationViewController] prepareDetailView:article];
}

-(void)refreshView:(UIRefreshControl *)refresh {
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];

    [self fetchAllArticles];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, h:mm a"];
    NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@",
                             [formatter stringFromDate:[NSDate date]]];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
}

-(void) viewDidAppear:(BOOL)animated {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Article"];
    self.articles = [[[self managedObjectContext] executeFetchRequest:fetchRequest error:nil] mutableCopy];    
}

@end

//
//  FavoritesViewController.m
//  Ass11CustomApplication
//
//  Created by swin on 20/11/13.
//  Copyright (c) 2013 PM. All rights reserved.
//

#import "FavoritesViewController.h"
#import "Article.h"
#import "PocketAPI.h"
#import "FavoritesDetailViewController.h"

@interface FavoritesViewController ()

@end

@implementation FavoritesViewController
@synthesize favArticles;

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

    [self retrieveArticlesFromCoreData];
    
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
     return [self.favArticles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    Article *article = [self.favArticles objectAtIndex:indexPath.row];
    cell.textLabel.text = article.heading;
    return cell;
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

- (void)retrieveArticlesFromCoreData {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Article"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"favorite = '1'"];
    [fetchRequest setPredicate:predicate];
    self.favArticles = [[[self managedObjectContext] executeFetchRequest:fetchRequest error:nil] mutableCopy];
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
    [self retrieveArticlesFromCoreData];
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

-(NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
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
    self.favArticles = nil;
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    [[segue destinationViewController] prepareDetailView:[self.favArticles objectAtIndex:indexPath.row]];
}

@end

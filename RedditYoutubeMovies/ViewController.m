//
//  ViewController.m
//  RedditYoutubeMovies
//
//  Created by John N Blanchard on 8/25/16.
//  Copyright © 2016 John N Blanchard. All rights reserved.
//

#import "ViewController.h"
@import JavaScriptCore;
#import "TFHpple.h"
#import "YoutubePlayerViewController.h"

#define urlRedditString @"https://www.reddit.com/r/fullmoviesonyoutube"

@interface NSURL (Parsing)

- (NSString *) getParameterValueFor:(NSString *)parameter;

@end

@implementation NSURL (Parsing)

-(NSString *)getParameterValueFor:(NSString *)parameter
{
    NSString * q = [self query];
    NSArray * pairs = [q componentsSeparatedByString:@"&"];
    NSMutableDictionary * kvPairs = [NSMutableDictionary dictionary];
    for (NSString * pair in pairs) {
        NSArray * bits = [pair componentsSeparatedByString:@"="];
        NSString * key = [[bits objectAtIndex:0] stringByRemovingPercentEncoding];
        NSString * value = [[bits objectAtIndex:1] stringByRemovingPercentEncoding];
        [kvPairs setObject:value forKey:key];
    }
    NSString *valueToReturn = [kvPairs objectForKey:parameter];
    return valueToReturn;
}

@end

@interface MovieObject : NSObject

@property (strong) NSString *title;
@property (strong) NSURL *movieURL;

@end

@implementation MovieObject

@end

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong) NSArray *movieArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    TFHpple* redditParser = [TFHpple hppleWithHTMLData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlRedditString]]];
    NSMutableArray* titleArray = [NSMutableArray arrayWithArray:[redditParser searchWithXPathQuery:@"//p[@class=\"title\"]"]];
    NSLog(@"titleArray count is %ld", (long) [titleArray count]);
    NSInteger index = 0;
    NSMutableArray *mutableMovieArray = [[NSMutableArray alloc] initWithCapacity:[titleArray count]];
    while(index < [titleArray count])
    {
        TFHppleElement *e = [titleArray objectAtIndex:index];

        TFHppleElement *titleNode = [e firstChildWithTagName:@"a"];
        
        NSLog(@"movie title is %@", titleNode.content);
        NSLog(@"href = %@", [titleNode.attributes objectForKey:@"href"]);
        
        MovieObject *newMovie = [[MovieObject alloc] init];
        newMovie.title = titleNode.content;
        newMovie.movieURL = [NSURL URLWithString:[titleNode.attributes objectForKey:@"href"]];
        [mutableMovieArray addObject: newMovie];
        index++;
    }
    
    self.movieArray = mutableMovieArray;
}

- (BOOL)prefersStatusBarHidden
{
    return true;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.movieArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];

    MovieObject *movieObject = [self.movieArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = movieObject.title;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"vid" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    YoutubePlayerViewController* ypvc = (YoutubePlayerViewController*)segue.destinationViewController;
    NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
    
    MovieObject *movieObject = [self.movieArray objectAtIndex:indexPath.row];
    NSURL *movieURL = movieObject.movieURL;
    if(movieURL)
    {
        ypvc.ytID = [movieURL getParameterValueFor:@"v"];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

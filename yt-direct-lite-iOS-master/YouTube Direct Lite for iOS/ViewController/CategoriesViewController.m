#import "CategoriesViewController.h"
#import "VideoData.h"
#import "GTLYouTube.h"
#import "VideoPlayerViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "Utils.h"
#import "ChannelsViewController.h"

@implementation CategoriesViewController

- (id)init {
  self = [super init];
  if (self) {
      _categories = [[NSArray alloc] init];
  }
  return self;
}

- (void)viewDidLoad {

  [super viewDidLoad];
    self.navigationItem.title = @"CATEGORIES";

  self.tableView = [[UITableView alloc] initWithFrame:(CGRectZero) style:(UITableViewStylePlain)];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.rowHeight = 40;
  self.tableView.separatorColor = [UIColor clearColor];
  self.view = self.tableView;
    
  YouTubeAPILibs *youtubeApiLibs = [YouTubeAPILibs sharedManager];
  youtubeApiLibs.delegate = self;
  [youtubeApiLibs getCategoriesWithRegionCode:@"JP" andLanguage:@"ja-JP"];
    
}

// プロトコル　ー　コルバック機能を返す
- (void)getYouTubeUploads:(YouTubeAPILibs *)getUploads withRequestType:(YTRequestType) type
     didFinishWithResults:(NSArray *)results{
    
    //[1] 全てカテゴリを習得
    if (type == YTRequestTypeCategories) {
        NSLog(@"categories data %@",results);
        for (int i =0 ; i < [results count]; i++) {
            GTLYouTubeGuideCategory *data = [results objectAtIndex:i];
            
            NSLog(@"=====================================\n");
            NSLog(@"CATEGORIES                           \n");
            NSLog(@" title          [%@] \n",data.snippet.title);
            NSLog(@" identifier     [%@] \n",[data identifier]);
            NSLog(@"=====================================\n");
            
        }
        
        self.categories = results;
    }
    

    
    [self.tableView reloadData];
    
}


#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *const kReuseIdentifier = @"imageCell";

  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kReuseIdentifier];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleSubtitle)
                                  reuseIdentifier:kReuseIdentifier];
  }
  GTLYouTubeGuideCategory *data = [self.categories objectAtIndex:indexPath.row];
  cell.textLabel.text = data.snippet.title;
//  cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ -- %@ views",
//                               [Utils humanReadableFromYouTubeTime:vidData.getDuration],
//                               vidData.getViews];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  /*GOTO CHANNEL*/
    NSString *channelIdentifier = [[self.categories objectAtIndex:indexPath.row] identifier];
    ChannelsViewController *channelsViewController = [[ChannelsViewController alloc]init];
    channelsViewController.identifier = channelIdentifier;
    [self.navigationController pushViewController:channelsViewController animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self.categories count];
}

@end

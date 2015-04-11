#import "ChanelListViewController.h"
#import "GTLYouTube.h"
#import "VideoPlayerViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "Utils.h"
#import "ChannelData.h"

@implementation ChanelListViewController

- (id)init {
  self = [super init];
  if (self) {
      _channelList = [[NSArray alloc] init];
  }
  return self;
}

- (void)viewDidLoad {

  [super viewDidLoad];

  self.tableView = [[UITableView alloc] initWithFrame:(CGRectZero) style:(UITableViewStylePlain)];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.rowHeight = 80;
  self.tableView.separatorColor = [UIColor clearColor];
  self.view = self.tableView;
    
  // ライブラリを呼ぶ
  YouTubeAPILibs *youtubeApiLibs = [YouTubeAPILibs sharedManager];
  youtubeApiLibs.delegate = self;
  [youtubeApiLibs getMyChanel];

}

// プロトコル　ー　コルバック機能を返す
- (void)getYouTubeUploads:(YouTubeAPILibs *)getUploads withRequestType:(YTRequestType) type
     didFinishWithResults:(NSArray *)results{
    
    if (type == YTRequestTypeGetMyChanel) {
        
         for ( int i = 0 ; i < [results count]; i++) {
             NSLog(@"=====================================\n");
             ChannelData *sub = [results objectAtIndex:i];
             NSLog(@"channel title         [%@] \n",sub.getTitle);
             NSLog(@"channel description   [%@] \n",sub.getDescription);
             NSLog(@"channel url           [%@] \n",sub.getDescription);
             NSLog(@"=====================================\n");
         }
        
        self.channelList = results;
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
  ChannelData *subCh = [self.channelList objectAtIndex:indexPath.row];
  cell.imageView.image = subCh.thumbnail;
  cell.textLabel.text = [subCh getTitle];
  cell.detailTextLabel.text = [subCh getDescription];
    
  return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self.channelList count];
}

@end

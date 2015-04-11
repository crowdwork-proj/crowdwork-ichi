#import "MyPlayListViewController.h"
#import "VideoData.h"
#import "GTLYouTube.h"
#import "VideoPlayerViewController.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import "Utils.h"

@implementation MyPlayListViewController

- (id)init {
  self = [super init];
  if (self) {
      _videos = [[NSArray alloc] init];
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
  [youtubeApiLibs getMyPlayList];

}

// プロトコル　ー　コルバック機能を返す
- (void)getYouTubeUploads:(YouTubeAPILibs *)getUploads withRequestType:(YTRequestType) type
     didFinishWithResults:(NSArray *)results{
    
    if (type == YTRequestTypeShowMyListVideo) {

        for (int i =0 ; i < [results count]; i++) {
            VideoData *data = [results objectAtIndex:i];
            NSLog(@"=====================================\n");
            NSLog(@" thumbnail data [%@] \n",data.thumbnail);
            NSLog(@" title          [%@] \n",[data getTitle]);
            NSLog(@" view           [%@] \n",data.getViews);
            NSLog(@" duration       [%@] \n",[Utils humanReadableFromYouTubeTime:data.getDuration]);
            NSLog(@"=====================================\n");
        }
        self.videos = results;
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
  VideoData *vidData = [self.videos objectAtIndex:indexPath.row];
  cell.imageView.image = vidData.thumbnail;
  cell.textLabel.text = [vidData getTitle];
  cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ -- %@ views",
                               [Utils humanReadableFromYouTubeTime:vidData.getDuration],
                               vidData.getViews];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    VideoData *selectedVideo = [_videos objectAtIndex:indexPath.row];
    VideoPlayerViewController *videoController = [[VideoPlayerViewController alloc] init];
    videoController.videoData = selectedVideo;
    [[self navigationController] pushViewController:videoController animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self.videos count];
}

@end

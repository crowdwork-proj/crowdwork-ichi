#import "PlaylistsViewController.h"
#import "GTLYouTube.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "Utils.h"
#import "VideosViewController.h"

@implementation PlaylistsViewController

- (id)init {
    self = [super init];
    if (self) {
        _playlists = [[NSArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.navigationItem.title = @"PLAYLISTS";
    self.tableView = [[UITableView alloc] initWithFrame:(CGRectZero) style:(UITableViewStylePlain)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 40;
    self.tableView.separatorColor = [UIColor clearColor];
    self.view = self.tableView;
    
    YouTubeAPILibs *youtubeApiLibs = [YouTubeAPILibs sharedManager];
    youtubeApiLibs.delegate = self;
    [youtubeApiLibs getPlaylistsWithChannelIdentifier:self.identifier andMaxResults:20];
    
}

// プロトコル　ー　コルバック機能を返す
- (void)getYouTubeUploads:(YouTubeAPILibs *)getUploads withRequestType:(YTRequestType) type
     didFinishWithResults:(NSArray *)results{
    
    //[3]: チャネルに対して全てプレイリストを習得
    if (type == YTRequestTypePlaylists) {
        NSLog(@"playlists data %@",results);
        for (int i =0 ; i < [results count]; i++) {
            GTLYouTubePlaylistItem *data = [results objectAtIndex:i];
            NSLog(@"=====================================\n");
            NSLog(@"PLAYLIST_LIST                        \n");
            NSLog(@" title          [%@] \n",data.snippet.title);
            NSLog(@" identifier     [%@] \n",[data identifier]);
            NSLog(@"=====================================\n");
            
        }
        self.playlists = results;
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
    GTLYouTubePlaylist *data = [self.playlists objectAtIndex:indexPath.row];
    cell.textLabel.text = data.snippet.title;
    //  cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ -- %@ views",
    //                               [Utils humanReadableFromYouTubeTime:vidData.getDuration],
    //                               vidData.getViews];
    // Fetch synchronously the full sized image.
    NSURL *url = [NSURL URLWithString:data.snippet.thumbnails.defaultProperty.url];
    NSData *imageData = [NSData dataWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:imageData];
    
    cell.imageView.image =image;
    #pragma mark - GTLYouTubePlaylist data structure, can get image from thumbnails
    /**
     {
     
     "kind": "youtube#playlist",
     "etag": "\"kYnGHzMaBhcGeLrcKRx6PAIUosY/dM76P-zTVdo_yM3RIfmn_1O0VwQ\"",
     "id": "PL3ZQ5CpNulQlbtPm4OJKTstowModhe7_a",
     "snippet": {
     "publishedAt": "2015-04-14T16:19:24.000Z",
     "channelId": "UCYfdidRxbB8Qhf0Nx7ioOYw",
     "title": "Vučić: Azerbejdžan zainteresovan da ulaže u Srbiju",
     "description": "",
     "thumbnails": {
     "default": {
     "url": "https://i.ytimg.com/vi/6qIOeMSAaS8/default.jpg",
     "width": 120,
     "height": 90
     },
     "medium": {
     "url": "https://i.ytimg.com/vi/6qIOeMSAaS8/mqdefault.jpg",
     "width": 320,
     "height": 180
     },
     "high": {
     "url": "https://i.ytimg.com/vi/6qIOeMSAaS8/hqdefault.jpg",
     "width": 480,
     "height": 360
     }
     },
     "channelTitle": "News",
     "localized": {
     "title": "Vučić: Azerbejdžan zainteresovan da ulaže u Srbiju",
     "description": ""
     }
     }
     */
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    /*GOTO VIDEOS*/
        NSString *videosIdentifier = [[self.playlists objectAtIndex:indexPath.row] identifier];
        VideosViewController *videosViewController = [[VideosViewController alloc]init];
    videosViewController.identifier = videosIdentifier;
        [self.navigationController pushViewController:videosViewController animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.playlists count];
}

@end

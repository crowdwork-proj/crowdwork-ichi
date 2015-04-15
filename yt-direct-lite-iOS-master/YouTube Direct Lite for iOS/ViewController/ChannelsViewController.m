#import "ChannelsViewController.h"
#import "GTLYouTube.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "Utils.h"
#import "PlaylistsViewController.h"

@implementation ChannelsViewController

- (id)init {
    self = [super init];
    if (self) {
        _channels = [[NSArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.navigationItem.title = @"CHANNELS";
    self.tableView = [[UITableView alloc] initWithFrame:(CGRectZero) style:(UITableViewStylePlain)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 40;
    self.tableView.separatorColor = [UIColor clearColor];
    self.view = self.tableView;
    
    YouTubeAPILibs *youtubeApiLibs = [YouTubeAPILibs sharedManager];
    youtubeApiLibs.delegate = self;
    [youtubeApiLibs getChannelsWithCategoryIdentifier:self.identifier andMaxResults:20];
    
}

// プロトコル　ー　コルバック機能を返す
- (void)getYouTubeUploads:(YouTubeAPILibs *)getUploads withRequestType:(YTRequestType) type
     didFinishWithResults:(NSArray *)results{
    
    //[2]: カテゴリの全てチャネルを習得
    if (type == YTRequestTypeChannels) {
        NSLog(@"chanels data %@",results);
        for (int i =0 ; i < [results count]; i++) {
            GTLYouTubeChannel *data = [results objectAtIndex:i];
            
            NSLog(@"=====================================\n");
            NSLog(@"CHANNELS                             \n");
            NSLog(@" title          [%@] \n",data.snippet.title);
            NSLog(@" identifier     [%@] \n",[data identifier]);
            NSLog(@"=====================================\n");
            
        }
        
        self.channels = results;
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
    GTLYouTubeChannel *data = [self.channels objectAtIndex:indexPath.row];
    cell.textLabel.text = data.snippet.title;
    //  cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ -- %@ views",
    //                               [Utils humanReadableFromYouTubeTime:vidData.getDuration],
    //                               vidData.getViews];
    // Fetch synchronously the full sized image.
    NSURL *url = [NSURL URLWithString:data.snippet.thumbnails.defaultProperty.url];
    NSData *imageData = [NSData dataWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:imageData];
    
    cell.imageView.image =image;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    /*GOTO PLAYLISTS*/
    NSString *playlistIdentifier = [[self.channels objectAtIndex:indexPath.row] identifier];
    PlaylistsViewController *playlistsViewController = [[PlaylistsViewController alloc]init];
    playlistsViewController.identifier = playlistIdentifier;
    [self.navigationController pushViewController:playlistsViewController animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.channels count];
}

@end

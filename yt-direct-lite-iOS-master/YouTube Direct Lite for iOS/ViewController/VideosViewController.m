#import "VideosViewController.h"
#import "GTLYouTube.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "Utils.h"

@implementation VideosViewController

- (id)init {
    self = [super init];
    if (self) {
        _videos = [[NSArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.navigationItem.title = @"VIDEOS";
    self.tableView = [[UITableView alloc] initWithFrame:(CGRectZero) style:(UITableViewStylePlain)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 40;
    self.tableView.separatorColor = [UIColor clearColor];
    self.view = self.tableView;
    
    YouTubeAPILibs *youtubeApiLibs = [YouTubeAPILibs sharedManager];
    youtubeApiLibs.delegate = self;
    [youtubeApiLibs getVideosWithPlaylistIdentifier:self.identifier andMaxResults:20];
    
}

// プロトコル　ー　コルバック機能を返す
- (void)getYouTubeUploads:(YouTubeAPILibs *)getUploads withRequestType:(YTRequestType) type
     didFinishWithResults:(NSArray *)results{
    
    //[4]: プレイリストのビデオを習得
    if (type == YTRequestTypeVideos) {
        NSLog(@"playlist data %@",results);
        for (int i =0 ; i < [results count]; i++) {
            GTLYouTubePlaylistItem *data = [results objectAtIndex:i];
            NSLog(@"=====================================\n");
            NSLog(@"VIDEOS                               \n");
            NSLog(@" title          [%@] \n",data.snippet.title);
            NSLog(@" identifier     [%@] \n",[data identifier]);
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
    GTLYouTubePlaylistItem *data = [self.videos objectAtIndex:indexPath.row];
    cell.textLabel.text = data.snippet.title;
    //  cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ -- %@ views",
    //                               [Utils humanReadableFromYouTubeTime:vidData.getDuration],
    //                               vidData.getViews];
    
#pragma mark - GTLYouTubePlaylistItem data structure, can get image from thumbnails
    /*
     "kind": "youtube#playlistItem",
     "etag": "\"kYnGHzMaBhcGeLrcKRx6PAIUosY/hCOmx-GOcxEdeLooexmhHUTzS2k\"",
     "id": "PL9PVTVr08ahxWrktQIXDKuUSsfb0YkxWOySQEHvN6-34",
     "snippet": {
     "publishedAt": "2015-04-14T16:19:51.000Z",
     "channelId": "UCYfdidRxbB8Qhf0Nx7ioOYw",
     "title": "Vučić: Azerbejdžan zainteresovan da ulaže u Srbiju",
     "description": "Premijer Srbije Aleksandar Vučić razgovarao je danas u Bakuu s predsednikom Azerbejdžana Ilhamom Alijevim o saradnji u oblasti infrastrukture, poljoprivrede, energetike, i najavio dolazak azerbejdžanskog predsednika i privrednika te zemlje u Srbiju pre kraja godine.\nRadio-televizija Vojvodine  http://www.rtv.rs\nServis odloženog gledanja i slušanja http://media.rtv.rs",
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
     "playlistId": "PL3ZQ5CpNulQlbtPm4OJKTstowModhe7_a",
     "position": 0,
     "resourceId": {
     "kind": "youtube#video",
     "videoId": "6qIOeMSAaS8"
     }
     */
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.videos count];
}

@end

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "GTLYouTube.h"
#import "VideoData.h"
#import "YouTubeAPILibs.h"

@interface VideoListViewController : UITableViewController<YouTubeAPILibsDelegate>

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSArray *videos;

@end
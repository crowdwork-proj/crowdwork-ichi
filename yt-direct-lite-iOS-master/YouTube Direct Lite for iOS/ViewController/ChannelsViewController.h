//
//  ChannelsViewController.h
//  YouTube Direct Lite for iOS
//
//  Created by imybags.com on 14/4/15.
//  Copyright (c) 2015 Google. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "GTLYouTube.h"
#import "YouTubeAPILibs.h"

@interface ChannelsViewController : UITableViewController<YouTubeAPILibsDelegate>

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSArray *channels;

@property(nonatomic, strong) NSString *identifier;

@end

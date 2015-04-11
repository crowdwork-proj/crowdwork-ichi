//
//  VideoPlayerViewController.m
//  YouTube Direct Lite for iOS
//
//  Created by Ibrahim Ulukaya on 11/5/13.
//  Copyright (c) 2013 Google. All rights reserved.
//

#import "VideoPlayerViewController.h"
#import "Utils.h"

@interface VideoPlayerViewController ()

@end

@implementation VideoPlayerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  NSError *error = nil;
  NSString *path = [[NSBundle mainBundle] pathForResource:@"iframe-player" ofType:@"html"];
  NSString *embedHTML =
      [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
  NSString *embedHTMLWithId = [NSString stringWithFormat:embedHTML, _videoData.getYouTubeId];

  self.webView = [[UIWebView alloc]
      initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
  [self.webView loadHTMLString:embedHTMLWithId baseURL:[[NSBundle mainBundle] resourceURL]];
  [self.webView setDelegate:self];
  self.webView.allowsInlineMediaPlayback = YES;
  self.webView.mediaPlaybackRequiresUserAction = NO;

  [self.view addSubview:_webView];

}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration {
  CGRect f = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
  self.webView.frame = f;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

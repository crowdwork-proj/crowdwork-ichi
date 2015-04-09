//
//  Utils.h
//  YouTube Direct Lite for iOS
//
//  Created by Ibrahim Ulukaya on 11/6/13.
//  Copyright (c) 2013 Google. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const DEFAULT_KEYWORD = @"ytdl";
static NSString *const UPLOAD_PLAYLIST = @"Replace me with the playlist ID you want to upload into";

static NSString *const kClientID = @"123907724495-ve9pcqkdge3pci7ngtdgfn5iismcfebu.apps.googleusercontent.com";
static NSString *const kClientSecret = @"M9YaEZfiquZKjn7OquG2kn0r";

static NSString *const kKeychainItemName = @"Youtube";

@interface Utils : NSObject

+ (UIAlertView*)showWaitIndicator:(NSString *)title;
+ (void)showAlert:(NSString *)title message:(NSString *)message;
+ (NSString *)humanReadableFromYouTubeTime:(NSString *)youTubeTimeFormat;

@end

//
//  VideoData.h
//  YouTube Direct Lite for iOS
//
//  Created by Ibrahim Ulukaya on 10/21/13.
//  Copyright (c) 2013 Google. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTLYouTube.h"

@interface ChannelData : NSObject
@property(nonatomic, strong) GTLYouTubeSubscription *subChannel;
@property(nonatomic, strong) UIImage *thumbnail;
@property(nonatomic, strong) UIImage *fullImage;
-(NSString *)getTitle;
-(NSString *)getThumbUri;
-(NSString *)getDescription;

@end

//
//  VideoData.m
//  YouTube Direct Lite for iOS
//
//  Created by Ibrahim Ulukaya on 10/21/13.
//  Copyright (c) 2013 Google. All rights reserved.
//

#import "ChannelData.h"

@implementation ChannelData

-(NSString *)getTitle {
    return self.subChannel.snippet.title;
}
-(NSString *)getThumbUri {
    return self.subChannel.snippet.thumbnails.defaultProperty.url;
}
-(NSString *)getDescription{
    return self.subChannel.snippet.description;
}

@end

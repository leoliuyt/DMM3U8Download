//
//  DMM3u8Parse.m
//  DMM3U8Download
//
//  Created by lbq on 2017/8/23.
//  Copyright © 2017年 lbq. All rights reserved.
//

#import "DMM3u8Parse.h"
@interface DMM3u8Parse()
@property (nonatomic, copy) NSString *urlString;

@end

@implementation DMM3u8Parse
- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

- (void)parseM3U8With:(NSURL *)url completionHandler:(void(^)(NSArray<NSString *>*infos ,NSError *error))completionHandler
{
    self.urlString = url.absoluteString;
    
    NSError *error;
    NSStringEncoding encoding;
    
    NSString *dataString = [[NSString alloc] initWithContentsOfURL:url usedEncoding:&encoding error:&error];
    /*
     #EXTM3U
     #EXT-X-VERSION:3
     #EXT-X-MEDIA-SEQUENCE:0
     #EXT-X-ALLOW-CACHE:YES
     #EXT-X-TARGETDURATION:11
     #EXTINF:10.080000,
     video_000.ts
     #EXTINF:10.000000,
     video_001.ts
     #EXTINF:10.000000,
     video_002.ts
     #EXTINF:10.000000,
     video_003.ts
     #EXTINF:10.000000,
     video_004.ts
     #EXTINF:10.000000,
     video_005.ts
     #EXTINF:10.000000,
     video_006.ts
     #EXTINF:10.000000,
     video_007.ts
     #EXTINF:10.000000,
     video_008.ts
     #EXTINF:10.000000,
     video_009.ts
     #EXTINF:10.000000,
     video_010.ts
     #EXTINF:0.880000,
     video_011.ts
     #EXT-X-ENDLIST
     */
    //获取m3u8的内容出错
    if (error) {
        return;
    }
    
    //判断m3u8的内容是否正确
    NSRange range = [dataString rangeOfString:@"#EXTINF"];
    
    if (range.location == NSNotFound) {
        return;
    }
    
    NSURL *baseUrl = [url URLByDeletingLastPathComponent];
    
    [self tsInfoWithM3U8String:dataString baseUrlStr:baseUrl.absoluteString completionHandler:completionHandler];
}

//获取ts信息
- (void)tsInfoWithM3U8String:(NSString *)m3u8Str baseUrlStr:(NSString *)baseUrlStr completionHandler:(void(^)(NSArray<NSString *>*infos ,NSError *error))completionHandler{
    
    NSArray *components = [m3u8Str componentsSeparatedByString:@"\n"];
    
    NSMutableArray *durations = [NSMutableArray array];
    NSMutableArray *urlArray = [NSMutableArray array];
    
    for (NSString *infoString in components) {
        
        NSRange durationRange = [infoString rangeOfString:@"#EXTINF:"];
        NSRange tsRange = [infoString rangeOfString:@".ts"];
        
        if (durationRange.location != NSNotFound) {
            NSString *durationStr = [infoString substringFromIndex:durationRange.length];
            [durations addObject:durationStr];
        }
        else if (tsRange.location != NSNotFound) {
            [urlArray addObject:infoString];
        }
    }
    NSMutableArray *segmentInfos = [NSMutableArray arrayWithCapacity:urlArray.count];
    for (int i = 0; i<urlArray.count; i++) {
        NSString *tsURL = urlArray[i];
        tsURL = [baseUrlStr stringByAppendingString:tsURL];
        [segmentInfos addObject:tsURL];
    }
    completionHandler(segmentInfos,nil);
}


@end

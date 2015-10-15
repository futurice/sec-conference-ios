//
//  Event.m
//  FestApp
//
//  Created by Daniel Lehtovirta on 12/08/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import "Event.h"

@implementation Event


- (instancetype)initFromJSON:(NSDictionary *)json
{
    self = [super init];
    if (self) {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        
        _begin    = [NSDate cast:[dateFormatter dateFromString:json[@"start_time"]]];
        _end      = [NSDate cast:[dateFormatter dateFromString:json[@"end_time"]]];
        _location = [NSString cast:json[@"location"]];
        
        if(!_location) {
            _location = @"Unknown Location";
        }
        
        _day             = [NSString cast:json[@"day"]];
        _artist          = [NSString cast:json[@"artists"]];
        _title           = [NSString cast:json[@"title"]];
        _info            = [NSString cast:json[@"description"]]; // "description" is an NSObject method
        _starredCount    = [NSNumber cast:json[@"starredCount"]];
        _identifier      = [NSString cast:json[@"_id"]];
        _imageURL        = [NSString cast:json[@"image_url"]];
        _speakerImageUrl = [NSString cast:json[@"speaker_image_url"]];
        _speakerRole     = [NSString cast:json[@"speaker_role"]];
        _bar_camp        = (NSNumber *)json[@"bar_camp"];
        _linkedIn        = [NSString cast:json[@"linkedin_url"]];
        _twitter         = [NSString cast:json[@"twitter_handle"]];
                     
    }
    return self;
}

- (NSString *)stageAndTimeIntervalString
{
    NSString *end = [self.end.hourAndMinuteString isEqualToString:@"23:59"] ? @"00:00" : self.end.hourAndMinuteString;
    return [NSString stringWithFormat:@"%@ %@–%@ %@", self.begin.weekdayName, self.begin.hourAndMinuteString, end, self.location];
}

@end

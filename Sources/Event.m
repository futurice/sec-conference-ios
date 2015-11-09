//
//  Event.m
//  FestApp
//
//  Created by Daniel Lehtovirta on 12/08/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import "Event.h"

@implementation Speaker

@end


@implementation Event

- (instancetype)initWithDictionary:(NSDictionary *)json
{
    self = [super init];
    if (self) {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        dateFormatter.calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierISO8601];
        dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT: 0];
        dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_GB"];

        _begin    = [NSDate cast:[dateFormatter dateFromString:json[@"start_time"]]];
        _end      = [NSDate cast:[dateFormatter dateFromString:json[@"end_time"]]];
        _location = [NSString stringOrNil:json[@"location"]];
        
        if(!_location) {
            _location = @"Unknown Location";
        }
        
        _day             = [NSString stringOrNil:json[@"day"]];
        _title           = [NSString stringOrNil:json[@"title"]];
        _info            = [NSString stringOrNil:json[@"description"]]; // "description" is an NSObject method
        _starredCount    = [NSNumber cast:json[@"starredCount"]];
        _identifier      = [NSString stringOrNil:json[@"_id"]];
        _bar_camp        = (NSNumber *)json[@"bar_camp"];
        _imageURL        = [NSString stringOrNil:json[@"image_url"]];

        NSMutableArray *speakers = [NSMutableArray new];

        if ([NSString stringOrNil:json[@"artists"]]) {
            Speaker *speaker1 = [Speaker new];
            speaker1.name = [NSString stringOrNil:json[@"artists"]];
            speaker1.role = [NSString stringOrNil:json[@"speaker_role"]];
            speaker1.imageURL = [NSString stringOrNil:json[@"speaker_image_url"]];
            speaker1.linkedIn = [NSString stringOrNil:json[@"linkedin_url"]];
            speaker1.twitter = [NSString stringOrNil:json[@"twitter_handle"]];
            [speakers addObject:speaker1];
        }

        if ([NSString stringOrNil:json[@"artists_2"]]) {
            Speaker *speaker2 = [Speaker new];
            speaker2.name = [NSString stringOrNil:json[@"artists_2"]];
            speaker2.role = [NSString stringOrNil:json[@"speaker_role_2"]];
            speaker2.imageURL = [NSString stringOrNil:json[@"speaker_image_url_2"]];
            speaker2.linkedIn = [NSString stringOrNil:json[@"linkedin_url_2"]];
            speaker2.twitter = [NSString stringOrNil:json[@"twitter_handle_2"]];
            [speakers addObject:speaker2];
        }

        if ([NSString stringOrNil:json[@"artists_3"]]) {
            Speaker *speaker3 = [Speaker new];
            speaker3.name = [NSString stringOrNil:json[@"artists_3"]];
            speaker3.role = [NSString stringOrNil:json[@"speaker_role_3"]];
            speaker3.imageURL = [NSString stringOrNil:json[@"speaker_image_url_3"]];
            speaker3.linkedIn = [NSString stringOrNil:json[@"linkedin_url_3"]];
            speaker3.twitter = [NSString stringOrNil:json[@"twitter_handle_3"]];
            [speakers addObject:speaker3];
        }

        _speakers = speakers;
    }
    return self;
}

- (NSString *)stageAndTimeIntervalString
{
    NSString *end = [self.end.hourAndMinuteString isEqualToString:@"23:59"] ? @"00:00" : self.end.hourAndMinuteString;
    return [NSString stringWithFormat:@"%@ %@–%@ %@", self.begin.weekdayName, self.begin.hourAndMinuteString, end, self.location];
}

@end

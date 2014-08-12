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
        _location    = [NSString cast:json[@"location"]];
        
        if(!_location) {
            _location = @"Unknown Location";
        }
        
        _day = [NSString cast:json[@"day"]];

        _artists = [NSArray cast:json[@"artists"]];
        
        _title = [NSString cast:json[@"title"]];
        _description = [NSString cast:json[@"description"]];
        _starredCount = [NSNumber cast:json[@"starredCount"]];
        _identifier = [NSString cast:json[@"_id"]];
    
        _imageURL = [NSString cast:json[@"imageURL"]];
        
    }
    return self;
}

@end

//
//  NewsItem.m
//  FestApp
//
//  Created by Oleg Grenrus on 10/06/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import "NewsItem.h"

@implementation NewsItem

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];

        _title = [NSString stringOrNil:dict[@"title"]];
        _content = [NSString stringOrNil:dict[@"content"]]; // TODO: sanitize me
        _published = [dateFormatter dateFromString:dict[@"published"]];
    }
    return self;
}

@end

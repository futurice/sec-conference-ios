//
//  NSString+Additions.m
//  FestApp
//
//

#import "NSString+Additions.h"

@implementation NSString (Additions)

- (id)JSONValue
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    id value = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        NSLog(@"ERROR parsing: %@, error %@", self, error);
    }
    return value;
}

+ (NSString *)stringOrNil:(NSObject*)obj
{
    NSString *s = [NSString cast:obj];
    return [s isEqualToString:@""] ? nil : s;
}

@end

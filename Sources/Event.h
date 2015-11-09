//
//  Event.h
//  FestApp
//


@interface Speaker : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *role;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) NSString *linkedIn;
@property (nonatomic, strong) NSString *twitter;

@end

@interface Event : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)json;

@property (nonatomic, strong) NSDate *begin;
@property (nonatomic, strong) NSDate *end;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *day;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *info;
@property (nonatomic, strong) NSNumber *starredCount;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSNumber *bar_camp;
@property (nonatomic, strong) NSNumber *key_talk;
@property (nonatomic, strong) NSString *imageURL;

@property (nonatomic, strong) NSArray *speakers;

- (NSString *)stageAndTimeIntervalString;

@end

//
//  Event.h
//  FestApp
//

@interface Event : NSObject


- (instancetype)initFromJSON:(NSDictionary *)json;

@property (nonatomic, strong) NSDate *begin;
@property (nonatomic, strong) NSDate *end;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *day;

@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSNumber *starredCount;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) NSString *speakerRole;
@property (nonatomic, strong) NSNumber *bar_camp;
@property (nonatomic, strong) NSString *linkedIn;
@property (nonatomic, strong) NSString *twitter;

- (NSString *)stageAndTimeIntervalString;

@end

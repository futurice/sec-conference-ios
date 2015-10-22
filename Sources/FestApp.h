#import "NSDate+Additions.h"
#import "NSString+Additions.h"
#import "UIView+XYWidthHeight.h"

#define kResourceBaseURL           @"https://sec-conference-server.herokuapp.com"
#define FEST_FESTIVAL_JSON_URL     @"/api/v1/festival"
#define FEST_NEWS_JSON_URL         @"/api/v1/news"
#define FEST_GIGS_JSON_URL         @"/api/v1/events"
#define FEST_INFO_JSON_URL         @"/api/v1/info"

#define kResourceLastUpdatedPrefix @"lastModified"

// Resource poll interval in seconds
#ifdef NDEBUG
#define kResourcePollInterval      1
#else
#define kResourcePollInterval      1
#endif

#define kRefreshIntervalInHours    (6)

#define kAlertIntervalInMinutes    15

#define kOneMinute                (60)
#define kOneHour                  (60*60)
#define kDayDelimiterHour          6

#define kHourWidth                 200
#define kVenueRowHeight            48

#define kLatestSeenNewsPubDateKey             @"latestSeenNewsPubDate"
#define kLastRefreshTimestampKey              @"lastRefreshTimestamp"
#define kFavoritingInstructionAlreadyShownKey @"favoritingInstructionAlreadyShown"
#define kFavoritingInstructionShownCounterKey @"favoritingInstructionShownCounter"
#define kUniqueUserIDKey                      @"unique user id"
#define kDistanceFromFestKey                  @"distance from fest"

// Notifications
#define kNotificationForLoadedGigImage        @"loaded gig image"
#define kNotificationForFailedLoadingGigImage @"failed loading gig image"

// Colors
#define RGB_COLOR(r,g,b)  ([UIColor colorWithRed:r/255.0f green: g/255.0f blue: b/255.0f alpha:1])
#define SXC_COLOR_ORANGE  RGB_COLOR(240, 142, 12)

// Fonts

#define SXC_FONT_REGULAR @"AvenirNext-Regular"
#define SXC_FONT_MEDIUM @"AvenirNext-Medium"
#define SXC_FONT_DEMI_BOLD @"AvenirNext-DemiBold"

// Delegate
#define APPDELEGATE ((FestAppDelegate *)[[UIApplication sharedApplication] delegate])

// TODO: move me
@interface NSObject (Cast)
+ (instancetype)cast:(id)object;
@end

@implementation NSObject (Cast)
+ (instancetype)cast:(id)object
{
    return [object isKindOfClass:self] ? object : nil;
}
@end

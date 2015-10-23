//
//  FestAppAppDelegate.h
//  FestApp
//

#import <UIKit/UIKit.h>

#import "FestScheduleViewController.h"
#import "FestNewsViewController.h"
#import "FestEventsViewController.h"
#import "FestMapViewController.h"
#import "FestInfoViewController.h"
#import "FestBarCampViewController.h"

#import "Gig.h"
#import "NewsItem.h"
#import "InfoItem.h"

@class InfoViewController;

@interface FestAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet UINavigationController *navController;

@property (nonatomic, strong) IBOutlet FestScheduleViewController *scheduleViewController;
@property (nonatomic, strong) IBOutlet FestNewsViewController *newsViewController;
@property (nonatomic, strong) IBOutlet FestEventsViewController *eventsViewController;
@property (nonatomic, strong) FestBarCampViewController *barCampViewController;
@property (nonatomic, strong) IBOutlet FestMapViewController *mapViewController;
@property (nonatomic, strong) IBOutlet FestInfoViewController *infoViewController;

- (IBAction)showSchedule:(id)sender;
- (IBAction)showNews:(id)sender;
- (IBAction)showKeyTalks:(id)sender;
- (IBAction)showBarCamps:(id)sender;
- (IBAction)showMap:(id)sender;
- (IBAction)showGeneralInfo:(id)sender;

- (IBAction)showLambdaCalculus:(id)sender;

- (void)showNewsItem:(NewsItem *)newsItem;
- (void)showInfoItem:(InfoItem *)infoItem;
- (void)showGig:(Gig *)gig;
- (void)showEvent:(Event *)event;

@end

//
//  FestAppDelegate.m
//  FestApp
//

#import "FestAppDelegate.h"

#import "Gig.h"
#import "NSDate+Additions.h"
#import "UIViewController+Additions.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "FestDataManager.h"
#import "AFNetworkActivityIndicatorManager.h"

#import "FestEventViewController.h"
#import "FestNewsItemViewController.h"
#import "FestWebContentViewController.h"

@interface FestAppDelegate ()

@end

@implementation FestAppDelegate

#pragma mark Application lifecycle

void uncaughtExceptionHandler(NSException *exception);

void uncaughtExceptionHandler(NSException *exception)
{
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];

    // NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSInteger favoriteInstructionShownCount = [defaults integerForKey:kFavoritingInstructionShownCounterKey];
    if (favoriteInstructionShownCount < 3) {
        [defaults setBool:NO forKey:kFavoritingInstructionAlreadyShownKey];
        [defaults setInteger:(favoriteInstructionShownCount+1) forKey:kFavoritingInstructionShownCounterKey];
    }

    [defaults synchronize];

    // Navigation bar
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navigation-bar.png"] forBarMetrics:UIBarMetricsDefault];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;

    // Navigation view controller as root
    self.window.rootViewController = self.navController;
    self.window.backgroundColor = [UIColor blackColor];

    _barCampViewController = [[FestBarCampViewController alloc] initWithNibName:@"FestEventsViewController" bundle:nil];

    [self.window makeKeyAndVisible];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // [mapViewController.locationManager stopUpdatingLocation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // TODO: refresh data in festdatamanager?
    // [mapViewController.locationManager startUpdatingLocation];
    // [timelineViewController selectCurrentDayIfViable];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if (application.applicationState == UIApplicationStateActive) {

        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"gig.reminder.title", @"")
                                                            message:notification.alertBody
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"button.ok", @"")
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark - Navigation Actions

- (IBAction)showSchedule:(id)sender
{
    [self.navController pushViewController:self.scheduleViewController animated:YES];
}

- (IBAction)showNews:(id)sender
{
    [self.navController pushViewController:self.newsViewController animated:YES];
}

- (IBAction)showKeyTalks:(id)sender
{
    [self.navController pushViewController:self.eventsViewController animated:YES];
}

- (IBAction)showBarCamps:(id)sender
{
    [self.navController pushViewController:self.barCampViewController animated:YES];
}

- (IBAction)showMap:(id)sender
{
    [self.navController pushViewController:self.mapViewController animated:YES];
}

- (IBAction)showLambdaCalculus:(id)sender
{
    RACSignal *infoSignal = FestDataManager.sharedFestDataManager.infoSignal;
    [[infoSignal sample:[RACSignal return:nil]] subscribeNext:^(NSArray *info) {
        for (InfoItem *item in info) {
            if ([item.title isEqualToString:@"Lambda Calculus"]) {
                [self showInfoItem:item];
            }
        }
    }];
}

- (IBAction)showGeneralInfo:(id)sender
{
    [self.navController pushViewController:self.infoViewController animated:YES];
}

- (void)showNewsItem:(NewsItem *)newsItem
{
    UIViewController *controller = [[FestNewsItemViewController alloc] initWithNewsItem:newsItem];
    [self.navController pushViewController:controller animated:YES];
}

- (void)showInfoItem:(InfoItem *)infoItem
{
    UIViewController *controller = [[FestWebContentViewController alloc] initWithContent:infoItem.content title:infoItem.title];
    [self.navController pushViewController:controller animated:YES];
}

- (void)showEvent:(Event *)event
{
    UIViewController *controller = [FestEventViewController newWithEvent:event];
    [self.navController pushViewController:controller animated:YES];
}

- (void)showGig:(Gig *)gig
{
    UIViewController *controller = [FestEventViewController newWithEvent:gig];
    [self.navController pushViewController:controller animated:YES];
}

@end

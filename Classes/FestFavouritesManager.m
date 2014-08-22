//
//  FestFavouritesManager.m
//  FestApp
//
//  Created by Oleg Grenrus on 13/06/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import "FestFavouritesManager.h"

#define kFestFavouriteKey @"Favourites"

@interface FestFavouritesManager ()
@property (nonatomic, strong) RACSubject *favouritesSignal;
@end

@implementation FestFavouritesManager
+ (FestFavouritesManager *)sharedFavouritesManager
{
    static FestFavouritesManager *_sharedFestFavouritesManager = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedFestFavouritesManager = [[self alloc] init];
    });

    return _sharedFestFavouritesManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray *favourites = [defaults arrayForKey:kFestFavouriteKey];

        self.favouritesSignal = [RACBehaviorSubject behaviorSubjectWithDefaultValue:favourites];
    }
    return self;
}

- (void)toggleFavourite:(Gig *)gig favourite:(BOOL)favourite
{
    if (!gig) {
        NSLog(@"error, toggling favourites without gig");
        return;
    }

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *favourites = [defaults arrayForKey:kFestFavouriteKey];
    RACSubject *favouritesSubject = (RACSubject *)self.favouritesSignal;

    if (favourites == nil) {
        favourites = @[];
    }

    NSMutableArray *mutableFavourites = [NSMutableArray arrayWithArray:favourites];
    if (favourite) {
        // add only if not already there
        
        if ([gig isKindOfClass:[Gig class]]) {
            if (![mutableFavourites containsObject:gig.gigId]) {
                [mutableFavourites addObject:gig.gigId];
            }
        }
        if ([gig isKindOfClass:[Event class]]) {
            
            Event *event = [Event cast:gig];
    
            if (![mutableFavourites containsObject:event.identifier]) {
                [mutableFavourites addObject:event.identifier];
            }
        }
        

    } else {
        // remove while there are objects
        
        if ([gig isKindOfClass:[Gig class]]) {
            while ([mutableFavourites containsObject:gig.gigId]) {
                [mutableFavourites removeObject:gig.gigId];
            }
        }
        if ([gig isKindOfClass:[Event class]]) {
            
            Event *event = [Event cast:gig];

            while ([mutableFavourites containsObject:event.identifier]) {
                [mutableFavourites removeObject:event.identifier];
            }
        }
    }

    [self toggleNotification:gig favourite:favourite];

    [defaults setObject:mutableFavourites forKey:kFestFavouriteKey];
    [defaults synchronize];

    [favouritesSubject sendNext:mutableFavourites];
}

- (void)toggleNotification:(Gig *)gig favourite:(BOOL)favourite
{
    if (favourite) {
        
        if ([gig isKindOfClass:[Gig class]]) {
            
            if ([gig.begin after:[NSDate date]]) {
                
                NSString *alertText = [NSString stringWithFormat:@"%@\n%@-%@ (%@)", gig.gigName, [gig.begin hourAndMinuteString], [gig.end hourAndMinuteString], gig.stage];
                
                UILocalNotification *localNotif = [[UILocalNotification alloc] init];
                if (localNotif == nil) {return;}
                localNotif.fireDate = [gig.begin dateByAddingTimeInterval:-kAlertIntervalInMinutes*kOneMinute];
                localNotif.alertBody = alertText;
                localNotif.soundName = UILocalNotificationDefaultSoundName;
                [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
                
                NSLog(@"added alert: %@", alertText);
            }else {
            
                UILocalNotification *notificationToCancel = nil;
                for (UILocalNotification *aNotif in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
                    if([aNotif.alertBody rangeOfString:gig.gigName].location == 0) {
                        notificationToCancel = aNotif;
                        break;
                    }
                }
                if (notificationToCancel != nil) {
                    NSLog(@"removed alert: %@", notificationToCancel.alertBody);
                    [[UIApplication sharedApplication] cancelLocalNotification:notificationToCancel];
                }
            }
        }
        if ([gig isKindOfClass:[Event class]]) {
            Event *event = [Event cast:gig];
            
            if ([event.begin after:[NSDate date]]) {
                
                NSString *alertText = [NSString stringWithFormat:@"%@\n%@-%@ (%@)", event.title, [event.begin hourAndMinuteString], [event.end hourAndMinuteString], event.location];
                
                UILocalNotification *localNotif = [[UILocalNotification alloc] init];
                if (localNotif == nil) return;
                localNotif.fireDate = [event.begin dateByAddingTimeInterval:-kAlertIntervalInMinutes*kOneMinute];
                localNotif.alertBody = alertText;
                localNotif.soundName = UILocalNotificationDefaultSoundName;
                [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
                
                NSLog(@"added alert: %@", alertText);
            }else {
            
                UILocalNotification *notificationToCancel = nil;
                for (UILocalNotification *aNotif in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
                    if([aNotif.alertBody rangeOfString:event.title].location == 0) {
                        notificationToCancel = aNotif;
                        break;
                    }
                }
                if (notificationToCancel != nil) {
                    NSLog(@"removed alert: %@", notificationToCancel.alertBody);
                    [[UIApplication sharedApplication] cancelLocalNotification:notificationToCancel];
                }
            }
        
        }
    }
}
@end

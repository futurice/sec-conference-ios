//
//  RR2014ScheduleViewController.m
//  FestApp
//
//  Created by Oleg Grenrus on 10/06/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import "FestScheduleViewController.h"

#import "FestAppDelegate.h"
#import "FestDataManager.h"
#import "FestFavouritesManager.h"

@interface FestScheduleViewController () <TimelineViewDelegate, DayChooserDelegate, UIScrollViewDelegate>
@property (nonatomic, strong) IBOutlet UIView *timelineVenuesView;
@property (nonatomic, strong) IBOutlet DayChooser *dayChooser;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet TimelineView *timeLineView;
@end

@implementation FestScheduleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.dayChooser.delegate = self;
    self.dayChooser.dayNames = @[@"Friday", @"Saturday"];

    self.timeLineView.delegate = self;

    // gigs
    RACSignal *gigsSignal = FestDataManager.sharedFestDataManager.gigsSignal;
    [gigsSignal subscribeNext:^(id x) {
        self.timeLineView.gigs = x;
    }];

    RACSignal *favouritesSignal = FestFavouritesManager.sharedFavouritesManager.favouritesSignal;
    [favouritesSignal subscribeNext:^(id x) {
        self.timeLineView.favouritedGigs = x;
    }];

    // back button
    self.navigationItem.title = @"";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[self navigationController] setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    // This is to prevent the autoscrolling from happening when coming back from viewing the details of an event
    BOOL didJustGetPushed = self.isMovingToParentViewController;
    if (didJustGetPushed) {
        [self autoScrollToNow];
    }
}

- (void)autoScrollToNow
{
    // Some test code for the autoscroll
    /*
    NSString *str =@"14/9/2014 13:00";
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd/MM/yyyy HH:mm"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"Europe/Berlin"]];
    NSDate *now = [formatter dateFromString:str];
    */

    NSDate *now = [NSDate date];

    // Handle automatic day switching
    if ([self isDate:now sameDayAsDate:self.timeLineView.currentDate]) {
        // now is same day, don't switch
    } else if ([now compare:self.timeLineView.currentDate] == NSOrderedAscending) {
        // now is before currentDate, switch back if schedule is on Saturday
        if (self.dayChooser.selectedDayIndex == 1) {
            self.dayChooser.selectedDayIndex = 0;
        }
    } else if ([now compare:self.timeLineView.currentDate] == NSOrderedDescending) {
        // now is after currentDate, switch forward if schedule is on Firday
        if (self.dayChooser.selectedDayIndex == 0) {
            self.dayChooser.selectedDayIndex = 1;
        }
    }

    // Scroll content view to display now at the center of the view, while clamping offset to outer edges
    CGFloat viewWidth = self.scrollView.frame.size.width;
    CGFloat contentWidth = self.timeLineView.intrinsicContentSize.width;
    CGFloat offset = [self.timeLineView offsetForTime:now] - (viewWidth / 2);
    offset = MAX(offset, 0);
    offset = MIN(offset, contentWidth - viewWidth);
    [self.scrollView setContentOffset:CGPointMake(offset, 0) animated:YES];
}

#pragma mark DayChooserDelegate

- (void)dayChooser:(DayChooser *)dayChooser selectedDayWithIndex:(NSUInteger)dayIndex
{
    NSString *currentDay = @"Friday";
    switch (dayIndex) {
        case 0: currentDay = @"Friday"; break;
        case 1: currentDay = @"Saturday"; break;
    }

    self.timeLineView.currentDay = currentDay;
}

#pragma mark TimelineViewDelegate

- (void)timeLineView:(TimelineView *)timeLineView gigSelected:(Gig *)gig
{
    [APPDELEGATE showGig:gig];
}

- (void)timeLineView:(TimelineView *)timeLineView eventSelected:(Event *)event
{
    [APPDELEGATE showEvent:event];
}

- (void)timeLineView:(TimelineView *)timeLineView gigFavourited:(Gig *)gig favourite:(BOOL)favourite
{
    FestFavouritesManager *favouriteManager = [FestFavouritesManager sharedFavouritesManager];
    [favouriteManager toggleFavourite:gig favourite:favourite];
}

#pragma mark UIScrollDelegage

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [UIView animateWithDuration:0.3 animations:^{
        self.timelineVenuesView.alpha = 0.25;
    }];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [UIView animateWithDuration:0.3 animations:^{
        self.timelineVenuesView.alpha = 1.0;
    }];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [UIView animateWithDuration:0.3 animations:^{
            self.timelineVenuesView.alpha = 1.0;
        }];
    }
}

#pragma mark Helpers

- (BOOL)isDate:(NSDate *)date1 sameDayAsDate:(NSDate *)date2
{
    if (date1 == nil || date2 == nil) {
        return NO;
    }
    
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    calendar.timeZone = [NSTimeZone timeZoneWithName:@"Europe/Berlin"];

    NSDateComponents *day1 = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date1];
    NSDateComponents *day2 = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date2];
    return ([day2 day] == [day1 day] &&
            [day2 month] == [day1 month] &&
            [day2 year] == [day1 year]);
}



@end

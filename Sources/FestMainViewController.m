//
//  RR2014MainViewController.m
//  FestApp
//
//  Created by Oleg Grenrus on 09/06/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import "FestMainViewController.h"

#import "FestAppDelegate.h"
#import "FestDataManager.h"
#import "FestImageManager.h"
#import "FestFavouritesManager.h"

#import "NewsItem.h"
#import "Event.h"

#define kUpdateInterval 10
#define kTransitionAnimationDuration 1.0f

#define kNextInterval 3600

@interface RandomDate : NSObject
@property (nonatomic, readonly, strong) NSDate *date;
@property (nonatomic, readonly, assign) NSUInteger random;

- (instancetype)initWithRandom:(NSUInteger)random date:(NSDate *)date;
@end

@implementation RandomDate
- (instancetype)initWithRandom:(NSUInteger)random date:(NSDate *)date
{
    self = [super init];
    if (self) {
        _random = random;
        _date = date;
    }
    return self;
}
@end

@interface FestMainViewController ()

@property (nonatomic, strong) NewsItem *currentNewsItem;
@property (nonatomic, strong) id currentEvent;

@property (nonatomic, strong) IBOutlet UIImageView *gigImageView;
@property (nonatomic, strong) IBOutlet UILabel *gigLabel;
@property (nonatomic, strong) IBOutlet UILabel *gigSublabel;

@property (nonatomic, strong) IBOutlet UILabel *newsTitleLabel;

@property (nonatomic, strong) IBOutlet UIButton *agendaButton;
@property (nonatomic, strong) IBOutlet UIButton *keyTalksButton;
@property (nonatomic, strong) IBOutlet UIButton *barCampsButton;
@property (nonatomic, strong) IBOutlet UIButton *venueButton;
@property (nonatomic, strong) IBOutlet UIButton *infoButton;

@property (nonatomic, strong) IBOutlet UIView *futuLogoView;

- (IBAction)showSchedule:(id)sender;
- (IBAction)showKeyTalks:(id)sender;
- (IBAction)showMap:(id)sender;
- (IBAction)showInfo:(id)sender;
- (IBAction)showLC:(id)sender;

@end

@implementation FestMainViewController

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

    [self.agendaButton.imageView setContentMode: UIViewContentModeScaleAspectFit];
    self.agendaButton.imageEdgeInsets = UIEdgeInsetsMake(0,16,0,0);

    [self.keyTalksButton.imageView setContentMode: UIViewContentModeScaleAspectFit];
    self.keyTalksButton.imageEdgeInsets = UIEdgeInsetsMake(0,16,0,0);

    [self.barCampsButton.imageView setContentMode: UIViewContentModeScaleAspectFit];
    self.barCampsButton.imageEdgeInsets = UIEdgeInsetsMake(0,16,0,0);

    [self.venueButton.imageView setContentMode: UIViewContentModeScaleAspectFit];
    self.venueButton.imageEdgeInsets = UIEdgeInsetsMake(0,16,0,0);

    [self.infoButton.imageView setContentMode: UIViewContentModeScaleAspectFit];
    self.infoButton.imageEdgeInsets = UIEdgeInsetsMake(0,16,0,0);

    // Gig

    // Poor man random signal updated at the interval
    RACSignal *intervalSignal =
    [[[[RACSignal interval:kUpdateInterval onScheduler:[RACScheduler mainThreadScheduler]] startWith:[NSDate date]]
      scanWithStart:[[RandomDate alloc] initWithRandom:arc4random() date:[NSDate date]]
      reduce:^id(RandomDate *rd, NSDate *now) {
         NSUInteger r = (1103515245 * rd.random + 12345) % 0x100000000;
         return [[RandomDate alloc] initWithRandom:r date:now];
     }] replayLast];

    RACSignal *gigsSignal = FestDataManager.sharedFestDataManager.gigsSignal;
    RACSignal *favouritesSignal = FestFavouritesManager.sharedFavouritesManager.favouritesSignal;

    RACSignal *currentGigSignal =
    [[RACSignal combineLatest:@[intervalSignal, gigsSignal, favouritesSignal]
                      reduce:^id(RandomDate *rd, NSArray *gigs, NSArray *favourites) {
                          // if there is favourites, pick one from that list
                          Gig *nextGig = nil;
                          for (Gig *gig in gigs) {
                              if ([gig.begin after:rd.date]) {
                                  if (nextGig == nil) {
                                      nextGig = gig;
                                  } else if ([gig.begin before:nextGig.begin]) {
                                      nextGig = gig;
                                  }
                              }
                          }

                          // If less than interval to the beginning of the gig
                          // show it!
                          if (nextGig && [nextGig.begin timeIntervalSinceDate:rd.date] < kNextInterval) {
                              return nextGig;
                          }

                          if (favourites.count != 0) {
                              NSString *gigId = favourites[rd.random % favourites.count];
                              
                              NSUInteger gigIdx = [gigs indexOfObjectPassingTest:^BOOL(Gig* art, NSUInteger idx, BOOL *stop) {
                                  BOOL result;
                                  if ([art isKindOfClass:[Gig class]]) {
                                      result = [art.gigId isEqualToString:gigId];
                                  }else{
                                      Event *event = [Event cast:art];
                                      result = [event.identifier isEqualToString:gigId];
                                  }
                                  return result;
                              }];

                              if (gigIdx != NSNotFound) {
                                  return gigs[gigIdx];
                              }
                          }

                          // fallback, return random gig
                          NSUInteger randomIdx = rd.random % MAX(gigs.count, 1);
                          return gigs[randomIdx];
                      }] replayLast];

    [currentGigSignal subscribeNext:^(id eventObject) {
        
        self.currentEvent = eventObject;
        
        [UIView transitionWithView:self.view
                          duration:kTransitionAnimationDuration
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            
                            if([eventObject isKindOfClass:[Gig class]]) {
                                Gig *gig = [Gig cast:eventObject];
                                self.gigLabel.text = gig.gigName;
                                self.gigSublabel.text = gig.stageAndTimeIntervalString;
                            }
                            else if([eventObject isKindOfClass:[Event class]]) {
                                
                                Event *event = [Event cast:eventObject];
                                self.gigLabel.text = event.title;
                            }
                            
                        } completion:NULL];
    }];

    RACSignal *imageSignal = [[currentGigSignal map:^id(id event) {
        
        if([event isKindOfClass:[Gig class]]) {
            Gig *gig = [Gig cast:event];
            return [[FestImageManager sharedFestImageManager] imageSignalFor:gig.imagePath];
        }
        else {
            Event *eventObject = [Event cast:event];
            return [[FestImageManager sharedFestImageManager] imageSignalFor:eventObject.imageURL];
        }
        
    }] switchToLatest];

    [imageSignal subscribeNext:^(UIImage *image) {
        if (image) {
            [UIView transitionWithView:self.view
                              duration:kTransitionAnimationDuration
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                self.gigImageView.image = image;
                            } completion:NULL];
        }
    }];

    RACSignal *newsSignal = FestDataManager.sharedFestDataManager.newsSignal;
    [newsSignal subscribeNext:^(NSArray *news) {
        if (news.count > 0) {
            self.newsTitleLabel.text = ((NewsItem *) news[0]).title;
        }
    }];

    [self.futuLogoView addGestureRecognizer:
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openFuturicePage:)]];

    // No back text
    self.navigationItem.title = @"";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[self navigationController] setNavigationBarHidden:YES animated:animated];
}

#pragma mark Actions

- (IBAction)showSchedule:(id)sender
{
    [[FestDataManager sharedFestDataManager] reload];
    NSLog(@"show schedule");
    [APPDELEGATE showSchedule:sender];
}

- (IBAction)openFuturicePage:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.futurice.com"]];
}

- (IBAction)showKeyTalks:(id)sender
{
    NSLog("@show talks");
    [APPDELEGATE showKeyTalks:sender];
}

- (IBAction)showBarCamps:(id)sender
{
    NSLog("@show barcamps");
    [APPDELEGATE showBarCamps:sender];
}

- (IBAction)showMap:(id)sender
{
    [[FestDataManager sharedFestDataManager] reload];
    NSLog("@show map");
    [APPDELEGATE showMap:sender];
}

- (IBAction)showLC:(id)sender
{
    [[FestDataManager sharedFestDataManager] reload];
    NSLog(@"show lambda calculus");
    [APPDELEGATE showLambdaCalculus:sender];
}

- (IBAction)showInfo:(id)sender
{
    [[FestDataManager sharedFestDataManager] reload];
    NSLog("@show general info");
    [APPDELEGATE showGeneralInfo:sender];
}

@end

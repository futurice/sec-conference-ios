//
//  TimelineView.m
//  FestApp
//

#import "TimelineView.h"
#import "Gig.h"
#import "Event.h"
#import "NSDate+Additions.h"
#import <AudioToolbox/AudioServices.h>
#import <AVFoundation/AVFoundation.h>
#import "FestFavouritesManager.h"


#pragma mark - GigButton

@interface GigButton : UIButton
@property (nonatomic, readonly) Gig *gig;
@property (nonatomic, readonly) Event *event;
- (id)initWithFrame:(CGRect)frame gig:(Gig *)gig;
- (id)initWithFrame:(CGRect)frame event:(Event *)event;
@end

@implementation GigButton

- (id)initWithFrame:(CGRect)frame gig:(Gig *)gig
{
    self = [super initWithFrame:frame];
    if (self) {
        _gig = gig;

        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
        [self setTitle:gig.gigName.uppercaseString forState:UIControlStateNormal];

        self.backgroundColor = [UIColor grayColor];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

//        [self setImage:[UIImage imageNamed:@"star.png"] forState:UIControlStateNormal];
//        [self setImage:[UIImage imageNamed:@"star-selected-yellow.png"] forState:UIControlStateSelected];

        self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.titleLabel.numberOfLines = 3;

        self.titleLabel.font = [UIFont systemFontOfSize:15];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame event:(Event *)event
{
    self = [super initWithFrame:frame];
    if (self) {
        _event = event;
        
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.contentEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 12);
        [self setTitle:event.title forState:UIControlStateNormal];
        
        if ([event.bar_camp boolValue]) {
//            [self setBackgroundImage:[UIImage imageNamed:@"eventBackground"] forState:UIControlStateNormal];
            self.backgroundColor = RGB_COLOR(240,142,12); // orange
        } else {
            self.backgroundColor = RGB_COLOR(226,14,121); // pink
        }
        
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
//        [self setImage:[UIImage imageNamed:@"star.png"] forState:UIControlStateNormal];
//        [self setImage:[UIImage imageNamed:@"star-selected-yellow.png"] forState:UIControlStateSelected];
        
        self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.titleLabel.numberOfLines = 3;
        self.titleLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:11];

//        self.titleLabel.font = [UIFont fontWithName:@"Palatino-Roman" size:15];
    }
    return self;
}

@end


#pragma mark - FavButton

@interface FavButton : UIButton
@property (nonatomic, readonly) Gig *gig;
@property (nonatomic, readonly) Event *event;
- (id)initWithFrame:(CGRect)frame gig:(Gig *)gig;
- (id)initWithFrame:(CGRect)frame event:(Event *)event;
@end

@implementation FavButton
- (id)initWithFrame:(CGRect)frame gig:(Gig *)gig
{
    self = [super initWithFrame:frame];
    if (self) {
        _gig = gig;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame event:(Event *)event
{
    self = [super initWithFrame:frame];
    if (self) {
        _event = event;
    }
    return self;
}

@end


#pragma mark - TimelineView

@interface TimelineView ()
@property (nonatomic, strong) NSArray *stages;

@property (nonatomic, strong) NSDate *begin;
@property (nonatomic, strong) NSDate *end;

@property (nonatomic, strong) NSDate *dayBegin;
@property (nonatomic, strong) NSDate *dayEnd;

@property (nonatomic, strong) UIView *innerView;
@end

#define kHourWidth 200
#define kRowHeight 47
#define kTopPadding 26
#define kLeftPadding 76
#define kRightPadding 40
#define kRowPadding 1

static CGFloat timeWidthFrom(NSDate *from, NSDate *to)
{
    NSTimeInterval interval = [to timeIntervalSinceReferenceDate] - [from timeIntervalSinceReferenceDate];
    return (CGFloat) interval / 3600 * kHourWidth;
}

@implementation TimelineView

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor clearColor];

//    self.innerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    self.autoresizesSubviews = NO;
    self.innerView = [[UIView alloc] initWithFrame:self.bounds];
    self.innerView.clipsToBounds = NO;

    [self addSubview:self.innerView];
}

- (CGRect)gigRect:(Gig *)gig
{
    if ([gig.day isEqualToString:self.currentDay]) {
        CGFloat x = - kLeftPadding + timeWidthFrom(self.dayBegin, gig.begin);
        CGFloat w = timeWidthFrom(gig.begin, gig.end);
        return CGRectMake(x, 0, w, 1);
    } else {
        return CGRectMake(0, 0, 1, 1);
    }
}

- (CGFloat)offsetForTime:(NSDate *)time
{
    CGFloat distance = + kLeftPadding + timeWidthFrom(self.dayBegin, time);

    distance = MAX(distance, 0);
    distance = MIN(distance, self.intrinsicContentSize.width);

    return distance;
}

#pragma mark - DataSetters

- (void)setGigs:(NSArray *)gigs
{
    _gigs = gigs;

    if ([[gigs firstObject] isKindOfClass:[Gig class]]) {
        
        NSUInteger count = gigs.count;
        
        // Venues
        NSMutableArray *stages = [NSMutableArray arrayWithCapacity:6];
        for (NSUInteger idx = 0; idx < count; idx++) {
            Gig *gig = gigs[idx];
            if (![stages containsObject:gig.stage]) {
                [stages addObject:gig.stage];
            }
        }
        
        self.stages = stages;
    }
    else if([[gigs firstObject] isKindOfClass:[Event class]]) {
        
        //TODO: Fixed order of the locations
        self.stages = @[@"Galerie", @"Raum 2", @"Raum 3", @"Raum 4", @"Loft", @"Raum 5", @"Atelier"];
    }
    else {
        // HARDCODE order
        self.stages = @[@"Computing", @"Type Theory", @"Logic"];
    }

    [self recreate];
    [self invalidateIntrinsicContentSize];
}

- (void)setFavouritedGigs:(NSArray *)favouritedGigs
{
    _favouritedGigs = favouritedGigs;

    for (UIView *view in self.innerView.subviews) {
        if ([view isKindOfClass:[GigButton class]]) {
//            GigButton *button = (GigButton *)view;

//            BOOL favourited = [self.favouritedGigs containsObject:button.gig.gigId];

//            button.selected = favourited;
//            button.alpha = favourited ? 1.0f : 0.8f;
        }
    }

    [self recreate];
}

- (void)setCurrentDay:(NSString *)currentDay
{
    _currentDay = currentDay;

    [self recreateDay];
    [self invalidateIntrinsicContentSize];
}

- (NSDate *)currentDate
{
    return self.dayBegin;
}

#pragma mark - Internals

- (void)recreateDay
{
    NSDate *begin = [NSDate distantFuture];
    NSDate *end = [NSDate distantPast];

    if([[self.gigs firstObject] isKindOfClass:[Gig class]]) {
        for (Gig *gig in self.gigs) {
            if (![gig.day isEqualToString:self.currentDay]) {
                continue;
            }
            
            if ([gig.begin compare:begin] == NSOrderedAscending ) {
                begin = gig.begin;
            }
            
            if ([gig.end compare:end] == NSOrderedDescending) {
                end = gig.end;
            }
        }
    }
    else if([[self.gigs firstObject] isKindOfClass:[Event class]]) {
        for (Event *event in self.gigs) {
            if (![event.day isEqualToString:self.currentDay]) {
                continue;
            }
            
            if ([event.begin compare:begin] == NSOrderedAscending ) {
                begin = event.begin;
            }
            
            if ([event.end compare:end] == NSOrderedDescending) {
                end = event.end;
            }
        }
    }

    self.dayBegin = begin;
    self.dayEnd = end;


    CGFloat x = kLeftPadding - timeWidthFrom(self.begin, self.dayBegin);
    CGFloat y = 0;
    CGFloat w = timeWidthFrom(self.begin, self.end) + kRightPadding;
    CGFloat h = kTopPadding + (kRowHeight + kRowPadding + 3 ) * 7;

    [UIView animateWithDuration:0.5 animations:^{
        self.innerView.frame = CGRectMake(x, y, w, h);
    }];
}

- (void)recreate
{
    for (UIView *view in self.innerView.subviews) {
        [view removeFromSuperview];
    }

    NSUInteger count = self.gigs.count;
    if (count == 0) {
        return;
    }

    // timespan
    NSDate *begin = [NSDate distantFuture];
    NSDate *end = [NSDate distantPast];
    
    if([[self.gigs firstObject] isKindOfClass:[Gig class]]) {
        for (Gig *gig in self.gigs) {
            if ([gig.begin compare:begin] == NSOrderedAscending ) {
                begin = gig.begin;
            }
            
            if ([gig.end compare:end] == NSOrderedDescending) {
                end = gig.end;
            }
        }
    }
    else if([[self.gigs firstObject] isKindOfClass:[Event class]]) {
        
        for (Event *event in self.gigs) {
            if ([event.begin compare:begin] == NSOrderedAscending ) {
                begin = event.begin;
            }
            
            if ([event.end compare:end] == NSOrderedDescending) {
                end = event.end;
            }
        }
    }

    self.begin = begin;
    self.end = end;

    // Frets
    NSUInteger interval = (NSUInteger) [self.begin timeIntervalSinceReferenceDate] % 3600;
    if (interval < 60) {
        interval = -interval;
    } else {
        interval = 3600 - interval;
    }

    NSDate *fretDate = [NSDate dateWithTimeInterval:interval sinceDate:self.begin];
    UIImage *fretImage = [UIImage imageNamed:@"schedule-hoursep.png"];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Europe/Berlin"]];
    [dateFormatter setDateFormat:@"HH:mm"];

    while ([fretDate compare:self.end] == NSOrderedAscending) {
        // fret
        CGRect frame = CGRectMake(timeWidthFrom(self.begin, fretDate) - 2, -4, 1, 365);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
        imageView.image = fretImage;

        [self.innerView addSubview:imageView];

        // time label
        CGRect timeFrame = CGRectMake(timeWidthFrom(self.begin, fretDate) - 50, 0, 100, 20);
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:timeFrame];

        timeLabel.textColor = RGB_COLOR(240, 142, 12);
        timeLabel.text = [dateFormatter stringFromDate:fretDate];
        timeLabel.textAlignment = NSTextAlignmentCenter;
        timeLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:17];
        [self.innerView addSubview:timeLabel];

        // next
        fretDate = [NSDate dateWithTimeInterval:3600 sinceDate:fretDate];
    }

    NSUInteger stageCount = self.stages.count;

    if([[self.gigs firstObject] isKindOfClass:[Gig class]]) {
        // buttons
        for (Gig *gig in self.gigs) {
            NSUInteger stageIdx = 0;
            for (; stageIdx < stageCount; stageIdx++) {
                if ([gig.stage isEqualToString:self.stages[stageIdx]]) {
                    break;
                }
            }
            
            BOOL favourited = [self.favouritedGigs containsObject:gig.gigId];
            
            CGFloat x = timeWidthFrom(self.begin, gig.begin);
            CGFloat y = kTopPadding + kRowPadding + kRowHeight * stageIdx;
            CGFloat w = timeWidthFrom(gig.begin, gig.end);
            CGFloat h = kRowHeight - kRowPadding * 2;
            CGRect frame = CGRectMake(x, y, w, h);
            
            GigButton *button = [[GigButton alloc] initWithFrame:frame gig:gig];
            
            button.selected = favourited;
            button.alpha = favourited ? 1.0f : 0.8f;
            
            [button addTarget:self action:@selector(gigButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            CGRect favFrame = CGRectMake(x, y, 40, h);
            FavButton *favButton = [[FavButton alloc] initWithFrame:favFrame gig:gig];
            
            [favButton addTarget:self action:@selector(favButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            [self.innerView addSubview:button];
//            [self.innerView addSubview:favButton];
        }
    }
    else if([[self.gigs firstObject] isKindOfClass:[Event class]]) {
        
        for (Event *event in self.gigs) {
            NSUInteger stageIdx = 0;
            for (; stageIdx < stageCount; stageIdx++) {
                if ([event.location isEqualToString:self.stages[stageIdx]]) {
                    break;
                }
            }
            
            BOOL favourited = [self.favouritedGigs containsObject:event.identifier];
            
            CGFloat x = timeWidthFrom(self.begin, event.begin);
            CGFloat y = kTopPadding + ((kRowPadding + kRowHeight) * stageIdx);
            CGFloat w = timeWidthFrom(event.begin, event.end) - 1;
            CGFloat h = kRowHeight - kRowPadding * 2;
            CGRect frame = CGRectMake(x, y, w, h);
            
            GigButton *button = [[GigButton alloc] initWithFrame:frame event:event];
            
//            button.selected = favourited;
            button.alpha = 1;
            
            [button addTarget:self action:@selector(gigButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [self.innerView addSubview:button];

            CGRect favFrame = CGRectMake(button.frame.origin.x + button.frame.size.width - 12, button.frame.origin.y + button.frame.size.height - 12, 10, 10);
            if (favourited) {
                FavButton *favButton = [[FavButton alloc] initWithFrame:favFrame event:event];
                [favButton setImage:[UIImage imageNamed:@"star-selected-white"] forState:UIControlStateNormal];
                favButton.adjustsImageWhenHighlighted = NO;
                [self.innerView addSubview:favButton];
            }

//            [favButton addTarget:self action:@selector(favButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        }
    }

    [self recreateDay];
}

#pragma mark - Actions

- (void)gigButtonPressed:(GigButton *)sender
{
    if(sender.gig) {
        [self.delegate timeLineView:self gigSelected:sender.gig];
    }
    else {
        [self.delegate timeLineView:self eventSelected:sender.event];
    }
}

- (void)favButtonPressed:(FavButton *)sender
{
    Gig *gig = sender.gig;
    BOOL favourited = [self.favouritedGigs containsObject:gig.gigId];
    [self.delegate timeLineView:self gigFavourited:gig favourite:!favourited];
}

#pragma mark - AutoLayout
- (CGSize)intrinsicContentSize
{
    return CGSizeMake(timeWidthFrom(self.dayBegin, self.dayEnd) + kLeftPadding + kRightPadding, 100);
}

@end

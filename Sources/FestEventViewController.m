//
//  FestEventViewController.m
//  FestApp
//
//  Created by Oleg Grenrus on 10/06/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import "FestEventViewController.h"

#import "FestAppDelegate.h"
#import "FestDataManager.h"
#import "FestImageManager.h"
#import "FestFavouritesManager.h"

#import "UIView+XYWidthHeight.h"
#import "UIView+SubviewAdd.h"

#import "Masonry.h"

static UILabel *makeLabel(NSString *text, NSInteger fontSize)
{
    UILabel *label = [UILabel new];
    label.text = text;
    label.textColor = [UIColor whiteColor];
    label.numberOfLines = 0;
    label.font = [UIFont fontWithName:SXC_FONT_REGULAR size:fontSize];

    return label;
}

static UIView *makeDivider()
{
    UIView *div = [UIView new];
    div.backgroundColor = SXC_COLOR_ORANGE;
    [div mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@0.5);
    }];

    return div;
}


@interface SpeakerRow : UIView

@property (nonatomic, weak) Speaker *speaker;

@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UILabel *roleLabel;
@property (nonatomic, weak) UIButton *linkedInButton;
@property (nonatomic, weak) UIButton *twitterButton;

@end

@implementation SpeakerRow

+ (instancetype)rowWithSpeaker:(Speaker *)speaker
{
    SpeakerRow *row = [[SpeakerRow alloc] initWithFrame:CGRectZero];
    row.speaker = speaker;
    [row build];
    [row layOut];
    return row;
}

- (void)build
{
    self.nameLabel = [self addSubviewReturn:makeLabel(self.speaker.name, 16)];
    self.nameLabel.font = [UIFont fontWithName:SXC_FONT_MEDIUM size:16];

    self.roleLabel = [self addSubviewReturn:makeLabel(self.speaker.role, 12)];
    self.roleLabel.textColor = [UIColor lightGrayColor];
    self.roleLabel.font = [UIFont fontWithName:SXC_FONT_MEDIUM size:12];

    self.linkedInButton = [self addSubviewReturn:[UIButton buttonWithType:UIButtonTypeCustom]];
    [self.linkedInButton setImage:[UIImage imageNamed:@"linkedinButton"] forState:UIControlStateNormal];
    self.linkedInButton.enabled = (self.speaker.linkedIn != nil);
    [self.linkedInButton addTarget:self action:@selector(openLinkedIn:) forControlEvents:UIControlEventTouchUpInside];

    self.twitterButton = [self addSubviewReturn:[UIButton buttonWithType:UIButtonTypeCustom]];
    [self.twitterButton setImage:[UIImage imageNamed:@"twitterButton"] forState:UIControlStateNormal];
    self.twitterButton.enabled = (self.speaker.twitter != nil);
    [self.twitterButton addTarget:self action:@selector(openTwitter:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)layOut
{
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.equalTo(self);
        make.trailing.equalTo(self.linkedInButton.mas_leading);
    }];

    [self.twitterButton setContentHuggingPriority:251 forAxis:UILayoutConstraintAxisHorizontal];
    [self.twitterButton setContentCompressionResistancePriority:751 forAxis:UILayoutConstraintAxisHorizontal];
    [self.twitterButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.trailing.equalTo(self);
    }];

    [self.linkedInButton setContentHuggingPriority:251 forAxis:UILayoutConstraintAxisHorizontal];
    [self.linkedInButton setContentCompressionResistancePriority:751 forAxis:UILayoutConstraintAxisHorizontal];
    [self.linkedInButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.twitterButton);
        make.trailing.equalTo(self.twitterButton.mas_leading).with.offset(-10);
    }];

    [self.roleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.nameLabel);
        make.top.equalTo(self.nameLabel.mas_bottom);
        make.bottom.equalTo(self);
    }];
}

- (IBAction)openLinkedIn:(id)sender
{
    if (self.speaker.linkedIn) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.speaker.linkedIn]];
    }
}

- (IBAction)openTwitter:(id)sender
{
    NSURL *twitterURL = nil;
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]) {
        twitterURL = [NSURL URLWithString:[NSString stringWithFormat:@"twitter://user?screen_name=%@", self.speaker.twitter]];
        [[UIApplication sharedApplication] openURL:twitterURL];
    } else {
        twitterURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://twitter.com/%@", self.speaker.twitter]];
    }

    [[UIApplication sharedApplication] openURL:twitterURL];
}

@end


@interface FestEventViewController ()

@property (nonatomic, strong) id event;

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) UIView *contentView;

@property (nonatomic, weak) UIImageView *speakerImage;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UIButton *favouriteButton;
@property (nonatomic, weak) UIImageView *divider1;
@property (nonatomic, weak) UIImageView *timeIcon;
@property (nonatomic, weak) UILabel *timeLabel;
@property (nonatomic, weak) UILabel *dayLabel;
@property (nonatomic, weak) UIImageView *locationIcon;
@property (nonatomic, weak) UILabel *locationLabel;
@property (nonatomic, weak) UIImageView *divider2;
@property (nonatomic, strong) NSMutableArray *speakerRows;
@property (nonatomic, weak) UIImageView *divider3;
@property (nonatomic, weak) UILabel *infoLabel;

@end

@implementation FestEventViewController

+ (instancetype)newWithEvent:(id)event
{
    FestEventViewController *controller = [[FestEventViewController alloc] initWithNibName:nil bundle:nil];
    controller.event = event;
    return controller;
}

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

    self.navigationItem.title = @"";

    NSAssert(![self.event isKindOfClass:[Gig class]], @"Never expect to see gigs in this app.");
        
    [self build];
    [self layOut];

    FestFavouritesManager *favouriteManager = [FestFavouritesManager sharedFavouritesManager];
    [favouriteManager.favouritesSignal subscribeNext:^(NSArray *favourites) {
        
        if([self.event isKindOfClass:[Gig class]]) {
            
            Gig *gig = [Gig cast:self.event];
            
            BOOL favourited = [favourites containsObject:gig.gigId];
            self.favouriteButton.selected = favourited;
        }
        else {
            Event *eventModel = [Event cast:self.event];
            
            BOOL favourited = [favourites containsObject:eventModel.identifier];
            self.favouriteButton.selected = favourited;
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[self navigationController] setNavigationBarHidden:NO animated:animated];
}

- (void)build
{
    Event *event = [Event cast:self.event];

    self.view.backgroundColor = [UIColor blackColor];

    self.scrollView = [self.view addSubviewReturn:[UIScrollView new]];
    self.contentView = [self.scrollView addSubviewReturn:[UIView new]];

    self.speakerImage = [self.contentView addSubviewReturn:[UIImageView new]];
    self.speakerImage.contentMode = UIViewContentModeScaleAspectFit;
    self.speakerImage.backgroundColor = [UIColor yellowColor];
    RAC(self.speakerImage, image) = [[FestImageManager sharedFestImageManager] imageSignalFor:event.imageURL];
    [RACObserve(self.speakerImage, image) subscribeNext:^(id x) {
        [self.view setNeedsLayout];
        NSLog("");
    }];

    self.titleLabel = [self.contentView addSubviewReturn:makeLabel(event.title, 20)];

    self.favouriteButton = [self.contentView addSubviewReturn:[UIButton buttonWithType:UIButtonTypeCustom]];
    [self.favouriteButton setImage:[UIImage imageNamed:@"favButton"] forState:UIControlStateNormal];
    [self.favouriteButton setImage:[UIImage imageNamed:@"favButtonSelected"] forState:UIControlStateSelected];
    [self.favouriteButton addTarget:self action:@selector(toggleFavourite:) forControlEvents:UIControlEventTouchUpInside];

    self.divider1 = [self.contentView addSubviewReturn:makeDivider()];

    self.timeIcon = [self.contentView addSubviewReturn:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"timeIcon"]]];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Europe/Berlin"]];
    [dateFormatter setDateFormat:@"HH:mm"];

    NSString *timeString = [NSString stringWithFormat:@"%@ - %@",
        [dateFormatter stringFromDate:event.begin],
        [dateFormatter stringFromDate:event.end]];
    self.timeLabel = [self.contentView addSubviewReturn:makeLabel(timeString, 14)];
    self.timeLabel.font = [UIFont fontWithName:SXC_FONT_DEMI_BOLD size:14];

    self.dayLabel = [self.contentView addSubviewReturn:makeLabel(event.day, 14)];
    self.dayLabel.font = [UIFont fontWithName:SXC_FONT_MEDIUM size:14];
    self.dayLabel.textColor = [UIColor lightGrayColor];

    self.locationIcon = [self.contentView addSubviewReturn:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"stageIcon"]]];

    self.locationLabel = [self.contentView addSubviewReturn:makeLabel(event.location, 14)];
    self.locationLabel.font = [UIFont fontWithName:SXC_FONT_DEMI_BOLD size:14];

    self.divider2 = [self.contentView addSubviewReturn:makeDivider()];

    self.speakerRows = [NSMutableArray new];

    for (Speaker *s in event.speakers) {
        SpeakerRow *row = [SpeakerRow rowWithSpeaker:s];
        [self.speakerRows addObject:row];
        [self.contentView addSubview:row];
    }

    if (self.speakerRows.count > 0) {
        self.divider3 = [self.contentView addSubviewReturn:makeDivider()];
    }

    NSString *infoString = [event.info stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    self.infoLabel = [self.contentView addSubviewReturn:makeLabel(infoString, 15)];
}

- (void)layOut
{
    const CGFloat margin = 15;
    const CGFloat spacing = 15;

    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).with.offset(margin);
        make.trailing.equalTo(self.view).with.offset(-margin);
        make.top.equalTo(self.scrollView).with.offset(margin);
        make.bottom.equalTo(self.scrollView).with.offset(-margin);
    }];

    UIView *parent = self.contentView;

    [self.speakerImage setContentHuggingPriority:251 forAxis:UILayoutConstraintAxisVertical];
    [self.speakerImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.equalTo(parent).with.offset(-margin);
        make.trailing.equalTo(parent).with.offset(margin);
        make.height.equalTo(@180);
    }];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(parent);
        make.trailing.equalTo(self.favouriteButton.mas_leading).with.offset(-spacing);
        make.top.equalTo(self.speakerImage.mas_bottom).with.offset(spacing);
    }];

    [self.favouriteButton setContentCompressionResistancePriority:751 forAxis:UILayoutConstraintAxisHorizontal];
    [self.favouriteButton setContentCompressionResistancePriority:751 forAxis:UILayoutConstraintAxisVertical];
    [self.favouriteButton setContentHuggingPriority:251 forAxis:UILayoutConstraintAxisHorizontal];
    [self.favouriteButton setContentHuggingPriority:251 forAxis:UILayoutConstraintAxisVertical];
    [self.favouriteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(parent);
        make.centerY.equalTo(self.titleLabel);
    }];

    [self.divider1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(parent);
        make.top.equalTo(self.titleLabel.mas_bottom).with.offset(spacing);
    }];

    [self.timeIcon setContentHuggingPriority:251 forAxis:UILayoutConstraintAxisHorizontal];
    [self.timeIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(parent);
        make.top.equalTo(self.divider1.mas_bottom).with.offset(spacing);
    }];

    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.timeIcon.mas_trailing).with.offset(spacing / 2);
        make.top.equalTo(self.timeIcon);
    }];

    [self.dayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.timeLabel);
        make.top.equalTo(self.timeLabel.mas_bottom);
    }];

    [self.locationIcon setContentHuggingPriority:751 forAxis:UILayoutConstraintAxisHorizontal];
    [self.locationIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(parent.mas_centerX);
        make.top.equalTo(self.timeIcon);
    }];

    [self.locationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.locationIcon.mas_trailing).with.offset(spacing / 2);
        make.trailing.equalTo(parent);
        make.top.equalTo(self.locationIcon);
    }];

    [self.divider2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(parent);
        make.top.equalTo(self.dayLabel.mas_bottom).with.offset(spacing);
    }];

    UIView *previous = self.divider2;
    for (SpeakerRow *row in self.speakerRows)
    {
        [row mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(parent);
            make.top.equalTo(previous.mas_bottom).with.offset(spacing);
        }];
        previous = row;
    }

    if (self.divider3) {
        [self.divider3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(parent);
            make.top.equalTo(previous.mas_bottom).with.offset(spacing);
        }];
    }

    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(parent);
        make.top.equalTo((self.divider3 ? self.divider3.mas_bottom : self.divider2.mas_bottom)).with.offset(spacing);
    }];

}

#pragma mark - Actions

- (IBAction)toggleFavourite:(id)sender
{
    FestFavouritesManager *favouriteManager = [FestFavouritesManager sharedFavouritesManager];
    [favouriteManager toggleFavourite:self.event favourite:!self.favouriteButton.selected];
}

- (IBAction)openWikipedia:(id)sender
{
    if([self.event isKindOfClass:[Gig class]]) {
        Gig *gig = [Gig cast:self.event];
        [UIApplication.sharedApplication openURL:gig.wikipediaUrl];
    }
}
@end

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

#import "Masonry.h"

@interface FestEventViewController ()
@property (nonatomic, strong) id event;

@property (nonatomic, strong) IBOutlet UIImageView *imageView;

@property (nonatomic, strong) IBOutlet UIButton *favouriteButton;

@property (nonatomic, strong) IBOutlet UILabel *gigLabel;
@property (nonatomic, strong) IBOutlet UILabel *stageLabel;
@property (nonatomic, strong) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UILabel *hourLabel;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIButton *linkedinButton;
@property (weak, nonatomic) IBOutlet UIView *speakersView;

@property (nonatomic, strong) IBOutlet UIButton *wikipediaButton;

- (IBAction)toggleFavourite:(id)sender;
- (IBAction)openWikipedia:(id)sender;
@end

@implementation FestEventViewController

+ (instancetype)newWithEvent:(id)event
{
    FestEventViewController *controller = [[FestEventViewController alloc] initWithNibName:@"FestEventViewController" bundle:nil];

    // TODO: implement me

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

    if([self.event isKindOfClass:[Gig class]]) {
        
        Gig *gig = [Gig cast:self.event];
        
        self.gigLabel.text = gig.gigName;
        self.stageLabel.text = gig.stageAndTimeIntervalString;
        self.infoLabel.text = gig.info;
    }
    else {
        Event *eventModel = [Event cast:self.event];
        self.gigLabel.text = eventModel.title;
        self.stageLabel.text = eventModel.location;
        self.infoLabel.text = [eventModel.info stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Europe/Berlin"]];
        [dateFormatter setDateFormat:@"HH:mm"];
        
        self.hourLabel.text = [NSString stringWithFormat:@"%@ - %@",[dateFormatter stringFromDate:eventModel.begin],[dateFormatter stringFromDate:eventModel.end]];
        
        if (eventModel.twitter) {
            self.twitterButton.enabled = YES;
        }
        
        if (eventModel.linkedIn) {
            self.linkedinButton.enabled = YES;
        }
    }

    // Favourite
//    [self.favouriteButton setImage:[UIImage imageNamed:@"star-selected.png"] forState:UIControlStateSelected];

//    [self.favouriteButton setTitle:@"Star" forState:UIControlStateNormal];
//    [self.favouriteButton setTitle:@"Starred" forState:UIControlStateSelected];

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

    // Load image
    
    if([self.event isKindOfClass:[Gig class]]) {
        
        Gig *gig = [Gig cast:self.event];
        
        FestImageManager *imageManager = [FestImageManager sharedFestImageManager];
        [[imageManager imageSignalFor:gig.imagePath] subscribeNext:^(UIImage *image) {
            self.imageView.image = image;
        }];
        
        // wikipedia button
        if (gig.wikipediaUrl == nil) {
            self.wikipediaButton.hidden = YES;
        }
    }
    else {
        Event *eventModel = [Event cast:self.event];
        
        FestImageManager *imageManager = [FestImageManager sharedFestImageManager];
        [[imageManager imageSignalFor:eventModel.imageURL] subscribeNext:^(UIImage *image) {
            self.imageView.image = image;
        }];
        
        self.wikipediaButton.hidden = YES;
    }

    [self buildSpeakersView];
}

- (void)buildSpeakersView
{
    Event *eventModel = [Event cast:self.event];

    self.speakersView.translatesAutoresizingMaskIntoConstraints = NO;

    UIView *row = [self buildSpeakerRowWithSpeaker:eventModel.artist role:eventModel.speakerRole afterView: self.speakersView];
    [self.speakersView addSubview:row];

    [row mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.speakersView);
    }];
}

- (UIView *)buildSpeakerRowWithSpeaker:(NSString *)speaker role:(NSString *)role afterView:(UIView *)view
{
    UILabel *speakerLabel = [UILabel new];
    speakerLabel.text = speaker;
    speakerLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:16];
    speakerLabel.textColor = [UIColor whiteColor];
    speakerLabel.numberOfLines = 0;

    UILabel *roleLabel = [UILabel new];
    roleLabel.text = role;
    roleLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:12];
    roleLabel.textColor = [UIColor lightGrayColor];
    roleLabel.numberOfLines = 0;

    UIView *row = [UIView new];
    [row addSubview:speakerLabel];
    [row addSubview:roleLabel];
    [row addSubview:self.linkedinButton];
    [row addSubview:self.twitterButton];

    [speakerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.equalTo(row);
        make.trailing.equalTo(self.linkedinButton.mas_leading);
    }];

    [self.twitterButton setContentHuggingPriority:751 forAxis:UILayoutConstraintAxisHorizontal];
    [self.twitterButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.trailing.equalTo(row);
    }];

    [self.linkedinButton setContentHuggingPriority:751 forAxis:UILayoutConstraintAxisHorizontal];
    [self.linkedinButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.twitterButton);
        make.trailing.equalTo(self.twitterButton.mas_leading);
    }];

    [roleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(speakerLabel);
        make.top.equalTo(speakerLabel.mas_bottom);
        make.bottom.equalTo(row);
    }];

    return row;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[self navigationController] setNavigationBarHidden:NO animated:animated];
}

- (IBAction)openLinkedIn:(id)sender
{
    if([self.event isKindOfClass:[Gig class]]) {
        Gig *gig = [Gig cast:self.event];
        [UIApplication.sharedApplication openURL:gig.wikipediaUrl];
    }
    
    Event *eventModel = [Event cast:self.event];
    if (eventModel.linkedIn) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:eventModel.linkedIn]];
    }
}

- (IBAction)openTwitter:(id)sender
{
    Event *eventModel = [Event cast:self.event];

    NSURL *twitterURL = nil;
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]) {
        twitterURL = [NSURL URLWithString:[NSString stringWithFormat:@"twitter://user?screen_name=%@",eventModel.twitter]];
        [[UIApplication sharedApplication] openURL:twitterURL];
    }else{
        twitterURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://twitter.com/%@",eventModel.twitter]];
    }
    [[UIApplication sharedApplication] openURL:twitterURL];
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

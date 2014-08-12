//
//  FestGigViewController.m
//  FestApp
//
//  Created by Oleg Grenrus on 10/06/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import "FestArtistViewController.h"

#import "FestAppDelegate.h"
#import "FestDataManager.h"
#import "FestImageManager.h"
#import "FestFavouritesManager.h"

#import "UIView+XYWidthHeight.h"

@interface FestArtistViewController ()
@property (nonatomic, strong) id event;

@property (nonatomic, strong) IBOutlet UIImageView *imageView;

@property (nonatomic, strong) IBOutlet UIButton *favouriteButton;

@property (nonatomic, strong) IBOutlet UILabel *gigLabel;
@property (nonatomic, strong) IBOutlet UILabel *stageLabel;
@property (nonatomic, strong) IBOutlet UILabel *infoLabel;

@property (nonatomic, strong) IBOutlet UIButton *wikipediaButton;

- (IBAction)toggleFavourite:(id)sender;
- (IBAction)openWikipedia:(id)sender;
@end

@implementation FestArtistViewController

+ (instancetype)newWithEvent:(id)event
{
    FestArtistViewController *controller = [[FestArtistViewController alloc] initWithNibName:@"FestArtistViewController" bundle:nil];

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
        self.infoLabel.text = eventModel.description;
    }

    // Favourite
    [self.favouriteButton setImage:[UIImage imageNamed:@"star-selected.png"] forState:UIControlStateSelected];

    [self.favouriteButton setTitle:@"Star" forState:UIControlStateNormal];
    [self.favouriteButton setTitle:@"Starred" forState:UIControlStateSelected];

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
}

- (void)viewWillAppear:(BOOL)animated
{
    [[self navigationController] setNavigationBarHidden:NO animated:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

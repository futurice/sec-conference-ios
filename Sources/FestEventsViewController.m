//
//  FestGigsViewController.m
//  FestApp
//
//  Created by Oleg Grenrus on 10/06/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import "FestEventsViewController.h"

#import "FestAppDelegate.h"
#import "FestDataManager.h"
#import "FestImageManager.h"
#import "FestEventCell.h"

@interface FestEventsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSArray *gigs;
@property (nonatomic,strong) NSArray *days;

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@end

#define kCellButtonTag 1000
#define kCellHeight 86

@implementation FestEventsViewController

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

    // Subscribe
    RACSignal *gigsSignal = [FestDataManager.sharedFestDataManager gigsSignal];
    [gigsSignal subscribeNext:^(NSArray *events) {
        
        if([[events firstObject] isKindOfClass:[Gig class]]) {
            NSArray *sortedGigs = [events sortedArrayUsingComparator:^NSComparisonResult(Gig* a, Gig *b) {
                return [a.gigName compare:b.gigName];
            }];
            
            self.gigs = sortedGigs;
        }
        else {
            self.gigs = events;
        }
        
        if ([[self.gigs firstObject] isKindOfClass:[Event class]]) {
            self.days = @[[self.gigs filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:
                            @"day contains[c] 'Friday' AND bar_camp == NO"]],
                          [self.gigs filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:
                            @"day contains[c] 'Saturday' AND bar_camp == NO"]]
                          ];
            self.days = @[[self.days[0] sortedArrayUsingComparator:^NSComparisonResult(Event *a, Event *b) {
                              return [a.title compare:b.title];
                          }],
                          [self.days[1] sortedArrayUsingComparator:^NSComparisonResult(Event *a, Event *b) {
                              return [a.title compare:b.title];
                          }]];
        }

        [self.tableView reloadData];
    }];

    // back button
    self.navigationItem.title = @"";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[FestDataManager sharedFestDataManager] reload];
    [[self navigationController] setNavigationBarHidden:NO animated:animated];
}

#pragma mark UITableViewDataSource

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wsign-conversion"

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.days.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ((NSArray *)self.days[section]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger idx = indexPath.row;

    static NSString *cellIdentifier = @"FestEventCell";
    FestEventCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:@"FestEventCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }

    NSArray *gigs = self.days[indexPath.section];
    
    if ([gigs[idx] isKindOfClass:[Gig class]]) {
        cell.gig = self.gigs[idx];
    }
    else if([gigs[idx] isKindOfClass:[Event class]]) {
        cell.event = gigs[idx];
    }

    return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
	return nil;
}

#pragma mark UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.backgroundColor = SXC_COLOR_ORANGE;
    headerLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:20];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.text = section ? @"Saturday" : @"Friday";
    return headerLabel;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
    view.backgroundColor = RGB_COLOR(240,142,12);

    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Gig *gig = (self.days[indexPath.section])[indexPath.row];
    [APPDELEGATE showGig:gig];
}

#pragma clang diagnostic pop

@end

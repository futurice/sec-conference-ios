//
//  FestBarCampViewController.m
//  FestApp
//
//  Created by Erik Jälevik on 23/10/15.
//  Copyright © 2015 Futurice Oy. All rights reserved.
//

#import "FestBarCampViewController.h"

#import "FestAppDelegate.h"
#import "FestDataManager.h"
#import "FestImageManager.h"
#import "FestEventCell.h"

@interface FestBarCampViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *events;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end

#define kCellButtonTag 1000
#define kCellHeight 86

@implementation FestBarCampViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Subscribe
    RACSignal *eventsSignal = [FestDataManager.sharedFestDataManager gigsSignal];
    @weakify(self);
    [eventsSignal subscribeNext:^(NSArray *events) {
        
        @strongify(self);
        self.events = [events filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"bar_camp == YES"]];
        self.events = [self.events sortedArrayUsingComparator:^NSComparisonResult(Event *a, Event *b) {
            return [a.title compare:b.title];
        }];

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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.events.count;
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

    cell.event = self.events[idx];

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
    headerLabel.text = @"Barcamp sessions";
    return headerLabel;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
    view.backgroundColor = RGB_COLOR(240,142,12);

    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Event *event = self.events[indexPath.row];
    [APPDELEGATE showEvent:event];
}

#pragma clang diagnostic pop

@end

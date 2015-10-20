//
//  FestInfoViewController.m
//  FestApp
//
//  Created by Oleg Grenrus on 14/06/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import "FestInfoViewController.h"

#import "FestAppDelegate.h"
#import "FestDataManager.h"

@interface InfoTableCellView : UITableViewCell
@end

@implementation InfoTableCellView
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    self.textLabel.textColor = highlighted ? RGB_COLOR(240,142,12) : [UIColor whiteColor];
}
@end

@interface FestInfoViewController ()  <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSArray *info;

@property (nonatomic, strong) UITableView *tableView;
@end

@implementation FestInfoViewController

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

    RACSignal *infoSignal = FestDataManager.sharedFestDataManager.infoSignal;
    [infoSignal subscribeNext:^(NSArray *info) {
        self.info = info;
        [self.tableView reloadData];
    }];

    self.navigationItem.title = @"";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

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
    return self.info.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger idx = indexPath.row;

    static NSString *cellIdentifier = @"InfoItemCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (cell == nil) {
        cell = [[InfoTableCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        // cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    InfoItem *infoItem = self.info[idx];

    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.text = infoItem.title;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:18];

    return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
	return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0f;
}

#pragma mark UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    InfoItem *infoItem = self.info[indexPath.row];
    [APPDELEGATE showInfoItem:infoItem];
}

#pragma clang diagnostic pop

@end

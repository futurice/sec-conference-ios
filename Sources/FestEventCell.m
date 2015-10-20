//
//  FestEventCell.m
//  FestApp
//
//  Created by Oleg Grenrus on 12/06/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import "FestEventCell.h"
#import "FestImageManager.h"
#import "UIImageView+AFNetworking.h"

@interface FestEventCell ()
@property (strong, nonatomic) IBOutlet UIImageView *speakerImageView;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *stageLabel;
@end

@implementation FestEventCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];

//    if (highlighted) {
//        self.nameLabel.textColor = self.stageLabel.textColor = FEST_COLOR_GOLD;
//    } else {
//        self.nameLabel.textColor = self.stageLabel.textColor = [UIColor blackColor];
//    }
}

#pragma mark - setter
- (void)setGig:(Gig *)gig
{
    if (_gig == gig) {
        return;
    }

    _gig = gig;
    self.nameLabel.text = gig.gigName;
    self.stageLabel.text = gig.stageAndTimeIntervalString;
}

- (void)setEvent:(Event *)event
{
    if (_event == event) {
        return;
    }
    
    _event = event;
    self.nameLabel.text = event.title;
    self.stageLabel.text = [NSString stringWithFormat:@"%@ - %@",event.artist,event.speakerRole];
//    if (event.speakerImageUrl) {
        [self.speakerImageView setImageWithURL:[NSURL URLWithString:event.speakerImageUrl] placeholderImage:[UIImage imageNamed:@"person_placeholder"]];
//    }
}

@end

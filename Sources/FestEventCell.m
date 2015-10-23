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
@property (nonatomic, strong) IBOutlet UILabel *stageLabel2;
@end

@implementation FestEventCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
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

    self.nameLabel.text = @"";
    self.stageLabel.text = @"";
    self.stageLabel2.text = @"";

    self.nameLabel.text = event.title;

    BOOL imageFound = NO;

    if (event.speakers.count > 0) {
        Speaker *sp = (Speaker*)event.speakers[0];
        self.stageLabel.text = [NSString stringWithFormat:@"%@ - %@", sp.name, sp.role];
        if (!imageFound && sp.imageURL) {
            [self.speakerImageView
                setImageWithURL:[NSURL URLWithString:sp.imageURL]
                placeholderImage:[UIImage imageNamed:@"person_placeholder"]];
            imageFound = YES;
        }
    }

    if (event.speakers.count > 1) {
        Speaker *sp = (Speaker*)event.speakers[1];
        self.stageLabel2.text = [NSString stringWithFormat:@"%@ - %@", sp.name, sp.role];

        if (!imageFound && sp.imageURL) {
            [self.speakerImageView
                setImageWithURL:[NSURL URLWithString:sp.imageURL]
                placeholderImage:[UIImage imageNamed:@"person_placeholder"]];
            imageFound = YES;
        }
    }

    if (!imageFound) {
        [self.speakerImageView
            setImageWithURL:[NSURL URLWithString:event.imageURL]
            placeholderImage:[UIImage imageNamed:@"person_placeholder"]];
    }
}

@end

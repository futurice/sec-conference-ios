//
//  FestArtistCell.h
//  FestApp
//
//  Created by Oleg Grenrus on 12/06/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Gig.h"
#import "Event.h"

@interface FestArtistCell : UITableViewCell
@property (nonatomic, strong) Gig *gig;
@property (nonatomic, strong) Event *event;
@end

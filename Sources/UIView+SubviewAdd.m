//
//  UIView+SubviewAdd.m
//
//  Created by Erik Jälevik on 02/09/14.
//  Copyright (c) 2014 Futurice. All rights reserved.
//

#import "UIView+SubviewAdd.h"


@implementation UIView (SubviewAdd)

- (id)addSubviewReturn:(UIView *)newView
{
    [self addSubview:newView];
    return newView;
}

@end

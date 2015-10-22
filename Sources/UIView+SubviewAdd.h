//
//  UIView+SubviewAdd.h
//
//  Created by Erik Jälevik on 02/09/14.
//  Copyright (c) 2014 Futurice. All rights reserved.
//

@interface UIView (SubviewAdd)

/// Convenience method for adding weakly held properties as subviews.
- (id)addSubviewReturn:(UIView *)view;

@end

//
//  SessionController.h
//  Puddle
//
//  Created by Wes Gibbs on 3/28/14.
//  Copyright (c) 2014 Wes Gibbs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PuddleScene.h"

@interface SessionController : NSObject

- (instancetype)initWithScene:(PuddleScene *)scene;
- (void)shutDown;

@end

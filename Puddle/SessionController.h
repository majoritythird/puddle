//
//  SessionController.h
//  Puddle
//
//  Created by Wes Gibbs on 3/28/14.
//  Copyright (c) 2014 Wes Gibbs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PuddleScene.h"

@class PuddleScene;

@interface SessionController : NSObject

- (instancetype)initWithScene:(PuddleScene *)scene;
- (BOOL)isPeerStillConnectedWithName:(NSString *)name;
- (void)peerEaten:(MCPeerID *)peerID;
- (void)startServices;
- (void)stopServices;

@end

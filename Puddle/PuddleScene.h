//
//  MyScene.h
//  Puddle
//

//  Copyright (c) 2014 Wes Gibbs. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "SessionController.h"

@class SessionController;

@interface PuddleScene : SKScene

@property(nonatomic,strong) SessionController *sessionController;

- (SKSpriteNode *)addLocalSpriteForPeer:(MCPeerID *)peerID;
- (SKSpriteNode *)addSpriteForPeer:(MCPeerID *)peerID imageName:(NSString *)imageName isME:(BOOL)isMe;
- (void)removeAllOtherCritters;
- (void)removeSpriteNamed:(NSString *)name;
- (void)spinSpriteForPeerNamed:(NSString *)name;

@end

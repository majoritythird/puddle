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

@property(nonatomic,copy) NSString *critterName;
@property(nonatomic,strong) SessionController *sessionController;

- (SKSpriteNode *)addPeerSpriteWithName:(NSString *)name imageName:(NSString *)imageName;
- (void)removeAllOtherCritters;
- (void)removeSpriteNamed:(NSString *)name;

@end

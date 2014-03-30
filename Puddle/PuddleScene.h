//
//  MyScene.h
//  Puddle
//

//  Copyright (c) 2014 Wes Gibbs. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface PuddleScene : SKScene

@property(nonatomic,copy) NSString *critterName;

- (SKSpriteNode *)addPeerSpriteWithName:(NSString *)name imageName:(NSString *)imageName;
- (void)removeSpriteNamed:(NSString *)name;

@end

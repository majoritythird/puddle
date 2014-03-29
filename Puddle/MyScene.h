//
//  MyScene.h
//  Puddle
//

//  Copyright (c) 2014 Wes Gibbs. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface MyScene : SKScene

@property(nonatomic,copy) NSString *critterName;

- (void)addSpriteNamed:(NSString *)name withImageNamed:(NSString *)imageName;
- (void)removeSpriteNamed:(NSString *)name;

@end

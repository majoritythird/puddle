//
//  VirusSpriteNode.m
//  Puddle
//
//  Created by Wes Gibbs on 3/29/14.
//  Copyright (c) 2014 Wes Gibbs. All rights reserved.
//

#import "VirusSpriteNode.h"

@implementation VirusSpriteNode

#pragma mark - Class methods

+ (instancetype)spriteNodeWithImageNamed:(NSString *)name
{
  SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:name];
  SKTexture *texture = [atlas textureNamed:@"1.png"];
  VirusSpriteNode *virus = [super spriteNodeWithTexture:texture];
  virus.name = @"virus";

  SKTexture *f1 = [atlas textureNamed:@"1.png"];
  SKTexture *f2 = [atlas textureNamed:@"2.png"];
  SKTexture *f3 = [atlas textureNamed:@"3.png"];
  SKTexture *f4 = [atlas textureNamed:@"4.png"];
  SKTexture *f5 = [atlas textureNamed:@"5.png"];
  SKTexture *f6 = [atlas textureNamed:@"6.png"];
  NSArray *virusTextures = @[f1,f2,f3,f4,f5,f6];
  
  SKAction *spriteAnimationAction = [SKAction animateWithTextures:virusTextures timePerFrame:0.1];
  [virus runAction:[SKAction repeatActionForever:spriteAnimationAction]];

  SKAction *rotateAction = [SKAction rotateByAngle:M_PI duration:20];
  [virus runAction:[SKAction repeatActionForever:rotateAction]];

  virus.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:virus.size.width/2.8f];
  virus.physicsBody.categoryBitMask = virusCategory;
  virus.physicsBody.contactTestBitMask = critterCategory;
  virus.physicsBody.friction = 0.2f;
  virus.physicsBody.linearDamping = 0.2f;
  virus.physicsBody.restitution = 0.8f;
  virus.physicsBody.mass = virus.physicsBody.mass * 4;
  virus.physicsBody.density = virus.physicsBody.density * 4;

  return virus;
}

@end

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
  VirusSpriteNode *virus = [super spriteNodeWithImageNamed:name];
  virus.name = @"virus";
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

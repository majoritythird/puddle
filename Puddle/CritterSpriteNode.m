//
//  CritterSpriteNode.m
//  Puddle
//
//  Created by Wes Gibbs on 3/29/14.
//  Copyright (c) 2014 Wes Gibbs. All rights reserved.
//

#import "CritterSpriteNode.h"

@implementation CritterSpriteNode

#pragma mark - Lifecycle

- (instancetype)initWithPeer:(MCPeerID *)peer imageName:(NSString *)imageName isMe:(BOOL)isMe
{
  self = [super initWithImageNamed:imageName];
  if (self) {
    _imageName = [imageName copy];
    _peerID = peer;
    _isMe = isMe;
    self.name = [peer.displayName copy];
    SKAction *rotateAction = [SKAction rotateByAngle:M_PI duration:40];
    [self runAction:[SKAction repeatActionForever:rotateAction]];
    self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
    self.physicsBody.categoryBitMask = critterCategory;
    self.physicsBody.contactTestBitMask = critterCategory;
    self.physicsBody.friction = 0.2;
    self.physicsBody.linearDamping = 0.2;
    self.physicsBody.restitution = 0.8;
  }
  return self;
}

#pragma mark - Methods

- (NSString *)birthSoundFileName
{
  return @"appear.mp3";
}

@end

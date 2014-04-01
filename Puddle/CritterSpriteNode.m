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
  SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:imageName];
  SKTexture *texture = [atlas textureNamed:@"1.png"];
  self = [super initWithTexture:texture];
  if (self) {
    self.name = [peer.displayName copy];
    _imageName = [imageName copy];
    _peerID = peer;
    _isMe = isMe;

    SKTexture *f1 = [atlas textureNamed:@"1.png"];
    SKTexture *f2 = [atlas textureNamed:@"2.png"];
    SKTexture *f3 = [atlas textureNamed:@"3.png"];
    SKTexture *f4 = [atlas textureNamed:@"4.png"];
    SKTexture *f5 = [atlas textureNamed:@"5.png"];
    SKTexture *f6 = [atlas textureNamed:@"6.png"];
    NSArray *critterTextures = @[f1,f2,f3,f4,f5,f6];
    
    SKAction *spriteAnimationAction = [SKAction animateWithTextures:critterTextures timePerFrame:0.1];
    [self runAction:[SKAction repeatActionForever:spriteAnimationAction]];
    
    SKAction *rotateAction = [SKAction rotateByAngle:M_PI duration:40];
    [self runAction:[SKAction repeatActionForever:rotateAction]];

    self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
    self.physicsBody.categoryBitMask = critterCategory;
    self.physicsBody.contactTestBitMask = critterCategory;
    self.physicsBody.friction = 0.2f;
    self.physicsBody.linearDamping = 0.2f;
    self.physicsBody.restitution = 0.8f;
  }
  return self;
}

#pragma mark - Methods

- (NSString *)birthSoundFileName
{
  return @"appear.mp3";
}

@end

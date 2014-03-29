//
//  MyScene.m
//  Puddle
//
//  Created by Wes Gibbs on 3/28/14.
//  Copyright (c) 2014 Wes Gibbs. All rights reserved.
//

#import "MyScene.h"

static const uint32_t wallCategory     =  0x1 << 0;
static const uint32_t critterCategory  =  0x1 << 1;

@interface MyScene ()

@property(nonatomic,strong) SKSpriteNode *mySprite;

@end

@implementation MyScene

#pragma mark - Lifecycle

-(id)initWithSize:(CGSize)size {
  if (self = [super initWithSize:size]) {
    
    self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
    
    NSUInteger critterImageIndex = arc4random() % 2 + 1;
    _mySprite = [SKSpriteNode spriteNodeWithImageNamed:[NSString stringWithFormat:@"Critter%@",@(critterImageIndex)]];
    CGPoint location = CGPointMake(CGRectGetMidX(self.scene.frame), CGRectGetMidY(self.scene.frame));
    _mySprite.name = @"ME";
    _mySprite.position = location;
    SKAction *action = [SKAction rotateByAngle:M_PI duration:40];
    [_mySprite runAction:[SKAction repeatActionForever:action]];
    _mySprite.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_mySprite.size];
    _mySprite.physicsBody.categoryBitMask = critterCategory;
    _mySprite.physicsBody.friction = 0.0;
    _mySprite.physicsBody.linearDamping = 0.0;
    _mySprite.physicsBody.restitution = 1;
    [self addChild:_mySprite];
    [_mySprite.physicsBody applyImpulse:CGVectorMake(5.0f, -0.5f)];

    SKPhysicsBody *wallBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsBody = wallBody;
    self.physicsBody.categoryBitMask = wallCategory;
    self.physicsBody.friction = 0.0;

    self.physicsWorld.gravity = CGVectorMake(0.0,0.0);
  }
  return self;
}

#pragma mark - Methods

- (NSString *)stringForPeerConnectionState:(MCSessionState)state
{
  switch (state) {
    case MCSessionStateConnected:
      return @"Connected";
      
    case MCSessionStateConnecting:
      return @"Connecting";
      
    case MCSessionStateNotConnected:
      return @"Not Connected";
  }
}

#pragma mark - MCSessionDelegate

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
  NSLog(@"Peer [%@] changed state to %@", peerID.displayName, [self stringForPeerConnectionState:state]);
  
  switch (state) {
    case MCSessionStateConnected: {
      CGPoint location = CGPointMake(CGRectGetMidX(self.scene.frame), CGRectGetMidY(self.scene.frame));
      SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Critter1"];
      sprite.name = peerID.displayName;
      sprite.position = location;
      SKAction *action = [SKAction rotateByAngle:M_PI duration:40];
      [sprite runAction:[SKAction repeatActionForever:action]];
      sprite.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:sprite.size];
      sprite.physicsBody.categoryBitMask = critterCategory;
      sprite.physicsBody.friction = 0.0;
      sprite.physicsBody.linearDamping = 0.0;
      sprite.physicsBody.restitution = 1;
      [sprite.physicsBody applyImpulse:CGVectorMake(5.0f, 0.5f)];
      [self addChild:sprite];
    }
      
    case MCSessionStateConnecting:
      return;
      
    case MCSessionStateNotConnected: {
      SKNode *sprite = [self childNodeWithName:peerID.displayName];
      [sprite removeFromParent];
    }
  }
}

// MCSession Delegate callback when receiving data from a peer in a given session
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
}

// MCSession delegate callback when we start to receive a resource from a peer in a given session
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
}

// MCSession delegate callback when a incoming resource transfer ends (possibly with error)
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
}

// Streaming API not utilized in this sample code
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
}

#pragma mark - SKScene

-(void)update:(CFTimeInterval)currentTime {
  /* Called before each frame is rendered */
}

@end

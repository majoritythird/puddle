//
//  MyScene.m
//  Puddle
//
//  Created by Wes Gibbs on 3/28/14.
//  Copyright (c) 2014 Wes Gibbs. All rights reserved.
//

#import "MyScene.h"

@interface MyScene ()

@end

@implementation MyScene

#pragma mark - Lifecycle

-(id)initWithSize:(CGSize)size {
  if (self = [super initWithSize:size]) {
    /* Setup your scene here */
    
    self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
    
    SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    
    myLabel.text = @"Hello, World!";
    myLabel.fontSize = 30;
    myLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    
    [self addChild:myLabel];
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
      SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
      sprite.name = peerID.displayName;
      sprite.position = location;
      SKAction *action = [SKAction rotateByAngle:M_PI duration:1];
      [sprite runAction:[SKAction repeatActionForever:action]];
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

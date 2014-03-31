//
//  MyScene.m
//  Puddle
//
//  Created by Wes Gibbs on 3/28/14.
//  Copyright (c) 2014 Wes Gibbs. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import "PuddleScene.h"
#import "CritterSpriteNode.h"
#import "VirusSpriteNode.h"

@interface PuddleScene ()
<SKPhysicsContactDelegate>

@property(nonatomic,strong) NSDate *lastContactSoundPlayedAt;
@property(nonatomic,strong) CMMotionManager *motionManager;
@property(nonatomic,strong) CMAttitude *referenceAttitude;

@end

@implementation PuddleScene

#pragma mark - Lifecycle

-(id)initWithSize:(CGSize)size {
  if (self = [super initWithSize:size]) {
    
    self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
    
    SKPhysicsBody *wallBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    wallBody.categoryBitMask = wallCategory;
    wallBody.friction = 0.2f;
    self.physicsBody = wallBody;

    VirusSpriteNode *virus = [VirusSpriteNode spriteNodeWithImageNamed:@"Virus"];
    virus.position = CGPointMake(CGRectGetMidX(self.scene.frame), CGRectGetMidY(self.scene.frame) + 100);
    [self addChild:virus];

    _motionManager = [[CMMotionManager alloc] init];
    if([_motionManager isDeviceMotionAvailable]) {
      [_motionManager setAccelerometerUpdateInterval:1.0/30.0];
      [_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue new] withHandler:^(CMDeviceMotion *motion, NSError *error)
       {
         if(!_referenceAttitude) {
           _referenceAttitude = motion.attitude;
         }
         if(!self.scene.isPaused) {
           CMAttitude *attitude = motion.attitude;
           // Multiply by the inverse of the reference attitude so motion is relative to the start attitude.
           [attitude multiplyByInverseOfAttitude:_referenceAttitude];
           for (SKSpriteNode *child in self.scene.children) {
             [child.physicsBody applyImpulse:CGVectorMake(attitude.roll * 0.2f, -attitude.pitch * 0.2f)];
           }
         }
       }];
    }
    
    self.physicsWorld.gravity = CGVectorMake(0.0f,0.0f);
    self.physicsWorld.contactDelegate = self;
  }
  return self;
}

#pragma mark - Methods

- (SKSpriteNode *)addLocalSpriteForPeer:(MCPeerID *)peerID
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSString *critterName = [defaults objectForKey:kCritterNameKey];
  if (critterName == nil) {
    NSUInteger critterImageIndex = arc4random() % 2 + 1;
    critterName = [NSString stringWithFormat:@"Critter%@", @(critterImageIndex)];
    [defaults setObject:critterName forKey:kCritterNameKey];
    [defaults synchronize];
  }
  
  return [self addSpriteForPeer:peerID imageName:critterName isME:YES];
}

- (SKSpriteNode *)addSpriteForPeer:(MCPeerID *)peerID imageName:(NSString *)imageName isME:(BOOL)isMe
{
  NSString *name = peerID.displayName;
  SKNode *existingNode = [self.scene.children bk_match:^BOOL(SKNode *node) {
    return ([node.name isEqualToString:name]);
  }];
  
  if (existingNode != nil) {
    return (SKSpriteNode *)existingNode;
  }
  
  CritterSpriteNode *sprite = [[CritterSpriteNode alloc] initWithPeer:peerID imageName:imageName isMe:isMe];
  CGPoint location = CGPointMake(CGRectGetMidX(self.scene.frame), CGRectGetMidY(self.scene.frame));
  sprite.position = location;
  [self addChild:sprite];
  [self runAction:[SKAction playSoundFileNamed:sprite.birthSoundFileName waitForCompletion:NO]];
  
  return sprite;
}

- (void)critter:(SKSpriteNode *)critter1 didCollideWithCritter:(SKSpriteNode *)critter2
{
  if (self.lastContactSoundPlayedAt == nil) {
    [self runAction:[SKAction playSoundFileNamed:@"contact.mp3" waitForCompletion:NO]];
    self.lastContactSoundPlayedAt = [NSDate date];
  }
  else if ([self.lastContactSoundPlayedAt timeIntervalSinceNow]*-1 > 1) {
    [self runAction:[SKAction playSoundFileNamed:@"contact.mp3" waitForCompletion:NO]];
    self.lastContactSoundPlayedAt = [NSDate date];
  }
}

- (void)critter:(CritterSpriteNode *)critter didCollideWithVirus:(SKSpriteNode *)virus
{
  [self runAction:[SKAction playSoundFileNamed:@"eaten.mp3" waitForCompletion:NO]];
  [critter removeFromParent];
  [self.sessionController peerEaten:critter.peerID];
  
  __weak typeof(self) weakSelf = self;
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
    if ([weakSelf.sessionController isPeerStillConnectedWithName:critter.name] || critter.isMe) {
      [weakSelf addSpriteForPeer:critter.peerID imageName:critter.imageName isME:critter.isMe];
    }
  });
}

- (void)removeAllOtherCritters
{
  [self.scene.children bk_each:^(SKNode *node) {
    if ([node isKindOfClass:[CritterSpriteNode class]]) {
      CritterSpriteNode *critterNode = (CritterSpriteNode *)node;
      if (critterNode.isMe == NO) {
        [node removeFromParent];
      }
    }
  }];
}

- (void)removeSpriteNamed:(NSString *)name
{
  SKNode *sprite = [self childNodeWithName:name];
  [sprite removeFromParent];
}

- (void)spinSpriteForPeerNamed:(NSString *)name
{
  SKNode *sprite = [self childNodeWithName:name];
  SKAction *rotateAction = [SKAction rotateByAngle:M_PI duration:0.5f];
  [sprite runAction:[SKAction repeatAction:rotateAction count:5]];
}

#pragma mark - SKPhysicsContactDelegate

- (void)didBeginContact:(SKPhysicsContact *)contact
{
  SKPhysicsBody *firstBody, *secondBody;
  
  if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
  {
    firstBody = contact.bodyA;
    secondBody = contact.bodyB;
  }
  else
  {
    firstBody = contact.bodyB;
    secondBody = contact.bodyA;
  }
  
  if ((firstBody.categoryBitMask & critterCategory) != 0 && (secondBody.categoryBitMask & critterCategory) != 0) {
    [self critter:(SKSpriteNode *)firstBody.node didCollideWithCritter:(SKSpriteNode *)secondBody.node];
  }
  else if ((firstBody.categoryBitMask & critterCategory) != 0 && (secondBody.categoryBitMask & virusCategory) != 0) {
    [self critter:(CritterSpriteNode *)firstBody.node didCollideWithVirus:(SKSpriteNode *)secondBody.node];
  }

}

#pragma mark - SKScene

-(void)update:(CFTimeInterval)currentTime {
  /* Called before each frame is rendered */
}

@end

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
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.critterName = [defaults objectForKey:kCritterNameKey];
    if (self.critterName == nil) {
      NSUInteger critterImageIndex = arc4random() % 2 + 1;
      self.critterName = [NSString stringWithFormat:@"Critter%@", @(critterImageIndex)];
      [defaults setObject:self.critterName forKey:kCritterNameKey];
    }
    
    _mySprite = [SKSpriteNode spriteNodeWithImageNamed:self.critterName];
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
    self.physicsBody.linearDamping = 0.0;

    self.physicsWorld.gravity = CGVectorMake(0.0,0.0);
  }
  return self;
}

#pragma mark - Methods

- (void)addSpriteNamed:(NSString *)name withImageNamed:(NSString *)imageName
{
  CGPoint location = CGPointMake(CGRectGetMidX(self.scene.frame), CGRectGetMidY(self.scene.frame));
  SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:imageName];
  sprite.name = name;
  sprite.position = location;
  SKAction *action = [SKAction rotateByAngle:M_PI duration:40];
  [sprite runAction:[SKAction repeatActionForever:action]];
  sprite.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:sprite.size];
  sprite.physicsBody.categoryBitMask = critterCategory;
  sprite.physicsBody.friction = 0.0;
  sprite.physicsBody.linearDamping = 0.0;
  sprite.physicsBody.restitution = 1;
  [self addChild:sprite];
  [sprite.physicsBody applyImpulse:CGVectorMake(25, 5)];
}

- (void)removeSpriteNamed:(NSString *)name
{
  SKNode *sprite = [self childNodeWithName:name];
  [sprite removeFromParent];
}

#pragma mark - SKScene

-(void)update:(CFTimeInterval)currentTime {
  /* Called before each frame is rendered */
}

@end

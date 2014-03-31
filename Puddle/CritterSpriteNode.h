//
//  CritterSpriteNode.h
//  Puddle
//
//  Created by Wes Gibbs on 3/29/14.
//  Copyright (c) 2014 Wes Gibbs. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface CritterSpriteNode : SKSpriteNode

@property(nonatomic,copy) NSString *birthSoundFileName;
@property(nonatomic,copy) NSString *imageName;
@property(nonatomic,assign) BOOL isMe;
@property(nonatomic,strong) MCPeerID *peerID;

- (instancetype)initWithPeer:(MCPeerID *)peer imageName:(NSString *)imageName isMe:(BOOL)isMe;

@end

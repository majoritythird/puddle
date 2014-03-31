//
//  SessionController.m
//  Puddle
//
//  Created by Wes Gibbs on 3/28/14.
//  Copyright (c) 2014 Wes Gibbs. All rights reserved.
//

#import "SessionController.h"

@interface SessionController ()
<MCNearbyServiceBrowserDelegate,MCNearbyServiceAdvertiserDelegate,MCSessionDelegate>

@property(nonatomic,strong) MCNearbyServiceAdvertiser *advertiser;
@property(nonatomic,strong) MCNearbyServiceBrowser *browser;
@property(nonatomic,strong) NSMutableArray *connectedPeers;
@property(nonatomic,strong) MCPeerID *peerID;
@property(nonatomic,strong) MCSession *session;
@property(nonatomic,strong) PuddleScene *scene;

@end

@implementation SessionController

#pragma mark - Lifecycle

- (void)dealloc
{
  [_advertiser stopAdvertisingPeer];
  [_browser stopBrowsingForPeers];
  [_session disconnect];
}

- (instancetype)initWithScene:(id)scene
{
  self = [super init];
  if (self) {
    _connectedPeers = [NSMutableArray array];
    _scene = scene;
    NSString *deviceName = [UIDevice currentDevice].name;
    _peerID = [[MCPeerID alloc] initWithDisplayName:deviceName];
    _session = [[MCSession alloc] initWithPeer:_peerID];
    NSLog(@"[%@] created session [%p]", _peerID.displayName, &_session);
    _session.delegate = self;
    _advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:_peerID discoveryInfo:nil serviceType:@"mt-puddle"];
    _advertiser.delegate = self;
    _browser = [[MCNearbyServiceBrowser alloc] initWithPeer:_peerID serviceType:@"mt-puddle"];
    _browser.delegate = self;
  }
  return self;
}

#pragma mark - Methods

- (NSString *)connectedPeersStringForSession:(MCSession *)session
{
  NSArray *peerDisplayNames = [session.connectedPeers bk_map:^id(MCPeerID *peer) {
    return peer.displayName;
  }];
  
  return [peerDisplayNames componentsJoinedByString:@", "];
}

- (BOOL)isPeerStillConnectedWithName:(NSString *)name
{
  return [self.connectedPeers bk_any:^BOOL(MCPeerID *peerID) {
    return [peerID.displayName isEqualToString:name];
  }];;
}

- (void)startServices
{
  [self.advertiser startAdvertisingPeer];
  [self.browser startBrowsingForPeers];
}

- (void)stopServices
{
  [self.advertiser stopAdvertisingPeer];
  [self.browser stopBrowsingForPeers];
  [self.session disconnect];
}

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

#pragma mark - MCNearbyServiceAdvertiserDelegate

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error
{
  NSLog(@"advertiser failure");
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler
{
  NSLog(@"Advertiser: [%@] accepting invitation from [%@] with session [%p]", self.peerID.displayName, peerID.displayName, &_session);
  invitationHandler(YES, self.session);
}

#pragma mark - MCNearbyServiceBrowserDelegate

- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
{
  NSLog(@"browser failure");
}

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
  BOOL shouldInvite = ([self.peerID.displayName compare:peerID.displayName]==NSOrderedDescending);
  
  if (shouldInvite) {
    [browser invitePeer:peerID toSession:self.session withContext:nil timeout:10];
  }
  
  NSLog(@"Browser: [%@] found [%@] – inviting to session [%p]: %@", self.peerID.displayName, peerID.displayName, &_session, @(shouldInvite));
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
  NSLog(@"%@ browser lost peer %@", self.peerID.displayName, peerID.displayName);
}

#pragma mark - MCSessionDelegate

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    NSLog(@"Session [%p] reports [%@] changed state to %@", &session, peerID.displayName, [self stringForPeerConnectionState:state]);
    
    switch (state) {
      case MCSessionStateConnected: {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *critterName = [defaults objectForKey:kCritterNameKey];
        NSData *critterNameAsData = [critterName dataUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"%@ sending data[%@] to %@ using session [%p]", self.peerID.displayName, critterName, [self connectedPeersStringForSession:session], &session);
        [session sendData:critterNameAsData toPeers:session.connectedPeers withMode:MCSessionSendDataReliable error:nil];
      }
        
      case MCSessionStateConnecting:
        return;
        
      case MCSessionStateNotConnected: {
        [self.scene removeSpriteNamed:peerID.displayName];
        [self.connectedPeers removeObject:peerID];
      }
    }
}

- (void) session:(MCSession *)session didReceiveCertificate:(NSArray *)certificate fromPeer:(MCPeerID *)peerID certificateHandler:(void (^)(BOOL accept))certificateHandler
{
  certificateHandler(YES);
}

// MCSession Delegate callback when receiving data from a peer in a given session
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
  __weak typeof(self) weakSelf = self;
  dispatch_async(dispatch_get_main_queue(), ^{
    NSString *critterName = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@ received data[%@] from %@ on session [%p]", weakSelf.peerID.displayName, critterName, peerID.displayName, &session);
    [weakSelf.scene addPeerSpriteWithName:peerID.displayName imageName:critterName];
    [self.connectedPeers addObject:peerID];
  });
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

@end

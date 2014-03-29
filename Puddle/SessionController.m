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
@property(nonatomic,strong) MCPeerID *peerID;
@property(nonatomic,strong) MCSession *session;
@property(nonatomic,strong) MyScene *scene;

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
    _scene = scene;
    [self startServices:nil];
  }
  return self;
}

#pragma mark - Methods

- (void)shutDown
{
  [self.advertiser stopAdvertisingPeer];
  [self.browser stopBrowsingForPeers];
  [self.session disconnect];
}

- (void)startServices:(id)notification
{
  NSString *deviceName = [UIDevice currentDevice].name;
  self.peerID = [[MCPeerID alloc] initWithDisplayName:deviceName];
  self.session = [[MCSession alloc] initWithPeer:_peerID];
  self.session.delegate = self;
  self.advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:_peerID discoveryInfo:nil serviceType:@"mt-puddle"];
  self.advertiser.delegate = self;
  
  self.browser = [[MCNearbyServiceBrowser alloc] initWithPeer:_peerID serviceType:@"mt-puddle"];
  self.browser.delegate = self;
  
  [self.advertiser startAdvertisingPeer];
  [self.browser startBrowsingForPeers];
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

#pragma mark - MCNearbyServiceBrowserDelegate

- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
{
  NSLog(@"browser failure");
}

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
  NSLog(@"%@ browser found peer %@", self.peerID.displayName, peerID.displayName);
  BOOL shouldInvite = ([self.peerID.displayName compare:peerID.displayName]==NSOrderedDescending);
  
  if (shouldInvite) {
    NSLog(@"Inviting");
    [browser invitePeer:peerID toSession:self.session withContext:nil timeout:10];
  }
  else {
    NSLog(@"Not inviting");
  }
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
  NSLog(@"%@ browser lost peer %@", self.peerID.displayName, peerID.displayName);
}

#pragma mark - MCNearbyServiceAdvertiserDelegate

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error
{
  NSLog(@"advertiser failure");
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler
{
  NSLog(@"Peer %@ accepting invitation from %@", self.peerID.displayName, peerID.displayName);
  invitationHandler(YES, self.session);
}

#pragma mark - MCSessionDelegate

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
  NSLog(@"Peer [%@] changed state to %@", peerID.displayName, [self stringForPeerConnectionState:state]);
  
  switch (state) {
    case MCSessionStateConnected: {
      NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
      NSString *critterName = [defaults objectForKey:kCritterNameKey];
      NSData *critterNameAsData = [critterName dataUsingEncoding:NSUTF8StringEncoding];
      [session sendData:critterNameAsData toPeers:session.connectedPeers withMode:MCSessionSendDataReliable error:nil];
    }
      
    case MCSessionStateConnecting:
      return;
      
    case MCSessionStateNotConnected: {
      [self.scene removeSpriteNamed:peerID.displayName];
    }
  }
}

// MCSession Delegate callback when receiving data from a peer in a given session
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
  NSString *critterName = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  [self.scene addSpriteNamed:peerID.displayName withImageNamed:critterName];
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

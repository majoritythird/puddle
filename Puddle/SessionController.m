//
//  SessionController.m
//  Puddle
//
//  Created by Wes Gibbs on 3/28/14.
//  Copyright (c) 2014 Wes Gibbs. All rights reserved.
//

#import "SessionController.h"

@interface SessionController ()
<MCNearbyServiceBrowserDelegate,MCNearbyServiceAdvertiserDelegate>

@property(nonatomic,strong) MCNearbyServiceAdvertiser *advertiser;
@property(nonatomic,strong) MCNearbyServiceBrowser *browser;
@property(nonatomic,strong) MCPeerID *peerID;
@property(nonatomic,strong) MCSession *session;
@property(nonatomic,strong) id<MCSessionDelegate> sessionDelegate;

@end

@implementation SessionController

#pragma mark - Lifecycle

- (void)dealloc
{
  [_advertiser stopAdvertisingPeer];
  [_browser stopBrowsingForPeers];
  [_session disconnect];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (instancetype)initWithSessionDelegate:(id<MCSessionDelegate>)sessionDelegate
{
  self = [super init];
  if (self) {
    _sessionDelegate = sessionDelegate;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startServices:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopServices:) name:UIApplicationDidEnterBackgroundNotification object:nil];
  }
  return self;
}

#pragma mark - Methods

- (void)startServices:(id)notification
{
  NSString *deviceName = [UIDevice currentDevice].name;
  self.peerID = [[MCPeerID alloc] initWithDisplayName:deviceName];
  self.session = [[MCSession alloc] initWithPeer:_peerID];
  self.session.delegate = self.sessionDelegate;
  self.advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:_peerID discoveryInfo:nil serviceType:@"mt-puddle"];
  self.advertiser.delegate = self;
  
  self.browser = [[MCNearbyServiceBrowser alloc] initWithPeer:_peerID serviceType:@"mt-puddle"];
  self.browser.delegate = self;
  
  [self.advertiser startAdvertisingPeer];
  [self.browser startBrowsingForPeers];
}

- (void)stopServices:(id)notification
{
  [self.advertiser stopAdvertisingPeer];
  [self.browser stopBrowsingForPeers];
  [self.session disconnect];
}

#pragma mark - MCNearbyServiceBrowserDelegate

- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
{
  NSLog(@"browser failure");
}

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
  NSLog(@"Browser found peer %@", peerID.displayName);
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
  NSLog(@"Browser lost peer %@", peerID.displayName);
}

#pragma mark - MCNearbyServiceAdvertiserDelegate

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error
{
  NSLog(@"advertiser failure");
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler
{
  invitationHandler(YES, self.session);
}

@end

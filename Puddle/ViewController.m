//
//  ViewController.m
//  Puddle
//
//  Created by Wes Gibbs on 3/28/14.
//  Copyright (c) 2014 Wes Gibbs. All rights reserved.
//

#import "ViewController.h"
#import "PuddleScene.h"
#import "SessionController.h"

@interface ViewController ()

@property(nonatomic,strong) SessionController *sessionController;
@property(nonatomic,strong) PuddleScene *puddleScene;

@end

@implementation ViewController

#pragma mark - Lifecycle

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder:aDecoder];
  if (self) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startPeerServices:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopPeerServices:) name:UIApplicationDidEnterBackgroundNotification object:nil];
  }
  return self;
}

#pragma mark - Methods

- (void)startPeerServices:(id)notification
{
  if (self.puddleScene != nil && self.sessionController == nil) {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
      weakSelf.sessionController = [[SessionController alloc] initWithScene:weakSelf.puddleScene];
      [weakSelf.sessionController startServices];
      [weakSelf.puddleScene removeAllOtherCritters];
    });
  }
}

- (void)stopPeerServices:(id)notification
{
  [self.sessionController stopServices];
  self.sessionController = nil;
}

#pragma mark - UIViewController

- (BOOL)prefersStatusBarHidden {
  return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)viewDidLoad
{
  // Configure the view.
  SKView *skView = (SKView *)self.view;
  skView.showsFPS = YES;
  skView.showsNodeCount = YES;
  
  // Create and configure the scene.
  self.puddleScene = [PuddleScene sceneWithSize:skView.bounds.size];
  self.puddleScene.scaleMode = SKSceneScaleModeAspectFill;
  
  [self startPeerServices:nil];

  // Present the scene.
  [skView presentScene:self.puddleScene];
}

@end

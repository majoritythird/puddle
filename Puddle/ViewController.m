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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(spinItUp:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(spinItDown:) name:UIApplicationDidEnterBackgroundNotification object:nil];
  }
  return self;
}

#pragma mark - Methods

- (void)spinItDown:(id)notification
{
  [self.sessionController shutDown];
}

- (void)spinItUp:(id)notification
{
  // Configure the view.
  SKView *skView = (SKView *)self.view;
  skView.showsFPS = YES;
  skView.showsNodeCount = YES;
  
  // Create and configure the scene.
  PuddleScene *scene = [PuddleScene sceneWithSize:skView.bounds.size];
  scene.scaleMode = SKSceneScaleModeAspectFill;
  
  self.sessionController = [[SessionController alloc] initWithScene:scene];
  
  // Present the scene.
  [skView presentScene:scene];
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

@end

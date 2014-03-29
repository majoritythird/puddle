//
//  ViewController.m
//  Puddle
//
//  Created by Wes Gibbs on 3/28/14.
//  Copyright (c) 2014 Wes Gibbs. All rights reserved.
//

#import "ViewController.h"
#import "MyScene.h"
#import "SessionController.h"

@interface ViewController ()

@property(nonatomic,strong) SessionController *sessionController;

@end

@implementation ViewController

#pragma mark - Lifecycle

- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder:aDecoder];
  if (self) {
    
  }
  return self;
}

#pragma mark - UIViewController

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
  [super viewDidLoad];
  
  // Configure the view.
  SKView *skView = (SKView *)self.view;
  skView.showsFPS = YES;
  skView.showsNodeCount = YES;
  
  // Create and configure the scene.
  MyScene *scene = [MyScene sceneWithSize:skView.bounds.size];
  scene.scaleMode = SKSceneScaleModeAspectFill;
  
  self.sessionController = [[SessionController alloc] initWithSessionDelegate:scene];
  
  // Present the scene.
  [skView presentScene:scene];
}

@end

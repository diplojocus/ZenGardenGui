//
//  ZenGarden_GUIAppDelegate.m
//  ZenGarden_GUI
//
//  Created by Joe White on 27/04/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ZenGarden_GUIAppDelegate.h"

@implementation ZenGarden_GUIAppDelegate

@synthesize window;
@synthesize mainViewController;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  
  mainViewController = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
  [window setContentView:mainViewController.view];
}

- (void)dealloc {
  
  [mainViewController release];
  [window release];
  [super dealloc];
}

@end

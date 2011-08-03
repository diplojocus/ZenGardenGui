//
//  ZenGarden_GUIAppDelegate.h
//  ZenGarden_GUI
//
//  Created by Joe White on 27/04/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MainViewController.h"
#import "ZenGarden.h"


@interface ZenGarden_GUIAppDelegate : NSObject <NSApplicationDelegate> {
@private
  NSWindow *window;
  MainViewController *mainViewController;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet MainViewController *mainViewController;

@end

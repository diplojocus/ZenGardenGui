//
//  MainViewController.m
//  ZenGarden_GUI
//
//  Created by Joe White on 03/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"

@implementation MainViewController

@synthesize headerView;
@synthesize projectView;
@synthesize helpView;
@synthesize canvasMainView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    
    }
    
    return self;
}

- (void)dealloc
{
  [super dealloc];
}

- (IBAction)toggleEditMode:(id)sender {
  [canvasMainView toggleEditMode:sender];
  for (NSView *view in self.view.subviews) {
    [view setNeedsDisplay:YES];
  }
}

- (IBAction)removeObject:(id)sender {
  [canvasMainView removeObject];
}

- (IBAction)putObject:(id)sender {
  [canvasMainView putObject];
}

- (IBAction)addBang:(id)sender {
  [canvasMainView addBang];
}


@end

//
//  MainViewController.h
//  ZenGarden_GUI
//
//  Created by Joe White on 03/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HeaderView.h"
#import "ProjectView.h"
#import "HelpView.h"
#import "CanvasMainView.h"

@interface MainViewController : NSViewController {
  
  HeaderView *headerView;
  ProjectView *projectView;
  HelpView *helpView;
  CanvasMainView *canvasMainView;

@private

}

@property (assign) IBOutlet HeaderView *headerView;
@property (assign) IBOutlet ProjectView *projectView;
@property (assign) IBOutlet HelpView *helpView;
@property (assign) IBOutlet CanvasMainView *canvasMainView;

- (IBAction)toggleEditMode:(id)sender;

- (IBAction)removeObject:(id)sender;

- (IBAction)putObject:(id)sender;

- (IBAction)addBang:(id)sender;

- (IBAction)removeObject:(id)sender;


@end

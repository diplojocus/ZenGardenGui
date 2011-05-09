//
//  CanvasMainView.h
//  ZenGarden_GUI
//
//  Created by Joe White on 27/04/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ObjectView.h"


@interface CanvasMainView : NSView {
  
  NSPoint marquee;
  NSPoint anchor;
  
}

-(IBAction)putObject:(id)sender;

@end

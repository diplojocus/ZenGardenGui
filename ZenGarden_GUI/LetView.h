//
//  LetView.h
//  ZenGarden_GUI
//
//  Created by Joe White on 17/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface LetView : NSView {

  NSCursor *cursor;
  NSTrackingArea *letTrackingArea;
  NSMutableArray *connectionsArray;
  
  BOOL isSignal; // YES is Signal, NO is Message
  BOOL isInlet; // YES is Inlet, NO is Outlet
    
}

- (void)drawBackground;
- (void)resetTrackingArea;

@end

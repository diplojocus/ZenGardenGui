//
//  LetView.h
//  ZenGarden_GUI
//
//  Created by Joe White on 17/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol LetViewDelegate

- (void)mouseDownOfLet:(id)aLetView;
- (void)mouseUpOfLet:(id)aLetView;

@end

@interface LetView : NSView {
  
  NSObject <LetViewDelegate> *delegate;
  
  NSCursor *cursor;
  NSTrackingArea *letTrackingArea;
  NSMutableArray *connectionsArray;
  
  BOOL isSignal; // YES is Signal, NO is Message
  BOOL isInlet; // YES is Inlet, NO is Outlet
}

- (void)drawBackground;

- (void)resetTrackingArea;

@end

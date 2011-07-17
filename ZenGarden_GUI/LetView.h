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
- (void)mouseDraggedOfLetWithEvent:(NSEvent *)theEvent;
- (void)mouseUpOfLet:(id)aLetView withEvent:(NSEvent *)theEvent;

@end

@interface LetView : NSView {
  
  NSObject <LetViewDelegate> *delegate;
  
  NSCursor *cursor;
  NSTrackingArea *letTrackingArea;
  NSMutableArray *connectionsArray;
  
  BOOL isInlet; // YES is Inlet, NO is Outlet

}

@property (nonatomic, readwrite) BOOL isInlet;

- (void)drawBackground;

- (void)resetTrackingArea;

@end

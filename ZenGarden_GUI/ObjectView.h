//
//  ObjectView.h
//  ZenGarden_GUI
//
//  Created by Joe White on 27/04/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ObjectView : NSView <NSTextFieldDelegate> {
  
  NSTextField *textField;
  
  NSPoint updatedFrameOrigin;
  
  BOOL isObjectInstantiated;
  NSColor *ObjectBackgroundState;
  
  
}

@end

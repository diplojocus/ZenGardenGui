//
//  ObjectView.h
//  ObjectDrawing
//
//  Created by Joe White on 03/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ObjectView : NSView {
@private
    
}

- (void)drawBackground:(NSRect)rect;

- (void)drawLet:(NSPoint)inletOrigin;

@end

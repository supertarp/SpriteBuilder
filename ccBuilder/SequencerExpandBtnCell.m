/*
 * CocosBuilder: http://www.cocosbuilder.com
 *
 * Copyright (c) 2012 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
#import "SequencerExpandBtnCell.h"
#import "SequencerHandler.h"

@interface SequencerExpandBtnCell()

- (void) loadImages;

@end


@implementation SequencerExpandBtnCell

@synthesize isExpanded;
@synthesize canExpand;
@synthesize expandedImage;
@synthesize collapsedImage;
@synthesize node;

- (void) loadImages
{
    if ( !expandedImage && !collapsedImage ) {
        self.expandedImage = [NSImage imageNamed:@"seq-btn-expand"];
        [expandedImage setFlipped:YES];
    
        self.collapsedImage = [NSImage imageNamed:@"seq-btn-collapse"];
        [collapsedImage setFlipped:YES];
    }
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    [self loadImages];
    return self;
}

- (id) initImageCell:(NSImage *)image
{
    self = [super initImageCell:image];
    [self loadImages];
    return self;
}

- (id) initTextCell:(NSString *)aString
{
    self = [super initTextCell:aString];
    [self loadImages];
    return self;
}

- (id) init
{
    self = [super init];
    [self loadImages];
    return self;
}

- (BOOL) trackMouse:(NSEvent *)theEvent
             inRect:(NSRect)cellFrame
             ofView:(NSView *)controlView
       untilMouseUp:(BOOL)untilMouseUp
{
    //NSPoint tempCoords = [controlView convertPoint: [theEvent locationInWindow] fromView: [[controlView window] contentView]];
    
    /*
    NSPoint mouseCoords = NSMakePoint(tempCoords.x - cellFrame.origin.x,
                                      tempCoords.y  - cellFrame.origin.y);
     */
    
    // Deal with the click however you need to here, for example in a slider cell you can use the mouse x
    // coordinate to set the floatValue.
    
    // Dragging won't work unless you still make the call to the super class...
    return [super trackMouse: theEvent inRect: cellFrame ofView:
            controlView untilMouseUp: untilMouseUp];
}

- (void) drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    if (!imagesLoaded)
    {
        imgRowBgChannel = [NSImage imageNamed:@"seq-row-channel-bg.png"];
        imagesLoaded = YES;
    }
    
    if (!node )
    {
        NSRect rowRect = NSMakeRect(cellFrame.origin.x, cellFrame.origin.y + cellFrame.size.height - kCCBSeqDefaultRowHeight, cellFrame.size.width, kCCBSeqDefaultRowHeight);
        [imgRowBgChannel drawInRect:rowRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
    }
    
    if (canExpand)
    {
        int smallOffset = node ? 0 : 1; //A small offset for sound rows.
        
        if (isExpanded)
        {
            [collapsedImage drawAtPoint:cellFrame.origin fromRect:NSMakeRect(0, 0 + smallOffset, 16, 16) operation:NSCompositeSourceOver fraction:1];
        }
        else
        {
            [expandedImage drawAtPoint:cellFrame.origin fromRect:NSMakeRect(0, 0 + smallOffset, 16, 16) operation:NSCompositeSourceOver fraction:1];
        }
    }
    else
    {
    
    }
}

- (id)copyWithZone:(NSZone *)zone
{
    SequencerExpandBtnCell *copy = [super copyWithZone:zone];
    copy->collapsedImage = nil;
    copy->expandedImage = nil;
    copy.collapsedImage = [self.collapsedImage copyWithZone:zone];
    copy.expandedImage = [self.expandedImage copyWithZone:zone];
    
    return copy;
}


@end

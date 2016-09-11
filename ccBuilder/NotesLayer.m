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

#import "NotesLayer.h"
#import "StickyNote.h"
#import "CCBGlobals.h"
#import "AppDelegate.h"
#import "CCBTransparentView.h"
#import "CCBTransparentWindow.h"
#import "CCBUtil.h"
#import "MainWindow.h"

@implementation NotesLayer

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    notesVisible = YES;
    
    return self;
}

- (void) addNote
{
    [[AppDelegate appDelegate] saveUndoStateWillChangeProperty:@"*notes"];
    StickyNote* note = [[StickyNote alloc] init];
    note.docPos = ccp(10,150);
    [self addChild:note];
}

- (void) editNote:(StickyNote*)note
{
    AppDelegate* ad = [AppDelegate appDelegate];
    
    CGFloat viewScale = ad.derivedViewScaleFactor;
    
    // Setup text area and add it to guiLayer
    CGSize size = note.contentSize;
    CGPoint pos = ccp(note.position.x * viewScale, note.position.y * viewScale - note.contentSize.height);
    
	// FIXME: fix deprecation warning
    SUPPRESS_DEPRECATED([NSBundle loadNibNamed:@"StickyNoteEditView" owner:self]);
    [editView setFrameOrigin:NSPointFromCGPoint(pos)];
    [editView setFrameSize:NSSizeFromCGSize(size)];
    [ad.guiView addSubview:editView];
    
    [textView setFont:[NSFont fontWithName:@"MarkerFelt-Thin" size:14]];
    [textView setDelegate:self];
    NSString* str = [note noteText];
    if (!str) str = @"";
    [textView setString:str];
    
    // Fix for the close buttons background
    [[closeButton cell] setHighlightsBy:NSContentsCellMask];
    
    // Show the gui window and make it key
    [ad.guiWindow setIsVisible:YES];
    [ad.guiWindow makeKeyWindow];
    [ad.guiWindow makeFirstResponder:textView];
    
    note.labelVisible = NO;
}

- (IBAction)clickedClose:(id)sender
{
    // Remove the sticky note
    [self removeChild:modifiedNote cleanup:YES];
    
    // End the editing session
    AppDelegate* ad = [AppDelegate appDelegate];
    [ad.window makeKeyWindow];
    
    modifiedNote = NULL;
}

- (void)textDidChange:(NSNotification *)notification
{
    [[AppDelegate appDelegate] saveUndoStateWillChangeProperty:@"*notes"];
    
    [modifiedNote setNoteText:[textView string]];
}

- (BOOL) mouseDown:(CGPoint)pt event:(NSEvent*)event
{
    modifiedNote = NULL;
    
    if (!self.visible) return NO;
    if (event.modifierFlags & NSCommandKeyMask) return NO;
    
    // Check if the click hits a note
    int hit = kCCBStickyNoteHitNone;
    StickyNote* note = NULL;
    
    NSArray* notes = [self children];
    for (int i = [notes count]-1; i >= 0; i--)
    {
        note = [notes objectAtIndex:i];
        
        hit = [note hitAreaFromPt:pt];
        if (hit != kCCBStickyNoteHitNone) break;
    }
    
    if (hit == kCCBStickyNoteHitNote)
    {
        noteStartPos = note.docPos;
        mouseDownPos = pt;
        operation = kCCBNoteOperationDragging;
        modifiedNote = note;
        
        // Reorder the child to the top
        [self removeChild:note cleanup:NO];
        [self addChild:note];
        
        return YES;
    }
    else if (hit == kCCBStickyNoteHitResize)
    {
        noteStartSize = note.contentSize;
        mouseDownPos = pt;
        operation = kCCBNoteOperationResizing;
        modifiedNote = note;
        return YES;
    }
    return NO;
}

- (BOOL) mouseDragged:(CGPoint)pt event:(NSEvent*)event
{
    if (operation == kCCBNoteOperationDragging)
    {
        [[AppDelegate appDelegate] saveUndoStateWillChangeProperty:@"*notes"];
        
        CGPoint delta = ccpSub(pt, mouseDownPos);
        
        modifiedNote.docPos = ccpRound(ccpAdd(noteStartPos, delta));
        return YES;
    }
    else if (operation == kCCBNoteOperationResizing)
    {
        AppDelegate *ad = [AppDelegate appDelegate];

        [ad saveUndoStateWillChangeProperty:@"*notes"];
        
        CGPoint delta = ccpSub(pt, mouseDownPos);
        delta = ccpMult(delta, ad.derivedViewScaleFactor);
        CGSize newSize;
        newSize.width = noteStartSize.width + delta.x;
        newSize.height = noteStartSize.height - delta.y;
        
        if (newSize.width < 60) newSize.width = 60;
        if (newSize.height < 60) newSize.height = 60;
        
        newSize.width = roundf(newSize.width);
        newSize.height = roundf(newSize.height);
        
        modifiedNote.contentSize = newSize;
        return YES;
    }
    
    return NO;
}

- (BOOL) mouseUp:(CGPoint)pt event:(NSEvent*)event
{
    if (operation == kCCBNoteOperationDragging
        && event.clickCount == 2
        && [modifiedNote hitAreaFromPt:pt] == kCCBNoteOperationDragging)
    {
        [self editNote:modifiedNote];
        return YES;
    }
    
    operation = kCCBNoteOperationNone;
    //modifiedNote = NULL;
    
    return NO;
}

- (void) updateWithSize:(CGSize)ws stageOrigin:(CGPoint)so zoom:(float)zm
{
    if (!self.visible) return;
    
    if (CGSizeEqualToSize(ws, winSize)
        && CGPointEqualToPoint(so, stageOrigin)
        && zm == zoom)
    {
        return;
    }
    
    // Store values
    winSize = ws;
    stageOrigin = so;
    zoom = zm;
    
    [super setVisible: (zoom == 1 && notesVisible)];
    
    
    NSArray* notes = [self children];
    for (int i = 0; i < [notes count]; i++)
    {
        StickyNote* note = [notes objectAtIndex:i];
        [note updatePos];
    }
}

- (BOOL) visible
{
    return notesVisible;
}

- (void) setVisible:(BOOL)visible
{
    notesVisible = visible;
    [super setVisible:(zoom == 1 && notesVisible)];
}

- (void) showAllNotesLabels
{
    modifiedNote = NULL;
    
    NSArray* notes = [self children];
    for (int i = 0; i < [notes count]; i++)
    {
        StickyNote* note = [notes objectAtIndex:i];
        note.labelVisible = YES;
    }
}

- (void) removeAllNotes
{
    [self removeAllChildrenWithCleanup:YES];
}

- (void) loadSerializedNotes:(id)ser
{
    [self removeAllChildrenWithCleanup:YES];
    
    for (NSDictionary* serNote in ser)
    {
        StickyNote* note = [[StickyNote alloc] init];
        
        // Load text
        note.noteText = [serNote objectForKey:@"text"];
        
        // Load position
        CGPoint pos = ccp([[serNote objectForKey:@"xPos"] floatValue],[[serNote objectForKey:@"yPos"] floatValue]);
        note.docPos = pos;
        
        // Load size
        note.contentSize = CGSizeMake([[serNote objectForKey:@"width"] floatValue], [[serNote objectForKey:@"height"] floatValue]);
        
        [self addChild:note];
    }
}

- (id) serializeNotes
{
    NSMutableArray* ser = [NSMutableArray array];
    
    NSArray* notes = [self children];
    for (int i = 0; i < [notes count]; i++)
    {
        StickyNote* note = [notes objectAtIndex:i];
        
        NSMutableDictionary* serNote = [NSMutableDictionary dictionary];
        if (note.noteText)
        {
            [serNote setObject:note.noteText forKey:@"text"];
        }
        [serNote setObject:[NSNumber numberWithFloat: note.contentSize.width] forKey:@"width"];
        [serNote setObject:[NSNumber numberWithFloat: note.contentSize.height] forKey:@"height"];
        [serNote setObject:[NSNumber numberWithFloat: note.docPos.x] forKey:@"xPos"];
        [serNote setObject:[NSNumber numberWithFloat: note.docPos.y] forKey:@"yPos"];
        
        [ser addObject:serNote];
    }
    
    return ser;
}

@end

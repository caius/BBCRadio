//
//  WindowController.m
//  BBCRadio
//
//  Created by Caius Durling on 07/05/2009.
//  Copyright 2009 Hentan Software. All rights reserved.
//

#import "WindowController.h"

#define TITLE_STOP  @"Stop"
#define TITLE_START @"Start"

#define VIEW_MENU_TAG 140
#define SIMPLE_TAG 150
#define DETAIL_TAG 155

#define VIEW_BORDER 20.0
#define TITLEBAR_HEIGHT 22.0

@interface WindowController (Private)

- (NSSize) minimumWindowSize;
- (NSSize) detailViewDefaultSize;
- (NSRect) NSRectWithOriginFrom:(NSWindow*)window andSize:(NSSize)size;
- (void) setMenuItems;
- (void) disableMenuItems;
- (BOOL) isSimpleView;
- (NSMenu*) viewMenu;
- (NSSize)windowWillResize:(NSWindow *) window toSize:(NSSize)newSize;
- (BOOL)windowShouldZoom:(NSWindow *)window toFrame:(NSRect)newFrame;
- (void) resizeWebkitViewWithWindowSize:(NSSize)winSize;

@end

@implementation WindowController

- (id) init
{
  self = [super init];
  return self;
}

- (void) awakeFromNib
{
  // Disable history in the webkit view - It'd
  // be a waste of memory for no good reason.
  [webview setMaintainsBackForwardList:NO];
  
  // Gotta do this to be able to (en|dis)able menu items
  [[self viewMenu] setAutoenablesItems:NO];
  // Make sure they are set properly
  [self setMenuItems];
  
  // Show or hide hide the window's resizing controls:
  [[[self window] standardWindowButton:NSWindowZoomButton] setHidden:[self isSimpleView]];
  [[self window] setShowsResizeIndicator:![self isSimpleView]];
  
  // Set the window's minimum size
  [[self window] setMinSize:[self detailViewDefaultSize]];
}

- (IBAction) toggleButtonClicked:(id)sender
{
  NSLog(@"Button is currently: %@", [toggleButton title]);
  
  if ([[toggleButton title] caseInsensitiveCompare:TITLE_START] == NSOrderedSame) {
    // Need to start it all playing
    [toggleButton setTitle:TITLE_STOP];
    
    // Figure out the URL to load
    NSString * stationTitle = [[stations selectedCell] title];
    stationTitle = [stationTitle lowercaseString];
    stationTitle = [stationTitle stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    
    NSLog(@"Station: %@", stationTitle);
    
    // Set the URL of the webview
    NSString * urlToLoad = [NSString stringWithFormat:@"http://www.bbc.co.uk/iplayer/playlive/bbc_%@/", stationTitle];
    NSLog(@"URL: %@", urlToLoad);
    [webview setMainFrameURL:urlToLoad];

  } else {
    // Stop it all playing
    [toggleButton setTitle:TITLE_START];
    
    [webview stopLoading:self];
    [webview setMainFrameURL:@"about:blank"];
  }
}

- (IBAction) showDetailView: (id)sender
{
  [self disableMenuItems];
  
  // Resize the window
  NSRect newSize = [self NSRectWithOriginFrom:[self window] andSize:[self detailViewDefaultSize]];
  [[self window] setFrame:newSize display:YES animate:YES];

  // Show the resize corner
  [[self window] setShowsResizeIndicator:YES];
  
  // Enable the right menu items
  [self setMenuItems];
}

- (IBAction) showBasicView: (id)sender
{
  [self disableMenuItems];
  
  // Resize the window
  NSRect newSize = [self NSRectWithOriginFrom:[self window] andSize:[self minimumWindowSize]];
  [[self window] setFrame:newSize display:YES animate:YES];
  
  // Hide the resize corner
  [[self window] setShowsResizeIndicator:NO];
  
  // Enable the right menu items
  [self setMenuItems];
}

@end

@implementation WindowController (Private)

- (NSSize) minimumWindowSize
{
  NSNumber *minWidth = [NSNumber numberWithFloat:([stations frame].size.width + 40)];
  NSNumber *minHeight = [NSNumber numberWithFloat:([stations frame].size.height + 90)];
  
  NSSize size = NSMakeSize([minWidth floatValue], [minHeight floatValue]);
  return size;
}

- (NSSize) detailViewDefaultSize
{
  NSSize minWidth = [self minimumWindowSize];
  
  int defWidth = 555;
  int defHeight = 300;
  
  NSNumber *width = [NSNumber numberWithInt:(defWidth > minWidth.width ? defWidth : minWidth.width)];
  NSNumber *height = [NSNumber numberWithInt:(defHeight > minWidth.height ? defHeight : minWidth.height)];
    
  NSSize detailSize = NSMakeSize([width floatValue], [height floatValue]);
  
  return detailSize;
}

- (NSRect) NSRectWithOriginFrom:(NSWindow*)window andSize:(NSSize)size
{
  return NSMakeRect([window frame].origin.x, [window frame].origin.y, size.width, size.height);
}

// En/Dis-ables the menu items as appropriate for current window size.
- (void) setMenuItems
{
  if ([self isSimpleView]) {
    // Its the simple view
    [[[self viewMenu] itemWithTag:DETAIL_TAG] setEnabled:YES];
    [[[self viewMenu] itemWithTag:SIMPLE_TAG] setEnabled:NO];
  } else {
    // Its the detail view
    [[[self viewMenu] itemWithTag:DETAIL_TAG] setEnabled:NO];
    [[[self viewMenu] itemWithTag:SIMPLE_TAG] setEnabled:YES];
  }
}

- (void) disableMenuItems
{
  [[[self viewMenu] itemWithTag:DETAIL_TAG] setEnabled:NO];
  [[[self viewMenu] itemWithTag:SIMPLE_TAG] setEnabled:NO];
}

- (BOOL) isSimpleView
{
  // Comparing NSSize == NSSize complains about binary comparison.
  return ([self minimumWindowSize].width == [[self window] frame].size.width &&
      [self minimumWindowSize].height == [[self window] frame].size.height);
}

- (NSMenu*) viewMenu
{
  return [[[NSApp mainMenu] itemWithTag:VIEW_MENU_TAG] submenu];
}

- (NSSize)windowWillResize:(NSWindow *) window toSize:(NSSize)newSize
{
  if ([[self window] showsResizeIndicator]) {
    [self resizeWebkitViewWithWindowSize:newSize];
    return newSize; //resize happens
  } else
    return [[self window] frame].size; //no change
}

- (BOOL)windowShouldZoom:(NSWindow *)window toFrame:(NSRect)newFrame
{
  //let the zoom happen iff showsResizeIndicator is YES
  return [[self window] showsResizeIndicator];
}

- (void) resizeWebkitViewWithWindowSize:(NSSize)winSize
{
  // Work out new y and height
  // 1. Figure out new height.
  NSNumber *newHeight = [NSNumber numberWithFloat:(winSize.height - (VIEW_BORDER*2) - TITLEBAR_HEIGHT)];
  // 2. Calc difference between old height & new height
  NSNumber *heightDiff = [NSNumber numberWithFloat:([newHeight floatValue] - [webview frame].size.height)];
  // 3. Subtract difference in 2 from y
  NSNumber *newY = [NSNumber numberWithFloat:([webview frame].origin.y - [heightDiff floatValue])];
  
  // Work out new x and width
  // 1. Figure out new width
  NSNumber *newWidth = [NSNumber numberWithFloat:((winSize.width - [webview frame].origin.x)-VIEW_BORDER)];
  // 2. Figure out new x
  NSNumber *newX = [NSNumber numberWithFloat:[webview frame].origin.x];

  // Set new size for webview
  NSRect newFrame = NSMakeRect([newX floatValue], [newY floatValue], [newWidth floatValue], [newHeight floatValue]);
  [webview setFrame:newFrame];
}

@end

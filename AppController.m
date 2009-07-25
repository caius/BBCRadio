//
//  WindowController.m
//  BBCRadio
//
//  Created by Caius Durling on 07/05/2009.
//  Copyright 2009 Hentan Software. All rights reserved.
//

#import "AppController.h"

#define TITLE_STOP  @"Stop"
#define TITLE_START @"Start"

#define VIEW_MENU_TAG 140
#define SIMPLE_TAG 150
#define DETAIL_TAG 155

#define VIEW_BORDER 20.0
#define TITLEBAR_HEIGHT 22.0

#define DETAIL_WIDTH 830
#define DETAIL_HEIGHT 493

#define MIN_WEBKIT_WIDTH 300.0
#define MIN_WEBKIT_HEIGHT 300.0

@interface AppController ()

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

@implementation AppController

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
  [self showBasicView:nil];
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
  [self windowWillResize:[self window] toSize:newSize.size];
  [[self window] setFrame:newSize display:YES animate:YES];
  
  // Reposition the viewport
  [webview stringByEvaluatingJavaScriptFromString:@"window.scrollTo(163, 148);"];
  [webview stringByEvaluatingJavaScriptFromString:@"var rules = 'body { overflow: hidden; }';\n"
   "var ref = document.createElement('style');\n"
   "ref.setAttribute('rel', 'stylesheet');\n"
   "ref.setAttribute('type', 'text/css');\n"
   "document.getElementsByTagName('head')[0].appendChild(ref);\n"
   "ref.appendChild(document.createTextNode(rules));"];
  
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
    
  NSNumber *width = [NSNumber numberWithInt:(DETAIL_WIDTH > minWidth.width ? DETAIL_WIDTH : minWidth.width)];
  NSNumber *height = [NSNumber numberWithInt:(DETAIL_HEIGHT > minWidth.height ? DETAIL_HEIGHT : minWidth.height)];
    
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
  if (newSize.width >= [self detailViewDefaultSize].width && newSize.height >= [self detailViewDefaultSize].height)
    [self resizeWebkitViewWithWindowSize:newSize];
  
  if ([[self window] showsResizeIndicator])
    return newSize; //resize happens
  else
    return [[self window] frame].size; //no change
}

- (BOOL)windowShouldZoom:(NSWindow *)window toFrame:(NSRect)newFrame
{
  //let the zoom happen if showsResizeIndicator is YES
  return [[self window] showsResizeIndicator];
}

- (void) resizeWebkitViewWithWindowSize:(NSSize)winSize
{
  NSLog(@"%s", _cmd);
  NSRect newFrame;

  NSLog(@"Frame: %@", NSStringFromRect([webview frame]));
  NSLog(@"Bounds: %@", NSStringFromRect([webview bounds]));
  
  // Work out new y and height
  // 1. Figure out new height.
  float newHeight = (winSize.height - (VIEW_BORDER*2) - TITLEBAR_HEIGHT);
  newFrame.size.height = (newHeight > MIN_WEBKIT_HEIGHT ? newHeight : MIN_WEBKIT_HEIGHT);
  // 2. Calc difference between old height & new height
  NSNumber *heightDiff = [NSNumber numberWithFloat:(newFrame.size.height - [webview frame].size.height)];
  // 3. Subtract difference in 2 from y
  newFrame.origin.y = ([webview frame].origin.y - [heightDiff floatValue]);
  
  // Work out new x and width
  // 1. Figure out new width
  float newWidth = ((winSize.width - [webview frame].origin.x)-VIEW_BORDER);
  newFrame.size.width = (newWidth > MIN_WEBKIT_WIDTH ? newWidth : MIN_WEBKIT_WIDTH);
  // 2. Figure out new x
  newFrame.origin.x = [webview frame].origin.x;

  // Set new size for webview
  [webview setFrame:newFrame];
  [webview setNeedsDisplay:YES];
}

@end

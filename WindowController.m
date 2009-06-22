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

@interface WindowController (Private)

- (NSSize) minimumWindowSize;
- (NSSize) detailViewDefaultSize;
- (NSRect) NSRectWithOriginFrom:(NSWindow*)window andSize:(NSSize)size;
- (void) toggleMenuItems;
- (BOOL) isSimpleView;
- (NSMenu*) viewMenu;

@end

@implementation WindowController

- (id) init
{
  self = [super init];
  return self;
}

- (void) awakeFromNib
{
  [webview setMaintainsBackForwardList:NO];
  
  [[self viewMenu] setAutoenablesItems:NO];
  [self toggleMenuItems];
  
  NSLog(@"Main Menu: %@", [NSApp mainMenu]);
  NSLog(@"View Menu: %@", [self viewMenu]);
  NSLog(@"Simple Item: %@", [[self viewMenu] itemWithTag:SIMPLE_TAG]);
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
  NSRect newSize = [self NSRectWithOriginFrom:[self window] andSize:[self detailViewDefaultSize]];
  [[self window] setFrame:newSize display:YES animate:YES];
  
  [self toggleMenuItems];
}

- (IBAction) showBasicView: (id)sender
{
  
  NSRect newSize = [self NSRectWithOriginFrom:[self window] andSize:[self minimumWindowSize]];
  [[self window] setFrame:newSize display:YES animate:YES];
  
  [self toggleMenuItems];
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
  NSSize winSize = [self minimumWindowSize];
  NSSize webSize = [webview frame].size;
  NSNumber *width = [NSNumber numberWithInt:(winSize.width + webSize.width + 80)];
  NSNumber *height = [NSNumber numberWithInt:(winSize.height + webSize.height + 80)];
  
  NSSize detailSize = NSMakeSize([height floatValue], [width floatValue]);
  
  return detailSize;
}

- (NSRect) NSRectWithOriginFrom:(NSWindow*)window andSize:(NSSize)size
{
  return NSMakeRect([window frame].origin.x, [window frame].origin.y, size.width, size.height);
}

- (void) toggleMenuItems
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

@end

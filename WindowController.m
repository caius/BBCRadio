//
//  WindowController.m
//  BBCRadio
//
//  Created by Caius Durling on 07/05/2009.
//  Copyright 2009 Hentan Software. All rights reserved.
//

#import "WindowController.h"

#define TITLE_STOP @"Stop"
#define TITLE_START @"Start"

@implementation WindowController

- (void) awakeFromNib
{
  [webview setMaintainsBackForwardList:NO];
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
    stationTitle = [stationTitle stringByReplacingOccurrencesOfString:@"radio_" withString:@""];
    
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

@end

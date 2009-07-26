//
//  WindowController.h
//  BBCRadio
//
//  Created by Caius Durling on 07/05/2009.
//  Copyright 2009 Hentan Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface AppController : NSWindowController {
  IBOutlet NSButton * toggleButton;
  IBOutlet NSMatrix * stations;

  IBOutlet WebView * webview;
    
  BOOL resizable; // Starts in simple view
}

- (IBAction) toggleButtonClicked: (id)sender;
- (IBAction) radioChanged: (id)sender;
- (IBAction) showDetailView: (id)sender;
- (IBAction) showBasicView: (id)sender;

@end

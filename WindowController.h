//
//  WindowController.h
//  BBCRadio
//
//  Created by Caius Durling on 07/05/2009.
//  Copyright 2009 Hentan Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface WindowController : NSWindowController {
  IBOutlet NSButton * toggleButton;
  IBOutlet NSMatrix * stations;
  
  IBOutlet WebView * webview;
}

- (IBAction) toggleButtonClicked:(id)sender;

@end

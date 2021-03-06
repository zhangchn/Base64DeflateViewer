//
//  RVMAppDelegate.h
//  Base64 GZip Viewer
//
//  Created by zhang chen on 1/6/14.
//  Copyright (c) 2014 Raiing Medical Company. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RVMAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (unsafe_unretained) IBOutlet NSTextView *base64View;
@property (unsafe_unretained) IBOutlet NSTextView *plainView;
@property (weak) IBOutlet NSTextField *statusLabel;
- (IBAction)decode:(id)sender;
- (IBAction)encode:(id)sender;
@end

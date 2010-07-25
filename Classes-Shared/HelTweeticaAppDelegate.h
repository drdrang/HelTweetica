//
//  HelTweeticaAppDelegate.h
//  HelTweetica
//
//  Created by Lucius Kwok on 3/30/10.

/*
 Copyright (c) 2010, Felt Tip Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:  
 1.  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 2.  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 3.  Neither the name of the copyright holder(s) nor the names of any contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "Twitter.h"

#ifdef TARGET_PROJECT_MAC

#import <Cocoa/Cocoa.h>
@class TwitterAccount, PreferencesController;

@interface HelTweeticaAppDelegate : NSObject {
	Twitter *twitter;
	int networkActionCount;
	NSMutableSet *windowControllers;
	PreferencesController *preferences;
}

@property (nonatomic, retain) Twitter *twitter;
@property (nonatomic, retain) NSMutableSet *windowControllers;

// Windows
- (IBAction)newMainWindow:(id)sender;
- (void)newMainWindowWithAccount:(TwitterAccount*)account;
- (IBAction)showPreferences:(id)sender;
- (void)addWindowController:(id)controller;

// Networking
- (void)incrementNetworkActionCount;
- (void)decrementNetworkActionCount;


@end

#else

#import <UIKit/UIKit.h>

@interface HelTweeticaAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow *window;
	UINavigationController *navigationController;
	Twitter *twitter;
	int networkActionCount;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) Twitter *twitter;

- (void) incrementNetworkActionCount;
- (void) decrementNetworkActionCount;

@end

#endif

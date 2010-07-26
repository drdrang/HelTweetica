//
//  ConversationWindowController.m
//  HelTweetica
//
//  Created by Lucius Kwok on 5/24/10.

/*
 Copyright (c) 2010, Felt Tip Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:  
 1.  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 2.  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 3.  Neither the name of the copyright holder(s) nor the names of any contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "ConversationWindowController.h"
#import "ConversationHTMLController.h"

#import "HelTweeticaAppDelegate.h"


@implementation ConversationWindowController
@synthesize messageIdentifier;

- (id)init {
	self = [super initWithWindowNibName:@"ConversationWindow"];
	if (self) {
		appDelegate = [NSApp delegate];
		
		// Timeline HTML Controller generates the HTML from a timeline
		ConversationHTMLController *controller = [[[ConversationHTMLController alloc] initWithMessageIdentifier:nil] autorelease];
		controller.twitter = appDelegate.twitter;
		self.htmlController = controller;
		controller.delegate = self;
	}
	return self;
}

- (void)dealloc {
	[messageIdentifier release];
	[super dealloc];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	NSString *account = [aDecoder decodeObjectForKey:@"accountScreenName"];
	
	self = [self init];
	if (self) {
		[self setAccountWithScreenName: account];
		self.messageIdentifier = [aDecoder decodeObjectForKey:@"messageIdentifier"];
		[self.window setFrameAutosaveName: [aDecoder decodeObjectForKey:@"windowFrameAutosaveName"]];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:htmlController.account.screenName forKey:@"accountScreenName"];
	[aCoder encodeObject:messageIdentifier forKey:@"messageIdentifier"];
	[aCoder encodeObject:[self.window frameAutosaveName ] forKey:@"windowFrameAutosaveName"];
}

- (void)loadConversation {
	ConversationHTMLController *controller = (ConversationHTMLController *)htmlController;
	controller.selectedMessageIdentifier = messageIdentifier;
	[controller loadMessage:messageIdentifier];
}

- (void)windowDidLoad {
	[self loadConversation];
	htmlController.webView = self.webView;
	[htmlController loadWebView];
}	

- (void) showConversationWithMessageIdentifier:(NSNumber*)identifier {
	// Select the tapped message
	ConversationHTMLController *controller= (ConversationHTMLController *)htmlController;
	self.messageIdentifier = identifier;
	controller.selectedMessageIdentifier = identifier;
	[controller rewriteTweetArea];
}

@end

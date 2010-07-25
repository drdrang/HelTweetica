//
//  TwitterSearchAction.m
//  HelTweetica
//
//  Created by Lucius Kwok on 5/1/10.
/*
 Copyright (c) 2010, Felt Tip Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:  
 1.  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 2.  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 3.  Neither the name of the copyright holder(s) nor the names of any contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "TwitterSearchAction.h"
#import "TwitterMessage.h"
#import "TwitterSearchJSONParser.h"


@implementation TwitterSearchAction
@synthesize query;


- (id)initWithQuery:(NSString *)aQuery count:(NSNumber*)count {
	self = [super init];
	if (self) {
		self.query = aQuery;
		
		NSMutableDictionary *theParameters = [NSMutableDictionary dictionary];
		[theParameters setObject:aQuery forKey:@"q"];
		if (count) 
			[theParameters setObject:count forKey:@"rpp"]; // Results per page.
		
		self.parameters = theParameters;
		
		// self.method is nil because search uses a completely different API from the rest of Twitter.
	}
	return self;
}

- (void) dealloc {
	[query release];
	[super dealloc];
}

// Search uses a completely different URL from the other Twitter methods.
- (void) start {
	NSString *base = @"http://search.twitter.com/search.json"; 
	NSURL *url = [TwitterAction URLWithBase:base query:parameters];
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
	[request setHTTPMethod:@"GET"];
	[request setValue:@"HelTweetica/1.0" forHTTPHeaderField:@"User-Agent"];
	[self startURLRequest:request];
}

- (void) parseReceivedData:(NSData*)data {
	if (statusCode < 400) {
		TwitterSearchJSONParser *parser = [[[TwitterSearchJSONParser alloc] init] autorelease];
		parser.receivedTimestamp = [NSDate date];
		[parser parseJSONData:data];
		newMessageCount = parser.messages.count;
		[self mergeTimelineWithMessages: parser.messages];
	} else {
		newMessageCount = 0;
	}
}


@end

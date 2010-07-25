//
//  TwitterFavoriteAction.m
//  HelTweetica
//
//  Created by Lucius Kwok on 4/25/10.
/*
 Copyright (c) 2010, Felt Tip Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:  
 1.  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 2.  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 3.  Neither the name of the copyright holder(s) nor the names of any contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "TwitterFavoriteAction.h"


@implementation TwitterFavoriteAction
@synthesize message;


- (id) initWithMessage:(TwitterMessage*)aMessage destroy:(BOOL)flag {
	if (self = [super init]) {
		self.message = aMessage;
		destroy = flag;
		self.twitterMethod = [NSString stringWithFormat:@"favorites/%@/%@",  destroy? @"destroy" : @"create", message.identifier];
	}
	return self;
}

- (void) dealloc {
	[message release];
	[super dealloc];
}
	
- (void) start {
	[self startPostRequest];
}

- (void) parseReceivedData:(NSData*)data {
	// Ignore data and just set the message's favorite flag if the status is good or is 403, which indicates that the message is already set to the status we want.
	if ((statusCode < 400) || (statusCode == 403)) {
		message.favorite = !destroy;
	}
}


@end

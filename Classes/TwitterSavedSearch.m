//
//  TwitterSavedSearch.m
//  HelTweetica
//
//  Created by Lucius Kwok on 5/5/10.
//  Copyright 2010 Felt Tip Inc. All rights reserved.
//

#import "TwitterSavedSearch.h"


@implementation TwitterSavedSearch
@synthesize query, identifier, receivedDate;

- (id)init {
	self = [super init];
	if (self) {
		self.receivedDate = [NSDate date];
	}
	return self;
}

- (void)dealloc {
	[query release];
	[identifier release];
	[receivedDate release];
	[super dealloc];
}



@end
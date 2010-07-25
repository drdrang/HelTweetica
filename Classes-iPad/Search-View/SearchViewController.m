//
//  SearchViewController.m
//  HelTweetica
//
//  Created by Lucius Kwok on 4/11/10.

/*
 Copyright (c) 2010, Felt Tip Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:  
 1.  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 2.  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 3.  Neither the name of the copyright holder(s) nor the names of any contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


#import "SearchViewController.h"
#import "TwitterAccount.h"
#import "TwitterSavedSearch.h"
#import "TwitterLoadSavedSearchesAction.h"
#import "TwitterSavedSearchAction.h"



@implementation SearchViewController
@synthesize statusMessage, delegate;

- (void) setContentSize {
	// Set the content size
	if ([UIViewController instancesRespondToSelector:@selector(setContentSizeForViewInPopover:)]) {
		
		int count = account.savedSearches.count;
		if (count < 3) count = 3;
		[self setContentSizeForViewInPopover: CGSizeMake(320, 44 * count + 66)];
	}
}

#pragma mark -
#pragma mark Memory management

- (id)initWithAccount:(TwitterAccount*)anAccount {
	if (self = [super initWithNibName:@"Search" bundle:nil]) {
		account = [anAccount retain];
		
		[self setContentSize];

		// Check how fresh the saved searches cache is.
		BOOL shouldReload = YES;
		if (account.savedSearches.count > 0) {
			TwitterSavedSearch *savedSearch = [account.savedSearches lastObject];
			if (savedSearch.receivedDate && [savedSearch.receivedDate timeIntervalSinceNow] > -60)
				shouldReload = NO;
		}
		
		if (shouldReload) {
			// Request a fresh list of list subscriptions.
			loading = YES;
			self.statusMessage = NSLocalizedString (@"Loading...", @"status message");
			
			// Load Saved Searches from Twitter
			TwitterLoadSavedSearchesAction *action = [[[TwitterLoadSavedSearchesAction alloc] init] autorelease];
			action.completionTarget= self;
			action.completionAction = @selector(didLoadSavedSearches:);
			action.delegate = self;
			action.consumerToken = account.xAuthToken;
			action.consumerSecret = account.xAuthSecret;
			
			// Start the URL connection
			[action start];
		}
	}
	return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
 }

- (void)viewDidUnload {
}

- (void)dealloc {
	[account release];
	[statusMessage release];
    [super dealloc];
}

#pragma mark TwitterAction

- (void)didLoadSavedSearches:(TwitterLoadSavedSearchesAction *)action {
	account.savedSearches = action.savedSearches;
	loading = NO;
	[self setContentSize];
	[self.tableView reloadData];
	
	// Set the default status message for an empty list of saved searches
	self.statusMessage = NSLocalizedString (@"No saved searches.", @"");
}

- (void) twitterActionDidFinishLoading:(TwitterAction*)action {
	// Do nothing. didLoadSavedSearches: will be called.
}

- (void) twitterAction:(TwitterAction*)action didFailWithError:(NSError*)error {
	loading = NO;
	self.statusMessage = [error localizedDescription];
	[self setContentSize];
	[self.tableView reloadData];
}

#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	// Set table header view
	CGRect frame = self.view.bounds;
	frame.size.height = 44;
	UISearchBar *searchBar = [[[UISearchBar alloc] initWithFrame:frame] autorelease];
	searchBar.delegate = self;
	//searchBar.tintColor = [UIColor blackColor];
	searchBar.placeholder = NSLocalizedString (@"Twitter", @"search bar placeholder");
	self.tableView.tableHeaderView = searchBar;

	// Title
	self.navigationItem.title = NSLocalizedString (@"Search", @"Nav bar");
	
	// Display an Edit button in the navigation bar for this view controller.
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	// Set the keyboard focus on the search bar
	[searchBar becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	int count = account.savedSearches.count;
	if (count == 0) count = 1;
	return count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return NSLocalizedString (@"Saved Searches", @"");
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SavedSearchCell"];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SavedSearchCell"] autorelease];
		cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
	}

	TwitterSavedSearch *savedSearch;
	if (indexPath.row < account.savedSearches.count) {
		savedSearch = [account.savedSearches objectAtIndex: indexPath.row];
		cell.textLabel.text = savedSearch.query;
		cell.textLabel.textColor = [UIColor blackColor];
	} else if (indexPath.row == 0) {
		cell.textLabel.text = self.statusMessage;
		cell.textLabel.textColor = [UIColor grayColor];
	}
	
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		// Delete saved search from server
		TwitterSavedSearch *savedSearch = [account.savedSearches objectAtIndex: indexPath.row];
		TwitterSavedSearchAction *action = [[[TwitterSavedSearchAction alloc] initWithDestroyIdentifier:savedSearch.identifier] autorelease];
		action.delegate = self;
		action.consumerToken = account.xAuthToken;
		action.consumerSecret = account.xAuthSecret;
		[action start];
		
        // Delete the row from the data source
		[account.savedSearches removeObjectAtIndex: indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
		
    }   
}


#pragma mark Table view delegate

- (void) showAlertWithTitle:(NSString*)aTitle message:(NSString*)aMessage {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:aTitle message:aMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (void)searchFor:(NSString*)query {
	if ([query length] == 0) return;
	
	// Call delegate to tell it we're about to load a new timeline
	if ([delegate respondsToSelector:@selector(search:didRequestQuery:)]) {
		[delegate search:self didRequestQuery:query];
	}
}	

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// Only allow selection of rows in the array
	if (indexPath.row >= account.savedSearches.count) return nil;
	return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row < account.savedSearches.count) {
		TwitterSavedSearch *savedSearch = [account.savedSearches objectAtIndex: indexPath.row];
		[self searchFor:savedSearch.query];
	}
}

#pragma mark -
#pragma mark Search bar delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	NSString *query = searchBar.text;
	[self searchFor:query];
}

@end


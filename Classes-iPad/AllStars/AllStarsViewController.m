//
//  AllStarsViewController.m
//  HelTweetica
//
//  Created by Lucius Kwok on 4/17/10.

/*
 Copyright (c) 2010, Felt Tip Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:  
 1.  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 2.  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 3.  Neither the name of the copyright holder(s) nor the names of any contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


#import "AllStarsViewController.h"
#import "AllStarsLoadURLAction.h"
#import "AllStarsMessageViewController.h"
#import "SoundEffects.h"
#import "TwitterStatusUpdate.h"
#import "HelTweeticaAppDelegate.h"


const float kPreviewTopMargin = 24.0;
const float kPreviewLeftMargin = 13.0;
const float kPreviewCellSpacing = 6.0;
const float kPreviewCellSize = 120.0;
const float kPreviewImageInset = 8.0;
const float kShuffleTargetAdvanceInterval = 1.0;
const float kDurationMessageIsShown = 10.0;
const float kAvatarSize = 256.0f;

const int kMaximumNumberOfAvatarsToShow = 96;


@interface AllStarsViewController (PrivateMethods)
- (NSArray*)uniqueTimeline:(NSArray*)aTimeline;
- (void)loadProfileImages;
- (void) showTweetAtIndex: (int) index;
@end


@implementation AllStarsViewController
@synthesize timeline, scrollView, allButtons, messageView;


- (id)initWithTimeline:(NSArray*)aTimeline {
	if ((self = [super initWithNibName:@"AllStarsViewController" bundle:nil])) {
		appDelegate = [[UIApplication sharedApplication] delegate];

		previewImageSize = kPreviewCellSize;
		shuffleCounter = 0;
		shuffleIndex = 0;
		shuffleTarget = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scanner_frame.png"]];

		self.timeline = [self uniqueTimeline:aTimeline];

		profileImages = [[NSMutableDictionary alloc] initWithCapacity:kMaximumNumberOfAvatarsToShow];
		loadURLActions = [[NSMutableSet alloc] initWithCapacity:kMaximumNumberOfAvatarsToShow];
		[self loadProfileImages];
	}
	return self;
}

- (void)dealloc {
	[timeline release];
 	[scrollView release];
	[allButtons release];
	[shuffleTarget release];
	
	[profileImages release];
	[loadURLActions release];
	
	[messageView release];
	
	[super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark Timeline

- (BOOL) screenName:(NSString*)screenName existsInArray:(NSArray*)array {
	for (TwitterStatusUpdate *message in array) {
		if ([screenName isEqualToString: message.userScreenName])
			return YES;
	}
	return NO;
}

- (NSArray*)uniqueTimeline:(NSArray*)aTimeline {
	NSMutableArray *uniqueTimeline = [NSMutableArray array];
	
	// Load every large avatar
	TwitterStatusUpdate *originalMessage;
	for (TwitterStatusUpdate *message in aTimeline) {
		// Use original retweeted message if this is a retweet
		originalMessage = message;
		if ([message.retweetedStatusIdentifier longLongValue] > 10000) 
			originalMessage = [appDelegate.twitter statusUpdateWithIdentifier:message.retweetedStatusIdentifier];
		if ([self screenName:message.userScreenName existsInArray:uniqueTimeline] == NO) {
			[uniqueTimeline addObject:originalMessage];
			if (uniqueTimeline.count >= kMaximumNumberOfAvatarsToShow) break; // Limit the number of avatars shown.
		}
	}
	return uniqueTimeline;
}

#pragma mark Profile images

- (void)loadProfileImages {
	UIImage *image;
	for (TwitterStatusUpdate *message in self.timeline) {
		NSString *largeImageURLString = [message.profileImageURL stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
		image = [profileImages objectForKey:largeImageURLString];
		if (image == nil) {
			// Start an action to load the url.
			AllStarsLoadURLAction *action = [[[AllStarsLoadURLAction alloc] init] autorelease];
			action.delegate = self;
			action.identifier = message.profileImageURL;
			[action loadURL:[NSURL URLWithString:largeImageURLString]];
			
			[loadURLActions addObject:action];
			[appDelegate incrementNetworkActionCount];
		}
	}
}

- (UIImage*) resizeImage:(UIImage*)originalImage withSize:(CGSize)newSize {
	CGSize originalSize = originalImage.size;
	CGFloat originalAspectRatio = originalSize.width / originalSize.height;
	
	CGImageRef cgImage = nil;
	int bitmapWidth = newSize.width;
	int bitmapHeight = newSize.height;
	CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(nil, bitmapWidth, bitmapHeight, 8, bitmapWidth * 4, colorspace, kCGImageAlphaPremultipliedLast);
	if (context != nil) {
		// Black background
		CGRect rect = CGRectMake(0, 0, bitmapWidth, bitmapHeight);
		CGContextSetRGBFillColor (context, 0, 0, 0, 1);
		CGContextFillRect (context, rect);
		
		// Resize box to maintain aspect ratio
		if (originalAspectRatio < 1.0) {
			rect.origin.y += (rect.size.height - rect.size.width / originalAspectRatio) * 0.5;
			rect.size.height = rect.size.width / originalAspectRatio;
		} else {
			rect.origin.x += (rect.size.width - rect.size.height * originalAspectRatio) * 0.5;
			rect.size.width = rect.size.height * originalAspectRatio;
		}
		
		CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
		
		// Draw image
		CGContextDrawImage (context, rect, [originalImage CGImage]);
		
		// Get image
		cgImage = CGBitmapContextCreateImage (context);
		
		// Release context
		CGContextRelease(context);
	}
	CGColorSpaceRelease(colorspace);
	
	UIImage *result = [UIImage imageWithCGImage:cgImage];
	CGImageRelease (cgImage);
	return result;
}

- (void)loadURLAction:(AllStarsLoadURLAction*)action didLoadData:(NSData*)data {
	UIImage *avatarImage = [[[UIImage alloc] initWithData:data] autorelease];
	if (avatarImage != nil) {
		CGSize imageSize = avatarImage.size;
		if ((imageSize.width > kAvatarSize) || (imageSize.height > kAvatarSize)) {
			avatarImage = [self resizeImage:avatarImage withSize:CGSizeMake(kAvatarSize, kAvatarSize)];
		}
		
		// Save large avatar in dictionary.
		[profileImages setObject:avatarImage forKey:action.identifier];
		
		// Update message view if necessary.
		if ((messageView.message.profileImageURL != nil) && ([action.identifier isEqualToString:messageView.message.profileImageURL]))
			messageView.imageView.image = avatarImage;
		
		// Set a timer to collect multiple updates into one
		if (reloadImagesTimer == nil) {
			reloadImagesTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(reloadImagesTimer:) userInfo:nil repeats:NO];
		}
	}
	
	[loadURLActions removeObject:action];
	[appDelegate decrementNetworkActionCount];
}

- (void)loadURLAction:(AllStarsLoadURLAction*)action didFailWithError:(NSError*)error {
	// TODO: Replace avatar image with a placeholder to indicate network action got an error.
	[loadURLActions removeObject:action];
	[appDelegate decrementNetworkActionCount];
}

			
- (UIButton*) addNewButtonWithImage: (UIImage*) image; {
	UIButton *button = [UIButton buttonWithType: UIButtonTypeCustom];
	button.contentMode = UIViewContentModeScaleAspectFill;
	CGFloat imageWidth = previewImageSize-2*kPreviewImageInset;
	[button setImage:[self resizeImage:image withSize:CGSizeMake(imageWidth, imageWidth)] forState:UIControlStateNormal];	
	[button setBackgroundImage:[UIImage imageNamed:@"scanner_frame.png"] forState:UIControlStateHighlighted];
	
	[button addTarget:self action:@selector(showTweet:) forControlEvents:UIControlEventTouchUpInside];
	[scrollView insertSubview:button belowSubview:shuffleTarget];
	[self.allButtons addObject:button];
	return button;
}

- (void) reloadImages {
	NSAutoreleasePool *pool;
	
	// Remove buttons from scroll view
	for (UIButton *button in allButtons) {
		[button removeFromSuperview];
	}
	self.allButtons = [NSMutableArray array];
	
	// Add a UIButton for each image to the scroll view
	for (int index = 0; index < timeline.count; index++) {
		pool = [[NSAutoreleasePool alloc] init];
		TwitterStatusUpdate *message = [timeline objectAtIndex:index];
		UIImage *avatarImage = [profileImages objectForKey:message.profileImageURL];
		UIButton *button = [self addNewButtonWithImage: avatarImage];
		button.tag = index + 1;
		[pool release];
	}
	[self layoutScrollImages];
}

- (void) reloadImagesTimer:(NSTimer*)timer {
	[self reloadImages];
	reloadImagesTimer = nil;
}


#pragma mark -

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	[self reloadImages];
}

- (void) startDelayedShuffleModeAfterInterval:(NSTimeInterval)interval {
	[showRandomTweetTimer invalidate];
	showRandomTweetTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(startShuffleModeWithTimer:) userInfo:nil repeats:NO];
}

- (void) startShuffleModeWithTimer:(NSTimer*)timer {
	[self shuffleMode: nil];
}

-(IBAction)shuffleMode:(id) sender {
	shuffleCounter = 0;
	shuffleIndex = 0;
	[showRandomTweetTimer invalidate];
	showRandomTweetTimer = [NSTimer scheduledTimerWithTimeInterval:kShuffleTargetAdvanceInterval target:self selector:@selector(selectRandomTweet:) userInfo:nil repeats:YES];
	
	
	// Set the UIApplication instance's idleTimerDisabled to YES to disable sleep.
}

#pragma mark View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)viewDidUnload {
	[super viewDidUnload];
	self.scrollView = nil;
	self.allButtons = nil;
}

- (void) viewWillAppear: (BOOL) animated {
	[super viewWillAppear:animated];
	[self layoutScrollImages]; // Update layout in case a new image was added.
	self.messageView = nil;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)o duration:(NSTimeInterval)duration {
	[self layoutScrollImages];
}


#pragma mark -

- (IBAction) close: (id) sender {
	[reloadImagesTimer invalidate];
	reloadImagesTimer = nil;
	[showRandomTweetTimer invalidate];
	showRandomTweetTimer = nil;
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction) showTweet: (id) sender {
	if (showRandomTweetTimer != nil) {
		[showRandomTweetTimer invalidate];
		showRandomTweetTimer = nil;
	}
	
	[shuffleTarget removeFromSuperview];
	[self showTweetAtIndex: [sender tag] - 1];
}

- (void) showTweetAtIndex: (int) index {
	AllStarsMessageViewController *controller = [[[AllStarsMessageViewController alloc] init] autorelease];
	if ((index >= 0) && (index < self.timeline.count)) {
		// Replace ampersand-escaped letters with normal letters
		TwitterStatusUpdate *message = [self.timeline objectAtIndex:index];
		controller.message = message;
		
		// Set the large profile image.
		controller.profileImage = [profileImages objectForKey:message.profileImageURL];
	}
	[self presentModalViewController:controller animated:YES];
}


-(void)selectRandomTweet: (NSTimer*)timer {	
	if( self.allButtons.count != self.timeline.count ) return;
	if (self.timeline.count == 0) return;
	
	shuffleCounter++;
	
	if (shuffleCounter < 7) {
		shuffleIndex = (arc4random() % self.timeline.count);
		UIButton* button = [self.allButtons objectAtIndex:shuffleIndex];
		
		if (shuffleTarget.superview == nil) 
			[scrollView addSubview:shuffleTarget];
		
		// Animate changing the selection
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.50];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		[shuffleTarget setFrame:button.frame];
		[UIView commitAnimations];
		
		// Also scroll so that selected rect is visible
		[scrollView scrollRectToVisible:button.frame animated:YES];

		// Play sound effect for selecting
		[[SoundEffects sharedSoundEffects] playSelectMessageSound];
	}
	
	if( shuffleCounter > 7) {
		[[SoundEffects sharedSoundEffects] playShowMessageSound];
		[self showTweetAtIndex:shuffleIndex];
		
		[showRandomTweetTimer invalidate];
		showRandomTweetTimer = [NSTimer scheduledTimerWithTimeInterval:kDurationMessageIsShown target:self selector:@selector(dismissRandomTweet:) userInfo:nil repeats:NO];
	}
}

- (void) dismissRandomTweet: (NSTimer*) timer {
	if (self.modalViewController == nil) {
		showRandomTweetTimer = nil;
		return;
	}
	
	[self dismissModalViewControllerAnimated:YES]; // Close the message view
	shuffleCounter = 0;
	
	// Reschedule timer
	showRandomTweetTimer = [NSTimer scheduledTimerWithTimeInterval:kShuffleTargetAdvanceInterval target:self selector:@selector(selectRandomTweet:) userInfo:nil repeats:YES];
}	

#pragma mark -

- (void) layoutScrollImages {
	UIButton *button = nil;
	int numberOfRows = 0;
	const CGFloat xMargin = kPreviewLeftMargin;
	const CGFloat yMargin = kPreviewTopMargin;
	const CGFloat xStep = previewImageSize + kPreviewCellSpacing;
	const CGFloat xMax = scrollView.bounds.size.width;
	const CGFloat yStep = previewImageSize + kPreviewCellSpacing;
	CGRect imageFrame = CGRectMake(xMax, yMargin - yStep, previewImageSize, previewImageSize);
	int index;
	
	for (index=0; index<self.allButtons.count; index++) {
		button = [self.allButtons objectAtIndex:index];
		button.tag = index + 1;
		imageFrame.origin.x += xStep;
		if (imageFrame.origin.x + previewImageSize >= xMax) {
			imageFrame.origin.x = xMargin;
			imageFrame.origin.y += yStep;
			numberOfRows++;
		}
		// Set the frame of the UIImageView
		button.frame = imageFrame;
	}
	
	// set the content size so it can be scrollable
	[scrollView setContentSize:CGSizeMake(xMax, numberOfRows * yStep + yMargin)];
	
	// Move the shuffle target image
	
	if (shuffleTarget.superview != nil) {
		UIButton* button = [self.allButtons objectAtIndex:shuffleIndex];
		[shuffleTarget setFrame:button.frame];
	}
	
}


@end

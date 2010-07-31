//
//  AllStarsViewController.h
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


#import <UIKit/UIKit.h>
#import "LKLoadURLAction.h"

@class AllStarsMessageViewController;
@class HelTweeticaAppDelegate;


@interface AllStarsViewController : UIViewController <LKLoadURLActionDelegate> {
	NSArray *timeline;
	IBOutlet UIScrollView *scrollView;
	NSMutableArray *allButtons;
	UIImageView *shuffleTarget;
	
	NSMutableDictionary *profileImages;
	CGFloat previewImageSize;
	NSMutableSet *loadURLActions;
	
	NSTimer *reloadImagesTimer;
	NSTimer *showRandomTweetTimer;
	
	int shuffleCounter;
	int shuffleIndex;
	
	AllStarsMessageViewController *messageView;
	HelTweeticaAppDelegate *appDelegate;

}
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) NSMutableArray *allButtons;
@property (nonatomic, retain) NSArray *timeline;
@property (nonatomic, retain) AllStarsMessageViewController *messageView;

- (id)initWithTimeline:(NSArray*)aTimeline;

- (IBAction) close: (id) sender;
- (IBAction)shuffleMode: (id)sender; 

- (void) startDelayedShuffleModeAfterInterval:(NSTimeInterval)interval;
- (void) layoutScrollImages;

@end

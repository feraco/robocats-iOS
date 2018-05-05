/*
 *	Copyright 2013, David Book, buzztouch.com
 *
 *	All rights reserved.
 *
 *	Redistribution and use in source and binary forms, with or without modification, are 
 *	permitted provided that the following conditions are met:
 *
 *	Redistributions of source code must retain the above copyright notice which includes the
 *	name(s) of the copyright holders. It must also retain this list of conditions and the 
 *	following disclaimer. 
 *
 *	Redistributions in binary form must reproduce the above copyright notice, this list 
 *	of conditions and the following disclaimer in the documentation and/or other materials 
 *	provided with the distribution. 
 *
 *	Neither the name of David Book, or buzztouch.com nor the names of its contributors 
 *	may be used to endorse or promote products derived from this software without specific 
 *	prior written permission.
 *
 *	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 *	ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
 *	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
 *	IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
 *	INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT 
 *	NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
 *	PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
 *	WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
 *	ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY 
 *	OF SUCH DAMAGE. 
 */


#import <UIKit/UIKit.h>
#import "BT_item.h"
#import "robocats_appDelegate.h"
#import "BT_fileManager.h"
#import "BT_debugger.h"
#import "BT_strings.h"
#import "BT_viewUtilities.h"

#import "BT_audioPlayer.h"

@implementation BT_audioPlayer
@synthesize buttonStartStop, audioPlayer, volumeLowLabel, volumeHighLabel;
@synthesize audioFileName, audioFileURL, audioTimerLabel, audioIsPlaying;
@synthesize audioStartOnLoad, audioSlider, volumeSlider, currentVolume, audioFadeOutTimer;
@synthesize receivedData, remoteConn, audioStatusLabel, expectedDownloadSize;
@synthesize audioNumberOfLoops, screenData, audioPlaybackTimer, audioDurationLabel;


-(id)initWithScreenData:(BT_item *)theScreenData{
	if((self = [super init])){
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"INIT %@", @"(preparing it for possible background audio)"]];
 		
		//set screen
		[self setScreenData:theScreenData];
	
		//init default properties
		[self setAudioIsPlaying:FALSE];
		[self setAudioStartOnLoad:FALSE];
		[self setRemoteConn:nil];
		[self setRemoteConn:nil];
		[self setExpectedDownloadSize:0];
		[self setAudioFileName:@""];
		[self setAudioFileURL:@""];
		[self setAudioNumberOfLoops:0];
		[self setAudioPlaybackTimer:nil];
		[self setAudioSlider:nil];
		[self setCurrentVolume:0.5];
		
		//app delegate
		robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];	
			
		[self.view setFrame:[[UIScreen mainScreen] bounds]];
		[self.view setUserInteractionEnabled:TRUE];

		//mask entire screen
		UIView *mask = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
		[mask setBackgroundColor:[UIColor blackColor]];
		mask.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
		[mask setAlpha:.75];
		[self.view addSubview:mask];
		
		//find center, x for sub-views
		int center = ([appDelegate.rootDevice deviceWidth] / 2);
		int boxWidth = 260;
		int partsWidth = 200;
		int top = 150;
		if([appDelegate.rootDevice isIPad]){
			top = 250;
		}

		//box for controls
		UIView *box = [[UIView alloc] initWithFrame:CGRectMake(0, 0, boxWidth, 190)];
		box.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
		[box setCenter:CGPointMake(center, top)];
		[box setBackgroundColor:[UIColor blackColor]];
		box = [BT_viewUtilities applyBorder:box borderWidth:2 borderColor:[UIColor lightGrayColor]];
		box = [BT_viewUtilities applyRoundedCorners:box radius:10];
		
		//close button
		UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[closeButton setFrame:CGRectMake(-5, -5, 40, 40)];
		[closeButton setImage:[UIImage imageNamed:@"closeX.png"] forState:UIControlStateNormal];
		[closeButton addTarget:self action:@selector(hideAudioPlayer) forControlEvents:UIControlEventTouchUpInside];
		[box addSubview:closeButton];

		//status label
		audioStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, boxWidth, 20)];
		audioStatusLabel.font = [UIFont systemFontOfSize:15];
		audioStatusLabel.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
		audioStatusLabel.backgroundColor = [UIColor clearColor];
		audioStatusLabel.textColor = [UIColor whiteColor];
		audioStatusLabel.textAlignment = UITextAlignmentCenter;
		audioStatusLabel.text = NSLocalizedString(@"audioNotLoaded", "audio not loaded");
		[box addSubview:audioStatusLabel];

		//volume slider
		volumeSlider = [[UISlider alloc] initWithFrame:CGRectMake(30, 25, partsWidth, 35)];
		volumeSlider.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
		volumeSlider.backgroundColor = [UIColor clearColor];
		[volumeSlider setContinuous:TRUE];
		[volumeSlider setEnabled:FALSE];		
		[volumeSlider setMinimumValue:0.0];
		[volumeSlider setMaximumValue:1.0];
		[volumeSlider setValue:0.5];
		[volumeSlider addTarget:self action:@selector(volumeSliderChanged:) forControlEvents:UIControlEventValueChanged];
		[box addSubview:volumeSlider];

		//volume low label
		volumeLowLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 48, partsWidth / 2, 20)];
		volumeLowLabel.font = [UIFont systemFontOfSize:12];
		volumeLowLabel.backgroundColor = [UIColor clearColor];
		volumeLowLabel.textColor = [UIColor whiteColor];
		volumeLowLabel.textAlignment = UITextAlignmentLeft;
		volumeLowLabel.text = NSLocalizedString(@"audioLow", "low");
		[box addSubview:volumeLowLabel];

		//volume high label
		volumeHighLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, 48, partsWidth / 2, 20)];
		volumeHighLabel.font = [UIFont systemFontOfSize:12];
		volumeHighLabel.backgroundColor = [UIColor clearColor];
		volumeHighLabel.textColor = [UIColor whiteColor];
		volumeHighLabel.textAlignment = UITextAlignmentRight;
		volumeHighLabel.text = NSLocalizedString(@"audioHigh", "high");
		[box addSubview:volumeHighLabel];
		
		//timer label
		audioTimerLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 165, partsWidth / 2, 20)];
		audioTimerLabel.font = [UIFont systemFontOfSize:12];
		audioTimerLabel.backgroundColor = [UIColor clearColor];
		audioTimerLabel.textColor = [UIColor whiteColor];
		audioTimerLabel.textAlignment = UITextAlignmentLeft;
		audioTimerLabel.text = @"00:00";
		[box addSubview:audioTimerLabel];

		//duration label
		audioDurationLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, 165, partsWidth / 2, 20)];
		audioDurationLabel.font = [UIFont systemFontOfSize:12];
		audioDurationLabel.backgroundColor = [UIColor clearColor];
		audioDurationLabel.textColor = [UIColor whiteColor];
		audioDurationLabel.textAlignment = UITextAlignmentRight;
		audioDurationLabel.text = @"00:00";
		[box addSubview:audioDurationLabel];
		
		//start / stop view
		buttonStartStop = [UIButton buttonWithType:UIButtonTypeCustom];
		[buttonStartStop setFrame:CGRectMake(95, 65, 75, 75)];
		buttonStartStop.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
		[buttonStartStop setImage:[UIImage imageNamed:@"audioOff.png"] forState:UIControlStateNormal];
		[buttonStartStop addTarget:self action:@selector(toggleAudio) forControlEvents:UIControlEventTouchUpInside];
		[buttonStartStop setEnabled:FALSE];
		[box addSubview:buttonStartStop];
		
		//slider (allows dragging forward / back in audio)
		audioSlider = [[UISlider alloc] initWithFrame:CGRectMake(30, 140, partsWidth, 35)];
		audioSlider.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
		audioSlider.backgroundColor = [UIColor clearColor];
		[audioSlider setContinuous:FALSE];
		[audioSlider setEnabled:FALSE];		
   	 	[audioSlider addTarget:self action:@selector(audioSliderChanged:) forControlEvents:UIControlEventValueChanged];
		[box addSubview:audioSlider];
		
		//add box
		[self.view addSubview:box];

		
    }
    return self;
}


//turn on controls
-(void)turnOnControls{
	//[BT_debugger showIt:self message:[NSString stringWithFormat:@"turnOnControls%@", @""]];
	//unhide / enable parts
	[volumeSlider setEnabled:TRUE];
	[audioSlider setEnabled:TRUE];
	[buttonStartStop setEnabled:TRUE];

}

//turn off controls
-(void)turnOffControls{
	//[BT_debugger showIt:self message:[NSString stringWithFormat:@"turnOffControls%@", @""]];
	//hide / disable parts
	[volumeSlider setEnabled:FALSE];
	[audioSlider setEnabled:FALSE];
	[buttonStartStop setEnabled:FALSE];
}


//toggleAudio on / off
-(void)toggleAudio{
	//[BT_debugger showIt:self message:[NSString stringWithFormat:@"toggleAudio%@", @""]];
	//start / stop if loaded, else, load audio
	if(self.audioPlayer != nil){
		//play or stop?
		if(self.audioIsPlaying){
			[self stopAudio];
		}else{
			[self startAudio];
		}
	}else{

		//try to load the audio. We should only be here if the screen didn't load the "onLoad"
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        SEL sel3 = NSSelectorFromString(@"loadAudioForScreen");
        if([self respondsToSelector:sel3]){
            [self performSelector:sel3];
        }
        #pragma clang diagnostic pop

	}
	
}

//load audio
-(void)loadAudioForScreen:(BT_item *)theScreenData{	
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"loadAudioForScreen%@", [theScreenData itemId]]];
	
	//set the screen data
	[self setScreenData:theScreenData];
	
	//get values from passed in screen data. Grab the audio file name if a URL is being used
	self.audioFileName = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"audioFileName" defaultValue:@""];
	self.audioFileURL = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"audioFileURL" defaultValue:@""];
	if(self.audioFileName.length < 3 && self.audioFileURL.length > 3){
		self.audioFileName = [BT_strings getFileNameFromURL:self.audioFileURL];
	}
		
	self.audioNumberOfLoops = [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"audioNumberOfLoops" defaultValue:@""] intValue];
	self.audioStartOnLoad = TRUE;

	//did we have a file name?
	if([self.audioFileName length] > 3){

		//where is the file?
		NSString *tmpSoundFileURLInFileSystem = @"";
		if([self.audioFileName length] > 3){
		
			//bundle audio, cached audio, or url audio?
			if([BT_fileManager doesFileExistInBundle:self.audioFileName]){
				
				[BT_debugger showIt:self message:[NSString stringWithFormat:@"loading audio from Xcode bundle: %@", self.audioFileName]];
				tmpSoundFileURLInFileSystem = [BT_fileManager getBundlePath:self.audioFileName];
			
			}else{
			
				if([BT_fileManager doesLocalFileExist:self.audioFileName]){

					[BT_debugger showIt:self message:[NSString stringWithFormat:@"loading from cache: %@", self.audioFileName]];
					tmpSoundFileURLInFileSystem = [BT_fileManager getFilePath:self.audioFileName];

				}else{
				
					if([[self audioFileURL] length] > 3){
						[BT_debugger showIt:self message:[NSString stringWithFormat:@"loading audio from URL: %@", self.audioFileURL]];
						
						[self updateStatusLabel:[NSString stringWithFormat:NSLocalizedString(@"audioDownloading", "downloading audio..."), @""]];
						[self performSelectorOnMainThread:@selector(downloadAudioFile:) withObject:self.audioFileURL waitUntilDone:false];
						
					}
					
				}
			}
			
		}//audioFileName length

		//init a player, this is a bit slow but we need to do this to play the darn thing!
		//we will notn be here if the file comes from a URL and has not been cached already
		if(tmpSoundFileURLInFileSystem != nil){	
		
			//show file name in status..
			NSString *tmpStatus = NSLocalizedString(@"audioLoading", "loading audio...");
			[self performSelectorOnMainThread:@selector(updateStatusLabel:) withObject:tmpStatus waitUntilDone:false];

			//init the audio player 
			[self initAudioPlayerWithLocalURL:tmpSoundFileURLInFileSystem];

		}
	
	}//self.audioFileName length	

}

//sets status label. Helper method, sometimes called from another thread
-(void)updateStatusLabel:(NSString *)theString{
	[self.audioStatusLabel setText:theString];
}

//sets timer label. Helper method, sometimes called from another thread
-(void)updateTimerLabel:(NSString *)theString{
	[self.audioTimerLabel setText:theString];
}

//init's audio player from URL (local file)
-(void)initAudioPlayerWithLocalURL:(NSString *)theURLinFileSystem{
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"initAudioPlayerWithLocalURL%@", theURLinFileSystem]];

	//this may take a moment..spawn a new thread

	//prevent UI blocking..
    @autoreleasepool {

        NSURL *localFileURL = [NSURL fileURLWithPath:theURLinFileSystem];;

        //method called after delay from loadAudioForScreen so we can update interface				
        NSError *error = nil;
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:localFileURL error:&error];
        [self.audioPlayer setNumberOfLoops:[self audioNumberOfLoops]];
        [self.audioPlayer prepareToPlay];
        [self.audioPlayer setDelegate:self];
        [self.audioPlayer setVolume:0.5];
        
        
        if(error != nil){
            [BT_debugger showIt:self message:[NSString stringWithFormat:@"Error! Description: %@ Reason: %@", 
                    [error localizedDescription], 
                    [error localizedFailureReason] 
                    
                    ]];
            [self updateStatusLabel:NSLocalizedString(@"audioLoadingError", "error loading audio?")];
            
            //because we had an error, delete possible corruped cached data
            //[BT_fileManager deleteFile:[self audioFileName]];
            
        }else{
        
            [self setAudioIsPlaying:TRUE];
            [self turnOnControls];
            [self startAudio];
            
        }
	
	}
	
}



//start audio
-(void)startAudio{
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"startAudio%@", @""]];
	//must have audio player
	if(self.audioPlayer != nil){
	
		//update the image
		[buttonStartStop setImage:[UIImage imageNamed:@"audioOn.png"] forState:UIControlStateNormal];

		//show volume
		[self.volumeSlider setHidden:FALSE];

		//show slider
		[self.audioSlider setHidden:FALSE];
		[self.audioSlider setMaximumValue:[audioPlayer duration]];
		
		//start the timer to update gui
		[self performSelectorOnMainThread:@selector(startAudioTimer) withObject:nil waitUntilDone:false];
		
		//start audio
   		[self.audioPlayer prepareToPlay];
		[self.audioPlayer play];
		
		//flag as playing
		[self setAudioIsPlaying:TRUE];
		
	}
}
		
//start timer
-(void)startAudioTimer{
	//kill possible previous audio timer
	if(self.audioPlaybackTimer != nil){
		[self.audioPlaybackTimer invalidate];
		self.audioPlaybackTimer = nil;
	}
	
	//start timer to update elapased time
	self.audioPlaybackTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self 
				selector:@selector(updateAudioTimer:) userInfo:nil repeats:YES];
	
}

//stop timer
-(void)stopAudioTimer{
	//kill possible previous audio timer
	if(self.audioPlaybackTimer != nil){
		[self.audioPlaybackTimer invalidate];
		self.audioPlaybackTimer = nil;
	}		
}		
	
//stop audio
-(void)stopAudio{
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"stopAudio%@", @""]];
	//must have audio player
	if(self.audioPlayer != nil){
	
		//update the image
		[buttonStartStop setImage:[UIImage imageNamed:@"audioOff.png"] forState:UIControlStateNormal];

		//stop audio
		[self.audioPlayer stop];
		
		//flag as playing
		[self setAudioIsPlaying:FALSE];
		
		//kill audio timer
		if(self.audioPlaybackTimer != nil){
			[self.audioPlaybackTimer invalidate];
			self.audioPlaybackTimer = nil;
		}
		
		//show stopped..
		[self updateStatusLabel:NSLocalizedString(@"audioStopped", "audio stopped")];
		
	}	
}

//audio slider changed...
-(void)audioSliderChanged:(UISlider *)sender{
	//[BT_debugger showIt:self message:[NSString stringWithFormat:@"audioSliderChanged%@", @""]];
	[self.audioPlayer stop];
	[self.audioPlayer setCurrentTime:[self.audioSlider value]];
    [self.audioPlayer prepareToPlay];
    [self.audioPlayer play];
	
	int elapsedSeconds = self.audioPlayer.currentTime;
	NSString *strElapsed = [BT_strings formatTimeFromSeconds:[NSString stringWithFormat:@"%d", elapsedSeconds]];	
	[self updateTimerLabel:strElapsed];
	
	//audioPlayerDidFinishPlaying gets called if slider all the way to the end...
	if([self.audioSlider value] >= [self.audioPlayer duration]){
		[self stopAudio];
	}else{
		[self startAudio];
	}
	
}

//volum slider changed...
-(void)volumeSliderChanged:(UISlider *)sender{
	//[BT_debugger showIt:self message:[NSString stringWithFormat:@"volumeSliderChanged%@", @""]];
	//adjust volume
	if(self.audioPlayer != nil){
		[self.audioPlayer setVolume:[self.volumeSlider value]];
	}
	
}


//updates audio timer during playback
-(void)updateAudioTimer:(NSTimer*)timer {
	//[BT_debugger showIt:self message:[NSString stringWithFormat:@"updateAudioTimer%@", @""]];
	int elapsedSeconds = self.audioPlayer.currentTime;
	NSString *strElapsed = [BT_strings formatTimeFromSeconds:[NSString stringWithFormat:@"%d", elapsedSeconds]];	
	
	//update timer label
	[self updateTimerLabel:strElapsed];

	//set duration label
	int durationSeconds = self.audioPlayer.duration;
	NSString *strDuration = [BT_strings formatTimeFromSeconds:[NSString stringWithFormat:@"%d", durationSeconds]];	
	[self.audioDurationLabel setText:strDuration];

	//update slider bar
	[self.audioSlider setHidden:FALSE];
	[self.audioSlider setValue:[self.audioPlayer currentTime]];

	//update status label
	[self updateStatusLabel:NSLocalizedString(@"audioPlaying", "audio playing")];
	[self setAudioIsPlaying:TRUE];

	
}



//hides view
-(void)hideAudioPlayer{
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"hideAudioPlayer%@", @""]];
	//app delegate
	robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];	
	[appDelegate hideAudioControls];
	
}

//audio finished playing
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"audioPlayerDidFinishPlaying%@", @""]];
	
	//flag by calling stop
	[self stopAudio];
	
}

//audio interuption started
-(void)audioPlayerBeginInterruption:(AVAudioPlayer *)player{
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"audioPlayerBeginInterruption%@", @""]];
	
	//flag as not-playing
	[self setAudioIsPlaying:FALSE];
	
}

//donwload audio
-(void)downloadAudioFile:(NSString *)theURL{
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"downloadAudioFile: %@", theURL]];

	//prevent UI blocking..
    @autoreleasepool {
        
		///merge possible variables in URL
		NSString *useURL = [BT_strings mergeBTVariablesInString:theURL];
		NSString *escapedURL = [useURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

		//kill possible previous download..
		if(self.remoteConn != nil){
			self.remoteConn = nil;
		}

		//init the download request
		NSMutableURLRequest  *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:escapedURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];	
		[theRequest setHTTPMethod:@"GET"];  
		self.remoteConn = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
		if(self.remoteConn){
			self.receivedData = [[NSMutableData data] init];
		}	
	
	}

}

/////////////////////////////////////////////////////////////
//connection delegate methods

//received response
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"didReceiveResponse: %@", @""]];
	
	[receivedData setLength:0];	
		
	//save the size of the download
	[self setExpectedDownloadSize:(int)[response expectedContentLength]];
	
	//check the status code
    SEL selector = NSSelectorFromString(@"statusCode");
    if ([response respondsToSelector:selector]){
		int statusCode = (int)[((NSHTTPURLResponse *)response) statusCode];
		if (statusCode >= 400){
			
			[remoteConn cancel];  // stop connecting; no more delegate messages
			
			//show message on label
			[self updateStatusLabel:NSLocalizedString(@"audioLoadingError", "error loading audio?")];
			[self turnOffControls];
			
		}
	}
	
}

//receive data
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	//[BT_debugger showIt:self message:[NSString stringWithFormat:@"didReceiveData: %@", @""]];
	
	if(data != nil){
	
		//append data
		[receivedData appendData:data];
		
		//show percentage dowloaded in status label
		float theVal = 0;
		if([self expectedDownloadSize] > 0 && [receivedData length] > 0){
			theVal = ([receivedData length] *100) / [self expectedDownloadSize];
			NSString *formatted = [NSString stringWithFormat:@"%g%%", theVal];
			[self updateStatusLabel:formatted];
		}
	}
	
}

//connection failure
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"didFailWithError: %@", @""]];
	
	//show message on label
	[self updateStatusLabel:NSLocalizedString(@"audioLoadingError", "error loading audio?")];
	
}

//done dowloading
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"connectionDidFinishLoading: %@", @""]];
	
	//save downloaded data to file..
	[BT_fileManager saveDataToFile:receivedData fileName:[self audioFileName]];
	
	//init player with the URL to the cached data...
	NSString *tmpSoundFileURLInFileSystem = [BT_fileManager getFilePath:self.audioFileName];
	[self initAudioPlayerWithLocalURL:tmpSoundFileURLInFileSystem];
	
}




@end








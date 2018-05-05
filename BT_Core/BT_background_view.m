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

#import "BT_background_view.h"

@implementation BT_background_view
@synthesize theScreen, JSONdata, backgroundImageView, backgroundImage, bgColorView, bgGradientView;
@synthesize imageName, imageURL, colorOpacity, imageOpacity;

//initWithFrame...
-(id)initWithFrame:(CGRect)aRect{
    self = [super initWithFrame:aRect];
    [BT_debugger showIt:self message:@"INIT"];
    
    //sub-view for background color...
    bgColorView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    bgColorView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [self addSubview:bgColorView];
    
    //sub-view for background gradient...
    bgGradientView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    bgGradientView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    UIView *gradView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [gradView setTag:33];
    gradView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [self.bgGradientView addSubview:gradView];
    [self addSubview:bgGradientView];
    
    //sub-view for background image image...
    backgroundImageView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    backgroundImageView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [self addSubview:self.backgroundImageView];
    
    //return...
    return self;
}


//updateProperties...
-(void)updateProperties:(BT_item *)theScreenData{
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"updateProperties (color and image) for screen with itemId: %@:", [theScreenData itemId]]];
    
	//appDelegate 
	robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];	

	//////////////////////////////////////////////////////////////
	// 1) update the solid color
	
	//solid background properties..
    NSString *defaultBgColor = @"#FFFFFF";
	UIColor *solidBgColor = [BT_color getColorFromHexString:[BT_strings getStyleValueForScreen:theScreenData nameOfProperty:@"backgroundColor" defaultValue:defaultBgColor]];
	NSString *solidBgOpacity = [BT_strings getStyleValueForScreen:theScreenData nameOfProperty:@"backgroundColorOpacity" defaultValue:@"100"];
	if([solidBgOpacity isEqualToString:@"100"]) solidBgOpacity = @"99";
	solidBgOpacity = [NSString stringWithFormat:@".%@", solidBgOpacity];
	
	//sub-view for background color
	[self setColorOpacity:[solidBgOpacity doubleValue]];
	[bgColorView setAlpha:[self colorOpacity]];
	[bgColorView setBackgroundColor:solidBgColor];
	
	//////////////////////////////////////////////////////////////
	// 2) update the gradient view
			
	UIColor *gradBgColorTop = [BT_color getColorFromHexString:[BT_strings getStyleValueForScreen:theScreenData nameOfProperty:@"backgroundColorGradientTop" defaultValue:@""]];
	UIColor *gradBgColorBottom = [BT_color getColorFromHexString:[BT_strings getStyleValueForScreen:theScreenData nameOfProperty:@"backgroundColorGradientBottom" defaultValue:@""]];
			
	//if our gradient view has subViews, we already applied a gradient..remove it..
	for(UIView* subView in [self.bgGradientView subviews]){
		if([subView tag] == 33){
			[subView removeFromSuperview];
		}			
	}
	
	//gradients will NOT automatically scale so we need to make it larger than the screen.
	UIView *gradView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	gradView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	[gradView setTag:33];
		
	//apply gradient to gradView color
	if([[BT_strings getStyleValueForScreen:theScreenData nameOfProperty:@"backgroundColorGradientTop" defaultValue:@""] length] > 3 && [[BT_strings getStyleValueForScreen:theScreenData nameOfProperty:@"backgroundColorGradientBottom" defaultValue:@""] length] > 3){
		gradView = [BT_viewUtilities applyGradient:gradView colorTop:gradBgColorTop colorBottom:gradBgColorBottom];
	}else{
		[gradView  setBackgroundColor:[UIColor clearColor]];
	}
	[self.bgGradientView addSubview:gradView];

	//////////////////////////////////////////////////////////////
	// 3) update the image
	
	//set the image's opacity
	NSString *imageBgOpacity = [BT_strings getStyleValueForScreen:theScreenData nameOfProperty:@"backgroundImageOpacity" defaultValue:@"100"];
	if([imageBgOpacity isEqualToString:@"100"]) imageBgOpacity = @"99";
	imageBgOpacity = [NSString stringWithFormat:@".%@", imageBgOpacity];
	[self.backgroundImageView setAlpha:[imageBgOpacity doubleValue]];
		
	NSString *backgroundImageScale = [BT_strings getStyleValueForScreen:theScreenData nameOfProperty:@"backgroundImageScale" defaultValue:@"center"];
		
	//set the content mode for the image...
	if([backgroundImageScale isEqualToString:@"center"]) [backgroundImageView setContentMode:UIViewContentModeCenter];
	if([backgroundImageScale isEqualToString:@"fullScreen"]) [backgroundImageView setContentMode:UIViewContentModeScaleToFill];
	if([backgroundImageScale isEqualToString:@"fullScreenPreserve"]) [backgroundImageView setContentMode:UIViewContentModeScaleAspectFit];
	if([backgroundImageScale isEqualToString:@"top"]) [backgroundImageView setContentMode:UIViewContentModeTop];
	if([backgroundImageScale isEqualToString:@"bottom"]) [backgroundImageView setContentMode:UIViewContentModeBottom];
	if([backgroundImageScale isEqualToString:@"topLeft"]) [backgroundImageView setContentMode:UIViewContentModeTopLeft];
	if([backgroundImageScale isEqualToString:@"topRight"]) [backgroundImageView setContentMode:UIViewContentModeTopRight];
	if([backgroundImageScale isEqualToString:@"bottomLeft"]) [backgroundImageView setContentMode:UIViewContentModeBottomLeft];
	if([backgroundImageScale isEqualToString:@"bottomRight"]) [backgroundImageView setContentMode:UIViewContentModeBottomRight];
	
		
	//////////////////////////////////////////////////////////////
	// 4) find / load a possible image
	
	//image name, URL
	self.imageName = [BT_strings getStyleValueForScreen:theScreenData nameOfProperty:@"backgroundImageNameSmallDevice" defaultValue:@""];
	self.imageURL = [BT_strings getStyleValueForScreen:theScreenData nameOfProperty:@"backgroundImageURLSmallDevice" defaultValue:@""];
	if([appDelegate.rootDevice isIPad]){
		self.imageName = [BT_strings getStyleValueForScreen:theScreenData nameOfProperty:@"backgroundImageNameLargeDevice" defaultValue:@""];
		self.imageURL = [BT_strings getStyleValueForScreen:theScreenData nameOfProperty:@"backgroundImageURLLargeDevice" defaultValue:@""];
	}
	//if we have an imageURL, and no imageName, figure out a name to use...
	if(self.imageName.length < 3 && self.imageURL.length > 3){
		self.imageName = [BT_strings getFileNameFromURL:self.imageURL];
	}
    
    //if both are blank... this is necessary so 'previous screen background' does not show on 'back button' if previous
    //screen did not have a background image set.
    if([self.imageName length] < 1 && [self.imageURL length] < 1){
        [self setImageName:@"blank.png"];
    }   
	

	/* 
		Where is the background image?
		a) File exists in bundle. Use this image, ignore possible download URL
		b) File DOES NOT exist in bundle, but does exist in writeable data directory: Use it. (it was already downloaded and saved)
		c) File DOES NOT exist in bundle, and DOES NOT exist in writeable data directory and an imageURL is set: Download it, save it for next time, use it.
	*/
	
	//get the image
	if([self.imageName length] > 1){
		
		
		if([BT_fileManager doesFileExistInBundle:imageName]){
			
			[BT_debugger showIt:self message:[NSString stringWithFormat:@"\"%@\" exists in Xcode bundle - not downloading.", imageName]];
			self.backgroundImage = [UIImage imageNamed:self.imageName];
			[self setImage:self.backgroundImage];
			
		}else{
		
			if([BT_fileManager doesLocalFileExist:imageName]){

				[BT_debugger showIt:self message:[NSString stringWithFormat:@"\"%@\" exists in cache, not downloading", [self imageName]]];
				self.backgroundImage = [BT_fileManager getImageFromFile:imageName];
				[self setImage:self.backgroundImage];

			}else{
			
				if([self.imageURL length] > 3 && [self.imageName length] > 3){
			
					[BT_debugger showIt:self message:[NSString stringWithFormat:@"Image does not exist in cache, starting downloader...%@", @""]];
					[self performSelector:@selector(downloadImage) withObject:nil afterDelay:.5];
				
				}else{
				
					[BT_debugger showIt:self message:[NSString stringWithFormat:@"Image for background view does not exist in xcode project, or in cache and no URL provided, not downloading: %@", [self imageName]]];

				}
				
			}
			
		}
		
	}//imageName


}


//downloadImage 
-(void)downloadImage{

	//only do this if we have an image URL
	if([self.imageURL length] > 3 && [self.imageName length] > 3){

		[BT_debugger showIt:self message:[NSString stringWithFormat:@"downloadImage from: %@", self.imageURL]];

		//start download
		BT_downloader *tmpDownloader = [[BT_downloader alloc] init];
		[tmpDownloader setUrlString:imageURL];
		[tmpDownloader setSaveAsFileName:imageName];
		[tmpDownloader setSaveAsFileType:@"image"];
		[tmpDownloader setDelegate:self];
		[tmpDownloader downloadFile];
		
	
	}
}

//set image
-(void)setImage:(UIImage *)theImage{
	[BT_debugger showIt:self message:@"setImage"];
	
	if(theImage != nil){
		[self.backgroundImageView setImage:theImage];
	}
	
}


//////////////////////////////////////////////////////////////
//downloader delegate methods
-(void)downloadFileStarted:(NSString *)message{
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"downloadFileStarted: %@", message]];
}
-(void)downloadFileInProgress:(NSString *)message{
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"downloadFileInProgress: %@", message]];
}
-(void)downloadFileCompleted:(NSString *)message{
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"downloadFileCompleted: %@", message]];
	
	//set image we just downloaded and saved.
	if([BT_fileManager doesLocalFileExist:imageName]){
		self.backgroundImage = [BT_fileManager getImageFromFile:imageName];
		[self setImage:self.backgroundImage];
	}else{
		self.backgroundImage = [UIImage imageNamed:@"blank.png"];
		[self setImage:self.backgroundImage];
	}

	
}
//////////////////////////////////////////////////////////////


@end







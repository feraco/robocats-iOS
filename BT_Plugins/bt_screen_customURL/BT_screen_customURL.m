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
#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "JSON.h"
#import "BT_strings.h"
#import "robocats_appDelegate.h"
#import "BT_fileManager.h"
#import "BT_color.h"
#import "BT_viewUtilities.h"
#import "BT_item.h"
#import "BT_debugger.h"
#import "BT_screen_customURL.h"

@implementation BT_screen_customURL
@synthesize dataURL, webView, externalURL, didInit;
@synthesize browserToolBar;

//viewDidLoad
-(void)viewDidLoad{
	[BT_debugger showIt:self theMessage:@"viewDidLoad"];
	[super viewDidLoad];
    
	//init screen properties
	[self setBrowserToolBar:nil];
	self.externalURL = @"";
	self.didInit = 0;
	
    //get the dataURL to load. Remember it in externalURL so we can open native browser to current url...
	self.dataURL = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"dataURL" defaultValue:@""];
	[self setExternalURL:dataURL];
	
 	//appDelegate
	robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];	
    
	//the height of the webView depends on whether or not we are showing a bottom tool bar. 
	int browserHeight = self.view.bounds.size.height;
	int browserWidth = self.view.bounds.size.width;
	int browserTop = UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? 0 : 0;
	if(![appDelegate.rootDevice isIPad]){
		browserTop = UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? 0 : 10;
	}
	if([[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"navBarStyle" defaultValue:@""] isEqualToString:@"hidden"]){
		browserTop = 0;
	}
	
	//get the bottom toolbar (utility may return nil depending on this screens data)
	browserToolBar = [BT_viewUtilities getWebToolBarForScreen:self theScreenData:[self screenData]];
	if(browserToolBar != nil){
		browserToolBar.tag = 49;
		browserHeight = (browserHeight - 44);
	}
    
    
	//webView
	self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, browserTop, browserWidth, browserHeight)]; 
	self.webView.delegate = self;
	self.webView.scalesPageToFit = YES;
	[self.webView setOpaque:NO];
	self.webView.backgroundColor = [UIColor clearColor];
	self.webView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);	
	//data detector types...
	if([[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"dataDetectorType" defaultValue:@"1"] isEqualToString:@"0"]){
		self.webView.dataDetectorTypes = UIDataDetectorTypeNone;
	}else{
		self.webView.dataDetectorTypes = UIDataDetectorTypeAll;
	}
	if([[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"preventUserInteraction" defaultValue:@""] isEqualToString:@"1"]){
		[self.webView setUserInteractionEnabled:FALSE];
	}
	
	[self.view addSubview:webView];
	
	/*
     //fix up web-view..
     In iOS 3.1 < UIScrollView repors as UIScroller (not sure this changed?). UIScrollView has different methods.
     */
	for(UIView* subView in [self.webView subviews]){
		
		//ios sometimes put's images behind web-views (like shadows)... hide these
		if([subView isKindOfClass:[UIImageView class]]){
			[subView setHidden:YES];
		}
		
		//ios sometimes puts images behind web-view sub-views (like shadows behind UIScrollViews)..hide these
		for(UIView* shadowView in [subView subviews]){
			if([shadowView isKindOfClass:[UIImageView class]]){
				[shadowView setHidden:YES];
			}
		}		
		
		//UIScrollView *tmp = (UIScrollView *)subView;
		
		//enable, disable scrolls to top (disables status bar tap-to-top property)
		if([subView respondsToSelector:@selector(setScrollsToTop:)]){
			//[tmp setScrollsToTop:scrollsToTop];
		}		
		
		//hide vertical scroll bar
		if([[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"hideVerticalScrollBar" defaultValue:@""] isEqualToString:@"1"]){
			if([subView respondsToSelector:@selector(setShowsVerticalScrollIndicator:)]){
				[(UIScrollView *)subView setShowsVerticalScrollIndicator:FALSE];
			}
		}
		
		//hide horizontal scroll bar
		if([[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"hideHorizontalScrollBar" defaultValue:@""] isEqualToString:@"1"]){
			if([subView respondsToSelector:@selector(setShowsHorizontalScrollIndicator:)]){
				[(UIScrollView *)subView setShowsHorizontalScrollIndicator:FALSE];
			}		
		}
		
		//scroll bounce..
		if([[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"preventScrollBounce" defaultValue:@""] isEqualToString:@"1"]){
			if([subView respondsToSelector:@selector(setBounces:)]){
				[(UIScrollView *)subView setBounces:FALSE];
			}	
		}
		
		//prevent scrolling in iOS 3.1 < 
		if([[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"preventAllScrolling" defaultValue:@""] isEqualToString:@"1"]){
			if([subView respondsToSelector:@selector(setScrollEnabled:)]){
				[(UIScrollView *)subView setScrollEnabled:FALSE];
			}	
		}
		
		//prevent scrolling in iOS 3.1 > 
		if([[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"preventAllScrolling" defaultValue:@""] isEqualToString:@"1"]){
			if([[[self.webView subviews] lastObject] respondsToSelector:@selector(setScrollEnabled:)]){
				[[[self.webView subviews] lastObject] setScrollEnabled:NO];
			}	
		}
        
        
	}//for each sub-view in UIWebView
    
    
	//add the toolbar if we have one (utility may return nil depending on this screens data)
	if(browserToolBar != nil){
		[self.view addSubview:browserToolBar];
		
        //if we don't have a dataURL, disable possible launch in Safari button
		if([self.dataURL length] < 3){
			for(UIBarButtonItem *button in [browserToolBar items]){
				//launch in safari app = 103 (see BT_viewUtilties.m > getWebToolBarForScreen)
				if([button tag] == 103){ 
					button.enabled = FALSE;
				}
			}
		}
        
	}
    
	//create adView?
	if([[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"includeAds" defaultValue:@"0"] isEqualToString:@"1"]){
	   	[self createAdBannerView];
	}		
    
    
}


//resets layout
-(void)layoutScreen{
    
	//appDelegate
	robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];	
    
	//the height of the webView depends on whether or not we are showing a bottom tool bar. 
	int browserHeight = self.view.bounds.size.height;
	int browserWidth = self.view.bounds.size.width;
	int browserTop = UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? 0 : 0;
	if(![appDelegate.rootDevice isIPad]){
		browserTop = UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? 0 : 10;
	}
	if([[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"navBarStyle" defaultValue:@""] isEqualToString:@"hidden"]){
		browserTop = 0;
	}
	//get the bottom toolbar (utility may return nil depending on this screens data)
	if(browserToolBar != nil){
		browserHeight = (browserHeight - 44);
	}
	
	//webView
	[self.webView setFrame:CGRectMake(0, browserTop, browserWidth, browserHeight)]; 
    
}

//view will appear
-(void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	[BT_debugger showIt:self theMessage:@"viewWillAppear"];
	
	//load url
	if(didInit == 0){
		didInit = 1;
		[self initLoad];
	}
	
	//show adView?
	if([[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"includeAds" defaultValue:@"0"] isEqualToString:@"1"]){
	    [self showHideAdView];
	}	
    
    
}

//initializes load
-(void)initLoad{
	[BT_debugger showIt:self theMessage:@"initLoad"];
    
    
	//We need a dataURL or a localFileName (or both)
	NSString *useURL = @"";
    
	if([self.dataURL length] > 3){
        
		//merge possible variables in URL
		useURL = [BT_strings mergeBTVariablesInString:self.dataURL];
        
 	}
	
 	//escape bogus characters in URL
	NSString *escapedUrl = [useURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	[self setExternalURL:escapedUrl];
	
	if([escapedUrl length] > 3){
		[self showProgress];
		[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"Downloading URL, not caching%@", @""]];
		NSURL *remoteURL = [NSURL URLWithString:escapedUrl];
		NSURLRequest *URLReq = [NSURLRequest requestWithURL:remoteURL];
		[webView loadRequest:URLReq];
	}else{
		[self showAlert:nil theMessage:NSLocalizedString(@"noLocalDataAvailable", @"Data for this screen has not been downloaded. Please check your internet connection.") alertTag:0];
	}
	
	
}



//refresh button
-(void)refreshData{
	[BT_debugger showIt:self theMessage:@"refresh"];
	
 	//refresh original page or starting file?
	if([[self webView] canGoBack]){
		[self.webView reload];
	}else{
		[self initLoad];
	}
        
	
}

//stops loading...
-(void)stopLoading{
	[BT_debugger showIt:self theMessage:@"stopLoading"];
	if([self.webView isLoading]){
		[self.webView stopLoading];
		[self hideProgress];
	}
}

//go forward
-(void)goForward{
	[BT_debugger showIt:self theMessage:@"goForward"];
	if([self.webView canGoForward]){
		[self.webView goForward];
	}
}
//go back
-(void)goBack{
	[BT_debugger showIt:self theMessage:@"goBack"];
	if([self.webView canGoBack]){
		[self.webView goBack];
	}
}

//launch in native app
-(void)launchInNativeApp{
	[BT_debugger showIt:self theMessage:@"launchSafari"];
	
	//confirm first
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"launch_webBrowser", "Whould you like to view this in Safari?")
                                                             delegate:self cancelButtonTitle:NSLocalizedString(@"no", "NO") destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"yes", "YES"), nil];
	[actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
    [actionSheet setTag:1];
	
	//appDelegate
	robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];	
	
	//is this a tabbed app?
	if([appDelegate.rootApp.tabs count] > 0){
		[actionSheet showFromTabBar:[appDelegate.rootApp.rootTabBarController tabBar]];
	}else{
		if(self.browserToolBar != nil){
			[actionSheet showFromToolbar:self.browserToolBar];
		}else{
			[actionSheet showInView:[self view]];
		}
	}	
		
    
}

//email document
-(void)emailDocument{
	//confirm first
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"launch_emailDocument", "Would you like to email this document?")
                                                             delegate:self cancelButtonTitle:NSLocalizedString(@"no", "NO") destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"yes", "YES"), nil];
	[actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
    [actionSheet setTag:2];
    
    //appDelegate
	robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];	
	
	//is this a tabbed app?
	if([appDelegate.rootApp.tabs count] > 0){
		[actionSheet showFromTabBar:[appDelegate.rootApp.rootTabBarController tabBar]];
	}else{
		if(self.browserToolBar != nil){
			[actionSheet showFromToolbar:self.browserToolBar];
		}else{
			[actionSheet showInView:[self view]];
		}
	}	
	    
    
}

//////////////////////////////////////////////////////////////////////////////////////////////////
//webView delegate methods

//everytime the web-view loads. This could be called multiple times during the content load...
-(BOOL)webView:(UIWebView*)theWebView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType{
    
	NSURL *url = request.URL;
	NSString *urlString = [url absoluteString];
	NSString *urlScheme = [url scheme];
	
	[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"shouldStartLoadWithRequest: URL: %@", urlString]];
	[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"shouldStartLoadWithRequest: SCHEME: %@", urlScheme]];
    
	//bail if this is an "about" request, very common in javascript ads, and banners, and other stuff..
	if([@"about" isEqualToString:[url scheme]]) {
        return YES;
    }
    
	//must have a URL string
	if([urlString length] > 3){
		
		//appDelegate
		robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];	
        
		//remember the URL in case action sheet needs to load an external app
		[self setExternalURL:urlString];
        
		/*
         if .mp4 link tapped. This is a bit of a hack to get around the known issue with iOS 4.0 when clicking
         .mp4 links (movies) in web pages. iOS 4.0 tends to crash the device
         */
		if([urlString rangeOfString:@".mp4" options:NSCaseInsensitiveSearch].location != NSNotFound){
			
			theWebView.delegate = nil;
			[self hideProgress];
			
			//appDelegate
			robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];	
            
			//get reference to navigation controller...
            BT_navController *theNavController = [appDelegate getNavigationController];
			
			NSURL *escapedUrl = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
			if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 3.2) {
				//NSLog(@"Embedding video WITH subView..");
				MPMoviePlayerViewController *moviePlayerController = [[MPMoviePlayerViewController alloc] initWithContentURL:escapedUrl];
				[moviePlayerController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
				[theNavController presentViewController:moviePlayerController animated:YES completion:nil];
            
            }else{
				//NSLog(@"Embedding video WITHOUT subView..");
				//init moviePlayer...with iPhone OS 3.2 or earlier player
				MPMoviePlayerController *moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:escapedUrl];
				moviePlayer.scalingMode = MPMovieScalingModeAspectFill;
				[moviePlayer play];
			}	
            
			//bail out!
			return NO;
		}
		
        
		// if email link tapped
		if ([request.URL.scheme isEqualToString:@"mailto"]){
			
			if([appDelegate.rootDevice canSendEmails]){
				
				//send email using method in parent class...
				NSString *toAddress = request.URL.resourceSpecifier;
				[self sendEmailFromWebLink:self.screenData toAddress:toAddress];
                
				//bail..
				return NO;
				
			}
		}
		
		//if not returned already, intercept special links.
		int showConfirm = 0;
		NSString *confirmMessage;
        
		//iTunes URL
		if([urlString rangeOfString: @"itunes.apple" options:NSCaseInsensitiveSearch].location != NSNotFound){
			showConfirm = 1;
			confirmMessage = NSLocalizedString(@"launch_iTunes", "Would you like to launch iTunes?");
		}
        
		//iTunes or App Store URL
		if([urlString rangeOfString: @"phobos.apple" options:NSCaseInsensitiveSearch].location != NSNotFound){
			showConfirm = 1;
			confirmMessage = NSLocalizedString(@"launch_iTunes", "Would you like to launch iTunes?");
		}
        
		//google maps
		if([urlString rangeOfString: @"maps.google" options:NSCaseInsensitiveSearch].location != NSNotFound){
			showConfirm = 1;
			confirmMessage = NSLocalizedString(@"launch_maps", "Would you like to launch Maps?");
		}
        
		//text message
		if([urlString rangeOfString: @"sms:" options:NSCaseInsensitiveSearch].location != NSNotFound){
			if([appDelegate.rootDevice canSendSMS]){
				showConfirm = 1;
				confirmMessage = NSLocalizedString(@"launch_sms", "Would you like to send an SMS?");
			}else{
				//bail
				return NO;
			}
		}
		
		//ask for confirmation before launching native app
		if(showConfirm == 1){
			
			[self confirmLink:confirmMessage];
			return NO;
			
		}
		
		//only here if we did not click a special link
		return YES;
		
		
	} //URL to load was empty		
	
	//only here if URL was empty?
	return NO;
	
}

//started loading...
-(void)webViewDidStartLoad:(UIWebView *)theWebView{
	[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"webViewDidStartLoad%@", @""]];
	[self showProgress];
	
}

//done loading
- (void)webViewDidFinishLoad:(UIWebView *)theWebView{	
	[BT_debugger showIt:self theMessage:@"webViewDidFinishLoad"];
	
	//hide progress
	[self hideProgress];
    
	//if we have a back button in a toolbar, we may need to disable it
	if(self.browserToolBar != nil){
		for(UIBarButtonItem *button in [self.browserToolBar items]){
			int theTag = [button tag];
			//back == 101 (see BT_viewUtilties.m > getWebToolBarForScreen)
            if(theTag == 101){
				if(![self.webView canGoBack]){
					[button setEnabled:FALSE];
				}else{
					[button setEnabled:TRUE];
				}
			}
		}
	}
    
}

//failed to load
- (void)webView:(UIWebView *)theWebView didFailLoadWithError:(NSError *)error{	
	NSString *errorMsg = [error localizedDescription];
	int errorCode = [error code];
	NSString *errorInfo = [NSString stringWithFormat:@"iOS Error Code: %d iOS Error Message: %@", errorCode, errorMsg];
	[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"didFailLoadWithError: %@", errorInfo]];
	
	//hide progress
	[self hideProgress];
	
	//some codes should be ignored...
	if(errorCode == -999) return; //happens on lots of embedded ads in web-pages.
	if(errorCode == 204) return; //happens when plug-ins handle load (like audio streams).
	if(errorCode == 101) return; //happens sometimes when URL is for an app [UIApplication sharedApplication].
	if(errorCode == 102) return; //happens when "frame load interupt".
	
	//if error is 1009, show friendly 'not connected' message
	if(errorCode == -1009){
		errorInfo = NSLocalizedString(@"downloadError", "There was a problem downloading some data from the internet. Please check your interent connection.");
	}
	
	//show error.
	[self showAlert:nil theMessage:errorInfo alertTag:0];
    
	//kill the web-views delegate so the URL request stops! Without this it will almost always crash
	theWebView.delegate = nil;
	
}

//confirms unsupported / launch native app URL's
-(void)confirmLink:(NSString *)theMessage{
	[BT_debugger showIt:self theMessage:@"confirmLink"];
	
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:theMessage
                                                             delegate:self cancelButtonTitle:NSLocalizedString(@"no", "NO") destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"yes", "YES"), nil];
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
    [actionSheet setTag:1];
    
    //appDelegate
    robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];	
    
    //figure out what view to show it in
    BT_navController *theNavController = [appDelegate getNavigationController];
    
    //is this a tabbed app?
    if([appDelegate.rootApp.tabs count] > 0 && self.browserToolBar != nil){
        [actionSheet showFromTabBar:[appDelegate.rootApp.rootTabBarController tabBar]];
    }else{
        [actionSheet showInView:[theNavController view]];
    }			
    
    
    
}



//////////////////////////////////////////////////////////////////////////////////////////////////
//action sheet delegate methods
-(void)actionSheet:(UIActionSheet *)actionSheet  clickedButtonAtIndex:(NSInteger)buttonIndex {
	[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"actionSheetClick for button index: %i", buttonIndex]];
	if(buttonIndex == 0){
		
        //tag == 1 for launch in native app button
        if([actionSheet tag] == 1){
            
            //we cannot open local files in the external browser
            NSString *openURL = self.externalURL;
            if([openURL rangeOfString:@"file://" options:NSCaseInsensitiveSearch].location != NSNotFound){
                //use the screens dataURL
                openURL = self.dataURL;		
            }
            
            //show error if we could not opent he url
            if(![[UIApplication sharedApplication] openURL:[NSURL URLWithString:openURL]]){
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"launch_errorTitle", "Problem Launching App?")
                                                                    message:NSLocalizedString(@"launch_errorMessage", "Your device could not determine which app to use to launch this URL?") delegate:self
                                                          cancelButtonTitle:NSLocalizedString(@"ok", "OK") otherButtonTitles:nil];
                [alertView show];
                
            }else{
                [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"launching native app: %@", openURL]];
            }
            
		}
        
        //tag == 2 for email document button
        if([actionSheet tag] == 2){
        
            
            [self showAlert:nil theMessage:NSLocalizedString(@"attachDocumentError", @"There was a problem attaching the document?") alertTag:0];
            [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"Email Document not a valid option in URL screens. URL screens do not cache the document.%@", @""]];
                                
        }
        
        
	}else{
		//cancel clicked, do nothing
	}
}




//dealloc
-(void)dealloc {
    webView.delegate = nil;
	[webView stopLoading];
}


@end








/*
 *	Copyright David Book, buzztouch.com
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


#import "iAd/ADBannerView.h"
#import "BT_tabBarController.h"


@implementation BT_tabBarController

//init
-(id)init{
    if((self = [super init])){
		//[BT_debugger showIt:self message:[NSString stringWithFormat:@"INIT%@", @""]];
	}
	return self;
}

//after the tabber's view loaded
- (void)viewDidLoad {
    [super viewDidLoad];
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"view loaded%@", @""]];
}




//should rotate
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"shouldAutorotateToInterfaceOrientation %@", @""]];
    
	//allow / dissallow rotations
	BOOL canRotate = TRUE;
	
	//appDelegate
	robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
	if([appDelegate.rootDevice isIPad]){
		canRotate = TRUE;
	}else{
		//should we prevent rotations on small devices?
		if([appDelegate.rootApp.jsonVars objectForKey:@"allowRotation"]){
			if([[appDelegate.rootApp.jsonVars objectForKey:@"allowRotation"] isEqualToString:@"largeDevicesOnly"]){
				canRotate = FALSE;
			}
		}
	}
    
	//can it rotate? 
	if(canRotate){
		return YES;
	}else{
		return (interfaceOrientation == UIInterfaceOrientationPortrait);
	}
	
	//we should not get here
	return YES;		
	
}


//will rotate
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"willRotateToInterfaceOrientation %@", @""]];
	
	//delegate
	robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];	
    
    //hide the context menu...
    [appDelegate hideContextMenu];
    
    
	//some screens need to reload...
	UIViewController *theViewController;
	int selectedTab = 0;
	if([appDelegate.rootApp.tabs count] > 0){
		selectedTab = (int)[appDelegate.rootApp.rootTabBarController selectedIndex];
		theViewController = [[appDelegate.rootApp.rootTabBarController.viewControllers objectAtIndex:selectedTab] visibleViewController];
	}else{
		theViewController = [appDelegate.rootApp.rootNavController visibleViewController];
	}
    
    
    //If we have an ad view we may need to modify it's layout...
	for(UIView* subView in [theViewController.view subviews]){
		if(subView.tag == 94){
			for(UIView* subView_2 in [subView subviews]){
				if(subView_2.tag == 955){
					
                    ADBannerView *theAdView = (ADBannerView *)subView_2;
                    SEL selector = NSSelectorFromString(@"setCurrentContentSizeIdentifier:");
                    if([subView_2 respondsToSelector:selector]){
                        if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
                            [theAdView setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifierLandscape];
                        }else{
                            [theAdView setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifierPortrait];            
                        }
                    }
                    
				}
			}
			break;
		}	
	}
    
    
    //if this view controller has a property named "rotating" set it to false...
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        SEL selector = NSSelectorFromString(@"setIsRotating:");
        if([theViewController respondsToSelector:selector]) {
            [theViewController performSelector:selector];
        }
    #pragma clang diagnostic pop
    
	
}

//did rotate
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"didRotateFromInterfaceOrientation %@", @""]];
	
	//delegate
	robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];	
    
	//some screens need to reload...
	UIViewController *theViewController;
	int selectedTab = 0;
	if([appDelegate.rootApp.tabs count] > 0){
		selectedTab = (int)[appDelegate.rootApp.rootTabBarController selectedIndex];
		theViewController = [[appDelegate.rootApp.rootTabBarController.viewControllers objectAtIndex:selectedTab] visibleViewController];
	}else{
		theViewController = [appDelegate.rootApp.rootNavController visibleViewController];
	}
    
    //if this view controller has a property named "rotating" set it to false...
    SEL sel1 = NSSelectorFromString(@"rotating");
    if([theViewController respondsToSelector:sel1]) {
        [theViewController setValue:0 forKey:@"rotating"];
    } 
    
    
	//some screens need to re-build their layout...If a plugin has a method called
    //"layoutScreen" we trigger it everytime the device rotates. The plugin author can
    //create this method in the UIViewController (layoutScreen) if they need something to 
    //happen after rotation occurs.
    
    
    //if this view controller has a property named "rotating" set it to false...This for sure
    //is used in the Image Gallery plugin...
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL sel2 = NSSelectorFromString(@"setNotRotating");
    if ([theViewController respondsToSelector:sel2]) {
        [theViewController performSelector:sel2];
    }
    #pragma clang diagnostic pop

	
	//some screens need to re-build their layout...If a plugin has a method called
    //"layoutScreen" we trigger it everytime the device rotates. The plugin author can
    //create this method in the UIViewController (layoutScreen) if they need something to
    //happen after rotation occurs.
    
    //if this view controller has a "layoutScreen" method, trigger it...
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL sel3 = NSSelectorFromString(@"layoutScreen");
        if([theViewController respondsToSelector:sel3]){
            [theViewController performSelector:sel3];
        }
    #pragma clang diagnostic pop
    
	
}




@end






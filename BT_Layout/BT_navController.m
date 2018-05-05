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
#import <QuartzCore/QuartzCore.h>
#import "BT_navController.h"




@implementation BT_navController


/*
 This core navigation method determines what type of transition to use
 before pushing the next view controller. Before pushing the controller, it refers to the currentMenuItemData
 object remembered in the app's delegate. 	
 */
-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"pushViewController %@", @""]];

	//appDelegate.rootApp remembers the last screen that loaded and the last menu item that was tapped...
	robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];	
	BT_item *theMenuItemData = [appDelegate.rootApp currentMenuItemData];
    
	//animated or not?
	if([theMenuItemData.jsonVars objectForKey:@"transitionType"]){
		NSString *theTransition = [theMenuItemData.jsonVars objectForKey:@"transitionType"];
		NSArray *supportedAnimations = [NSArray arrayWithObjects:@"curl", @"flip", @"fade", @"grow", @"slideUp", @"slideDown", nil];
		if([supportedAnimations containsObject:theTransition]){
			[BT_debugger showIt:self message:[NSString stringWithFormat:@"transition type: %@", theTransition]];
			
			//add the transition to the history so we can reverse it.
			[appDelegate.rootApp.transitionTypeHistory addObject:theTransition];
			
			//curl
			if([theTransition isEqualToString:@"curl"]){
				[UIView beginAnimations:nil context:NULL];
				[UIView setAnimationDuration:0.75];
				[UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.view cache:NO];
				[super pushViewController:viewController animated:NO];
				[UIView commitAnimations];
			}
			
			//flip
			if([theTransition isEqualToString:@"flip"]){
				[UIView beginAnimations:nil context:NULL];
				[UIView setAnimationDuration:0.75];
				[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:NO];
				[super pushViewController:viewController animated:NO];
				[UIView commitAnimations];
			}
			
			//fade
			if([theTransition isEqualToString:@"fade"]){
				CATransition * animation = [CATransition animation];
				animation.type = kCATransitionFade;
				[animation setDuration:0.35];
				[[self.view layer] addAnimation:animation forKey:@"Animate"];	
				[super pushViewController:viewController animated:NO];
			}
			
			//grow
			if([theTransition isEqualToString:@"grow"]){
				[UIView beginAnimations:nil context:nil]; 
				self.view.transform = CGAffineTransformMakeScale(0.01, 0.01);
				[UIView setAnimationDuration:0.5];
				self.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
				[UIView commitAnimations];
				[super pushViewController:viewController animated:NO];
			}		
			
			//slideUp
			if([theTransition isEqualToString:@"slideUp"]){
				CATransition * animation = [CATransition animation];
				[animation setType:kCATransitionPush];
				[animation setSubtype:kCATransitionFromTop];
				[animation setDuration:0.35];
				[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
				[[self.view layer] addAnimation:animation forKey:@"Animate"];	
				[super pushViewController:viewController animated:NO];
			}		
            
			//slideDown
			if([theTransition isEqualToString:@"slideDown"]){
				CATransition * animation = [CATransition animation];
				[animation setType:kCATransitionPush];
				[animation setSubtype:kCATransitionFromBottom];
				[animation setDuration:0.35];
				[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
				[[self.view layer] addAnimation:animation forKey:@"Animate"];	
				[super pushViewController:viewController animated:NO];
			}		
			
			//bail
			return;
			
		}//supported animation
		
	}
	
	//add the transition to the history so we can reverse it.
	[appDelegate.rootApp.transitionTypeHistory addObject:@""];
    
	//if we are here, this screen does not use an animation (or the animation is not supported)
	[super pushViewController:viewController animated:animated];
	
    
}


//over-ride the generic pop method so we can use a custom animation
-(UIViewController *)popViewControllerAnimated:(BOOL)animated{

	//delegate.
	robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];	
    
	//the screen that was tapped is remembered in the app's delegate
	[BT_debugger showIt:self message:[NSString stringWithFormat:@"popViewControllerAnimated for screen with itemId: %@", [appDelegate.rootApp.currentScreenData itemId]]];
    
	//previous transition is the last item in the history array
	NSString *theTransition = @"";
	if([appDelegate.rootApp.transitionTypeHistory count] > 0){
		theTransition = [appDelegate.rootApp.transitionTypeHistory lastObject];
		[appDelegate.rootApp.transitionTypeHistory removeLastObject];
	}
	
	//animated or not?
	if([theTransition length] > 1){
		NSArray *supportedAnimations = [NSArray arrayWithObjects:@"curl", @"flip", @"fade", @"grow", @"slideUp", @"slideDown", nil];
		if([supportedAnimations containsObject:theTransition]){
			[BT_debugger showIt:self message:[NSString stringWithFormat:@"transition type: %@", theTransition]];
            
            
			UIViewController *viewController;
			//curl
			if([theTransition isEqualToString:@"curl"]){
				[UIView beginAnimations:nil context:NULL];
				[UIView setAnimationDuration:0.75];
				[UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:self.view cache:NO];
				viewController = [super popViewControllerAnimated:NO];
				[UIView commitAnimations];
			}
			
			//flip
			if([theTransition isEqualToString:@"flip"]){
				[UIView beginAnimations:nil context:NULL];
				[UIView setAnimationDuration:0.75];
				[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:NO];
				viewController = [super popViewControllerAnimated:NO];
				[UIView commitAnimations];
			}
			
			//fade
			if([theTransition isEqualToString:@"fade"]){
				CATransition * animation = [CATransition animation];
				animation.type = kCATransitionFade;
				[animation setDuration:0.35];
				[[self.view layer] addAnimation:animation forKey:@"Animate"];	
				viewController = [super popViewControllerAnimated:NO];
			}
			
			//grow
			if([theTransition isEqualToString:@"grow"]){
				[UIView beginAnimations:nil context:nil]; 
				self.view.transform = CGAffineTransformMakeScale(0.01, 0.01);
				[UIView setAnimationDuration:0.5];
				self.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
				[UIView commitAnimations];	
				viewController = [super popViewControllerAnimated:NO];
			}		
			
			//slideUp (this slides down when popping)
			if([theTransition isEqualToString:@"slideUp"]){
				CATransition * animation = [CATransition animation];
				[animation setType:kCATransitionPush];
				[animation setSubtype:kCATransitionFromBottom];
				[animation setDuration:0.35];
				[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
				[[self.view layer] addAnimation:animation forKey:@"Animate"];	
				viewController = [super popViewControllerAnimated:NO];
			}		
            
			//slideDown (this slides up when popping)
			if([theTransition isEqualToString:@"slideDown"]){
				CATransition * animation = [CATransition animation];
				[animation setType:kCATransitionPush];
				[animation setSubtype:kCATransitionFromTop];
				[animation setDuration:0.35];
				[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
				[[self.view layer] addAnimation:animation forKey:@"Animate"];	
				viewController = [super popViewControllerAnimated:NO];
			}	
            
			//return		
			return viewController;
            
		}//supported animation
        
	}
	
	//if we are here, this screen does not use an animation (or the animation is not supported)
	return [super popViewControllerAnimated:animated];
	
	
}







@end









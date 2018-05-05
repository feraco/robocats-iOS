/*
 *	Copyright 2014, Barry Jones
 *
 *	All rights reserved.
 *
 *  Based on the Splash Screen plugin written by David Book.
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



#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BT_viewController.h"
#import "BT_item.h"
#import "BT_downloader.h"
#import "BT_item.h"

@interface RD_simpleFence : BT_viewController <BT_downloadFileDelegate> {
    
	UIImageView *backgroundImageView;
	UIImage *backgroundImage;
	NSString *imageName;
	NSString *imageURL;
	NSString *transitionType;
	double startTransitionAfterSeconds;
	double transitionDurationSeconds;
    
    // ******************************************
    
    NSString *tmpLatitude;
    NSString *tmpLongitude;
    NSString *itemId;
    NSString *url;
	BT_item *theParentMenuScreenData;
    
    // ******************************************

	
    
    
}

@property (nonatomic, retain) UIImageView *backgroundImageView;
@property (nonatomic, retain) UIImage *backgroundImage;
@property (nonatomic, retain) NSString *imageName;
@property (nonatomic, retain) NSString *imageURL;
@property (nonatomic, retain) NSString *transitionType;
@property (nonatomic) double startTransitionAfterSeconds;
@property (nonatomic) double transitionDurationSeconds;




// *************************************

@property (nonatomic, retain) NSString *tmpLatitude;
@property (nonatomic, retain) NSString *tmpLongitude;
@property (nonatomic, retain) NSString *itemId;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *regionRadius;
@property (nonatomic, retain) BT_item *theParentMenuScreenData;

// *************************************





-(void)downloadImage;
-(void)animateSplashScreen;
-(void)removeSplashScreen;
-(void)setImage:(UIImage *)theImage;

@end












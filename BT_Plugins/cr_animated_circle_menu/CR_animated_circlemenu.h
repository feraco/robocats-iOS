//
// Animated Cirlce Menu
// Copyright 2013, Chris Ruddell, churchphoneapps.com
// All rights reserved.
// 


//  Open Source Copyright Information:
//
//  Original files named:
//
//  KYCircleMenu.h
//  KYCircleMenu
//
//  Created by Kaijie Yu on 2/1/12.
//  Copyright (c) 2012 Kjuly. All rights reserved.
//

/*
 *	Copyright 2013, David Book, buzztouch.com
 *
 *	All rights reserved.
 *
 *	Redistribution and use in source and binary forms, with or without modification, are 
 *	permitted provided that the following conditions are met:
 *
 *	Redistributions of source code must retain the above copyright notices which include the
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

// The default case is that the navigation bar is only shown in child views.
// If it is needed to be shown with the circle menu together,
//   just copy this macro into your own config file & comment it out.
//
// #define KY_CIRCLEMENU_WITH_NAVIGATIONBAR 1

// Constants
#define kKYCircleMenuViewHeight CGRectGetHeight([UIScreen mainScreen].applicationFrame)
#define kKYCircleMenuViewWidth  CGRectGetWidth([UIScreen mainScreen].applicationFrame)
#define kKYCircleMenuNavigationBarHeight 44.f

// Notification to close the menu
#define kKYNCircleMenuClose @"KYNCircleMenuClose"

@interface CR_animated_circlemenu : BT_viewController {
    UIView   * menu;
    NSMutableArray *menuItems;
    UIButton * centerButton;
    UILabel * buttonLabel;
    BOOL       isOpening;
    BOOL       isInProcessing;
    BOOL       isClosed;
    NSInteger buttonCount;
    CGRect    buttonOriginFrame;
    NSString * centerButtonImageName;
    NSString * centerButtonBackgroundImageName;
    
    BOOL shouldRecoverToNormalStatusWhenViewWillAppear;
    
    // Basic configuration for the Circle Menu
    CGFloat menuSize,         // size of menu
    buttonSize,       // size of buttons around
    centerbuttonSize; // size of center button
    CGFloat defaultTriangleHypotenuse, minBounceOfTriangleHypotenuse, maxBounceOfTriangleHypotenuse, maxTriangleHypotenuse;
}

@property (nonatomic, retain) UIView   * menu;
@property (nonatomic, retain) NSMutableArray *menuItems;
@property (nonatomic, retain) UIButton * centerButton;
@property (nonatomic, retain) UILabel * buttonLabel;
@property (nonatomic, assign) BOOL       isOpening;
@property (nonatomic, assign) BOOL       isInProcessing;
@property (nonatomic, assign) BOOL       isClosed;
@property (nonatomic, copy) NSString * buttonImageNameFormat,
* centerButtonImageName,
* centerButtonBackgroundImageName;



//Action to run when a button is pressed
- (void)runButtonActions:(id)sender;

// Open menu to show all buttons around
- (void)open;

// Recover all buttons to normal position
- (void)recoverToNormalStatus;

@end












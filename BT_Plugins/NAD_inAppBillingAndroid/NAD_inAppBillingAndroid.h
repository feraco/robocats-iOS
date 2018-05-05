/* ver 1.2
 *	Copyright 2013, Nicholas D'Innocenzo
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



//{
//    "itemId": "0BBD9FCCE1286A5E2AE28B5",
//    "itemType": "NAD_inAppBillingAndroid",
//    "itemNickname": "billing",
//    "navBarTitleText": "billing",
//    "titleTextPrior": "Expand the quiz bank!",
//    "titleTextSizePrior": "17",
//    "titleTextColorPrior": "#000000",
//    "titleBackgroundColorPrior": "#FFFFFF",
//    "imageNamePrior": "genuine.jpg",
//    "textBoxPrior": "Unlock the full quiz banke for $0.99.",
//    "textBoxTextSizePrior": "15",
//    "textBoxTextSizeLargePrior": "18",
//    "textBoxTextColorPrior": "#000000",
//    "textBoxBackgroundColorPrior": "#FFFFFF",
//    "purchaseButtonTextPrior": "$0.99",
//    "purchaseButtonTextSizePrior": "15",
//    "purchaseButtonTextColorPrior": "#000000",
//    "purchaseButtonBackgroundColorPrior": "#FFFFFF",
//    "titleTextAfter": "Thank you for your purchase.",
//    "titleTextSizeAfter": "18",
//    "titleTextColorAfter": "#000000",
//    "titleBackgroundColorAfter": "#FFFFFF",
//    "imageNameAfter": "thumbs_up.jpg",
//    "textBoxAfter": "Thank you for purchasing the expanded quiz bank.  Click the continue button below to access your quiz.",
//    "textBoxTextSizeAfter": "14",
//    "textBoxTextSizeLargeAfter": "18",
//    "textBoxTextColorAfter": "#000000",
//    "textBoxBackgroundColorAfter": "#FFFFFF",
//    "continueButtonTextAfter": "Continue to trivia.",
//    "continueButtonTextSizeAfter": "16",
//    "continueButtonTextColorAfter": "#000000",
//    "continueButtonBackgroundColorAfter": "#FFFFFF",
//    "unLockScreenNickname": "paid quiz",
//    "unLockScreenItemId": "A58557D0057753B7BDD0754",
//  "restoreButtonText": "Restore Purchase",
//  "restoreButtonTextSize": "15",
//  "restoreButtonTextColor": "#000000",
//  "restoreButtonBackgroundColor": "#FFFFFF",
//    "backgroundColor": "#666666"
//}



#import "BT_viewController.h"
#import "NAD_RMStore.h"


@interface NAD_inAppBillingAndroid : BT_viewController<RMStoreObserver> {
	
    NSString *titleTextPrior;
    NSInteger titleTextSizePrior;
    UIColor *titleTextColorPrior;
    UIColor *titleBackgroundColorPrior;
    NSString *imageNamePrior;
    NSString *textBoxPrior;
    NSInteger textBoxTextSizePrior;
    NSInteger textBoxTextSizeLargePrior;
    UIColor *textBoxtTextColorPrior;
    UIColor *textBoxBackgroundColorPrior;
    NSString *purchaseButtonTextPrior;
    NSInteger purchaseButtonTextSizePrior;
    UIColor *purchaseButtonTextColorPrior;
    UIColor *purchaseButtonBackgroundColorPrior;
    
    NSString *titleTextAfter;
    NSInteger titleTextSizeAfter;
    UIColor *titleTextColorAfter;
    UIColor *titleBackgroundColorAfter;
    NSString *imageNameAfter;
    NSString *textBoxAfter;
    NSInteger textBoxTextSizeAfer;
    NSInteger textBoxTextSizeLargeAfter;
    UIColor *textBoxTextColorAfter;
    UIColor *textBoxBackgroundColorAfter;
    NSString *continueButtonTextAfter;
    NSInteger continueButtonTextSizeAfter;
    UIColor *continueButtonTextColorAfter;
    UIColor *continueButtonBackgroundColorAfter;
    
    NSString *unlockScreenNickname;
    NSInteger *unlockScreenItemId;
    
    NSString *restoreButtonText;
    NSInteger restoreButtonTextSize;
    UIColor *restoreButtonTextColor;
    UIColor *restoreButtonBackgroundColor;

    UIColor *backgroundColor;
    
    UILabel *titleLabel;
    UIImage *titleImage;
    UIImageView *titleImageView;
    UILabel *textBox;
    UIButton *purchaseButton;
    UILabel *purchaseButtonLabel;
    UIButton *restoreButton;
    UIButton *restoreButtonLabel;
    UIButton *continueButton;
    UILabel *continueButtonLabel;
    
    
    UIScrollView *scrollView;
    
    UIView *innerView;
    
    UILabel *innerLabel;
    

}

@property (nonatomic, strong) NSString *titleTextPrior;
@property (nonatomic) NSInteger titleTextSizePrior;
@property (nonatomic, strong) UIColor *titleTextColorPrior;
@property (nonatomic, strong) UIColor *titleBackgroundColorPrior;
@property (nonatomic, strong) NSString *imageNamePrior;
@property (nonatomic, strong) NSString *textBoxPrior;
@property (nonatomic) NSInteger textBoxTextSizePrior;
@property (nonatomic) NSInteger textBoxTextSizeLargePrior;
@property (nonatomic, strong) UIColor *textBoxtTextColorPrior;
@property (nonatomic, strong) UIColor *textBoxBackgroundColorPrior;
@property (nonatomic, strong) NSString *purchaseButtonTextPrior;
@property (nonatomic) NSInteger purchaseButtonTextSizePrior;
@property (nonatomic, strong) UIColor *purchaseButtonTextColorPrior;
@property (nonatomic, strong) UIColor *purchaseButtonBackgroundColorPrior;

@property (nonatomic, strong) NSString *titleTextAfter;
@property (nonatomic) NSInteger titleTextSizeAfter;
@property (nonatomic, strong) UIColor *titleTextColorAfter;
@property (nonatomic, strong) UIColor *titleBackgroundColorAfter;
@property (nonatomic, strong) NSString *imageNameAfter;
@property (nonatomic, strong) NSString *textBoxAfter;
@property (nonatomic) NSInteger textBoxTextSizeAfer;
@property (nonatomic) NSInteger textBoxTextSizeLargeAfter;
@property (nonatomic, strong) UIColor *textBoxTextColorAfter;
@property (nonatomic, strong) UIColor *textBoxBackgroundColorAfter;
@property (nonatomic, strong) NSString *continueButtonTextAfter;
@property (nonatomic) NSInteger continueButtonTextSizeAfter;
@property (nonatomic, strong) UIColor *continueButtonTextColorAfter;
@property (nonatomic, strong) UIColor *continueButtonBackgroundColorAfter;

@property (nonatomic, strong) NSString *unlockScreenNickname;
@property (nonatomic) NSInteger unlockScreenItemId;

@property (nonatomic, strong) NSString *restoreButtonText;
@property (nonatomic) NSInteger restoreButtonTextSize;
@property (nonatomic, strong) UIColor *restoreButtonTextColor;
@property (nonatomic, strong) UIColor *restoreButtonBackgroundColor;

@property (nonatomic, strong) UIColor *backgroundColor;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImage *titleImage;
@property (nonatomic, strong) UIImageView *titleImageView;
@property (nonatomic, strong) UILabel *textBox;
@property (nonatomic, strong) UIButton *purchaseButton;
@property (nonatomic, strong) UILabel *purchaseButtonLabel;
@property (nonatomic, strong) UIButton *restoreButton;
@property (nonatomic, strong) UILabel *restoreButtonLabel;
@property (nonatomic, strong) UIButton *continueButton;
@property (nonatomic, strong) UILabel *continueButtonLabel;


@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *innerView;
@property (nonatomic, strong) UILabel *innerLabel;


-(void)getBTVars;
-(void)setInitialVars;
-(void)testBTVars;
-(void)purchaseButtonPressed;
-(void)restoreButtonPressed;
-(void)transitionScreenElements;
-(void)transitionScreenElementsWithNewScreen;
-(void)setUpAfterPurchaseScreen;
-(void)fadeIn;
-(void)fadeOut;
-(void)loadNewScreen;


@end











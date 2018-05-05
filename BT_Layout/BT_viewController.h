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



#import <iAd/iAd.h>
#import "iAd/ADBannerView.h"
#import <MessageUI/MessageUI.h>


@interface BT_viewController : UIViewController <UIAlertViewDelegate, 
												ADBannerViewDelegate,
                                                MFMailComposeViewControllerDelegate,
													  NSFileManagerDelegate,
                                                MFMessageComposeViewControllerDelegate>{

}

@property (nonatomic, strong) BT_item *screenData;
@property (nonatomic, strong) UIView *progressView;
@property (nonatomic, strong) UIView *adView;
@property (nonatomic, strong) id adBannerView;
@property (nonatomic) BOOL adBannerViewIsVisible;
@property (nonatomic) BOOL hasStatusBar;
@property (nonatomic) BOOL hasNavBar;
@property (nonatomic) BOOL hasToolBar;

-(id)initWithScreenData:(BT_item *)theScreenData;
-(void)viewDidLoad;
-(void)viewWillAppear:(BOOL)animated;
-(void)viewWillDisappear:(BOOL)animated;
-(void)fadeInOnEntry;
-(void)fadeOutOnExit;
-(void)showProgress;
-(void)hideProgress;
-(void)navLeftTap;
-(void)navRightTap;
-(void)toggleTopBar:(NSString *)withOptions;
-(void)setTopBarTitle:(NSString *)theTitle;
-(void)showAudioControls;
-(void)showContextMenu;
-(void)showAlert:(NSString *)theTitle theMessage:(NSString *)theMessage alertTag:(int)alertTag;
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
-(void)createAdBannerView;
-(void)showHideAdView;
-(void)bannerViewDidLoadAd:(ADBannerView *)banner;
-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error;
-(void)loadScreenWithItemId:(NSString *)theItemId;
-(void)loadScreenWithNickname:(NSString *)theNickname;
-(void)loadScreenObject:(BT_item *)theScreenData;
-(void)handleTapToLoadScreen:(BT_item *)theScreenData theMenuItemData:(BT_item *)theMenuItemData;
-(void)configureNavBar;
-(void)configureBackground;
-(void)placeCallWithScreenData:(BT_item *)theScreenData;
-(void)sendEmailWithScreenData:(BT_item *)theScreenData imageAttachment:(UIImage *)imageAttachment imageAttachmentName:(NSString *)imageAttachmentName;
-(void)sendEmailWithAttachmentFromScreenData:(BT_item *)theScreenData theAttachmentData:(NSData *)theAttachmentData attachmentName:(NSString *)attachmentName;
-(void)sendEmailFromWebLink:(BT_item *)theScreenData toAddress:(NSString *)toAddress;
-(void)sendTextMessageWithScreenData:(BT_item *)theScreenData;
-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result;
-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error;
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;





@end










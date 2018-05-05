/*
 *	Copyright Chris Ruddell, www.buzz-tools.com
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

#import "BT_viewController.h"
#import <MapKit/MapKit.h>
#import "cr_ultimateSlider.h"
#import "cr_ultimateStepper.h"
#import "cr_ultimateTapRecognizer.h"
#import "cr_ultimateTableViewCell.h"

@interface CR_ultimatScreenCreator : BT_viewController <BT_downloadFileDelegate, UIWebViewDelegate, UITextFieldDelegate,UIGestureRecognizerDelegate,UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, retain) UITableView *myTableView;
@property (nonatomic, retain) NSMutableArray *menuItems;
@property (nonatomic, retain) NSMutableArray *tableItems;
@property (nonatomic, retain) NSString *saveAsFileName;
@property (nonatomic, retain) BT_downloader *downloader;
@property (nonatomic) BOOL isLoading;
@property (nonatomic) int didInit;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UITextField *activeField;
@property (nonatomic) CGFloat scrollOffset;
@property (nonatomic) CGFloat headerHeight;
@property (nonatomic) BOOL tableRowAsButtons;
@property (nonatomic, retain) NSString *tableListStyle;
@property (nonatomic, retain) NSString *tableRowFontColor;
@property (nonatomic, retain) NSString *tableRowSelectStyle;
@property (nonatomic) int tableFontSize;
@property (nonatomic) CGFloat tableRowHeight;

@property (nonatomic) CGFloat tableDescriptionSize;
@property (nonatomic) CGFloat tableFontSizeLarge;
@property (nonatomic) CGFloat tableDescriptionSizeLarge;
@property (nonatomic, retain) NSString *listTitleHeightSmallDevice;
@property (nonatomic) CGFloat listRowHeightLargeDevice;
@property (nonatomic, retain) NSString *listTitleHeightLargeDevice;
@property (nonatomic, retain) NSString *tableRowBackgroundColor;
//@property (nonatomic, retain) MPMoviePlayerController *theVideoPlayer;
@property (nonatomic, retain) UIView *theMovieMask;
@property (nonatomic, retain) UIImageView *playButton;
@property (nonatomic) bool newMedia;
@property (nonatomic, retain) UIButton *buttonPressed;
@property (nonatomic, retain) NSMutableArray *arrayOfElements;  //to retain them in memory

@property (nonatomic, retain) UIView *rotationView;
@end

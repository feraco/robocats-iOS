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

#import <UIKit/UIKit.h>

@interface cr_ultimateTableViewCell : UITableViewCell {
    BT_item *theParentMenuScreenData;
	BT_item *theMenuItemData;
	UILabel *titleLabel;
	UITextView *descriptionLabel;
	UIView *imageBox;
	UIImageView *cellImageView;
	UIImageView *glossyMaskView;
	UIActivityIndicatorView *imageLoadingView;
	NSThread *thread;
    BOOL isSelected;
}

@property (nonatomic, retain) BT_item *theParentMenuScreenData;
@property (nonatomic, retain) BT_item *theMenuItemData;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UIView *imageBox;
@property (nonatomic, retain) UITextView *descriptionLabel;
@property (nonatomic, retain) UIImageView *cellImageView;
@property (nonatomic, retain) UIImageView *glossyMaskView;
@property (nonatomic, retain) UIActivityIndicatorView *imageLoadingView;
@property (nonatomic) BOOL isSelected;

@property (nonatomic) CGFloat tableFontSize;
@property (nonatomic) CGFloat tableDescriptionSize;
@property (nonatomic) CGFloat tableFontSizeLarge;
@property (nonatomic) CGFloat tableDescriptionSizeLarge;
@property (nonatomic, retain) NSString *tableRowSelectStyle;
@property (nonatomic, retain) NSString *tableRowFontColor;
@property (nonatomic, retain) NSString *tableListStyle;
@property (nonatomic) CGFloat listRowHeightSmallDevice;
@property (nonatomic, retain) NSString *listTitleHeightSmallDevice;
@property (nonatomic) CGFloat listRowHeightLargeDevice;
@property (nonatomic, retain) NSString *listTitleHeightLargeDevice;



-(void)configureCell;
-(void)showImage;
-(void)downloadImage;
-(void)setImageFromThread:(UIImage *)theImage;

@end

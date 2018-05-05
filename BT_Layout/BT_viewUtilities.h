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



@interface BT_viewUtilities : NSObject{

}

+(CGRect)frameForNavBarAtOrientation:(UIViewController *)theViewController theScreenData:(BT_item *)theScreenData;
+(CGRect)frameForToolBarAtOrientation:(UIViewController *)theViewController theScreenData:(BT_item *)theScreenData;
+(CGRect)frameForAdView:(UIViewController *)theViewController theScreenData:(BT_item *)theScreenData;
+(UIView *)getProgressView:(NSString *)loadingText;
+(UIColor *)getNavBarBackgroundColorForScreen:(BT_item *)theScreenData;
+(UIColor *)getTextColorForScreen:(BT_item *)theScreenData;


+(UIView *)applyRoundedCorners:(UIView *)theView radius:(int)radius;
+(UITextView *)applyRoundedCornersToTextView:(UITextView *)theView radius:(int)radius;
+(UIImageView *)applyRoundedCornersToImageView:(UIImageView *)theView radius:(int)radius;
+(UIView *)applyBorder:(UIView *)theView borderWidth:(int)borderWidth borderColor:(UIColor *)borderColor;
+(UIView *)applyDropShadow:(UIView *)theView shadowColor:(UIColor *)shadowColor;
+(UIView *)applyGradient:(UIView *)theView colorTop:(UIColor *)colorTop colorBottom:(UIColor *)colorBottom;


/* BT DEPRECATED METHODS. PLUGINS SHOULD NOT USE THESE ANYMORE */
+(UITableView *)getTableViewForScreen:(BT_item *)theScreenData;
+(UIToolbar *)getWebToolBarForScreen:(UIViewController *)theViewController theScreenData:(BT_item *)theScreenData;
+(UIToolbar *)getMapToolBarForScreen:(UIViewController *)theViewController theScreenData:(BT_item *)theScreenData;
+(UIToolbar *)getImageToolBarForScreen:(UIViewController *)theViewController theScreenData:(BT_item *)theScreenData;
+(UIToolbar *)getAudioToolBarForScreen:(UIViewController *)theViewController theScreenData:(BT_item *)theScreenData;
+(UIToolbar *)getQuizToolBarForScreen:(UIViewController *)theViewController theScreenData:(BT_item *)theScreenData;
+(UISegmentedControl *)getButtonForQuiz:(UIViewController *)theViewController theFrame:(CGRect)theFrame theTag:(int)theTag buttonColor:(UIColor *)buttonColor;
+(UILabel *)getLabelForQuizButton:(CGRect)theFrame fontSize:(int)fontSize fontColor:(UIColor *)fontColor;
+(UIView *)getCellBackgroundForListRow:(BT_item *)theScreenData theIndexPath:(NSIndexPath *)theIndexPath numRows:(int)numRows;





@end







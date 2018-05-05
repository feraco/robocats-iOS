/*
 *	Copyright 2015, Chris Ruddell
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

#import "CR_calendarViewCell.h"
#import "BT_imageTools.h"


@implementation CR_calendarViewCell
@synthesize titleLabel, descriptionLabel, theParentMenuScreenData, theMenuItemData, cellImageView;


//size and color come from screen, not menu item
- (id)initWithStyle:(UITableViewCellStyle)stylereuseIdentifier reuseIdentifier:(NSString *)reuseIdentifier {
    if((self = [super initWithStyle:stylereuseIdentifier reuseIdentifier:reuseIdentifier])){
        
        //set background to clear to start
//        [self.contentView setBackgroundColor:[UIColor clearColor]];
//        self.backgroundColor = [UIColor clearColor];
        
        //image view for icon
        cellImageView = [[CR_calendarIconView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.height, self.contentView.frame.size.height)];
        [cellImageView setClipsToBounds:YES];
        //Changed SJM to the row below[cellImageView setContentMode:UIViewContentModeCenter];
        [cellImageView setContentMode:UIViewContentModeScaleAspectFill];
        [cellImageView setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:cellImageView];
        
        //label for text
        titleLabel = [[UILabel alloc] init];
        [titleLabel setClipsToBounds:YES];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        titleLabel.numberOfLines = 1;
        [self.contentView addSubview:titleLabel];
        
        //textView for description. no padding!
        descriptionLabel = [[UITextView alloc] init];
        [descriptionLabel setClipsToBounds:YES];
        [descriptionLabel setBackgroundColor:[UIColor clearColor]];
        [descriptionLabel setEditable:FALSE];
        [descriptionLabel setUserInteractionEnabled:FALSE];
        [descriptionLabel setShowsVerticalScrollIndicator:FALSE];
        [descriptionLabel setShowsHorizontalScrollIndicator:FALSE];
        [descriptionLabel setContentInset:UIEdgeInsetsMake(-8,-4,0,0)];
        descriptionLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:descriptionLabel];
        
    }
    return self;
}

//sets text, image, size, etc.
-(void)configureCell{
    
    //appDelegate
    robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
    
    /*
     cell design comes from rootApp.rootTheme OR from parentScreen's JSON data if over-ridden
     Scenarios:
     a) 	Title NO Description.
     In this case, the row-height is used for the label the text is centered.
     b) 	Title + Description.
     In this case, the "listTitleHeight" is used and the the difference between this and
     the row-height becomes the height of the description label
     
     IMPORTANT: The image with be center in the image box. This means if the image is larger than
     the row height it will not look right. Scaling images in lists is memory intensive so we do
     not do it. This means you should only use icons / images that are "smaller than the row height"
     
     
     */
    
    //default values
    int rowHeight = 50;
    int titleHeight = 50;
    int descriptionHeight = 0;
    int titleFontSize = 20;
    int descriptionFontSize = 20;
    UIColor *titleFontColor = [UIColor blackColor];
    UIColor *descriptionFontColor = [UIColor blackColor];
    NSString *rowSelectionStyle = @"arrow";
    NSString *rowAccessoryType = @"";
    NSString *titleText = @"";
    NSString *descriptionText = @"";
    
    
    ////////////////////////////////////////////////////////////////////////
    //properties not related to the device's size
    
    //listTitle / description
    titleText = [BT_strings getJsonPropertyValue:theMenuItemData.jsonVars nameOfProperty:@"titleText" defaultValue:@""];
    titleText = [BT_strings cleanUpCharacterData:titleText];
    titleText = [BT_strings stripHTMLFromString:titleText];
    
    descriptionText = [BT_strings getJsonPropertyValue:theMenuItemData.jsonVars nameOfProperty:@"descriptionText" defaultValue:@""];
    descriptionText = [BT_strings cleanUpCharacterData:descriptionText];
    descriptionText = [BT_strings stripHTMLFromString:descriptionText];
    
    titleFontColor = [BT_color getColorFromHexString:[BT_strings getStyleValueForScreen:theParentMenuScreenData nameOfProperty:@"listTitleFontColor" defaultValue:@"#000000"]];
    descriptionFontColor = [BT_color getColorFromHexString:[BT_strings getStyleValueForScreen:theParentMenuScreenData nameOfProperty:@"listDescriptionFontColor" defaultValue:@"#000000"]];
    rowSelectionStyle = [BT_strings getStyleValueForScreen:theParentMenuScreenData nameOfProperty:@"listRowSelectionStyle" defaultValue:@"blue"];
    
    //row accessory type
    rowAccessoryType = [BT_strings getJsonPropertyValue:theMenuItemData.jsonVars nameOfProperty:@"rowAccessoryType" defaultValue:@"none"];
    
    
    ////////////////////////////////////////////////////////////////////////
    //properties related to the device's size
    
    //height and size depends on device type
    if([appDelegate.rootDevice isIPad]){
        
        //user large device settings
        rowHeight = [[BT_strings getStyleValueForScreen:theParentMenuScreenData nameOfProperty:@"listRowHeightLargeDevice" defaultValue:@"50"] intValue];
        titleHeight = [[BT_strings getStyleValueForScreen:theParentMenuScreenData nameOfProperty:@"listTitleHeightLargeDevice" defaultValue:@"30"] intValue];
        titleFontSize = [[BT_strings getStyleValueForScreen:theParentMenuScreenData nameOfProperty:@"listTitleFontSizeLargeDevice" defaultValue:@"20"] intValue];
        descriptionFontSize = [[BT_strings getStyleValueForScreen:theParentMenuScreenData nameOfProperty:@"listDescriptionFontSizeLargeDevice" defaultValue:@"15"] intValue];
        
    }else{
        
        //user small device settings
        rowHeight = [[BT_strings getStyleValueForScreen:theParentMenuScreenData nameOfProperty:@"listRowHeightSmallDevice" defaultValue:@"50"] intValue];
        titleHeight = [[BT_strings getStyleValueForScreen:theParentMenuScreenData nameOfProperty:@"listTitleHeightSmallDevice" defaultValue:@"30"] intValue];
        titleFontSize = [[BT_strings getStyleValueForScreen:theParentMenuScreenData nameOfProperty:@"listTitleFontSizeSmallDevice" defaultValue:@"20"] intValue];
        descriptionFontSize = [[BT_strings getStyleValueForScreen:theParentMenuScreenData nameOfProperty:@"listDescriptionFontSizeSmallDevice" defaultValue:@"15"] intValue];
        
    }
    
    //figure out heights
    if(titleHeight > rowHeight){
        titleHeight = rowHeight;
    }
    if([descriptionText length] > 0){
        descriptionHeight = (rowHeight - titleHeight);
    }else{
        titleHeight = rowHeight;
    }
    
    //this is bound to happen! Users will enter a rowHeight that is the same as the titleHeight and
    //provide a description. In this case, it won't work because the title will cover the description.
    //ignore their settings in the case so they can see what they did and force them to adjust.
    if(titleHeight == rowHeight && [descriptionText length] > 0){
        titleHeight = (rowHeight / 2);
        descriptionHeight	 = (rowHeight / 2);
    }
    
        //text
        int labelLeft = (cellImageView.frame.size.width + 12);
        int labelWidth = self.contentView.frame.size.width - labelLeft-12;
        
        [titleLabel setFrame:CGRectMake(labelLeft, 0, labelWidth, titleHeight)];
        [descriptionLabel setFrame:CGRectMake(labelLeft, titleHeight - 5, labelWidth, descriptionHeight)];
        if (descriptionText.length<1) titleLabel.frame = CGRectMake(labelLeft, (65-titleHeight)/2, labelWidth, titleHeight);
    
    
    //set date
    cellImageView.day = [[BT_strings getJsonPropertyValue:theMenuItemData.jsonVars nameOfProperty:@"day" defaultValue:@"0"] intValue];
    cellImageView.month = [[BT_strings getJsonPropertyValue:theMenuItemData.jsonVars nameOfProperty:@"month" defaultValue:@"1"] intValue];
    [cellImageView configureView];
    
    //set title
    [titleLabel setTextColor:titleFontColor];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:titleFontSize]];
    [titleLabel setText:titleText];
    [titleLabel setOpaque:FALSE];
    
    //set description
    [descriptionLabel setTextColor:descriptionFontColor];
    [descriptionLabel setFont:[UIFont systemFontOfSize:descriptionFontSize]];
    [descriptionLabel setText:descriptionText];
    [descriptionLabel setOpaque:FALSE];
    
    //cell selection style: Blue, Gray, None
    if([rowSelectionStyle rangeOfString:@"blue" options:NSCaseInsensitiveSearch].location != NSNotFound){
        [self setSelectionStyle:UITableViewCellSelectionStyleBlue];
    }
    if([rowSelectionStyle rangeOfString:@"gray" options:NSCaseInsensitiveSearch].location != NSNotFound){
        [self setSelectionStyle:UITableViewCellSelectionStyleGray];
    }
    if([rowSelectionStyle rangeOfString:@"none" options:NSCaseInsensitiveSearch].location != NSNotFound){
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    //chevron indicator: DisclosureButton, DetailDisclosureButton, Checkmark, None
    if([rowAccessoryType rangeOfString:@"arrow" options:NSCaseInsensitiveSearch].location != NSNotFound){
        [self setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
    }
    if([rowAccessoryType rangeOfString:@"details" options:NSCaseInsensitiveSearch].location != NSNotFound){
        [self setAccessoryType: UITableViewCellAccessoryDetailDisclosureButton];
    }
    if([rowAccessoryType rangeOfString:@"checkmark" options:NSCaseInsensitiveSearch].location != NSNotFound){
        [self setAccessoryType: UITableViewCellAccessoryCheckmark];
    }
    if([rowAccessoryType rangeOfString:@"none" options:NSCaseInsensitiveSearch].location != NSNotFound){
        [self setAccessoryType: UITableViewCellAccessoryNone];
    }
    
}


@end

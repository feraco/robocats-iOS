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

#import "CR_calendarIconView.h"

@interface CR_calendarIconView()

@end

@implementation CR_calendarIconView
@synthesize dateView,dayLabel,monthLabel,rowHeight,month,day;
-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    rowHeight = 50;
    
    dateView = [UIView new];
    dateView.frame = CGRectMake(5, (65-rowHeight)/2, rowHeight, rowHeight);
    [self addSubview:dateView];
    
    dayLabel = [UILabel new];
    dayLabel.frame = CGRectMake(0, 0, rowHeight, rowHeight-20);
    [dateView addSubview:dayLabel];
    
    monthLabel = [UILabel new];
    monthLabel.frame = CGRectMake(0, rowHeight-20, rowHeight, 20);
    [dateView addSubview:monthLabel];

    
    return self;
}

-(void)configureView {
    dateView.frame = CGRectMake(5, 5, rowHeight-10, rowHeight-10);
    monthLabel.frame = CGRectMake(0, 0, rowHeight-10, 16);
    dayLabel.frame = CGRectMake(0, rowHeight-29, rowHeight-10, rowHeight-36);
    
    

    dayLabel.text = [NSString stringWithFormat:@"%i",day];
    dayLabel.font = [UIFont systemFontOfSize:20];
    dayLabel.textAlignment = NSTextAlignmentCenter;
    dayLabel.adjustsFontSizeToFitWidth = true;
    
    monthLabel.text = [self monthStringFromInt:month];
    monthLabel.font = [UIFont systemFontOfSize:12];
    monthLabel.textAlignment = NSTextAlignmentCenter;
    monthLabel.adjustsFontSizeToFitWidth = true;
    monthLabel.backgroundColor = [UIColor redColor];
    
    dateView.layer.borderWidth = 1;
    dateView.layer.borderColor = [UIColor blackColor].CGColor;
    dateView.layer.cornerRadius = 2;
    
    self.frame = CGRectMake(5, (65-rowHeight)/2, rowHeight, rowHeight);
}

-(NSString*)monthStringFromInt:(int)_month {
    NSString *theMonth = @"";
    switch (_month) {
        case 1:
            theMonth = @"Jan";
            break;
        case 2:
            theMonth = @"Feb";
            break;
        case 3:
            theMonth = @"Mar";
            break;
        case 4:
            theMonth = @"Apr";
            break;
        case 5:
            theMonth = @"May";
            break;
        case 6:
            theMonth = @"June";
            break;
        case 7:
            theMonth = @"July";
            break;
        case 8:
            theMonth = @"Aug";
            break;
        case 9:
            theMonth = @"Sept";
            break;
        case 10:
            theMonth = @"Oct";
            break;
        case 11:
            theMonth = @"Nov";
            break;
        case 12:
            theMonth = @"Dec";
            break;
        default:
            break;
    }
    return theMonth;
}


@end

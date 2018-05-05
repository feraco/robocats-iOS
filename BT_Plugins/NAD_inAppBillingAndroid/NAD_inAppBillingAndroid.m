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


#import "NAD_inAppBillingAndroid.h"
#import "NAD_RMStore.h"
#import "NAD_iapItem.h"


typedef void (^AnimationBlock)();


// for private member var productID
@interface NAD_inAppBillingAndroid ()

@property (nonatomic, strong) NSString *productID;

@property (nonatomic) BOOL vDidLoad;



@end

@implementation NAD_inAppBillingAndroid


@synthesize titleTextPrior = _titleTextPrior;
@synthesize titleTextSizePrior = _titleTextSizePrior;
@synthesize titleTextColorPrior = _titleTextColorPrior;
@synthesize titleBackgroundColorPrior = _titleBackgroundColorPrior;
@synthesize imageNamePrior = _imageNamePrior;
@synthesize textBoxPrior = _textBoxPrior;
@synthesize textBoxTextSizePrior = _textBoxTextSizePrior;
@synthesize textBoxTextSizeLargePrior = _textBoxTextSizeLargePrior;
@synthesize textBoxtTextColorPrior = _textBoxTextColorPrior;
@synthesize textBoxBackgroundColorPrior = _textBoxBackgroundColorPrior;
@synthesize purchaseButtonTextPrior = _purchaseButtonTextPrior;
@synthesize purchaseButtonTextSizePrior = _purchaseButtonTextSizePrior;
@synthesize purchaseButtonTextColorPrior = _purchaseButtonTextColorPrior;
@synthesize purchaseButtonBackgroundColorPrior = _purchaseButtonBackgroundColorPrior;

@synthesize titleTextAfter = _titleTextAfter;
@synthesize titleTextSizeAfter = _titleTextSizeAfter;
@synthesize titleTextColorAfter = _titleTextColorAfter;
@synthesize titleBackgroundColorAfter = _titleBackgroundColorAfter;
@synthesize imageNameAfter = _imageNameAfter;
@synthesize textBoxAfter = _textBoxAfter;
@synthesize textBoxTextSizeAfer = _textBoxTextSizeAfter;
@synthesize textBoxTextSizeLargeAfter = _textBoxTextSizeLargeAfter;
@synthesize textBoxTextColorAfter = _textBoxTextColorAfter;
@synthesize textBoxBackgroundColorAfter = _textBoxBackgroundColorAfter;
@synthesize continueButtonTextAfter = _continueButtonTextAfter;
@synthesize continueButtonTextSizeAfter = _continueButtonTextSizeAfter;
@synthesize continueButtonTextColorAfter = _continueButtonTextColorAfter;
@synthesize continueButtonBackgroundColorAfter = _continueButtonBackgroundColorAfter;

@synthesize unlockScreenNickname = _unlockScreenNickname;
@synthesize unlockScreenItemId = _unlockScreenItemId;

@synthesize restoreButtonText = _restoreButtonText;
@synthesize restoreButtonTextSize = _restoreButtonTextSize;
@synthesize restoreButtonTextColor = _restoreButtonTextColor;
@synthesize restoreButtonBackgroundColor = _restoreButtonBackgroundColor;

@synthesize backgroundColor = _backgroundColor;

@synthesize titleLabel = _titleLabel;
@synthesize titleImage = _titleImage;
@synthesize titleImageView = _titleImageView;
@synthesize textBox = _textBox;
@synthesize purchaseButton = _purchaseButton;
@synthesize purchaseButtonLabel = _purchaseButtonLabel;
@synthesize restoreButton = _restoreButton;
@synthesize restoreButtonLabel = _restoreButtonLabel;
@synthesize continueButton = _continueButton;
@synthesize continueButtonLabel = _continueButtonLabel;


@synthesize innerLabel = _innerLabel;

@synthesize scrollView = _scrollView;
@synthesize innerView = _innerView;


@synthesize productID = _productID;


@synthesize vDidLoad = _vDidLoad;

//OVERRIDE
-(void)viewDidLoad{
	[BT_debugger showIt:self theMessage:@"viewDidLoad"];
	[super viewDidLoad];

    //[RMStore defaultStore];
    
    _productID = [[NSString alloc] init];
    _productID = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"iab_sku" defaultValue:@""];
    
    NSLog(@"productID : %@", _productID);
    
    
    _unlockScreenNickname = [[NSString alloc] init];
    
    _titleLabel = [[UILabel alloc] init];
    _titleImage = [[UIImage alloc] init];
    
    //_imageNamePrior = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"imageNamePrior" defaultValue:@""];
    
   // _titleImage = [UIImage imageNamed:_imageNamePrior];
    _titleImageView = [[UIImageView alloc] init];
    
    
    _textBox = [[UIView alloc] init];
    _purchaseButton = [[UIButton alloc] init];
    _purchaseButtonLabel = [[UILabel alloc] init];
    _restoreButton  = [[UIButton alloc] init];
    _restoreButtonLabel = [[UILabel alloc] init];
    _continueButton = [[UIButton alloc] init];
    _continueButtonLabel = [[UILabel alloc] init];
   _scrollView = [[UIScrollView alloc] init];
    _innerView = [[UIView alloc] init];
    _innerLabel = [[UILabel alloc] init];
    
    
    
    _scrollView.showsVerticalScrollIndicator = YES;
    
    [self.view addSubview:_scrollView];
    [_scrollView addSubview:_innerView];
    [_innerView addSubview:_titleLabel];
    [_innerView addSubview:_titleImageView];
    [_innerView addSubview:_textBox];
    [_textBox addSubview:_innerLabel];
    [_innerView addSubview:_purchaseButton];
    [_purchaseButton addSubview:_purchaseButtonLabel];
    [_innerView addSubview:_restoreButton];
    [_restoreButton addSubview:_restoreButtonLabel];
    
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    _innerView.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _textBox.translatesAutoresizingMaskIntoConstraints = NO;
    _purchaseButton.translatesAutoresizingMaskIntoConstraints = NO;
    _purchaseButtonLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _restoreButton.translatesAutoresizingMaskIntoConstraints = NO;
    _restoreButtonLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _continueButton.translatesAutoresizingMaskIntoConstraints = NO;
    _continueButtonLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _innerLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    //NSTextAlignmentLeft
    [_titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_purchaseButtonLabel setTextAlignment:NSTextAlignmentCenter];
    [_restoreButtonLabel setTextAlignment:NSTextAlignmentCenter];
    [_continueButtonLabel setTextAlignment:NSTextAlignmentCenter];

    _titleLabel.layer.cornerRadius = 3;
 
    _titleLabel.layer.masksToBounds = YES;
    _titleLabel.numberOfLines = 0;
    _titleImageView.layer.cornerRadius = 3;
    _titleImageView.layer.masksToBounds = YES;
    _textBox.layer.cornerRadius =3;
    _textBox.layer.masksToBounds = YES;
    
    _innerLabel.layer.cornerRadius = 3;
    _innerLabel.layer.masksToBounds = YES;
    _innerLabel.numberOfLines = 0;
    
    //_innerLabel.alpha = 1;
    
    _purchaseButton.layer.cornerRadius = 14;
    _purchaseButton.layer.masksToBounds = YES;
    _restoreButton.layer.cornerRadius = 14;
    _restoreButton.layer.masksToBounds = YES;
    _continueButton.layer.cornerRadius =14;
    _continueButton.layer.masksToBounds = YES;
    
//        [_emailButton addTarget:self action:@selector(emailScore) forControlEvents:UIControlEventTouchUpInside];
    
    
    [_purchaseButton addTarget:self action:@selector(purchaseButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [_restoreButton addTarget:self action:@selector(restoreButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [_continueButton addTarget:self action:@selector(loadNewScreen) forControlEvents:UIControlEventTouchUpInside];
    
    _vDidLoad = TRUE;
    
    
    [self getBTVars];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [super willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration];
    
    [self updateViewConstraints];
}





// OVERRIDE
-(void)updateViewConstraints {
    [super updateViewConstraints];
    
    // clear old constraints
    //[self.view removeConstraints:self.view.constraints];
    
    NSLayoutConstraint *constraint;

    constraint = [NSLayoutConstraint
				  constraintWithItem:_titleImageView
				  attribute:NSLayoutAttributeCenterX
				  relatedBy:NSLayoutRelationEqual
				  toItem:self.view
				  attribute:NSLayoutAttributeCenterX
				  multiplier:1.0f
				  constant:0];
	
	[self.view addConstraint:constraint];
    
   constraint = [NSLayoutConstraint
                 constraintWithItem:_innerView
                 attribute:NSLayoutAttributeLeading
                 relatedBy:0
                 toItem:self.view
                 attribute:NSLayoutAttributeLeft
                 multiplier:1.0
                 constant:0];
    
    [self.view addConstraint:constraint];
    
   constraint = [NSLayoutConstraint
                 constraintWithItem:_innerView
                 attribute:NSLayoutAttributeTrailing
                 relatedBy:0
                 toItem:self.view
                 attribute:NSLayoutAttributeRight
                 multiplier:1.0
                 constant:0];
    
    [self.view addConstraint:constraint];
    
  
    //  set constraints
	NSDictionary *viewsDictionary =
	NSDictionaryOfVariableBindings(_scrollView, _innerView, _titleLabel, _titleImageView, _textBox, _innerLabel, _purchaseButton, _restoreButton, _continueButton ,_continueButtonLabel, _purchaseButtonLabel, _restoreButtonLabel);
    
    
	[self.view addConstraints:[NSLayoutConstraint
							   constraintsWithVisualFormat:@"H:|[_scrollView]|"
							   options:0
							   metrics:0
							   views:viewsDictionary]];
	
	[self.view addConstraints:[NSLayoutConstraint
							   constraintsWithVisualFormat:@"V:|[_scrollView]|"
							   options:0
							   metrics:0
							   views:viewsDictionary]];
    
//    [self.view addConstraints:[NSLayoutConstraint
//							   constraintsWithVisualFormat:@"H:|[_innerView]|"
//							   options:0
//							   metrics:0
//							   views:viewsDictionary]];
	
	[self.view addConstraints:[NSLayoutConstraint
							   constraintsWithVisualFormat:@"V:|[_innerView]|"
							   options:0
							   metrics:0
							   views:viewsDictionary]];
    if(_purchaseButton.superview !=nil) {
        
        [self.view addConstraints:[NSLayoutConstraint
							   constraintsWithVisualFormat:@"H:|[_purchaseButtonLabel]|"
							   options:0
							   metrics:0
							   views:viewsDictionary]];
	
        [self.view addConstraints:[NSLayoutConstraint
							   constraintsWithVisualFormat:@"V:|[_purchaseButtonLabel]|"
							   options:0
							   metrics:0
							   views:viewsDictionary]];
    }
    
    if(_restoreButton.superview != nil) {
    
        [self.view addConstraints:[NSLayoutConstraint
							   constraintsWithVisualFormat:@"H:|[_restoreButtonLabel]|"
							   options:0
							   metrics:0
							   views:viewsDictionary]];
	
        [self.view addConstraints:[NSLayoutConstraint
							   constraintsWithVisualFormat:@"V:|[_restoreButtonLabel]|"
							   options:0
							   metrics:0
							   views:viewsDictionary]];
    }
    
    //
    if(_continueButtonLabel.superview != nil) {
        
    
        [self.view addConstraints:[NSLayoutConstraint
							   constraintsWithVisualFormat:@"H:|[_continueButtonLabel]|"
							   options:0
							   metrics:0
							   views:viewsDictionary]];
	
        [self.view addConstraints:[NSLayoutConstraint
							   constraintsWithVisualFormat:@"V:|[_continueButtonLabel]|"
							   options:0
							   metrics:0
							   views:viewsDictionary]];
    
    }
    
    //
    
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-[_titleLabel]-|"
                               options:0
                               metrics:0
                               views:viewsDictionary]];
    
//    [self.view addConstraints:[NSLayoutConstraint
//                               constraintsWithVisualFormat:@"H:|-[_titleImageView]-|"
//                               options:0
//                               metrics:0
//                               views:viewsDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-[_textBox]-|"
                               options:0
                               metrics:0
                               views:viewsDictionary]];
    
    
    [_textBox addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-[_innerLabel]-|"
                               options:0
                               metrics:0
                               views:viewsDictionary]];
    
    [_textBox addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:|-5-[_innerLabel]-5-|"
                               options:0
                               metrics:0
                               views:viewsDictionary]];
    
    
    if(_purchaseButton.superview !=nil) {
        
    
        [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-[_purchaseButton]-|"
                               options:0
                               metrics:0
                               views:viewsDictionary]];
    
        [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-[_restoreButton]-|"
                               options:0
                               metrics:0
                               views:viewsDictionary]];

        [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:|-[_titleLabel(>=30)]-[_titleImageView]-[_textBox(>=30)]-[_purchaseButton]-[_restoreButton]-|"
                               options:0
                               metrics:0
                               views:viewsDictionary]];
    }
    
    if(_continueButton.superview != nil) {
        
        [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:@"H:|-[_continueButton]-|"
                                   options:0
                                   metrics:0
                                   views:viewsDictionary]];
    
        [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:@"V:|-[_titleLabel(>=30)]-[_titleImageView]-[_textBox(>=30)]-[_continueButton]-|"
                                   options:0
                                   metrics:0
                                   views:viewsDictionary]];
    }
    
    
}

//OVERRIDE
-(void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];


    
}


//OVERRIDE
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
    
    
    NSData *purchaseData = [[NSUserDefaults standardUserDefaults] objectForKey:_productID];
    
    NAD_iapItem *purchaseItem = [NSKeyedUnarchiver unarchiveObjectWithData:purchaseData];
    
    if (purchaseItem.purchased) {
        
        NSLog(@"purchase item retrieved");
        
        if(_vDidLoad){
        
            [self transitionScreenElementsWithNewScreen];
            _vDidLoad = FALSE;
        
        }else{
            
            [self setUpAfterPurchaseScreen];
            
        }
        
    }else{
        NSLog(@"no purchase item to retrieve");
        
        // get product info from apple
        NSSet *products = [NSSet setWithArray:@[_productID]];
        
        [[RMStore defaultStore] requestProducts:products ];
        
        //[self getBTVars];
    }
    
    _vDidLoad = FALSE;
    
}



-(void)getBTVars{
    
    robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    _titleTextPrior = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"titleTextPrior" defaultValue:@"Make Purchase"];
    
    [_titleLabel setText:_titleTextPrior];
    
    _titleTextSizePrior = [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"titleTextSizePrior" defaultValue:@"13"] integerValue];
    
    [_titleLabel setFont:[UIFont boldSystemFontOfSize:_titleTextSizePrior]];
    
    _titleTextColorPrior = [BT_color getColorFromHexString:[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"titleTextColorPrior" defaultValue:@"#000000"]];
    
    [_titleLabel setTextColor:_titleTextColorPrior];
    
    
    _titleBackgroundColorPrior = [BT_color getColorFromHexString:[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"titleBackgroundColorPrior" defaultValue:@"#FFFFFF"]];
    
    [_titleLabel setBackgroundColor:_titleBackgroundColorPrior];
    
    _imageNamePrior = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"imageNamePrior" defaultValue:@""];
   
    if(_imageNamePrior.length >1){
       _titleImage = [UIImage imageNamed:_imageNamePrior];
        [_titleImageView setImage:_titleImage];
    }
    
    _textBoxPrior = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"textBoxPrior" defaultValue:@""];
    
    //[_textBox setText:_textBoxPrior];
    [_innerLabel setText:_textBoxPrior];
    
    _textBoxTextSizePrior = [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"textBoxTextSizePrior" defaultValue:@"13"] integerValue];
    
    [_innerLabel setFont:[UIFont boldSystemFontOfSize:_titleTextSizePrior]];

    
    
    _textBoxTextSizeLargePrior = [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"textBoxTextSizeLargePrior" defaultValue:@"16"] integerValue];
    
    
    if([appDelegate.rootDevice isIPad]) {
        
        
        [_innerLabel setFont:[UIFont boldSystemFontOfSize:_textBoxTextSizeLargePrior]];
        
    }
    
    
    _textBoxTextColorPrior = [BT_color getColorFromHexString:[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"textBoxTextColorPrior" defaultValue:@"#000000"]];
    
    [_innerLabel setTextColor:_textBoxTextColorPrior];
    
    _textBoxBackgroundColorPrior = [BT_color getColorFromHexString:[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"textBoxBackgroundColorPrior" defaultValue:@"#FFFFFF"]];
    
    [_textBox setBackgroundColor:_textBoxBackgroundColorPrior];
    [_innerLabel setBackgroundColor:_textBoxBackgroundColorPrior];

    _purchaseButtonTextPrior = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"purchaseButtonTextPrior" defaultValue:@"Make Purchase"] ;
    
    [_purchaseButtonLabel setText:_purchaseButtonTextPrior];
    
    _purchaseButtonTextSizePrior = [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"purchaseButtonTextSizePrior" defaultValue:@"15"] integerValue];
    
    [_purchaseButtonLabel setFont:[UIFont boldSystemFontOfSize:_purchaseButtonTextSizePrior]];
   
    
    _purchaseButtonTextColorPrior = [BT_color getColorFromHexString:[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"purchaseButtonTextColorPrior" defaultValue:@"#000000"]];
    
    [_purchaseButtonLabel setTextColor:_purchaseButtonTextColorPrior];
    
    
    _purchaseButtonBackgroundColorPrior = [BT_color getColorFromHexString:[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"purchaseButtonBackgroundColorPrior" defaultValue:@"#FFFFFF"]];

    [_purchaseButtonLabel setBackgroundColor:_purchaseButtonBackgroundColorPrior];
    
    _titleTextAfter = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"titleTextAfter" defaultValue:@"Purchased"];
    
    
    
    _titleTextSizeAfter =  [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"titleTextSizeAfter" defaultValue:@"15"] integerValue];
    
    
    
    _titleTextColorAfter = [BT_color getColorFromHexString:[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"titleTextColorAfter" defaultValue:@"#000000"]];
    
    
    
    _titleBackgroundColorAfter = [BT_color getColorFromHexString:[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"titleBackgroundColorAfter" defaultValue:@"#FFFFFF"]];
    
    
    
    _imageNameAfter = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"imageNameAfter" defaultValue:@""];
    
    
    
    _textBoxAfter = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"textBoxAfter" defaultValue:@""];
    
    
    
    _textBoxTextSizeAfter = [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"textBoxTextSizeAfter" defaultValue:@"15"] integerValue];
    
    
    
    _textBoxTextSizeLargeAfter =  [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"textBoxTextSizeLargeAfter" defaultValue:@"15"] integerValue];
    
    
    
    _textBoxTextColorAfter = [BT_color getColorFromHexString:[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"textBoxTextColorAfter" defaultValue:@"#000000"]];
    
    
    
    _textBoxBackgroundColorAfter = [BT_color getColorFromHexString:[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"textBoxBackgroundColorAfter" defaultValue:@"#FFFFFF"]];
    
    
    
    _continueButtonTextAfter = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"continueButtonTextAfter" defaultValue:@""];
    
    [_continueButtonLabel setText:_continueButtonTextAfter];
    
    _continueButtonTextSizeAfter = [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"continueButtonTextSizeAfter" defaultValue:@"15"] integerValue];
    
       //[_titleLabel setFont:[UIFont boldSystemFontOfSize:_titleTextSizePrior]];
    [_continueButtonLabel setFont:[UIFont boldSystemFontOfSize:_continueButtonTextSizeAfter]];
     
    
    
    _continueButtonTextColorAfter = [BT_color getColorFromHexString:[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"continueButtonTextColorAfter" defaultValue:@"#000000"]];
    
    [_continueButtonLabel setTextColor:_continueButtonTextColorAfter];
    
    _continueButtonBackgroundColorAfter =  [BT_color getColorFromHexString:[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"continueButtonBackgroundColorAfter" defaultValue:@"#FFFFFF"]];
    
    
    [_continueButtonLabel setBackgroundColor:_continueButtonBackgroundColorAfter];
    
    
    _unlockScreenNickname = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"unLockScreenNickname" defaultValue:@""];
    
    
    
    _unlockScreenItemId = [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"unlockScreenItemId" defaultValue:@"15"] integerValue];
    
    
    
    _backgroundColor = [BT_color getColorFromHexString:[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"backgroundColor" defaultValue:@"#000000"]];
    
    
    
    _restoreButtonText = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"restoreButtonText" defaultValue:@""];
    
    
    [_restoreButtonLabel setText:_restoreButtonText];
    
    _restoreButtonTextSize = [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"restoreButtonTextSize" defaultValue:@"15"] integerValue];
    
    [_restoreButtonLabel setFont:[UIFont boldSystemFontOfSize:_restoreButtonTextSize]];
    
    _restoreButtonTextColor = [BT_color getColorFromHexString:[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"restoreButtonTextColor" defaultValue:@"#000000"]];
    
    [_restoreButtonLabel setTextColor:_restoreButtonTextColor];
    
     _restoreButtonBackgroundColor = [BT_color getColorFromHexString:[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"restoreButtonBackgroundColor" defaultValue:@"#000000"]];
    
    [_restoreButtonLabel setBackgroundColor:_restoreButtonBackgroundColor];
    
   // [self updateViewConstraints];
    
    [self setInitialVars];
    
    [self testBTVars];
    

    


    
    
}


-(void)setInitialVars {
    
    [_continueButton removeFromSuperview];
    [_continueButtonLabel removeFromSuperview];
    [_innerView addSubview:_purchaseButton];
    [_purchaseButton addSubview:_purchaseButtonLabel];
    [_innerView addSubview:_restoreButton];
    [_restoreButton addSubview:_restoreButtonLabel];
    [self updateViewConstraints];
    
}


-(void)testBTVars{
    
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"\ntitle text prior : %@", _titleTextPrior]];
    
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"\ntitle text Size prior : %ld", (long)_titleTextSizePrior]];
    
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"\ntitle text Color prior : %@", _titleTextColorPrior]];
    
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"\ntitle background color prior : %@", _titleBackgroundColorPrior]];
    
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"\nimage name prior : %@", _imageNamePrior]];
    
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"\ntext box prior : %@", _textBoxPrior]];
    
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"\ntext box text size prior : %ld", (long)_textBoxTextSizePrior]];
    
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"\ntext box text size large prior : %ld", (long)_textBoxTextSizeLargePrior]];
    
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"\ntext box text color prior : %@", _textBoxTextColorPrior]];
    
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"\ntext box background color prior : %@", _textBoxBackgroundColorPrior]];
    
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"\npurchase button text prior : %@", _purchaseButtonTextPrior]];

    [BT_debugger showIt:self message:[NSString stringWithFormat:@"\npurchase button text size prior : %ld", (long)_purchaseButtonTextSizePrior]];
    
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"\npurchase button text color prior : %@", _purchaseButtonTextColorPrior]];

    [BT_debugger showIt:self message:[NSString stringWithFormat:@"\npurchase button background color prior : %@", _purchaseButtonBackgroundColorPrior]];

    [BT_debugger showIt:self message:[NSString stringWithFormat:@"\ntitle text after : %@", _titleTextAfter]];
    
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"\ntitle text size after : %ld", (long)_titleTextSizeAfter]];
    
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"\ntitle text color after : %@", _titleTextColorAfter]];
    
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"\ntitle background color after : %@", _titleBackgroundColorAfter]];

    [BT_debugger showIt:self message:[NSString stringWithFormat:@"\nimage name after : %@", _imageNameAfter]];
    
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"\ntext box after : %@", _textBoxAfter]];
    
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"\ntext box text size after : %ld", (long)_textBoxTextSizeAfter]];
    
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"\ntext box text size large after : %ld", (long)_textBoxTextSizeLargeAfter]];
    
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"\ntext box text color after : %@", _textBoxTextColorAfter]];
    
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"\ntext box background color after: %@", _textBoxBackgroundColorAfter]];
    
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"\ncontinue button text after : %@", _continueButtonTextAfter]];
    
     [BT_debugger showIt:self message:[NSString stringWithFormat:@"\ncontinue button text size after : %ld", (long)_continueButtonTextSizeAfter]];
    
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"\ncontinue button text color after: %@", _continueButtonTextColorAfter]];
    
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"\ncontinue button background color after: %@", _continueButtonBackgroundColorAfter]];
    
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"\nunlock screen nickname: %@", _unlockScreenNickname]];
    
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"\nunlock screen item id : %ld", (long)_unlockScreenItemId]];
    
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"\nBackground Color: %@", _backgroundColor]];

    [BT_debugger showIt:self message:[NSString stringWithFormat:@"\nRestore button text : %@", _restoreButtonText]];

    [BT_debugger showIt:self message:[NSString stringWithFormat:@"\nRestore button text size : %ld", (long)_restoreButtonTextSize]];
    
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"\nRestore button text color : %@", _restoreButtonTextColor]];
    
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"\nRestore button background color : %@", _restoreButtonBackgroundColor]];
}



-(void)restoreButtonPressed{
    
    [[RMStore defaultStore] restoreTransactionsOnSuccess:^{
        //This is where you will run the code for whatever your IAP is restoring.
        NSLog(@"Transactions restored");
        
        NAD_iapItem *tmpItem = [[NAD_iapItem alloc] init];
        tmpItem.purchased =YES;
        tmpItem.productID = _productID;
        
        NSData *purchaseData = [NSKeyedArchiver archivedDataWithRootObject:tmpItem];
        [[NSUserDefaults standardUserDefaults] setObject:purchaseData forKey:_productID];
        [self transitionScreenElementsWithNewScreen];
        
    } failure:^(NSError *error) {
        //This code will run if the restore fails or if the user has nothing to restore
        NSLog(@"Something went wrong");
        
        
        
    }];
    
}



-(void)purchaseButtonPressed {
  
    [[RMStore defaultStore] addPayment:_productID success:^(SKPaymentTransaction *transaction) {
        NSLog(@"Purchased!");
        
//        [_persistence persistTransaction:transaction];
      //  SKPaymentTransaction *tmpTransaction = [[SKPaymentTransaction alloc] init];
        
        //tmpTransaction = transaction;
        
        NAD_iapItem *tmpItem = [[NAD_iapItem alloc] init];
        tmpItem.purchased =YES;
        tmpItem.productID = _productID;
        
        NSData *purchaseData = [NSKeyedArchiver archivedDataWithRootObject:tmpItem];
        
        [[NSUserDefaults standardUserDefaults] setObject:purchaseData forKey:_productID];
        
        
        [self transitionScreenElementsWithNewScreen];
        
       
        
        //[self loadScreenWithNickname:_unlockScreenNickname];
        
    } failure:^(SKPaymentTransaction *transaction, NSError *error) {
        NSLog(@"Something went wrong");
    }];
    
    
}

-(void)transitionScreenElements {
    
    AnimationBlock fadeOutAnimation = ^{
        [self fadeOut];
    };
    
    
    AnimationBlock fadeInAnimation = ^{
        [self fadeIn];
    };
    
    [UIView animateWithDuration:0.7 animations:fadeOutAnimation completion:^(BOOL finished) {
        
        [self setUpAfterPurchaseScreen];
        
        [UIView animateWithDuration:0.7 animations:fadeInAnimation];

    }];
    
}

-(void)transitionScreenElementsWithNewScreen {
    
    AnimationBlock fadeOutAnimation = ^{
        [self fadeOut];
    };
    
    
    AnimationBlock fadeInAnimation = ^{
        [self fadeIn];
    };
    
    [UIView animateWithDuration:0.7 animations:fadeOutAnimation completion:^(BOOL finished) {
        
        [self setUpAfterPurchaseScreen];
        
        [UIView animateWithDuration:0.7 animations:fadeInAnimation completion:^(BOOL finished) {
            
            [self loadNewScreen];
            
        }];
    }];
  
}

-(void)setUpAfterPurchaseScreen {
    
    robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
    
    [_purchaseButton removeFromSuperview];
    [_restoreButton removeFromSuperview];
    
    [_innerView addSubview:_continueButton];
    [_continueButton addSubview:_continueButtonLabel];
    
    [_titleLabel setText:_titleTextAfter]; 
    
    [_titleLabel setFont:[UIFont boldSystemFontOfSize:_titleTextSizeAfter]];
    
    [_titleLabel setTextColor:_titleTextColorAfter];
    
    [_titleLabel setBackgroundColor:_titleBackgroundColorAfter];
    
    if(_imageNameAfter.length >1) {
        _titleImage = [UIImage imageNamed:_imageNameAfter];
        [_titleImageView setImage:_titleImage];
        
    }
    
    //[_textBox setText:_textBoxAfter];
    [_innerLabel setText:_textBoxAfter];
    
    [_innerLabel setFont:[UIFont boldSystemFontOfSize:_titleTextSizeAfter]];
    
    _textBoxTextSizeLargePrior = [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"textBoxTextSizeLargePrior" defaultValue:@"16"] integerValue];
    
    
    if([appDelegate.rootDevice isIPad]) {
        
        
        [_innerLabel setFont:[UIFont boldSystemFontOfSize:_textBoxTextSizeLargeAfter]];
        
    }
    
    [_innerLabel setTextColor:_textBoxTextColorAfter];
    
    [_textBox setBackgroundColor:_textBoxBackgroundColorAfter];
    [_innerLabel setBackgroundColor:_textBoxBackgroundColorAfter];
    
    
   // _purchaseButtonTextPrior = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"purchaseButtonTextPrior" defaultValue:@"Make Purchase"] ;
    
    //[_purchaseButtonLabel setText:_purchaseButtonTextPrior];
    
    //_purchaseButtonTextSizePrior = [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"purchaseButtonTextSizePrior" defaultValue:@"15"] integerValue];
    
    //[_purchaseButtonLabel setFont:[UIFont boldSystemFontOfSize:_purchaseButtonTextSizePrior]];
    
    
    //_purchaseButtonTextColorPrior = [BT_color getColorFromHexString:[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"purchaseButtonTextColorPrior" defaultValue:@"#000000"]];
    
   // [_purchaseButtonLabel setTextColor:_purchaseButtonTextColorPrior];
    
    
   // _purchaseButtonBackgroundColorPrior = [BT_color getColorFromHexString:[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"purchaseButtonBackgroundColorPrior" defaultValue:@"#FFFFFF"]];
    
   // [_purchaseButtonLabel setBackgroundColor:_purchaseButtonBackgroundColorPrior];
    
    
    [self updateViewConstraints];
    
}

-(void)fadeOut {
    
    _scrollView.alpha = 0.0;
    
    
}

-(void)fadeIn {
    
    _scrollView.alpha =1.0;
    
}

-(void)loadNewScreen {
    
    robocats_appDelegate *appDelegate = (robocats_appDelegate *)[[UIApplication sharedApplication] delegate];
    
    BT_item *screenObjectToLoad = nil;
    
    screenObjectToLoad = [appDelegate.rootApp getScreenDataByNickname:_unlockScreenNickname];
    
    //build a temp menu-item to pass to screen load method. We need this because the transition type is in the menu-item
    BT_item *tmpMenuItem = [[BT_item alloc] init];
    
    //build an NSDictionary of values for the jsonVars property
    // SETS the transitionType
    NSDictionary *tmpDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"unused",
                                   @"itemId",
                                   @"fade",
                                   @"transitionType",
                                   nil];
    [tmpMenuItem setJsonVars:tmpDictionary];
    [tmpMenuItem setItemId:@"0"];
    
    //load the next screen
    [self handleTapToLoadScreen:screenObjectToLoad theMenuItemData:tmpMenuItem];
    

}




@end








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


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "BT_item.h"


@interface BT_audioPlayer : UIViewController <AVAudioPlayerDelegate>{
    
}


@property (nonatomic, strong) BT_item *screenData;
@property (nonatomic, strong) UIButton *buttonStartStop;
@property (nonatomic, strong) UISlider *audioSlider;
@property (nonatomic, strong) UISlider *volumeSlider;
@property (nonatomic, strong) UILabel *audioTimerLabel;	
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) UILabel *audioStatusLabel;	
@property (nonatomic, strong) UILabel *audioDurationLabel;	
@property (nonatomic, strong) UILabel *volumeHighLabel;	
@property (nonatomic, strong) UILabel *volumeLowLabel;	
@property (nonatomic, strong) NSTimer *audioPlaybackTimer;
@property (nonatomic, strong) NSTimer *audioFadeOutTimer;
@property (nonatomic, strong) NSString *audioFileName;
@property (nonatomic, strong) NSString *audioFileURL;
@property (nonatomic) BOOL audioIsPlaying;
@property (nonatomic) BOOL audioStartOnLoad;
@property (nonatomic) int audioNumberOfLoops;
@property (nonatomic) float currentVolume;
@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, strong) NSURLConnection *remoteConn;	
@property (nonatomic) int expectedDownloadSize;

-(id)initWithScreenData:(BT_item*)theScreenData;
-(void)loadAudioForScreen:(BT_item *)theScreenData;
-(void)updateStatusLabel:(NSString *)theString;
-(void)updateTimerLabel:(NSString *)theString;
-(void)initAudioPlayerWithLocalURL:(NSString *)theURLinFileSystem;
-(void)toggleAudio;
-(void)startAudio;
-(void)stopAudio;
-(void)hideAudioPlayer;
-(void)downloadAudioFile:(NSString *)theURL;
-(void)updateAudioTimer:(NSTimer *)timer;
-(void)audioSliderChanged:(UISlider *)sender;
-(void)volumeSliderChanged:(UISlider *)sender;
-(void)startAudioTimer;
-(void)stopAudioTimer;
-(void)turnOnControls;
-(void)turnOffControls;

@end



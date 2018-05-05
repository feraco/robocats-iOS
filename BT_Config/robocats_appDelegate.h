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


#import "BT_audioPlayer.h"
#import "BT_contextMenu.h"
#import "BT_reachability.h"
#import "BT_application.h"
#import "BT_device.h"
#import "BT_downloader.h"
#import "BT_user.h"
#import "BT_viewController.h"
#import "BT_navController.h"
#import "BT_tabBarController.h"


@interface robocats_appDelegate : NSObject <UIApplicationDelegate,
UITabBarControllerDelegate,
AVAudioPlayerDelegate,
UIAlertViewDelegate>{
    
}

@property (nonatomic) int statusBarStyle;
@property (nonatomic, strong) NSString *navBarTitleTextColor;
@property (nonatomic) BOOL showDebugInfo;
@property (nonatomic, strong) UIWindow *window;

@property (nonatomic, strong) BT_reachability *rootNetworkMonitor;
@property (nonatomic, strong) BT_locationManager *rootLocationMonitor;
@property (nonatomic, strong) BT_application *rootApp;
@property (nonatomic, strong) BT_device *rootDevice;
@property (nonatomic, strong) BT_user *rootUser;
@property (nonatomic, strong) NSString *currentMode;
@property (nonatomic, assign) BOOL uiIsVisible;
@property (nonatomic, assign) BOOL isRefreshing;
@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, strong) NSString *configurationFileName;
@property (nonatomic, strong) NSString *saveAsFileName;
@property (nonatomic, strong) NSString *modifiedFileName;
@property (nonatomic, strong) BT_audioPlayer *audioPlayer;
@property (nonatomic, strong) NSMutableArray *soundEffectNames;
@property (nonatomic, strong) NSMutableArray *soundEffectPlayers;
@property (nonatomic, strong) BT_contextMenu *contextMenu;


//launch methods..
-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
-(void)applicationDidBecomeActive:(UIApplication *)application;
-(void)applicationWillTerminate:(UIApplication *)application;
-(void)applicationWillResignActive:(UIApplication *)application;
-(void)applicationDidEnterBackground:(UIApplication *)application;
-(void)applicationWillEnterForeground:(UIApplication *)application;

//data methods...
-(void)refreshAppData;
-(void)reportToCloud;
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
-(void)connectionDidFinishLoading:(NSURLConnection *)connection;

//background audio methods...
-(void)loadAudioForScreen:(BT_item *)theScreenData;
-(void)showAudioControls;
-(void)hideAudioControls;
-(void)playSoundEffect:(NSString *)theFileName;

//push notification methods...
-(void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken;
-(void)unRegisterForPushNotifications;
-(void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error;
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;
-(void)playSoundFromPushMessage:(NSString *)soundEffectFileName;

//helper methods...
-(BT_navController *)getNavigationController;
-(BT_viewController *)getViewController;
-(void)networkTypeChanged:(NSNotification*)note;
-(void)showAlert:(NSString *)theTitle theMessage:(NSString *)theMessage alertTag:(int)alertTag;
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
-(void)showContextMenu;
-(void)hideContextMenu;

//orientation methods...
-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window;

@end














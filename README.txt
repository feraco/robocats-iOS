
buzztouch v3.0 for iOS
----------------------

Getting Started - YOU MUST HAVE XCODE TO USE THIS SOFTWARE. 7.0 is the latest release, older
releases may work. You also need the latest iOS Software Developer Kit. iOS 9.0 is the
latest release.

You should have downloaded a .zip archive containing an Xcode project and multiple folders.
See the instructions.pdf file included with this download for details about how to compile
this app's source code and run it on the simulator.

BUILD SETTINGS:

When you download the project and unzip the archive you should NOT have to change any build settings
or project properties to run your app on the simulator. 

TO RUN YOUR APP IN THE SIMULATOR: 
	You should not have to make any changes to the project's build settings to build-and-run in the iOS
	simulator. If Xcode (the compiler) shows warnings or errors and prevents you from running your app
	in the simulator something isn't right. It's assumed that you're running the latest iOS SDK in the
	latest Xcode version. Older versions can be used but some changes to the project properties and
	build settings are required. The necessary changes depend on what version of Xcode you're using. 
	
TO RUN YOUR APP ON A DEVICE:
	You need to have an iOS Developer Account at Apple to install your app on your device. After creating
	a Provisioning Profile for your app (this is done in the iOS Developer Center), drag it into Xcode then
	set it in the Provisioning Profile section of your apps build settings. 
	
	 
PROJECT PROPERTIES:
	The following project properties are provided in this README.txt file for reference. These are some
	important settings your project download came with. If they are different in Xcode then you've changed 
	something :-) There are dozens and dozens of other build settings, these are some common ones.
	
	GENERAL 
		--Deployment Target							5.0 (changing this will produce lots of warnings)
		--Devices										Universal
		
	BUILD SETTINGS	
		--Build Active Architecture Only			Set to NO for Debug and Release
		--Base SDK									Latest iOS (iOS 8.1)
		--Valid Architectures						arm64 armsv7 armsv7s
		--Code Signing Identity						Don't code sign
		--Provisioning Profile						Automatic
		--Targeted Device Family					iPhone/iPad
		--iOS Deployment Target						iOS7	
		--Objective C Automatic Reference Counting	YES




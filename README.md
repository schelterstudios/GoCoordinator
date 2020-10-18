# GoCoordinator
(Super) early build of GoCoordinator.

# Installation
 To add to your project, insert the following into your Podfile:  
`pod 'GoCoordinator', :git => 'https://github.com/schelterstudios/GoCoordinator.git'`

# Creating a new app with GoCoordinator
While the true strength of GoCoordinator is its extensibility, you can still reach a working demo with just a few steps. Try this guide to familiarize yourself with the setup.

To begin, let's create a new app using the iOS App template:
![Select App Template](/images/setup1.png)

Next, set your options to Storyboard and UIKit:
![New Project Options](/images/setup2.png)

Now that the project files are in place, add the GoCoordinator framework using the [installation](https://github.com/schelterstudios/GoCoordinator/blob/intro-documentation/README.md#installation) instructions.

Since coordinators are about view hierarchy control, we don't want our app to automatically instantiate view controllers. To prevent this, select your info.plist and delete the two lines selected here:
![Storyboard references in info.plist](/images/setup3.png)

If you run your app at this point, your simulator should just show a black screen. This is good! We will be writing a coordinator to add to our window's root.

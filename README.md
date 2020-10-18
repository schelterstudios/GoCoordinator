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

Now that the project files are in place, add the GoCoordinator framework using the [installation](https://github.com/schelterstudios/GoCoordinator/blob/intro-documentation/README.md#installation) instructions. Remember to use the workspace file when reopening the project!

Since coordinators are about view hierarchy control, we don't want our app to automatically instantiate view controllers. To prevent this, select your **info.plist** and delete the two lines selected here:
![Storyboard references in info.plist](/images/setup3.png)

If you run your app at this point, your simulator should just show a black screen. This is good! We will be writing a coordinator to add to our window's root.
Open your **SceneDelegate** and add this to your imports:
```swift
import GoCoordinator
```
Add a property for your coordinator:
```swift
private(set) var coordinator: ManualCoordinator?
```
And replace the first method code with this:
```swift
func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    window = UIWindow(windowScene: windowScene)
    let vc = UIViewController()
    vc.view.backgroundColor = .magenta
    coordinator = ManualCoordinator(viewController: vc)
    window?.rootViewController = coordinator?.viewController
    coordinator?.start()
    window?.makeKeyAndVisible()
}
```
Build your app now, and you should see a lovely magenta screen. Congrats, you just deployed your first view with GoCoordinator! There's a lot under the hood for coordinators, but the most basic setup flow is:
1. Instantiate a coordinator.
2. Grab its `viewController` and insert into the view hierarchy.
3. Call the coordinator's `start()` method.

# NibCoordinator and subclassing

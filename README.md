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

# NibCoordinators and go hooks 
ManualCoordinators are useful for testing with, but you likely wouldn't rely on them beyond that. NibCoordinators and StoryboardCoordinators are far more useful, as they leverage xibs and storyboards with UIKit. Let's set up a view controller using a xib. First, create a new **UIViewController** and name it **MyNibViewController**. Let's add the following code:
```swift
@IBOutlet weak var label: UILabel!
    
override func viewDidLoad() {
    super.viewDidLoad()
    label.text = "Hello, World!"
}
```
Next, create a new View User Interface and name it the same as your view controller.
![Creating the view](/images/nib1.png)

In the xib, select the **File's Owner** and set the class to **MyNibViewController**. In the outlets panel, bind **view** to your xib's view. Also add a label component and bind that to **label**. It should look something like so:
![Setting up the Xib](/images/nib2.png)

In **SceneDelegate**, change your coordinator property to:
```swift
private(set) var coordinator: NibCoordinator<MyNibViewController>?
```
And replace the first method code with this:
```swift
func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    window = UIWindow(windowScene: windowScene)
    coordinator = NibCoordinator<MyNibViewController>()
    window?.rootViewController = coordinator?.viewController
    coordinator?.start()
    window?.makeKeyAndVisible()
}
```
Go ahead and run it to see your new view. Generally by convention, xibs are given the same name as their **file's owner**. We leverage that in GoCoordinator to instantiate the view controller and attach its nib automatically. All you need to do is declare the view controller for NibCoordinator using *generics.*

# GoCoordinator
![Travis.com badge](https://travis-ci.org/schelterstudios/GoCoordinator.svg?branch=master)
[![Version](https://img.shields.io/cocoapods/v/GoCoordinator.svg?style=flat)](http://cocoapods.org/pods/GoCoordinator)
[![Swift 5.0](https://img.shields.io/badge/Swift-5.0-orange.svg?style=flat)](https://swift.org/)
[![Platform](https://img.shields.io/cocoapods/p/GoCoordinator.svg?style=flat)](http://cocoapods.org/pods/GoCoordinator)
[![License](https://img.shields.io/cocoapods/l/GoCoordinator.svg?style=flat)](http://cocoapods.org/pods/GoCoordinator)

(Super) early build of GoCoordinator.

# Installation
 To add to your project, insert the following into your Podfile:  
`pod 'GoCoordinator', :git => 'https://github.com/schelterstudios/GoCoordinator.git'`

# Creating a new app with GoCoordinator
While the true strength of GoCoordinator is its extensibility, you can still reach a working demo with just a few steps. Try this guide to familiarize yourself with the setup.

To begin, let's create a new app using the iOS App template:
![Select App Template](https://github.com/schelterstudios/GoCoordinator/blob/master/images/setup1.png)

Next, set your options to Storyboard and UIKit:
![New Project Options](https://github.com/schelterstudios/GoCoordinator/blob/master/images/setup2.png)

Now that the project files are in place, add the GoCoordinator framework using the [installation](https://github.com/schelterstudios/GoCoordinator/blob/intro-documentation/README.md#installation) instructions. Remember to use the workspace file when reopening the project!

Since coordinators are about view hierarchy control, we don't want our app to automatically instantiate view controllers. To prevent this, select your **info.plist** and delete the two lines selected here:
![Storyboard references in info.plist](https://github.com/schelterstudios/GoCoordinator/blob/master/images/setup3.png)

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

# Switching to NibCoordinator
ManualCoordinators are useful for testing with, but you likely wouldn't rely on them beyond that. NibCoordinators and StoryboardCoordinators are far more useful, as they leverage xibs and storyboards with UIKit. Let's set up a view controller using a xib. First, create a new **UIViewController** and name it **MyNibViewController**. Let's add the following code:
```swift
@IBOutlet weak var label: UILabel!
    
override func viewDidLoad() {
    super.viewDidLoad()
    label.text = "Hello, World!"
}
```
Next, create a new View User Interface and name it the same as your view controller.
![Creating the view](https://github.com/schelterstudios/GoCoordinator/blob/master/images/nib1.png)

In the xib, select the **File's Owner** and set the class to **MyNibViewController**. In the outlets panel, bind **view** to your xib's view. Also add a label component and bind that to **label**. It should look something like so:
![Setting up the Xib](https://github.com/schelterstudios/GoCoordinator/blob/master/images/nib2.png)

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

# Navigating with GO
Working with coordinators is nice and all, but it doesn't get us very far without navigation. GoCoordinator provides a powerful hook named **go** for view controllers. Use **go** for pushing, popping, presenting, and dismissing views via their respective coordinators. Let's try it with our app. First, go ahead and add **MyNib2ViewController** swift and xib files. In the class file, add the following code:
```swift
@IBAction func back(_ sender: Any?) {
    go.dismiss()
}
```
Since GoCoordinator is in your project, your view controllers automatically have access to **go**. This is the only logic you need for **MyNib2ViewController** to dismiss its coordinator (and itself in the process). Now go to your **MyNibViewController** class. Feel free to remove the "Hello, World!" logic, and add `import GoCoordinator`. Add this code:
```swift
@IBAction func next(_ sender: Any?) {
    let coordinator = NibCoordinator<MyNib2ViewController>().asAnyCoordinator()
    go.present(coordinator:coordinator)
}
```
A few things to note here. First of all, view controllers should not be interacting with coordinators beyond instantiating and passing to **go**. We don't even need to call `start()` here, since that is handled internally by our coordinators. The second is the introduction to `asAnyCoordinator()`. This method erases the concretion of our coordinator, as well as its generics, by wrapping it into **AnyCoordinator**. If you have no reason to maintain a concrete reference, you will most likely prefer **AnyCoordinator**, as it lets you store and interact with it in more abstract ways. Whenever you pass a coordinator to **go**, you must first erase concretion. Go ahead and add buttons to your xibs and bind them to your IBActions. Mine look like this:
![My Xibs](/images/nib3.png)

Now run your app. Tapping the buttons should now present and dismiss your new view.

# Subclassing Coordinators
The more view controllers you add to your app, the more elaborate your coordinator infrastructure will become. You'll also want some sophistication that allows your coordinators to shuffle data between view controllers. You will need to subclass coordinators to define its parameters and initialize a view controller accordingly, and, in practice, you will likely have a coordinator subclass for each view controller. For demonstration, we will refer to the [GoCoordinatorExamples](https://github.com/schelterstudios/GoCoordinator/tree/master/GoCoordinatorExamples) project. First, let's take a look at **FriendsCoordinator**.
```swift
import UIKit
import GoCoordinator

class FriendsCoordinator: StoryboardCoordinator<FriendsViewController> {
    
    private let friends: [Contact]
    
    override init() {
        friends = (0..<10).map{ _ in random_contact() }
        super.init()
    }
    
    override func start() throws {
        viewController.friends = friends
        try super.start()
    }
}
```
Since **FriendsViewController** is a storyboard view controller, we subclass StoryboardCoordinator and declare it's view controller as type **FriendsViewController**. We override it's initializer so it can capture data to pass on to its viewe controller, and we override `start()` to pass that data. That's it! Now, once you add **FriendsCoordinator** to the coordinator hierarchy, it will automatically call `start()` and load up **FriendsViewController** for you.
> Special Note: The default behavior of storyboard coordinators is to find a storyboard that matches its prefix. (ie: *Friends*Coordinator will look for *Friends*.storyboard.) If there's no StoryboardOwner assigned, it will also look for the view controller with the *Is Initial View Controller* flag.)

Now, let's move right on to the second coordinator **FriendInfoCoordinator**. This one, like the previous one, is a storyboard coordinator, but there are a few differences. Let's take a look.
```swift
class FriendInfoCoordinator: StoryboardCoordinator<FriendInfoViewController> {
    
    private let friend: Contact
    private weak var delegate: FriendInfoViewControllerDelegate?
    
    init(friend: Contact, delegate: FriendInfoViewControllerDelegate?, owner: StoryboardOwner) {
        self.friend = friend
        self.delegate = delegate
        super.init(owner: owner, identifier: "contact-details")
    }
    
    override func start() throws {
        viewController.friend = friend
        viewController.delegate = delegate
        try super.start()
    }
}
```
Its initializer has a few extra parameters, namely *owner* and *identifier*. When we set up a storyboard, one view controller is designated as the initial view controller. We treat that as the top-level owner of the storyboard. Any additional view controllers are essentially tenants within that space, and cannot be instantiated on their own. After instantiation, however, a tenant can be treated as an owner for any other tenants within the storyboard. The identifier is just the Storyboard ID you assign to the view controller in the storyboard. The rest is standard setup and start stuff. Now, let's link them up. In **FriendsCoordinator**, we have added this method:
```swift
func pushInfo(friend: Contact, delegate: FriendInfoViewControllerDelegate?) {
    let coordinator = FriendInfoCoordinator(friend: friend, delegate: delegate, owner: self)
    try! push(coordinator: coordinator.asAnyCoordinator())
}
```
Typically, if one coordinator is always pushed by another, I explicitly define that logic as a custom method of the parent coordinator. Since **FriendInfoCoordinator** needs an owner from the same storyboard, the expectation is that we will only be pushing it from our top level coordinator, anyway. To access your custom coordinator methods from within a view controller, use `go(as:)` and pass in the coordinaor type. **FriendsViewController** calls *pushInfo* like so:
```swift
go(as: FriendsCoordinator.self).pushInfo(friend: friends[indexPath.row], delegate: self)
```
**FriendInfoCoordinator**, however, has no custom methods, so we don't need `go(as:)` for it. **FriendInfoViewController** can take you back to the previous view controller by just calling `go.pop()` or `go.popOrDismiss()`.  
> Special Note: `go.popOrDismiss()` is a nice option to increase abstraction of a view controller. With it, our controller doesn't have to concern itself with how it was displayed. If it was pushed, it pops. If it was presented, it dismisses.

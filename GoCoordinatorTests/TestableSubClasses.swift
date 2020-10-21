//
//  TestableSubClasses.swift
//  GoCoordinatorTests
//
//  Created by Steve Schelter on 10/18/20.
//

import UIKit

@testable import GoCoordinator

class TestableViewController: UIViewController {
    
    @IBInspectable var inspectableValue: Int = -1
    var inputValue: Int = -1
    var loadedValue: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadedValue = inputValue
    }
}

class TestableManualCoordinator: ManualCoordinator {
    
    var inputValue: Int = -1
    
    override func start() throws {
        (viewController as? TestableViewController)?.inputValue = inputValue
        try super.start()
    }
}

class TestableNibCoordinator: NibCoordinator<TestableViewController> {
    
    var inputValue: Int = -1
    
    override func start() throws {
        viewController.inputValue = inputValue
        try super.start()
    }
}

class TestableStoryboardCoordinator: StoryboardCoordinator<UINavigationController> {
    
    var inputValue: Int = -1
    
    override func start() throws {
        (viewController.topViewController as? TestableViewController)?.inputValue = inputValue
        try super.start()
    }
}

class TestableStoryboardSubCoordinator: StoryboardCoordinator<TestableViewController> {
    
    var inputValue: Int = -1
    
    override func start() throws {
        viewController.inputValue = inputValue
        try super.start()
    }
}

//
//  TestableSubClasses.swift
//  GoCoordinatorTests
//
//  Created by Steve Schelter on 10/18/20.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

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

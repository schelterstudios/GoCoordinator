//
//  TestableSubClasses.swift
//  GoCoordinatorTests
//
//  Created by Steve Schelter on 10/18/20.
//

import UIKit

@testable import GoCoordinator

class TestableViewController: UIViewController {
    
    var inputValue: Int = -1
    var loadedValue: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadedValue = inputValue
    }
}

class TestableManualCoordinator: ManualCoordinator {
    
    var inputValue: Int = -1
    
    override func start() {
        (viewController as? TestableViewController)?.inputValue = inputValue
        super.start()
    }
}

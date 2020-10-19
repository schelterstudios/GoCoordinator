//
//  GoCoordinatorTests.swift
//  GoCoordinatorTests
//
//  Created by Steve Schelter on 10/17/20.
//

import XCTest

@testable import GoCoordinator

class GoCoordinatorTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testManualCoordinatorLifecycle() throws {
        var strongVC: TestableViewController? = TestableViewController()
        weak var weakVC = strongVC
        
        var tmc: TestableManualCoordinator? = TestableManualCoordinator(viewController:strongVC!)
        tmc?.inputValue = 99
        strongVC = nil
        
        // Verify view controller is still allocated, but not loaded
        XCTAssertNotNil(weakVC)
        XCTAssertNotEqual(weakVC?.loadedValue, 99)
        
        tmc?.start()
        
        // Verify view controller is loaded
        XCTAssertEqual(weakVC?.loadedValue, 99)
        
        tmc = nil
        
        // Verify view controller is deallocated
        XCTAssertNil(weakVC)
    }
}

//
//  UIKitControllerTests.swift
//  GoCoordinatorTests
//
//  Created by Steve Schelter on 11/11/20.
//

import XCTest

@testable import GoCoordinator

class UIKitControllerTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAlertCoordinator() throws {
        weak var weakAC: UIAlertCoordinator?
        weak var weakAVC: UIAlertController?
        
        try autoreleasepool {
            var strongNibC: TestableNibCoordinator? = TestableNibCoordinator()
            
            // Set the alert coordinator's values and actions, but not loaded or presented
            var strongAC: UIAlertCoordinator? = UIAlertCoordinator(title:"My Title", message:"My Message", preferredStyle: .alert)
            strongAC?.addAction(title: "OK", style: .default)
            weakAC = strongAC
            weakAVC = strongAC?.viewController
            
            // Verify alert controller is still allocated, but not loaded or presented
            XCTAssertNotNil(weakAC)
            XCTAssertNotNil(weakAVC)
            XCTAssertNotEqual(weakAC?.actions.count, weakAVC?.actions.count)
            XCTAssertTrue(weakAVC?.isBeingPresented == false)
            
            // Present alert coordinator
            XCTAssertNoThrow(try strongNibC?.start())
            strongNibC?.present(coordinator: strongAC!.asAnyCoordinator())
            strongAC = nil
            
            // Verify alert controller is loaded and presented
            XCTAssertNotNil(weakAC)
            XCTAssertNotNil(weakAVC)
            XCTAssertEqual(weakAC?.actions.count, weakAVC?.actions.count)
            XCTAssert(weakAC?.presenting as? TestableNibCoordinator === strongNibC)
            
            // Trigger OK Action
            weakAC?.triggerAction(titled: "OK")
            
            // Verify alert controller is dismissed
            XCTAssertNil(weakAC?.presenting)
            
            strongNibC = nil
        }
        
        // Verify alert controller is deallocated
        XCTAssertNil(weakAC)
        XCTAssertNil(weakAVC)
    }
}

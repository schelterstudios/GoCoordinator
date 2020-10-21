//
//  LifecycleTests.swift
//  GoCoordinatorTests
//
//  Created by Steve Schelter on 10/17/20.
//

import XCTest

@testable import GoCoordinator

class LifecycleTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testManualCoordinatorLifecycle() throws {
        weak var weakVC: TestableViewController?
        
        autoreleasepool {
            var strongVC: TestableViewController? = TestableViewController()
            weakVC = strongVC
            
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
        }
        
        // Verify view controller is deallocated
        XCTAssertNil(weakVC)
    }
    
    func testManualCoordinatorBlocks() throws {
        let block = { UIViewController() }
        weak var weakVC1: UIViewController?
        weak var weakVC2: UIViewController?
        
        autoreleasepool {
            var mc1: ManualCoordinator? = ManualCoordinator(block: block)
            mc1?.start()
            weakVC1 = mc1?.viewController
            
            var mc2: ManualCoordinator? = ManualCoordinator(block: block)
            mc2?.start()
            weakVC2 = mc2?.viewController
            
            // Verify view controllers instantiated via code block are unique
            XCTAssertNotNil(weakVC1)
            XCTAssertNotNil(weakVC2)
            XCTAssertNotEqual(weakVC1, weakVC2)
            
            mc1 = nil
            mc2 = nil
        }
        
        // Verify view controllers are deallocated
        XCTAssertNil(weakVC1)
        XCTAssertNil(weakVC2)
    }
    
    func testNibCoordinatorLifecycle() throws {
        weak var weakVC: TestableViewController?
        
        autoreleasepool {
            var tnc: TestableNibCoordinator? = TestableNibCoordinator()
            weakVC = tnc?.viewController
            tnc?.inputValue = 89
            
            // Verify view controller is still allocated, but not loaded
            XCTAssertNotNil(weakVC)
            XCTAssertNotEqual(weakVC?.loadedValue, 89)
            
            tnc?.start()
            
            // Verify view controller is loaded
            XCTAssertEqual(weakVC?.loadedValue, 89)
            
            tnc = nil
        }
        
        // Verify view controller is deallocated
        XCTAssertNil(weakVC)
    }
    
    func testStoryboardCoordinatorLifecycle() throws {
        weak var weakVC: TestableViewController?
        
        autoreleasepool {
            var tsc: TestableStoryboardCoordinator? = TestableStoryboardCoordinator()
            weakVC = tsc?.viewController.topViewController as? TestableViewController
            tsc?.inputValue = 79
            
            // Verify view controller is still allocated, but not loaded
            XCTAssertNotNil(weakVC)
            XCTAssertNotEqual(weakVC?.loadedValue, 79)
            
            tsc?.start()
            weakVC?.viewDidLoad()
            
            // Verify view controller is loaded
            XCTAssertEqual(weakVC?.loadedValue, 79)
            
            tsc = nil
        }
        
        // Verify view controller is deallocated
        XCTAssertNil(weakVC)
    }
    
    func testNavigatonCoordinatorLifecycle() throws {
        weak var weakNibC1: TestableNibCoordinator?
        weak var weakNibC2: TestableNibCoordinator?
        weak var weakVC1: TestableViewController?
        weak var weakVC2: TestableViewController?
        weak var weakNavC: NavigationCoordinator?
        
        autoreleasepool {
            var strongNibC1: TestableNibCoordinator? = TestableNibCoordinator()
            var strongNibC2: TestableNibCoordinator? = TestableNibCoordinator()
            weakNibC1 = strongNibC1
            weakNibC2 = strongNibC2
            weakVC1 = strongNibC1?.viewController
            weakVC2 = strongNibC2?.viewController
            
            // Set the coordinators' input test values, and add NibC1 to NavC root
            strongNibC1?.inputValue = 70
            strongNibC2?.inputValue = 71
            var strongNavC: NavigationCoordinator? = NavigationCoordinator(root: strongNibC1!.asAnyCoordinator())
            weakNavC = strongNavC
            strongNibC1 = nil
        
            // Verify view controller is still allocated, but not loaded nor added to navigation
            XCTAssertNotNil(weakNibC1)
            XCTAssertNotNil(weakVC1)
            XCTAssertNotEqual(weakVC1?.loadedValue, 70)
            XCTAssertNil(weakVC1?.navigationController)
        
            // Start NavC
            strongNavC?.start()
        
            // Verify view controller is loaded and added to navigation
            XCTAssertEqual(weakVC1?.loadedValue, 70)
            XCTAssertNotNil(weakVC1?.navigationController)
        
            // Push NibC2 to NavC
            try? weakVC1?.go.push(coordinator: strongNibC2!.asAnyCoordinator())
            strongNibC2 = nil
                        
            // Verify view controller 2 is loaded and added to navigation
            XCTAssertNotNil(weakNibC2)
            XCTAssertEqual(weakVC2?.loadedValue, 71)
            XCTAssert(weakNibC2?.parent as? TestableNibCoordinator === weakNibC1)
            
            strongNavC = nil
        }
        
        // Verify view controllers are deallocated
        XCTAssertNil(weakNavC)
        XCTAssertNil(weakNibC1)
        XCTAssertNil(weakNibC2)
        XCTAssertNil(weakVC1)
        XCTAssertNil(weakVC2)
    }
    
    
}

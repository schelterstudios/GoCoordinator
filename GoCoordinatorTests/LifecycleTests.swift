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
        
        try autoreleasepool {
            var strongVC: TestableViewController? = TestableViewController()
            weakVC = strongVC
            
            var tmc: TestableManualCoordinator? = TestableManualCoordinator(viewController:strongVC!)
            tmc?.inputValue = 99
            strongVC = nil
            
            // Verify view controller is still allocated, but not loaded
            XCTAssertNotNil(weakVC)
            XCTAssertNotEqual(weakVC?.loadedValue, 99)
            
            XCTAssertNoThrow(try tmc?.start())
            
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
        
        try autoreleasepool {
            var mc1: ManualCoordinator? = ManualCoordinator(block: block)
            XCTAssertNoThrow(try mc1?.start())
            weakVC1 = mc1?.viewController
            
            var mc2: ManualCoordinator? = ManualCoordinator(block: block)
            XCTAssertNoThrow(try mc2?.start())
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
        
        try autoreleasepool {
            var tnc: TestableNibCoordinator? = TestableNibCoordinator()
            weakVC = tnc?.viewController
            tnc?.inputValue = 89
            
            // Verify view controller is still allocated, but not loaded
            XCTAssertNotNil(weakVC)
            XCTAssertNotEqual(weakVC?.loadedValue, 89)
            
            XCTAssertNoThrow(try tnc?.start())
            
            // Verify view controller is loaded
            XCTAssertEqual(weakVC?.loadedValue, 89)
            
            tnc = nil
        }
        
        // Verify view controller is deallocated
        XCTAssertNil(weakVC)
    }
    
    func testNibCoordinatorError() throws {
        let nc1 = NibCoordinator<TestableViewController>()
        let nc2 = NibCoordinator<UIViewController>()
        
        XCTAssertNoThrow(try nc1.start())
        XCTAssertThrowsError(try nc2.start())
    }
    
    func testStoryboardCoordinatorLifecycle() throws {
        weak var weakVC1: TestableViewController?
        weak var weakVC2: TestableViewController?
        
        try autoreleasepool {
            var sbc1: TestableStoryboardCoordinator? = TestableStoryboardCoordinator()
            weakVC1 = sbc1?.viewController.topViewController as? TestableViewController
            sbc1?.inputValue = 72
            
            var sbc2: TestableStoryboardSubCoordinator? = TestableStoryboardSubCoordinator(owner: sbc1!, identifier: "child")
            weakVC2 = sbc2?.viewController
            sbc2?.inputValue = 73
            
            // Verify view controllers are still allocated, but not loaded
            XCTAssertNotNil(weakVC1)
            XCTAssertNotNil(weakVC2)
            XCTAssertNotEqual(weakVC1?.loadedValue, 72)
            XCTAssertNotEqual(weakVC2?.loadedValue, 73)
            
            XCTAssertNoThrow(try sbc1?.start())
            weakVC1?.viewDidLoad()
            XCTAssertNoThrow(try sbc2?.start())
            weakVC2?.viewDidLoad()
            
            // Verify view controllers are loaded
            XCTAssertEqual(weakVC1?.loadedValue, 72)
            XCTAssertEqual(weakVC2?.loadedValue, 73)
            
            sbc1 = nil
            sbc2 = nil
        }
        
        // Verify view controllers are deallocated
        XCTAssertNil(weakVC1)
        XCTAssertNil(weakVC2)
    }
    
    func testStoryboardCoordinatorErrors() throws {
        let sbc1 = StoryboardCoordinator<UINavigationController>()
        let sbc2 = TestableStoryboardCoordinator(storyboardName: "WrongName", identifier: "wrongID")
        
        let sbc3 = TestableStoryboardCoordinator()
        let tvc3 = sbc3.viewController.topViewController as? TestableViewController
        
        let sbc4 = TestableStoryboardSubCoordinator(owner: sbc3, identifier: "wrongID")
        let tvc4 = sbc4.viewController
        
        let sbc5 = TestableStoryboardSubCoordinator(owner: sbc3, identifier: "child")
        let tvc5 = sbc5.viewController
        
        // Verify sbc1 and sbc2 have no root controllers (due to missing storyboard)
        XCTAssertNil(sbc1.viewController.topViewController)
        XCTAssertNil(sbc2.viewController.topViewController)
        XCTAssertThrowsError(try sbc1.start())
        XCTAssertThrowsError(try sbc2.start())
        
        // Verify sbc3 has correct root
        XCTAssertEqual(tvc3?.inspectableValue, 10)
        XCTAssertNoThrow(try sbc3.start())
        
        // Verify sbc4 failed (has placeholder)
        XCTAssertNotEqual(tvc4.inspectableValue, 20)
        XCTAssertThrowsError(try sbc4.start())
        
        // Verify sbc5 has correct controller
        XCTAssertEqual(tvc5.inspectableValue, 20)
        XCTAssertNoThrow(try sbc5.start())
    }
    
    func testNavigatonCoordinatorLifecycle() throws {
        weak var weakNibC1: TestableNibCoordinator?
        weak var weakNibC2: TestableNibCoordinator?
        weak var weakVC1: TestableViewController?
        weak var weakVC2: TestableViewController?
        weak var weakNavC: NavigationCoordinator?
        
        try autoreleasepool {
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
            XCTAssertNoThrow(try strongNavC?.start())
        
            // Verify view controller is loaded and added to navigation
            XCTAssertEqual(weakVC1?.loadedValue, 70)
            XCTAssertNotNil(weakVC1?.navigationController)
        
            // Push NibC2 to NavC
            XCTAssertNoThrow(try weakVC1?.go.push(coordinator: strongNibC2!.asAnyCoordinator()))
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

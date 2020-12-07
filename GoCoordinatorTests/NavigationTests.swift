//
//  NavigationTests.swift
//  GoCoordinatorTests
//
//  Created by Steve Schelter on 10/20/20.
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

import XCTest

@testable import GoCoordinator

class NavigationTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPushAndPopNavigation() throws {
        var nc: UINavigationCoordinator!
        weak var weakC1: TestableNibCoordinator?
        weak var weakC2: TestableNibCoordinator?
        weak var weakC3: TestableNibCoordinator?
        weak var weakC4: TestableNibCoordinator?
        
        //autoreleasepool {
            var strongC1: TestableNibCoordinator? = TestableNibCoordinator()
            var strongC2: TestableNibCoordinator? = TestableNibCoordinator()
            var strongC3: TestableNibCoordinator? = TestableNibCoordinator()
            var strongC4: TestableNibCoordinator? = TestableNibCoordinator()
            weakC1 = strongC1
            weakC2 = strongC2
            weakC3 = strongC3
            weakC4 = strongC4
            nc = UINavigationCoordinator(root: strongC1!.asAnyCoordinator())
            XCTAssertNoThrow(try nc.start())
        
            // Verify that only c1 is in the stack
            XCTAssert(weakC1?.parent === nc)
            XCTAssertNil(weakC2?.parent)
            XCTAssertNil(weakC3?.parent)
            XCTAssertNil(weakC4?.parent)

            XCTAssertNoThrow(try weakC1?.push(coordinator: strongC2!.asAnyCoordinator(), animated: false))
            XCTAssertNoThrow(try weakC2?.push(coordinator: strongC3!.asAnyCoordinator(), animated: false))
            XCTAssertNoThrow(try weakC3?.push(coordinator: strongC4!.asAnyCoordinator(), animated: false))
            
            // Verify that c2, c3, and c4 are now in the stack
            XCTAssert(weakC1?.parent === nc)
            XCTAssert(weakC2?.parent === strongC1)
            XCTAssert(weakC3?.parent === strongC2)
            XCTAssert(weakC4?.parent === strongC3)
            
            strongC1 = nil
            strongC2 = nil
            strongC3 = nil
            strongC4 = nil
            weakC4?.viewController.go?.pop()
            
            // Verify that c4 is no longer in the stack
            XCTAssert(weakC1?.parent === nc)
            XCTAssert(weakC2?.parent === weakC1)
            XCTAssert(weakC3?.parent === weakC2)
            XCTAssertNil(weakC4?.parent)
            
            weakC2?.viewController.go?.pop()
            
            // Verify that c2 and c3 are no longer in the stack
            XCTAssert(weakC1?.parent === nc)
            XCTAssertNil(weakC2?.parent)
            XCTAssertNil(weakC3?.parent)
            XCTAssertNil(weakC4?.parent)
        //}
        
        weakC1?.viewController.go?.pop()
        
        // Verify that c1 is unchanged (can't pop because it's root)
        XCTAssert(weakC1?.parent === nc)
        XCTAssertNil(weakC2?.parent)
        XCTAssertNil(weakC3?.parent)
        XCTAssertNil(weakC4?.parent)
    }
    
    func testStoryboardPushAndPop() throws {
        weak var weakC1: TestableStoryboardSubCoordinator?
        weak var weakC2: TestableStoryboardSubCoordinator?
        weak var weakC3: TestableNibCoordinator?
        
        let root = TestableStoryboardCoordinator()
        var strongC1: TestableStoryboardSubCoordinator? = TestableStoryboardSubCoordinator(owner: root, identifier: "child")
        var strongC2: TestableStoryboardSubCoordinator? = TestableStoryboardSubCoordinator(owner: strongC1!, identifier: "child")
        var strongC3: TestableNibCoordinator? = TestableNibCoordinator()
        weakC1 = strongC1
        weakC2 = strongC2
        weakC3 = strongC3
        XCTAssertNoThrow(try root.start())
        XCTAssertNoThrow(try root.push(coordinator: strongC1!.asAnyCoordinator(), animated: false))
        
        // Verify that only c1 is in the stack
        XCTAssert(weakC1?.parent === root)
        XCTAssertNil(weakC2?.parent)
        XCTAssertNil(weakC3?.parent)
        
        XCTAssertNoThrow(try weakC1?.push(coordinator: strongC2!.asAnyCoordinator(), animated: false))
        XCTAssertNoThrow(try weakC2?.push(coordinator: strongC3!.asAnyCoordinator(), animated: false))
        
        // Verify that c2, c3, and c4 are now in the stack
        XCTAssert(weakC1?.parent === root)
        XCTAssert(weakC2?.parent === strongC1)
        XCTAssert(weakC3?.parent === strongC2)
        
        strongC1 = nil
        strongC2 = nil
        strongC3 = nil
        weakC3?.viewController.go?.pop()
        
        // Verify that c3 is no longer in the stack
        XCTAssert(weakC1?.parent === root)
        XCTAssert(weakC2?.parent === weakC1)
        XCTAssertNil(weakC3?.parent)
        
        weakC1?.viewController.go?.pop()
        
        // Verify that c1 and c2 are no longer in the stack, and that top is now root
        XCTAssert(root.viewController.viewControllers.first === root.viewController.topViewController)
        XCTAssertNil(weakC1?.parent)
        XCTAssertNil(weakC2?.parent)
        XCTAssertNil(weakC3?.parent)
        
        root.viewController.topViewController?.go?.pop()
        
        // Verify that tsc is unchanged (can't pop because it's root)
        XCTAssert(root.viewController.viewControllers.first === root.viewController.topViewController)
    }
    
    func testPresentAndDismissNavigation() throws {
        weak var weakC1: TestableNibCoordinator?
        weak var weakC2: TestableNibCoordinator?
        
        let root = TestableNibCoordinator()
        var strongC1: TestableNibCoordinator? = TestableNibCoordinator()
        var strongC2: TestableNibCoordinator? = TestableNibCoordinator()
        weakC1 = strongC1
        weakC2 = strongC2
        XCTAssertNoThrow(try root.start())
        root.present(coordinator: strongC1!.asAnyCoordinator())
        strongC1 = nil
        
        // Verify that only c1 is in the stack
        XCTAssert(weakC1?.presenting === root)
        XCTAssertNil(weakC2?.presenting)
        weakC1?.present(coordinator: strongC2!.asAnyCoordinator())
        strongC2 = nil
        
        // Verify that c1 and c2 are in the stack
        XCTAssert(weakC1?.presenting === root)
        XCTAssert(weakC2?.presenting === weakC1)
        
        weakC1?.viewController.go.dismiss()
        
        // Verify that c1 and c2 are no longer in the stack
        XCTAssertNil(weakC1?.presenting)
        XCTAssertNil(weakC2?.presenting)
    }
    
    func testPresentAndReplaceNavigation() throws {
        weak var weakC1: TestableNibCoordinator?
        weak var weakC2: TestableNibCoordinator?
        
        let root = TestableNibCoordinator()
        var strongC1: TestableNibCoordinator? = TestableNibCoordinator()
        var strongC2: TestableNibCoordinator? = TestableNibCoordinator()
        weakC1 = strongC1
        weakC2 = strongC2
        XCTAssertNoThrow(try root.start())
        root.present(coordinator: strongC1!.asAnyCoordinator())
        strongC1 = nil
        
        // Verify that only c1 is in the stack
        XCTAssert(weakC1?.presenting === root)
        XCTAssertNil(weakC2?.presenting)
        
        root.present(coordinator: strongC2!.asAnyCoordinator())
        strongC2 = nil
        
        // Verify that only c2 is in the stack
        XCTAssertNil(weakC1?.presenting)
        XCTAssert(weakC2?.presenting === root)
        
        weakC2?.viewController.go.dismiss()
        
        // Verify that c1 and c2 are no longer in the stack
        XCTAssertNil(weakC1?.presenting)
        XCTAssertNil(weakC2?.presenting)
    }
}

//
//  UIKitControllerTests.swift
//  GoCoordinatorTests
//
//  Created by Steve Schelter on 11/11/20.
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
    }
}

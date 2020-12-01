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
            
            // Verify controller is still allocated, but not loaded or presented
            XCTAssertNotNil(weakAC)
            XCTAssertNotNil(weakAVC)
            XCTAssertNotEqual(weakAC?.actions.count, weakAVC?.actions.count)
            XCTAssertTrue(weakAVC?.isBeingPresented == false)
            
            // Present coordinator
            XCTAssertNoThrow(try strongNibC?.start())
            strongNibC?.present(coordinator: strongAC!.asAnyCoordinator())
            strongAC = nil
            
            // Verify controller is loaded and presented
            XCTAssertNotNil(weakAC)
            XCTAssertNotNil(weakAVC)
            XCTAssertEqual(weakAC?.actions.count, weakAVC?.actions.count)
            XCTAssert(weakAC?.presenting as? TestableNibCoordinator === strongNibC)
            
            // Trigger OK Action
            weakAC?.triggerAction(titled: "OK")
            
            // Verify controller is dismissed
            XCTAssertNil(weakAC?.presenting)
            
            strongNibC = nil
        }
        
        // Verify controller is deallocated
        XCTAssertNil(weakAC)
    }
    
    func testImagePickerCoordinator() throws {
        weak var weakCoordinator: UIImagePickerCoordinator?
        weak var weakViewController: UIImagePickerController?
        
        try autoreleasepool {
            var strongParent: TestableNibCoordinator? = TestableNibCoordinator()
            
            // Set the coordinator's values, but not loaded or presented
            var strongCoordinator: UIImagePickerCoordinator? = UIImagePickerCoordinator(delegate: nil)
            strongCoordinator?.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)
            weakCoordinator = strongCoordinator
            weakViewController = strongCoordinator?.viewController
            
            // Verify controller is still allocated, but not loaded or presented
            XCTAssertNotNil(weakCoordinator)
            XCTAssertNotNil(weakViewController)
            XCTAssertNotEqual(weakCoordinator?.mediaTypes?.count, weakViewController?.mediaTypes.count)
            XCTAssertTrue(weakViewController?.isBeingPresented == false)
            
            // Present coordinator
            XCTAssertNoThrow(try strongParent?.start())
            strongParent?.present(coordinator: strongCoordinator!.asAnyCoordinator())
            strongCoordinator = nil
            
            // Verify controller is loaded and presented
            XCTAssertNotNil(weakCoordinator)
            XCTAssertNotNil(weakViewController)
            XCTAssertEqual(weakCoordinator?.mediaTypes?.count, weakViewController?.mediaTypes.count)
            XCTAssert(weakCoordinator?.presenting as? TestableNibCoordinator === strongParent)
                        
            // Deallocate parent
            strongParent = nil
        }
        
        // Verify controller is deallocated
        XCTAssertNil(weakCoordinator)
    }
    
    func testActivityCoordinator() throws {
        weak var weakAC: UIActivityViewCoordinator?
        weak var weakAVC: UIActivityViewController?
        
        try autoreleasepool {
            var strongNibC: TestableNibCoordinator? = TestableNibCoordinator()
            
            // Set the activity coordinator's values and, but not loaded or presented
            var strongAC: UIActivityViewCoordinator? = UIActivityViewCoordinator(activityItems: [], applicationActivities: nil)
            strongAC?.excludedActivityTypes = [.airDrop]
            weakAC = strongAC
            weakAVC = strongAC?.viewController
            
            // Verify controller is still allocated, but not loaded or presented
            XCTAssertNotNil(weakAC)
            XCTAssertNotNil(weakAVC)
            XCTAssertNotEqual(weakAC?.excludedActivityTypes?.count, weakAVC?.excludedActivityTypes?.count)
            XCTAssertTrue(weakAVC?.isBeingPresented == false)
            
            // Present coordinator
            XCTAssertNoThrow(try strongNibC?.start())
            strongNibC?.present(coordinator: strongAC!.asAnyCoordinator())
            strongAC = nil
            
            // Verify controller is loaded and presented
            XCTAssertNotNil(weakAC)
            XCTAssertNotNil(weakAVC)
            XCTAssertEqual(weakAC?.excludedActivityTypes?.count, weakAVC?.excludedActivityTypes?.count)
            XCTAssert(weakAC?.presenting as? TestableNibCoordinator === strongNibC)
            
            // Deallocate parent
            strongNibC = nil
        }
        
        // Verify controller is deallocated
        XCTAssertNil(weakAC)
    }
    
    @available(iOS 14.0, *)
    func testActivityCoordinatorWithConfig() throws {
        weak var weakAC: UIActivityViewCoordinator?
        weak var weakAVC: UIActivityViewController?
        
        try autoreleasepool {
            var strongNibC: TestableNibCoordinator? = TestableNibCoordinator()
            
            // Set the activity coordinator's values and, but not loaded or presented
            let config = UIActivityItemsConfiguration(itemProviders: [])
            var strongAC: UIActivityViewCoordinator? = UIActivityViewCoordinator(activityItemsConfiguration: config)
            strongAC?.excludedActivityTypes = [.airDrop]
            weakAC = strongAC
            weakAVC = strongAC?.viewController
            
            // Verify controller is still allocated, but not loaded or presented
            XCTAssertNotNil(weakAC)
            XCTAssertNotNil(weakAVC)
            XCTAssertNotEqual(weakAC?.excludedActivityTypes?.count, weakAVC?.excludedActivityTypes?.count)
            XCTAssertTrue(weakAVC?.isBeingPresented == false)
            
            // Present coordinator
            XCTAssertNoThrow(try strongNibC?.start())
            strongNibC?.present(coordinator: strongAC!.asAnyCoordinator())
            strongAC = nil
            
            // Verify controller is loaded and presented
            XCTAssertNotNil(weakAC)
            XCTAssertNotNil(weakAVC)
            XCTAssertEqual(weakAC?.excludedActivityTypes?.count, weakAVC?.excludedActivityTypes?.count)
            XCTAssert(weakAC?.presenting as? TestableNibCoordinator === strongNibC)
            
            // Deallocate parent
            strongNibC = nil
        }
        
        // Verify controller is deallocated
        XCTAssertNil(weakAC)
    }
}

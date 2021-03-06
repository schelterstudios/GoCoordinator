//
//  NavigationCoordinator.swift
//  GoCoordinator
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

import Foundation
import UIKit.UINavigationController

/// Coordinator for navigation controllers
open class UINavigationCoordinator: CoordinatorBase<UINavigationController> {
    
    /// The root coordinator
    public let root: AnyCoordinator
    
    /// Creates a navigation coordinator with the root set to the provided coordinator.
    /// - Parameters:
    ///     - root: The coordinator to be used as the navigation root.
    ///     Must be wrapped to `AnyCoordinator`.
    public init(root: AnyCoordinator) {
        self.root = root
    }
    
    /// Starts the view controller.
    open override func start() throws {
        try super.start()
        try push(coordinator: root, animated: false)
    }
    
    final override func instantiateViewController() throws -> UINavigationController {
        return UINavigationController()
    }
}

extension Coordinator {
    
    /// Presents a navigation coordinator modally.
    /// - Parameters:
    ///     - root: The coordinator to be used as the navigation root.
    ///     - completion: The block to execute after the presentation finishes.
    ///         - error: Error if one occurred, otherwise nil.
    public func presentUINavigation(root: AnyCoordinator, completion: ((Error?)->Void)? = nil) {
        let coordinator = UINavigationCoordinator(root: root)
        present(coordinator: coordinator.asAnyCoordinator(), completion: completion)
    }
}

//
//  ManualCoordinator.swift
//  GoCoordinator
//
//  Created by Steve Schelter on 10/17/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
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
import UIKit.UIViewController

/// Coordinator for manually coded view controllers
open class ManualCoordinator: CoordinatorBase<UIViewController> {
    
    private let factory: () -> UIViewController
    
    /// Creates a manual coordinator whose view controller is provided by the given closure.
    /// - Parameters:
    ///     - factory: A closure that returns a view controller instance.
    public init(_ factory: @escaping ()->UIViewController ) {
        self.factory = factory
    }
    
    /// Creates a manual coordinator using the provided view controller.
    /// - Parameters:
    ///     - viewController: The view controller to be used by the coordinator.
    public init(viewController: UIViewController) {
        self.factory = { viewController }
    }
    
    /// Starts the view controller.
    open override func start() throws {
        try super.start()
        viewController.viewDidLoad()
    }
    
    // NOTE: Overriding CoordinatorBase to fix autocompletion bug
    /// Pushes a coordinator onto the receiver's stack and starts it.
    /// - Parameters:
    ///     - coordinator: The coordinator to push onto the stack. Must be wrapped to `AnyCoordinator`.
    ///     - animated: Flag used to animate the stack's navigation controller.
    final public override func push(coordinator: AnyCoordinator, animated: Bool) throws {
        try super.push(coordinator: coordinator, animated: animated)
    }

    /// Pops the coordinator from the stack.
    final public override func pop() {
        super.pop()
    }

    /// Presents a coordinator modally.
    /// - Parameters:
    ///     - coordinator: The coordinator to present. Must be wrapped to `AnyCoordinator`.
    ///     - completion: The block to execute after the presentation finishes.
    ///         - error: Error if one occurred, otherwise nil.
    final public override func present(coordinator: AnyCoordinator, completion: ((Error?)->Void)?) {
        super.present(coordinator: coordinator, completion: completion)
    }

    /// Dismisses the coordinator that was presented modally.
    /// - Parameters:
    ///     - completion: The block to execute after the presentation finishes.
    ///         - error: Error if one occurred, otherwise nil.
    final public override func dismiss(completion: ((Error?)->Void)?) {
        super.dismiss(completion: completion)
    }
    // /////////
    
    final override func instantiateViewController() throws -> UIViewController {
        return factory()
    }
}

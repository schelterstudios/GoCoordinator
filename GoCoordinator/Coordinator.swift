//
//  Coordinator.swift
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
import class UIKit.UIViewController
import class UIKit.UINavigationController
import class UIKit.UITabBarController

public enum CoordinatorError: Error {
    case missingNavigation
    case missingImplementation(String)
    case invalidInstantiation
    case dismissalRejected
}

/// Navigation methods for coordinators.
public protocol CoordinatorNavigator: class {
    
    /// The coordinator that pushed this coordinator.
    var parent: CoordinatorParent? { get set }
    
    /// The coordinator that presented this coordinator.
    var presenting: CoordinatorParent? { get set }
    
    /// If false, prevents the coordinator from being dismissed. Default is `true`.
    var allowDismissal: Bool { get set }
 
    /// Pushes a coordinator onto the receiver's stack and starts it.
    /// - Parameters:
    ///     - coordinator: The coordinator to push onto the stack. Must be wrapped to `AnyCoordinator`.
    ///     - animated: Flag used to animate the stack's navigation controller.
    func push(coordinator: AnyCoordinator, animated: Bool) throws
    
    /// Pops the coordinator from the stack.
    func pop()
    
    /// Presents a coordinator modally.
    /// - Parameters:
    ///     - coordinator: The coordinator to present. Must be wrapped to `AnyCoordinator`.
    ///     - completion: The block to execute after the presentation finishes.
    ///         - error: Error if one occurred, otherwise nil.
    func present(coordinator: AnyCoordinator, completion: ((Error?)->Void)?)
    
    /// Dismisses the coordinator that was presented modally.
    /// - Parameters:
    ///     - completion: The block to execute after the presentation finishes.
    ///         - error: Error if one occurred, otherwise nil.
    func dismiss(completion: ((Error?)->Void)?)
}

public extension CoordinatorNavigator {
    
    /// Pushes a coordinator if it can be pushed, otherwise presents it.
    /// - Parameters:
    ///     - coordinator: The coordinator to push or present. Must be wrapped to `AnyCoordinator`.
    ///     - animated: Flag used to animate the stack's navigation controller.
    ///     - completion: The block to execute after the presentation finishes.
    ///         - error: Error if one occurred, otherwise nil.
    func pushOrPresent(coordinator: AnyCoordinator, animated: Bool = true,
                       completion: ((Error?)->Void)? = nil) {
        do {
            try push(coordinator: coordinator, animated: animated)
            completion?(nil)
        } catch {
            present(coordinator: coordinator, completion: completion)
        }
    }
    
    /// Pops a coordinator if it can be popped, otherwise dismisses it.
    /// - Parameters:
    ///     - completion: The block to execute after the presentation finishes.
    ///         - error: Error if one occurred, otherwise nil.
    func popOrDismiss(completion: ((Error?)->Void)? = nil) {
        if parent != nil {
            pop()
            completion?(nil)
        } else {
            dismiss(completion: completion)
        }
    }
    
    /// Pushes a coordinator onto the receiver's stack and starts it.
    /// - Parameters:
    ///     - coordinator: The coordinator to push onto the stack. Must be wrapped to `AnyCoordinator`.
    func push(coordinator: AnyCoordinator) throws {
        try push(coordinator: coordinator, animated: true)
    }
    
    /// Presents a coordinator modally.
    /// - Parameters:
    ///     - coordinator: The coordinator to present. Must be wrapped to `AnyCoordinator`.
    func present(coordinator: AnyCoordinator) {
        present(coordinator: coordinator, completion: nil)
    }
    
    /// Dismisses the coordinator that was presented modally.
    func dismiss() {
        dismiss(completion: nil)
    }
}

/// Concretion erasure for coordinators.
public protocol CoordinatorAbstractor: AnyObject {
    
    /// Wraps the coordinator to an `AnyCoordinator` object.
    func asAnyCoordinator() -> AnyCoordinator
}

public protocol Coordinator: CoordinatorNavigator, CoordinatorAbstractor {
    associatedtype VC: UIViewController
    
    /// The view controller instantiated by the coordinator.
    var viewController: VC { get }
    
    /// Starts the view controller.
    func start() throws
}

public extension Coordinator {
    func asAnyCoordinator() -> AnyCoordinator {
        return AnyCoordinator(self)
    }
}

/// Parent methods for coordinators.
public protocol CoordinatorParent: AnyObject {
    
    /// Pops the child coordinator from the stack.
    /// - Parameters:
    ///     - animated: Flag used to animate the stack's navigation controller.
    func popChild(animated: Bool)
    
    /// Dismisses the child coordinator from the stack.
    /// - Parameters:
    ///     - animated: Flag used to animate the stack's navigation controller.
    ///     - completion: The block to execute after the presentation finishes.
    ///         - error: Error if one occurred, otherwise nil.
    func dismissPresented(animated: Bool, completion: ((Error?)->Void)?)
}

open class CoordinatorBase<VC: UIViewController>: Coordinator, CoordinatorParent {
    
    private var _viewController: VC?
    public var viewController: VC {
        if _viewController == nil {
            do {
                _viewController = try instantiateViewController()
            } catch let err {
                instantiationError = err
            }

            // NOTE: throwing from getter is not supported. Instead, just return a placeholder
            if _viewController == nil {
                _viewController = VC()
            }
        }
        return _viewController!
    }
    
    private var instantiationError: Error?
    
    weak public var parent: CoordinatorParent?
    weak public var presenting: CoordinatorParent?
    
    private var _allowDismissal = true
    public var allowDismissal: Bool {
        get { return (pushedChild?.allowDismissal != false) && _allowDismissal }
        set { _allowDismissal = newValue }
    }
    
    private var pushedChild: AnyCoordinator?
    private var presentedChild: AnyCoordinator?
        
    func instantiateViewController() throws -> VC {
        throw CoordinatorError.missingImplementation(#function)
    }
    
    open func start() throws {
        CoordinatorLinker.linker.linkCoordinator(self, for: viewController)
        if let error = instantiationError {
            throw error
        }
    }
    
    deinit {
        CoordinatorLinker.linker.unlinkCooordinatorFor(viewController)
    }
    
    open func push(coordinator: AnyCoordinator, animated: Bool) throws {
        if pushedChild != nil {
            popChild(animated: false)
        }
        if let nc = viewController as? UINavigationController ?? viewController.navigationController {
            nc.pushViewController(coordinator.viewController, animated: animated)
        } else {
            throw CoordinatorError.missingNavigation
        }
        
        coordinator.parent = self
        coordinator.presenting = self.presenting
        pushedChild = coordinator
        try coordinator.start()
    }
    
    public func popChild(animated: Bool) {
        if let nc = viewController as? UINavigationController {
            // NOTE: Navigation controller can't pop its child because it's root!
            if pushedChild?.viewController == nc.viewControllers.first { return }
            else { nc.popToRootViewController(animated: animated) }
        
        } else if let nc = viewController.navigationController {
            nc.popToViewController(viewController, animated: animated)
        }
        pushedChild?.parent = nil
        pushedChild = nil
    }
    
    open func pop() {
        parent?.popChild(animated: true)
    }
    
    open func present(coordinator: AnyCoordinator, completion: ((Error?)->Void)?) {
        dismissPresented(animated: true) { [weak self] e in
            if let err = e {
                if completion == nil {
                    fatalError("Unhandled Error: \(err)")
                }
                completion?(err)
                return
            }
            
            var throwing: Error?
            
            // NOTE: Trying start() first here, see other note below.
            coordinator.presenting = self
            self?.presentedChild = coordinator
            do {
                try coordinator.start()
            } catch let err {
                throwing = err
            }
            //
            
            self?.viewController.present(coordinator.viewController, animated: true) {
                if completion == nil && throwing != nil {
                    fatalError("Unhandled Error: \(throwing!)")
                }
                completion?(throwing)
            }
            
            /* NOTE: Normally we add to hierarchy before calling start(),
             but this fails with custom presentations. Trying start() first.
             
            coordinator.presenting = self
            self?.presentedChild = coordinator
            do {
                try coordinator.start()
            } catch let err {
                throwing = err
            }
            */
        }
    }
    
    public func dismissPresented(animated: Bool, completion: ((Error?)->Void)?) {
        if presentedChild?.allowDismissal == false {
            // NOTE: Dismissal rejection is non-fatal
            // if completion == nil {
            //    fatalError("Unhandled Error: \(CoordinatorError.dismissalRejected)")
            // }
            completion?(CoordinatorError.dismissalRejected)
            return
        }
        
        if let presented = viewController.presentedViewController {
            presented.dismiss(animated: animated) {
                completion?(nil)
            }
            presentedChild?.presenting = nil
            presentedChild = nil
        } else {
            presentedChild?.presenting = nil
            presentedChild = nil
            completion?(nil)
        }
    }
    
    open func dismiss(completion: ((Error?)->Void)?) {
        presenting?.dismissPresented(animated: true, completion: completion)
    }
}

/// Concretion erasure wrapper for coordinators.
public class AnyCoordinator: Coordinator {
    
    public var viewController: UIViewController { return wrappedVC() }
    
    public var parent: CoordinatorParent? {
        get { wrappedParentGetter() }
        set { wrappedParentSetter(newValue) }
    }
    
    public var presenting: CoordinatorParent? {
        get { wrappedPresentingGetter() }
        set { wrappedPresentingSetter(newValue) }
    }
    
    public var allowDismissal: Bool {
        get { wrappedAllowDismissalGetter() }
        set { wrappedAllowDismissalSetter(newValue) }
    }
    
    private let wrappedVC: () -> UIViewController
    private let wrappedParentGetter: () -> CoordinatorParent?
    private let wrappedParentSetter: (CoordinatorParent?) -> Void
    private let wrappedPresentingGetter: () -> CoordinatorParent?
    private let wrappedPresentingSetter: (CoordinatorParent?) -> Void
    private let wrappedAllowDismissalGetter: () -> Bool
    private let wrappedAllowDismissalSetter: (Bool) -> Void
    private let wrappedStart: () throws -> Void
    private let wrappedPush: (AnyCoordinator, Bool) throws -> Void
    private let wrappedPop: () -> Void
    private let wrappedPresent: (AnyCoordinator, ((Error?)->Void)?) -> Void
    private let wrappedDismiss: (((Error?)->Void)?) -> Void
    
    /// Creates a wrapper for the coordinator.
    /// - Parameters:
    ///     - coordinator: The coordinator to wrap.
    init<C: Coordinator>(_ coordinator: C) {
        wrappedVC = { coordinator.viewController }
        wrappedParentGetter = { coordinator.parent }
        wrappedParentSetter = { coordinator.parent = $0 }
        wrappedPresentingGetter = { coordinator.presenting }
        wrappedPresentingSetter = { coordinator.presenting = $0 }
        wrappedAllowDismissalGetter = { coordinator.allowDismissal }
        wrappedAllowDismissalSetter = { coordinator.allowDismissal = $0 }
        wrappedStart = { try coordinator.start() }
        wrappedPush = { try coordinator.push(coordinator:$0, animated:$1) }
        wrappedPop = { coordinator.pop() }
        wrappedPresent = { coordinator.present(coordinator:$0, completion: $1) }
        wrappedDismiss = { coordinator.dismiss(completion: $0) }
    }
    
    public func start() throws {
        try wrappedStart()
    }
    
    public func push(coordinator: AnyCoordinator, animated: Bool = true) throws {
        try wrappedPush(coordinator, animated)
    }
    
    public func pop() {
        wrappedPop()
    }
    
    public func present(coordinator: AnyCoordinator, completion: ((Error?)->Void)?) {
        wrappedPresent(coordinator, completion)
    }
    
    public func dismiss(completion: ((Error?)->Void)? = nil) {
        wrappedDismiss(completion)
    }
}

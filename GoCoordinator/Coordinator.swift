//
//  Coordinator.swift
//  GoCoordinator
//
//  Created by Steve Schelter on 10/17/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import Foundation
import class UIKit.UIViewController
import class UIKit.UINavigationController
import class UIKit.UITabBarController

public enum CoordinatorError: Error {
    case missingNavigation
    case missingImplementation(String)
    case dismissalRejected
}

public protocol CoordinatorNavigator: class {
    var parent: CoordinatorParent? { get set }
    var presenting: CoordinatorParent? { get set }
    var allowDismissal: Bool { get set }
    
    func push(coordinator: AnyCoordinator, animated: Bool) throws
    func pop()
    func present(coordinator: AnyCoordinator, completion: ((Error?)->Void)?)
    func dismiss(completion: ((Error?)->Void)?)
}

public extension CoordinatorNavigator {
        
    func present(coordinator: AnyCoordinator) {
        present(coordinator: coordinator, completion: nil)
    }
    
    func pushOrPresent(coordinator: AnyCoordinator, animated: Bool = true,
                       completion: ((Error?)->Void)? = nil) {
        do {
            try push(coordinator: coordinator, animated: animated)
            completion?(nil)
        } catch {
            present(coordinator: coordinator, completion: completion)
        }
    }
    
    func popOrDismiss(completion: ((Error?)->Void)? = nil) {
        if parent != nil {
            pop()
            completion?(nil)
        } else {
            dismiss(completion: completion)
        }
    }
}

public protocol CoordinatorAbstractor: class {
    func asAnyCoordinator() -> AnyCoordinator
}

public protocol Coordinator: CoordinatorNavigator, CoordinatorAbstractor {
    associatedtype VC: UIViewController
    var viewController: VC { get }
    func start() throws
}

public extension Coordinator {
    func asAnyCoordinator() -> AnyCoordinator {
        return AnyCoordinator(self)
    }
}

public protocol CoordinatorParent: class {
    func popChild(animated: Bool)
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
    
    public func push(coordinator: AnyCoordinator, animated: Bool = true) throws {
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
    
    public func pop() {
        parent?.popChild(animated: true)
    }
    
    public func present(coordinator: AnyCoordinator, completion: ((Error?)->Void)?) {
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
            presentedChild?.parent = nil
            presentedChild = nil
        } else {
            presentedChild?.parent = nil
            presentedChild = nil
            completion?(nil)
        }
    }
    
    public func dismiss(completion: ((Error?)->Void)? = nil) {
        presenting?.dismissPresented(animated: true, completion: completion)
    }
}

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

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
    case navigationError
    case missingImplementation(String)
}

public protocol CoordinatorNavigator: class {
    var parent: CoordinatorParent? { get set }
    var presenting: CoordinatorParent? { get set }
    var allowDismissal: Bool { get set }
    
    func push(coordinator: AnyCoordinator) throws
    func popFromParent()
    func present(coordinator: AnyCoordinator, completion: ((Bool)->Void)?)
    func dismiss(completion: ((Bool)->Void)?)
}

public extension CoordinatorNavigator {
    
    func present(coordinator: AnyCoordinator) {
        present(coordinator: coordinator, completion: nil)
    }
    
    func pushOrPresent(coordinator: AnyCoordinator) {
        do {
            try push(coordinator: coordinator)
        } catch {
            present(coordinator: coordinator)
        }
    }
    
    func dismiss() {
        dismiss(completion: nil)
    }
    
    func popOrDismiss() {
        if parent != nil {
            popFromParent()
        } else {
            dismiss()
        }
    }
}

public protocol CoordinatorAbstractor: class {
    func asAnyCoordinator() -> AnyCoordinator
}

public protocol Coordinator: CoordinatorNavigator, CoordinatorAbstractor {
    associatedtype VC: UIViewController
    var viewController: VC { get }
    func start()
}

public extension Coordinator {
    func asAnyCoordinator() -> AnyCoordinator {
        return AnyCoordinator(self)
    }
}

public protocol CoordinatorParent: class {
    func popChild(animated: Bool)
    func dismissPresented(animated: Bool, completion: ((Bool)->Void)?)
}

open class CoordinatorBase<VC: UIViewController>: Coordinator, CoordinatorParent {
    
    private var _viewController: VC?
    public var viewController: VC {
        if _viewController == nil {
            do {
                _viewController = try instantiateViewController()
            } catch NibCoordinatorError.missingNib(let name) {
                print("COORDINATOR ERROR: Missing Nib named \(name)")
            } catch StoryboardCoordinatorError.missingInitialViewController(let type) {
                print("COORDINATOR ERROR: Missing Initial View Controller of type \(type)")
            } catch StoryboardCoordinatorError.missingViewController(let type, let identifier) {
                print("COORDINATOR ERROR: Missing View Controller of type \(type) with identifier \(identifier)")
            } catch let err {
                print("COORDINATOR ERROR: \(err.localizedDescription)")
            }

            // NOTE: throwing from getter is not supported. Instead, just return a placeholder
            if _viewController == nil {
                _viewController = VC()
            }
        }
        return _viewController!
    }
    
    weak public var parent: CoordinatorParent?
    weak public var presenting: CoordinatorParent?
    public var allowDismissal: Bool = true
    
    private var pushedChild: AnyCoordinator?
    private var presentedChild: AnyCoordinator?
        
    func instantiateViewController() throws -> VC {
        throw CoordinatorError.missingImplementation(#function)
    }
    
    open func start() {
        CoordinatorLinker.linker.linkCoordinator(self, for: viewController)
    }
    
    deinit {
        CoordinatorLinker.linker.unlinkCooordinatorFor(viewController)
    }
    
    public func push(coordinator: AnyCoordinator) throws {
        if pushedChild != nil {
            popChild(animated: false)
        }
        if let nc = viewController as? UINavigationController ?? viewController.navigationController {
            nc.pushViewController(coordinator.viewController, animated: true)
        } else {
            throw CoordinatorError.navigationError
        }
        
        coordinator.parent = self
        coordinator.presenting = self.presenting
        pushedChild = coordinator
        coordinator.start()
    }
    
    public func popChild(animated: Bool) {
        if let nc = viewController as? UINavigationController {
            nc.popToRootViewController(animated: animated)
        } else if let nc = viewController.navigationController {
            nc.popToViewController(viewController, animated: animated)
        }
        pushedChild?.parent = nil
        pushedChild = nil
    }
    
    public func popFromParent() {
        parent?.popChild(animated: true)
    }
    
    public func present(coordinator: AnyCoordinator, completion: ((Bool)->Void)?) {
        dismissPresented(animated: true) { [weak self] success in
            if success {
                self?.viewController.present(coordinator.viewController, animated: true) {
                    completion?(true)
                }
                coordinator.presenting = self
                self?.presentedChild = coordinator
                coordinator.start()
            } else {
                completion?(false)
            }
        }
    }
    
    public func dismissPresented(animated: Bool, completion: ((Bool)->Void)?) {
        if presentedChild?.allowDismissal == false {
            completion?(false)
            return
        }
        
        if let presented = viewController.presentedViewController {
            presented.dismiss(animated: animated) {
                completion?(true)
            }
            presentedChild?.parent = nil
            presentedChild = nil
        } else {
            presentedChild?.parent = nil
            presentedChild = nil
            completion?(true)
        }
    }
    
    public func dismiss(completion: ((Bool)->Void)?) {
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
    private let wrappedStart: () -> Void
    private let wrappedPush: (AnyCoordinator) throws -> Void
    private let wrappedPopFromParent: () -> Void
    private let wrappedPresent: (AnyCoordinator, ((Bool)->Void)?) -> Void
    private let wrappedDismiss: (((Bool)->Void)?) -> Void
    
    init<C: Coordinator>(_ coordinator: C) {
        wrappedVC = { coordinator.viewController }
        wrappedParentGetter = { coordinator.parent }
        wrappedParentSetter = { coordinator.parent = $0 }
        wrappedPresentingGetter = { coordinator.presenting }
        wrappedPresentingSetter = { coordinator.presenting = $0 }
        wrappedAllowDismissalGetter = { coordinator.allowDismissal }
        wrappedAllowDismissalSetter = { coordinator.allowDismissal = $0 }
        wrappedStart = { coordinator.start() }
        wrappedPush = { try coordinator.push(coordinator:$0) }
        wrappedPopFromParent = { coordinator.popFromParent() }
        wrappedPresent = { coordinator.present(coordinator:$0, completion: $1) }
        wrappedDismiss = { coordinator.dismiss(completion: $0) }
    }
    
    public func start() {
        wrappedStart()
    }
    
    public func push(coordinator: AnyCoordinator) throws {
        try wrappedPush(coordinator)
    }
    
    public func popFromParent() {
        wrappedPopFromParent()
    }
    
    public func present(coordinator: AnyCoordinator, completion: ((Bool)->Void)?) {
        wrappedPresent(coordinator, completion)
    }
    
    public func dismiss(completion: ((Bool)->Void)?) {
        wrappedDismiss(completion)
    }
}

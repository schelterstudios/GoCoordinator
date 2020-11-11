//
//  NavigationCoordinator.swift
//  GoCoordinator
//
//  Created by Steve Schelter on 10/18/20.
//

import Foundation
import UIKit.UINavigationController

open class UINavigationCoordinator: CoordinatorBase<UINavigationController> {
    
    public let root: AnyCoordinator
    
    public init(root: AnyCoordinator) {
        self.root = root
    }
    
    open override func start() throws {
        try super.start()
        try push(coordinator: root, animated: false)
    }
    
    override func instantiateViewController() throws -> UINavigationController {
        return UINavigationController()
    }
}

extension Coordinator {
    public func presentUINavigation(root: AnyCoordinator) {
        let coordinator = UINavigationCoordinator(root: root)
        present(coordinator: coordinator.asAnyCoordinator())
    }
}
//
//  NavigationCoordinator.swift
//  GoCoordinator
//
//  Created by Steve Schelter on 10/18/20.
//

import Foundation
import UIKit.UINavigationController

open class NavigationCoordinator: CoordinatorBase<UINavigationController> {
    
    public let root: AnyCoordinator
    
    public init(root: AnyCoordinator) {
        self.root = root
    }
    
    open override func start() {
        super.start()
        try! push(coordinator: root)
    }
    
    override func instantiateViewController() -> UINavigationController {
        return UINavigationController()
    }
}

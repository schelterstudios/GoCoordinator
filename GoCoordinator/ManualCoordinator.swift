//
//  ManualCoordinator.swift
//  GoCoordinator
//
//  Created by Steve Schelter on 10/17/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import Foundation
import UIKit.UIViewController

open class ManualCoordinator: CoordinatorBase<UIViewController> {
    
    private let block: () -> UIViewController
    
    public init(block: @escaping ()->UIViewController ) {
        self.block = block
    }
    
    public init(viewController: UIViewController) {
        self.block = { viewController }
    }
    
    override func instantiateViewController() -> UIViewController {
        return block()
    }
}
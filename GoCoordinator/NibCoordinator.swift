//
//  NibCoordinator.swift
//  GoCoordinator
//
//  Created by Steve Schelter on 10/17/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import Foundation
import class UIKit.UIViewController
import class UIKit.UINib

enum NibCoordinatorError: Error {
    case missingNib(String)
}

open class NibCoordinator<VC: UIViewController>: CoordinatorBase<VC> {
    
    public override init() {}
    
    open override func start() throws {
        try super.start()
        viewController.viewDidLoad()
    }
    
    override func instantiateViewController() throws -> VC {
        let bundle = Bundle(for: VC.self)
        let nibName = NSStringFromClass(VC.self).components(separatedBy: ".").last!
        guard bundle.path(forResource: nibName, ofType: "nib") != nil else {
            throw NibCoordinatorError.missingNib(nibName)
        }
        let vc = VC()
        bundle.loadNibNamed(nibName, owner: vc, options: nil)
        return vc
    }
}

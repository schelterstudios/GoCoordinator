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
    
    open override func start() {
        super.start()
        viewController.viewDidLoad()
    }
    
    override func instantiateViewController() throws -> VC {
        let nibName = NSStringFromClass(VC.self).components(separatedBy: ".").last!
        guard Bundle.main.path(forResource: nibName, ofType: "nib") != nil else {
            throw NibCoordinatorError.missingNib(nibName)
        }
        let vc = VC()
        Bundle.main.loadNibNamed(nibName, owner: vc, options: nil)
        return vc
    }
}

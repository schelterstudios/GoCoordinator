//
//  NibCoordinator.swift
//  GoCoordinator
//
//  Created by Steve Schelter on 10/17/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import Foundation
import class UIKit.UIViewController

public class NibCoordinator<VC: UIViewController>: CoordinatorBase<VC> {
    
    override func instantiateViewController() -> VC {
        let vc = VC()
        let nibName = NSStringFromClass(VC.self).components(separatedBy: ".").last!
        Bundle.main.loadNibNamed(nibName, owner: vc, options: nil)
        vc.viewDidLoad()
        return vc
    }
}

//
//  StoryboardCoordinator.swift
//  GoCoordinator
//
//  Created by Steve Schelter on 10/17/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import Foundation
import class UIKit.UIViewController
import class UIKit.UIStoryboard

public protocol StoryboardOwner {
    var storyboardName: String { get }
}

enum StoryboardCoordinatorError: Error {
    case missingInitialViewController(String)
    case missingViewController(String, String)
}

open class StoryboardCoordinator<VC: UIViewController>: CoordinatorBase<VC>, StoryboardOwner {
    
    public var storyboardName: String {
        if ownerName != nil { return ownerName! }
        
        var name = NSStringFromClass(Self.self).components(separatedBy: ".").last!
        if let index = name.range(of: "Coordinator", options: [])?.lowerBound {
            name = String(name[..<index])
        }
        return name
    }
    
    private let ownerName: String?
    private let identifier: String?
    
    public init(owner: StoryboardOwner, identifier: String) {
        self.ownerName = owner.storyboardName
        self.identifier = identifier
    }
    
    public override init() {
        self.ownerName = nil
        self.identifier = nil
    }
    
    override func instantiateViewController() throws -> VC {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        if let identifier = self.identifier {
            let vc = storyboard.instantiateViewController(withIdentifier: identifier) as? VC
            if vc == nil {
                throw StoryboardCoordinatorError.missingViewController(NSStringFromClass(VC.self), identifier)
            }
            return vc!
        } else {
            let vc = storyboard.instantiateInitialViewController() as? VC
            if vc == nil {
                throw StoryboardCoordinatorError.missingInitialViewController(NSStringFromClass(VC.self))
            }
            return vc!
        }
    }
}

//
//  StoryboardCoordinator.swift
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
import UIKit.UIViewController
import UIKit.UIStoryboard

/// Designates an object as a storyboard owner for use by storyboard coordinators. All
/// storyboard coordinators are already storyboard owners, and should be used in most
/// cases when initializing new storyboard coordinators from the same storyboard.
public protocol StoryboardOwner {
    
    /// The name of the storyboard used for instantiation. This value is derived based on the
    /// initialization used for the coordinator.
    var storyboardName: String { get }
}

enum StoryboardCoordinatorError: Error {
    case missingStoryboard(String)
    case missingInitialViewController
    case missingViewControllerIdentifier(String)
    case wrongViewControllerType(String)
}

/// Coordinator for storyboard view controllers
open class StoryboardCoordinator<VC: UIViewController>: CoordinatorBase<VC>, StoryboardOwner {
    
    private var _storyboardName: String?
    public var storyboardName: String {
        if let name = _storyboardName { return name }
        var name = NSStringFromClass(Self.self).components(separatedBy: ".").last!
        if let index = name.range(of: "Coordinator", options: [])?.lowerBound {
            name = String(name[..<index])
        }
        return name
    }
    
    private let identifier: String?
    
    /// Creates a storyboard coordinator using the same storyboard as the storyboard owner.
    /// - Parameters:
    ///     - owner: A storyboard owner. Usually this would be another coordinator from the
    ///     same storyboard.
    ///     - identifier: The Storyboard ID used for the view controller.
    public init(owner: StoryboardOwner, identifier: String) {
        self._storyboardName = owner.storyboardName
        self.identifier = identifier
    }
    
    /// Creates a storyboard coordinator using a storyboard with the given name.
    /// - Parameters:
    ///     - storyboardName: The name of the storyboard.
    ///     - identifier: The Storyboard ID used for the view controller or `nil` if view
    ///     controller is the initial view controller of the storyboard. Default is `nil`.
    public init(storyboardName: String, identifier: String? = nil) {
        self._storyboardName = storyboardName
        self.identifier = identifier
    }
    
    /// Creates a storyboard coordinator using a storyboard with the same name as the prefix
    /// of the class name (ie. `MainCoordinator` would use storyboard named `Main`). The view
    /// controller must be the initial view controller of the storyboard.
    public override init() {
        self._storyboardName = nil
        self.identifier = nil
    }

    override func instantiateViewController() throws -> VC {
        let bundle = Bundle(for: Self.self)
        guard bundle.path(forResource: storyboardName, ofType: "storyboardc") != nil else {
            throw StoryboardCoordinatorError.missingStoryboard(storyboardName)
        }
        
        var vc: VC!
        let storyboard = UIStoryboard(name: storyboardName, bundle: bundle)
        if let identifier = self.identifier {
            
            if let idMap = storyboard.value(forKey: "identifierToNibNameMap") as? [String: Any],
               let _ = idMap[identifier] {
                vc = storyboard.instantiateViewController(withIdentifier: identifier) as? VC
                if vc == nil {
                    throw StoryboardCoordinatorError.wrongViewControllerType(identifier)
                }
            } else {
                throw StoryboardCoordinatorError.missingViewControllerIdentifier(identifier)
            }
            
        } else {
            vc = storyboard.instantiateInitialViewController() as? VC
            if vc == nil {
                throw StoryboardCoordinatorError.missingInitialViewController
            }
        }
        
        return vc
    }
}

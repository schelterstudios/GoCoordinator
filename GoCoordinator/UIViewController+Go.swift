//
//  UIViewController+Go.swift
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
import class UIKit.UIViewController

fileprivate class CoordinatorWrapper {
    
    private weak var base: CoordinatorNavigator?
    
    init(_ base: CoordinatorNavigator) {
        self.base = base
    }
    
    func unwrap<C:CoordinatorNavigator>() -> C? {
        return base as? C
    }
    
    func unwrapAny() -> AnyCoordinator? {
        return (base as? CoordinatorAbstractor)?.asAnyCoordinator()
    }
}

final class CoordinatorLinker {
    
    static var linker = CoordinatorLinker()
    
    private var linkerTable = NSMapTable<UIViewController, CoordinatorWrapper>()
    
    func coordinatorForController<C:CoordinatorNavigator>(_ controller: UIViewController) -> C? {
        if let wrapper = linkerTable.object(forKey: controller),
           let unwrapped:C = wrapper.unwrap() { return unwrapped }
        
        if let nc = controller.navigationController {
            if let wrapper = linkerTable.object(forKey: nc),
               let unwrapped:C = wrapper.unwrap() { return unwrapped }
        }
        
        if let tbc = controller.tabBarController {
            if let wrapper = linkerTable.object(forKey: tbc),
               let unwrapped:C = wrapper.unwrap() { return unwrapped }
        }
        
        return nil            
    }
    
    func anyCoordinatorForController(_ controller: UIViewController) -> AnyCoordinator? {
        if let wrapper = linkerTable.object(forKey: controller),
           let unwrapped = wrapper.unwrapAny() { return unwrapped }
        
        if let nc = controller.navigationController {
            if let wrapper = linkerTable.object(forKey: nc),
               let unwrapped = wrapper.unwrapAny() { return unwrapped }
        }
        
        if let tbc = controller.tabBarController {
            if let wrapper = linkerTable.object(forKey: tbc),
               let unwrapped = wrapper.unwrapAny() { return unwrapped }
        }
        
        return nil
    }
    
    func linkCoordinator(_ coordinator: CoordinatorNavigator, for controller: UIViewController) {
        let wrapper = CoordinatorWrapper(coordinator)
        linkerTable.setObject(wrapper, forKey: controller)
    }
    
    func unlinkCooordinatorFor(_ controller: UIViewController) {
        linkerTable.removeObject(forKey: controller)
    }
}

extension UIViewController {
    
    public var go: AnyCoordinator! {
        get { return CoordinatorLinker.linker.anyCoordinatorForController(self)! }
    }
    
    public func go<C:CoordinatorNavigator>(as type: C.Type) -> C {
        return CoordinatorLinker.linker.coordinatorForController(self)!
    }
}

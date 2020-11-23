//
//  ManualCoordinator.swift
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

open class ManualCoordinator: CoordinatorBase<UIViewController> {
    
    private let block: () -> UIViewController
    
    public init(block: @escaping ()->UIViewController ) {
        self.block = block
    }
    
    public init(viewController: UIViewController) {
        self.block = { viewController }
    }
    
    open override func start() throws {
        try super.start()
        viewController.viewDidLoad()
    }
    
    // NOTE: Overriding CoordinatorBase to fix autocompletion bug    
    final public override func push(coordinator: AnyCoordinator, animated: Bool) throws {
        try super.push(coordinator: coordinator, animated: animated)
    }
        
    final public override func pop() {
        super.pop()
    }
    
    final public override func present(coordinator: AnyCoordinator, completion: ((Error?)->Void)?) {
        super.present(coordinator: coordinator, completion: completion)
    }
    
    final public override func dismiss(completion: ((Error?)->Void)?) {
        super.dismiss(completion: completion)
    }
    // /////////
    
    override func instantiateViewController() throws -> UIViewController {
        return block()
    }
}
